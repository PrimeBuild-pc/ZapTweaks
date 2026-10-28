import 'dart:convert';

import '../../../core/services/process_runner.dart';
import 'folder_size_cache.dart' show isAppOwnedFolder, normalizeFolder;

enum LeftoverConfidence { good, medium, low }

enum LeftoverKind {
  folder,
  shortcut,
  registryKey,
  runValue,
  task,
  firewallRule,
}

/// One thing an uninstaller left behind. [path] identifies it: a folder or
/// file path, a registry key, `RunKey|ValueName`, a task path or a firewall
/// rule name. [machine] items need the elevated helper.
class Leftover {
  const Leftover({
    required this.kind,
    required this.path,
    required this.confidence,
    required this.machine,
    this.detail,
  });

  final LeftoverKind kind;
  final String path;
  final LeftoverConfidence confidence;
  final bool machine;

  /// What the user sees next to the path: shortcut target, Run command…
  final String? detail;

  /// Only Good leftovers start selected (BCU's rule).
  bool get preselected => confidence == LeftoverConfidence.good;

  Map<String, Object?> toJson() => <String, Object?>{
    'kind': kind.name,
    'path': path,
  };
}

/// What we knew about the program before it was uninstalled.
class LeftoverQuery {
  const LeftoverQuery({
    required this.name,
    required this.uninstallKey,
    this.publisher,
    this.installLocation,
  });

  final String name;
  final String? publisher;
  final String? installLocation;

  /// `HKLM\64\Key` as in AppPackage.packageId.
  final String uninstallKey;

  static String norm(String? value) =>
      (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// "Contoso Paint 3.2 (x64)" → "Contoso Paint".
  String get cleanName => name
      .replaceAll(RegExp(r'\([^)]*\)'), ' ')
      .replaceAll(RegExp(r'\b[vV]?\d+(\.\d+)+\b'), ' ')
      .replaceAll(
        RegExp(
          r'\b(x64|x86|64-bit|32-bit|amd64|arm64)\b',
          caseSensitive: false,
        ),
        ' ',
      )
      .trim();

  /// Publisher without "Ltd.", "Inc." and similar.
  String get publisherToken {
    final value = norm(
      (publisher ?? '').replaceAll(
        RegExp(
          r'\b(inc|ltd|llc|gmbh|corp|corporation|co|company|limited|s\.?r\.?l|s\.?p\.?a|sia|ag|bv|oy|ab|pty|technologies)\b\.?',
          caseSensitive: false,
        ),
        ' ',
      ),
    );
    return value.length < 3 || _generic.contains(value) ? '' : value;
  }

  String get fullToken {
    final value = norm(cleanName);
    return value.length < 3 || _generic.contains(value) ? '' : value;
  }

  /// The product part when the name starts with the publisher.
  String get productToken {
    final full = fullToken, vendor = publisherToken;
    final product = vendor.isNotEmpty && full.startsWith(vendor)
        ? full.substring(vendor.length)
        : '';
    return product.length < 3 || _generic.contains(product) ? '' : product;
  }

  Set<String> get tokens =>
      <String>{fullToken, productToken, publisherToken}..remove('');

  Map<String, Object?> toJson() => <String, Object?>{
    'tokens': tokens.toList(),
    'location': installLocation == null
        ? null
        : normalizeFolder(installLocation!),
    'uninstallKey': uninstallKeyPath,
  };

  String get uninstallKeyPath {
    final [hive, view, key] = uninstallKey.split(r'\');
    final software = view == '32' ? r'SOFTWARE\WOW6432Node' : 'SOFTWARE';
    return '$hive\\$software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\$key';
  }
}

/// Words too common to identify one program.
const _generic = <String>{
  'microsoft',
  'windows',
  'common',
  'google',
  'intel',
  'nvidia',
  'amd',
  'apple',
  'temp',
  'cache',
  'programs',
  'packages',
  'tools',
  'tool',
  'app',
  'apps',
  'data',
  'software',
  'update',
  'updater',
  'setup',
  'local',
  'roaming',
  'low',
  'documents',
  'settings',
  'user',
  'users',
  'system',
  'classes',
  'policies',
  'wow6432node',
  'clients',
  'crashpad',
  'logs',
};

typedef LeftoverFolder = ({String root, String path, int depth});
typedef LeftoverShortcut = ({String path, String target});
typedef LeftoverRun = ({String key, String name, String command});
typedef LeftoverTask = ({String path, String execute});
typedef LeftoverFirewall = ({String name, String displayName, String program});

/// Raw read-only observations from [leftoverFactsScript].
class LeftoverFacts {
  const LeftoverFacts({
    this.existingFolders = const <String>{},
    this.folders = const <LeftoverFolder>[],
    this.registryKeys = const <String>[],
    this.uninstallKeyPresent = false,
    this.shortcuts = const <LeftoverShortcut>[],
    this.runEntries = const <LeftoverRun>[],
    this.tasks = const <LeftoverTask>[],
    this.firewallRules = const <LeftoverFirewall>[],
  });

  final Set<String> existingFolders;
  final List<LeftoverFolder> folders;
  final List<String> registryKeys;
  final bool uninstallKeyPresent;
  final List<LeftoverShortcut> shortcuts;
  final List<LeftoverRun> runEntries;
  final List<LeftoverTask> tasks;
  final List<LeftoverFirewall> firewallRules;

  factory LeftoverFacts.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> rows(String key) => <Map<String, dynamic>>[
      for (final row in json[key] as List? ?? const <dynamic>[])
        if (row is Map) Map<String, dynamic>.from(row),
    ];
    String text(Map<String, dynamic> row, String key) =>
        row[key] is String ? row[key] as String : '';
    return LeftoverFacts(
      existingFolders: <String>{
        for (final path in json['existingFolders'] as List? ?? const [])
          if (path is String) path,
      },
      folders: <LeftoverFolder>[
        for (final row in rows('folders'))
          (
            root: text(row, 'root'),
            path: text(row, 'path'),
            depth: row['depth'] is int ? row['depth'] as int : 0,
          ),
      ],
      registryKeys: <String>[
        for (final key in json['registryKeys'] as List? ?? const [])
          if (key is String) key,
      ],
      uninstallKeyPresent: json['uninstallKeyPresent'] == true,
      shortcuts: <LeftoverShortcut>[
        for (final row in rows('shortcuts'))
          (path: text(row, 'path'), target: text(row, 'target')),
      ],
      runEntries: <LeftoverRun>[
        for (final row in rows('runEntries'))
          (
            key: text(row, 'key'),
            name: text(row, 'name'),
            command: text(row, 'command'),
          ),
      ],
      tasks: <LeftoverTask>[
        for (final row in rows('tasks'))
          (path: text(row, 'path'), execute: text(row, 'execute')),
      ],
      firewallRules: <LeftoverFirewall>[
        for (final row in rows('firewallRules'))
          (
            name: text(row, 'name'),
            displayName: text(row, 'displayName'),
            program: text(row, 'program'),
          ),
      ],
    );
  }
}

/// Confidence rules (BCU-style):
/// Good: the install folder; a folder or Software key named exactly after the
/// program (or Publisher\Program); anything whose target, command or program
/// path is inside the install folder.
/// Medium: a publisher folder/key holding nothing else we can see; the
/// surviving Uninstall key; a broken shortcut or a Run value named like it.
/// Low: a publisher folder/key that also holds other programs.
List<Leftover> classifyLeftovers(LeftoverQuery query, LeftoverFacts facts) {
  final full = query.fullToken, product = query.productToken;
  final vendor = query.publisherToken;
  if (full.isEmpty) return const <Leftover>[];
  // A shared InstallLocation (C:\, Program Files, Common Files…) would claim
  // every other program's files, shortcuts and tasks: ignore it.
  final location =
      query.installLocation == null || !isAppOwnedFolder(query.installLocation!)
      ? null
      : normalizeFolder(query.installLocation!);
  bool inside(String path) {
    if (location == null || location.isEmpty) return false;
    final clean = path.replaceAll('"', '').trim().toLowerCase();
    final folder = location.toLowerCase();
    return clean == folder || clean.startsWith('$folder\\');
  }

  bool isMachinePath(String path) {
    final lower = path.toLowerCase();
    return !lower.contains(r'\users\') || lower.contains(r'\users\public\');
  }

  String leaf(String path) => LeftoverQuery.norm(path.split(r'\').last);
  String spaced(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s'), '');
  final result = <Leftover>[];
  void add(
    LeftoverKind kind,
    String path,
    LeftoverConfidence confidence,
    bool machine, [
    String? detail,
  ]) {
    if (result.any((item) => item.path.toLowerCase() == path.toLowerCase())) {
      return;
    }
    result.add(
      Leftover(
        kind: kind,
        path: path,
        confidence: confidence,
        machine: machine,
        detail: detail,
      ),
    );
  }

  if (location != null &&
      facts.existingFolders.any(
        (p) => normalizeFolder(p).toLowerCase() == location.toLowerCase(),
      )) {
    add(
      LeftoverKind.folder,
      location,
      LeftoverConfidence.good,
      isMachinePath(location),
    );
  }

  // Folders and Software keys share one rule set: depth 1 below a root,
  // depth 2 below a publisher folder or key.
  void tree(
    LeftoverKind kind,
    List<({String parent, String path, int depth})> nodes,
    bool Function(String path) machine,
  ) {
    for (final node in nodes) {
      final name = leaf(node.path);
      if (node.depth == 1 && name == full) {
        // Good only when spaces and case are the sole difference:
        // "Acme-Paint" may belong to another program than "Acme Paint".
        add(
          kind,
          node.path,
          spaced(node.path.split(r'\').last) == spaced(query.cleanName)
              ? LeftoverConfidence.good
              : LeftoverConfidence.medium,
          machine(node.path),
        );
      } else if (node.depth == 1 && product.isNotEmpty && name == product) {
        add(kind, node.path, LeftoverConfidence.medium, machine(node.path));
      } else if (node.depth == 2 &&
          vendor.isNotEmpty &&
          leaf(node.parent) == vendor &&
          (name == product || name == full)) {
        add(kind, node.path, LeftoverConfidence.good, machine(node.path));
      }
    }
    for (final node in nodes.where(
      (n) => n.depth == 1 && leaf(n.path) == vendor,
    )) {
      final others = nodes.where(
        (n) =>
            n.depth == 2 &&
            n.parent.toLowerCase() == node.path.toLowerCase() &&
            leaf(n.path) != product &&
            leaf(n.path) != full,
      );
      add(
        kind,
        node.path,
        others.isEmpty ? LeftoverConfidence.medium : LeftoverConfidence.low,
        machine(node.path),
      );
    }
  }

  String parentOf(String path) => path.substring(0, path.lastIndexOf(r'\'));
  tree(LeftoverKind.folder, <({String parent, String path, int depth})>[
    for (final folder in facts.folders)
      (parent: parentOf(folder.path), path: folder.path, depth: folder.depth),
  ], isMachinePath);
  tree(LeftoverKind.registryKey, <({String parent, String path, int depth})>[
    for (final key in facts.registryKeys)
      (
        parent: parentOf(key),
        path: key,
        depth: key
            .split(r'\')
            .skipWhile((part) => part.toLowerCase() != 'software')
            .skip(1)
            .where((part) => part.toLowerCase() != 'wow6432node')
            .length,
      ),
  ], (key) => key.toUpperCase().startsWith('HKLM'));

  if (facts.uninstallKeyPresent) {
    add(
      LeftoverKind.registryKey,
      query.uninstallKeyPath,
      LeftoverConfidence.medium,
      query.uninstallKey.startsWith('HKLM'),
    );
  }
  for (final shortcut in facts.shortcuts) {
    final name = LeftoverQuery.norm(
      shortcut.path
          .split(r'\')
          .last
          .replaceFirst(RegExp(r'\.lnk$', caseSensitive: false), ''),
    );
    if (inside(shortcut.target)) {
      add(
        LeftoverKind.shortcut,
        shortcut.path,
        LeftoverConfidence.good,
        isMachinePath(shortcut.path),
        shortcut.target,
      );
    } else if (shortcut.target.isEmpty && name.contains(full)) {
      add(
        LeftoverKind.shortcut,
        shortcut.path,
        LeftoverConfidence.medium,
        isMachinePath(shortcut.path),
      );
    }
  }
  for (final run in facts.runEntries) {
    final name = LeftoverQuery.norm(run.name);
    final confidence = inside(run.command.split(RegExp(r'"\s|\.exe\s')).first)
        ? LeftoverConfidence.good
        : name == full || (product.isNotEmpty && name == product)
        ? LeftoverConfidence.medium
        : null;
    if (confidence != null) {
      add(
        LeftoverKind.runValue,
        '${run.key}|${run.name}',
        confidence,
        run.key.toUpperCase().startsWith('HKLM'),
        run.command,
      );
    }
  }
  for (final task in facts.tasks) {
    if (inside(task.execute)) {
      add(
        LeftoverKind.task,
        task.path,
        LeftoverConfidence.good,
        true,
        task.execute,
      );
    }
  }
  for (final rule in facts.firewallRules) {
    if (inside(rule.program)) {
      add(
        LeftoverKind.firewallRule,
        rule.name,
        LeftoverConfidence.good,
        true,
        rule.displayName,
      );
    } else if (LeftoverQuery.norm(rule.displayName) == full) {
      add(
        LeftoverKind.firewallRule,
        rule.name,
        LeftoverConfidence.medium,
        true,
        rule.displayName,
      );
    }
  }
  return result;
}

/// Read-only. The query reaches PowerShell only as base64 JSON, so program
/// names from the registry can never become script text.
String leftoverFactsScript(LeftoverQuery query) {
  final payload = base64Encode(utf8.encode(jsonEncode(query.toJson())));
  return '''
\$ErrorActionPreference = 'SilentlyContinue'
\$q = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$payload')) | ConvertFrom-Json
\$tokens = @(\$q.tokens)
function N([string]\$s) { (\$s.ToLowerInvariant() -replace '[^a-z0-9]', '') }
\$loc = [string]\$q.location
\$out = [ordered]@{ existingFolders = @(); folders = @(); registryKeys = @(); uninstallKeyPresent = \$false; shortcuts = @(); runEntries = @(); tasks = @(); firewallRules = @() }
if (\$loc -and (Test-Path -LiteralPath \$loc -PathType Container)) { \$out.existingFolders = @(\$loc) }
foreach (\$root in @(\$env:APPDATA, \$env:LOCALAPPDATA, \$env:ProgramData, \$env:ProgramFiles, \${env:ProgramFiles(x86)})) {
  if (-not \$root) { continue }
  foreach (\$d in Get-ChildItem -LiteralPath \$root -Directory -Force) {
    if (\$tokens -notcontains (N \$d.Name)) { continue }
    \$out.folders += [ordered]@{ root = \$root; path = \$d.FullName; depth = 1 }
    foreach (\$c in Get-ChildItem -LiteralPath \$d.FullName -Directory -Force) { \$out.folders += [ordered]@{ root = \$root; path = \$c.FullName; depth = 2 } }
  }
}
foreach (\$base in @('HKCU:\\Software', 'HKLM:\\Software', 'HKLM:\\Software\\WOW6432Node')) {
  foreach (\$k in Get-ChildItem -LiteralPath \$base) {
    if (\$tokens -notcontains (N \$k.PSChildName)) { continue }
    \$out.registryKeys += (\$k.Name -replace '^HKEY_CURRENT_USER', 'HKCU' -replace '^HKEY_LOCAL_MACHINE', 'HKLM')
    foreach (\$c in Get-ChildItem -LiteralPath \$k.PSPath) { \$out.registryKeys += (\$c.Name -replace '^HKEY_CURRENT_USER', 'HKCU' -replace '^HKEY_LOCAL_MACHINE', 'HKLM') }
  }
}
\$out.uninstallKeyPresent = [bool](Test-Path -LiteralPath ('Registry::' + \$q.uninstallKey))
\$shell = New-Object -ComObject WScript.Shell
\$linkRoots = @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('CommonPrograms'), [Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('CommonDesktopDirectory'), [Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))
foreach (\$lr in \$linkRoots) {
  if (-not \$lr) { continue }
  foreach (\$l in Get-ChildItem -LiteralPath \$lr -Filter *.lnk -Recurse -Force) {
    \$t = [string]\$shell.CreateShortcut(\$l.FullName).TargetPath
    \$n = N \$l.BaseName
    if ((\$loc -and \$t.StartsWith(\$loc, [StringComparison]::OrdinalIgnoreCase)) -or @(\$tokens | Where-Object { \$n.Contains(\$_) }).Count -gt 0) {
      \$out.shortcuts += [ordered]@{ path = \$l.FullName; target = \$(if (\$t -and (Test-Path -LiteralPath \$t)) { \$t } elseif (\$t -and \$loc -and \$t.StartsWith(\$loc, [StringComparison]::OrdinalIgnoreCase)) { \$t } else { '' }) }
    }
  }
}
foreach (\$rk in @('HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run', 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce', 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run', 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce', 'HKLM:\\Software\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Run')) {
  \$key = Get-Item -LiteralPath \$rk
  if (-not \$key) { continue }
  foreach (\$name in \$key.GetValueNames()) {
    \$out.runEntries += [ordered]@{ key = (\$rk -replace ':', ''); name = \$name; command = [string]\$key.GetValue(\$name) }
  }
}
foreach (\$task in Get-ScheduledTask) {
  foreach (\$a in @(\$task.Actions)) {
    if (\$a.Execute -and \$loc -and ([Environment]::ExpandEnvironmentVariables(\$a.Execute.Trim('"'))).StartsWith(\$loc, [StringComparison]::OrdinalIgnoreCase)) {
      \$out.tasks += [ordered]@{ path = (\$task.TaskPath + \$task.TaskName); execute = [Environment]::ExpandEnvironmentVariables(\$a.Execute.Trim('"')) }
    }
  }
}
foreach (\$f in Get-NetFirewallApplicationFilter -All) {
  \$p = [Environment]::ExpandEnvironmentVariables([string]\$f.Program)
  if (\$loc -and \$p.StartsWith(\$loc, [StringComparison]::OrdinalIgnoreCase)) {
    \$r = \$f | Get-NetFirewallRule
    \$out.firewallRules += [ordered]@{ name = [string]\$r.Name; displayName = [string]\$r.DisplayName; program = \$p }
  }
}
\$out | ConvertTo-Json -Compress -Depth 4
''';
}

Future<List<Leftover>> scanLeftovers(
  ProcessRunner runner,
  LeftoverQuery query,
) async {
  if (query.tokens.isEmpty) return const <Leftover>[];
  final output = await runner.runPowerShellForOutput(
    leftoverFactsScript(query),
  );
  return classifyLeftovers(
    query,
    LeftoverFacts.fromJson(jsonDecode(output) as Map<String, dynamic>),
  );
}
