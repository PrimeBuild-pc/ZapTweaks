import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

import '../../platform/windows/known_folder.dart';
import 'operation.dart';

/// Folders a leftover may live under, per context (user or machine).
class LeftoverRoots {
  const LeftoverRoots({required this.folders});

  final List<String> folders;

  static LeftoverRoots current({required bool machine}) {
    final ids = machine
        ? <String>[
            FOLDERID_ProgramData,
            FOLDERID_ProgramFiles,
            FOLDERID_ProgramFilesX86,
            FOLDERID_CommonPrograms,
            FOLDERID_CommonStartup,
            FOLDERID_PublicDesktop,
          ]
        : <String>[
            FOLDERID_RoamingAppData,
            FOLDERID_LocalAppData,
            FOLDERID_Desktop,
            FOLDERID_Programs,
            FOLDERID_Startup,
          ];
    return LeftoverRoots(
      folders: <String>[for (final id in ids) ?knownFolderPath(id)],
    );
  }
}

/// First folder below a root that is never a single program's leftover.
const _sharedFolders = <String>{
  'microsoft',
  'windows',
  'common files',
  'windowsapps',
  'packages',
  'windows defender',
  'windows nt',
  'windows mail',
  'windows media player',
  'windows photo viewer',
  'windows sidebar',
  'windowspowershell',
  'internet explorer',
  'modifiablewindowsapps',
  'package cache',
  'temp',
  'programs',
  'startup',
};

const _sharedKeys = <String>{
  'microsoft',
  'classes',
  'policies',
  'clients',
  'registeredapplications',
  'odbc',
  'wow6432node',
};

const _runKeys = <String>{
  r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run',
  r'HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce',
  r'HKLM\Software\Microsoft\Windows\CurrentVersion\Run',
  r'HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce',
  r'HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run',
};

final _control = RegExp(r'[\x00-\x1f"]');

/// Why a leftover may not be removed; the preview shows a translated label.
enum LeftoverRefusal {
  invalid('Malformed or unsafe entry.'),
  outsideAllowed('Outside what this context may clean.'),
  shared('Shared with Windows or other programs.');

  const LeftoverRefusal(this.message);
  final String message;
}

/// Null when [item] may be removed by the user ([machine] false) or the
/// elevated ([machine] true) operation; otherwise the reason it may not.
LeftoverRefusal? validateLeftoverItem(
  Map<String, Object?> item, {
  required bool machine,
  required LeftoverRoots roots,
}) {
  final kind = item['kind'], path = item['path'];
  if (kind is! String || path is! String || path.isEmpty) {
    return LeftoverRefusal.invalid;
  }
  if (_control.hasMatch(path)) return LeftoverRefusal.invalid;
  switch (kind) {
    case 'folder' || 'shortcut':
      if (!RegExp(r'^[A-Za-z]:\\').hasMatch(path) ||
          path.split(r'\').contains('..')) {
        return LeftoverRefusal.invalid;
      }
      if (kind == 'shortcut' && !path.toLowerCase().endsWith('.lnk')) {
        return LeftoverRefusal.invalid;
      }
      final normalized = p.windows.normalize(path).toLowerCase();
      // The deepest matching root decides (Start Menu sits inside AppData).
      String? root;
      for (final candidate in roots.folders) {
        final r = p.windows.normalize(candidate).toLowerCase();
        if (normalized.startsWith('$r\\') &&
            (root == null || r.length > root.length)) {
          root = r;
        }
      }
      if (root == null) return LeftoverRefusal.outsideAllowed;
      final below = normalized.substring(root.length + 1).split(r'\');
      // %LOCALAPPDATA%\Programs holds per-user installs: judge one level down.
      final owner = below.first == 'programs' && below.length > 1
          ? below[1]
          : below.first;
      if (_sharedFolders.contains(owner) || owner == 'common') {
        return LeftoverRefusal.shared;
      }
      return null;
    case 'registryKey':
      final hive = machine ? 'HKLM' : 'HKCU';
      final uninstall = RegExp(
        '^$hive\\\\SOFTWARE\\\\(WOW6432Node\\\\)?Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\[^\\\\]{1,255}\$',
        caseSensitive: false,
      );
      if (uninstall.hasMatch(path)) return null;
      final parts = path.split(r'\');
      if (parts.first.toUpperCase() != hive ||
          parts.length < 3 ||
          parts[1].toLowerCase() != 'software') {
        return LeftoverRefusal.outsideAllowed;
      }
      final below = parts.skip(2).toList();
      if (below.isNotEmpty && below.first.toLowerCase() == 'wow6432node') {
        if (!machine) return LeftoverRefusal.outsideAllowed;
        below.removeAt(0);
      }
      if (below.isEmpty ||
          below.length > 2 ||
          below.any((part) => part.isEmpty) ||
          _sharedKeys.contains(below.first.toLowerCase())) {
        return LeftoverRefusal.shared;
      }
      return null;
    case 'runValue':
      final split = path.lastIndexOf('|');
      if (split < 1 || split == path.length - 1) return LeftoverRefusal.invalid;
      final key = path.substring(0, split);
      final allowed = _runKeys.where(
        (run) => run.toLowerCase() == key.toLowerCase(),
      );
      if (allowed.isEmpty) return LeftoverRefusal.outsideAllowed;
      if (key.toUpperCase().startsWith('HKLM') != machine) {
        return LeftoverRefusal.outsideAllowed;
      }
      return null;
    case 'task':
      if (!machine) return LeftoverRefusal.outsideAllowed;
      if (!RegExp(r'^\\[^\\][^<>|&%]*$').hasMatch(path) ||
          path.toLowerCase().startsWith(r'\microsoft\')) {
        return LeftoverRefusal.shared;
      }
      return null;
    case 'firewallRule':
      if (!machine) return LeftoverRefusal.outsideAllowed;
      if (path.length > 255) return LeftoverRefusal.invalid;
      return null;
    default:
      return LeftoverRefusal.invalid;
  }
}

typedef CommandRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

/// Removes leftovers chosen in the preview. Registry keys and Run values are
/// exported to .reg first, tasks to XML, firewall rules to JSON; files and
/// folders go to the Recycle Bin. Before a file move every parent folder is
/// opened and held without delete sharing, after checking it is not a link,
/// so no parent can be swapped for a junction while the move runs.
class LeftoverRemovalOperation implements OperationDefinition {
  LeftoverRemovalOperation({
    required this.machine,
    LeftoverRoots? roots,
    CommandRunner? run,
    String? backupRoot,
    this.dryRun = false,
  }) : _roots = roots,
       _run = run ?? _runSystem,
       _backupRoot = backupRoot;

  final bool machine;
  final LeftoverRoots? _roots;
  final CommandRunner _run;
  final String? _backupRoot;
  final bool dryRun;

  LeftoverRoots get roots => _roots ?? LeftoverRoots.current(machine: machine);

  static String get _system32 => p.windows.join(
    Platform.environment['SystemRoot'] ?? r'C:\Windows',
    'System32',
  );
  static String get _reg => p.windows.join(_system32, 'reg.exe');
  static String get _schtasks => p.windows.join(_system32, 'schtasks.exe');
  static String get _powershell =>
      p.windows.join(_system32, r'WindowsPowerShell\v1.0\powershell.exe');

  List<Map<String, Object?>> _items(OperationRequest request) {
    final raw = request.parameters['items'];
    if (raw is! List ||
        raw.isEmpty ||
        raw.length > 500 ||
        request.desiredValue != false) {
      throw StateError('Invalid leftover request.');
    }
    final items = <Map<String, Object?>>[
      for (final row in raw)
        if (row is Map)
          Map<String, Object?>.from(row)
        else
          throw StateError('Invalid leftover.'),
    ];
    for (final item in items) {
      final reason = validateLeftoverItem(item, machine: machine, roots: roots);
      if (reason != null) {
        throw StateError('${item['path']}: ${reason.message}');
      }
    }
    return items;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _items(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  Future<bool> _exists(Map<String, Object?> item) async {
    final path = item['path']! as String;
    switch (item['kind']) {
      case 'folder':
        return Directory(path).existsSync();
      case 'shortcut':
        return File(path).existsSync();
      case 'registryKey':
        return (await _run(_reg, <String>['query', path])).exitCode == 0;
      case 'runValue':
        final split = path.lastIndexOf('|');
        return (await _run(_reg, <String>[
              'query',
              path.substring(0, split),
              '/v',
              path.substring(split + 1),
            ])).exitCode ==
            0;
      case 'task':
        return (await _run(_schtasks, <String>[
              '/Query',
              '/TN',
              path,
            ])).exitCode ==
            0;
      case 'firewallRule':
        return (await _powershellWith(
              r'if (-not (Get-NetFirewallRule -Name $arg -ErrorAction SilentlyContinue)) { exit 1 }',
              path,
            )).exitCode ==
            0;
    }
    return false;
  }

  /// True while any leftover is still there (the request asks for false);
  /// the remaining paths are listed in the message.
  @override
  Future<OperationState> inspect(OperationRequest request) async {
    final remaining = <String>[
      for (final item in _items(request))
        if (await _exists(item)) item['path']! as String,
    ];
    return OperationState(
      OperationStateKind.configured,
      value: remaining.isNotEmpty,
      message: remaining.isEmpty ? null : remaining.join('\n'),
    );
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final before = await inspect(request);
    return OperationSnapshot(
      type: 'leftovers',
      data: <String, Object?>{'remaining': before.message},
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final items = _items(request);
    if (dryRun) return;
    final backup = await _backupDirectory();
    final failures = <String>[];
    var n = 0;
    for (final item in items) {
      if (!await _exists(item)) continue;
      final path = item['path']! as String;
      try {
        await _remove(item['kind']! as String, path, backup.path, n++);
      } catch (error) {
        failures.add('$path: $error');
      }
    }
    if (failures.isNotEmpty) throw StateError(failures.join('\n'));
  }

  /// Fresh folder for this run's backups. In the elevated context every
  /// existing parent must be a plain folder owned by Administrators or
  /// SYSTEM, otherwise a standard user who pre-created it could steer the
  /// helper's writes through a junction; the run folder itself loses
  /// inherited rights (only Administrators and SYSTEM write) and must be
  /// empty before anything is written into it.
  Future<Directory> _backupDirectory() async {
    final base =
        _backupRoot ??
        p.windows.join(
          Platform.environment[machine ? 'ProgramData' : 'LOCALAPPDATA']!,
          'ZapTweaks',
        );
    final parents = <String>[base, p.windows.join(base, 'leftover-backups')];
    for (final dir in parents) {
      if (!Directory(dir).existsSync()) {
        Directory(dir).createSync();
      } else if (machine) {
        CloseHandle(_openChecked(dir, directory: true, keep: false));
        final owner = await _powershellWith(
          // .NET, not Get-Acl: the Security module can fail to load.
          r'[IO.Directory]::GetAccessControl($arg).GetOwner([Security.Principal.SecurityIdentifier]).Value',
          dir,
        );
        if (!const <String>{
          'S-1-5-32-544',
          'S-1-5-18',
        }.contains('${owner.stdout}'.trim())) {
          throw StateError(
            '$dir is not owned by Administrators; backups refused.',
          );
        }
      }
    }
    final run = Directory(
      p.windows.join(
        parents.last,
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[^0-9]'), ''),
      ),
    )..createSync();
    if (machine) {
      final acl = await _run(p.windows.join(_system32, 'icacls.exe'), <String>[
        run.path,
        '/inheritance:r',
        '/grant:r',
        '*S-1-5-32-544:(OI)(CI)F',
        '*S-1-5-18:(OI)(CI)F',
        '*S-1-5-11:(OI)(CI)RX',
      ]);
      if (acl.exitCode != 0 || run.listSync().isNotEmpty) {
        throw StateError(
          'Backup folder could not be secured; nothing removed.',
        );
      }
    }
    return run;
  }

  Future<void> _remove(String kind, String path, String backup, int n) async {
    Future<void> ok(Future<ProcessResult> call) async {
      final result = await call;
      if (result.exitCode != 0) {
        throw StateError(
          '${result.stderr}'.trim().isEmpty
              ? 'exit ${result.exitCode}'
              : '${result.stderr}'.trim(),
        );
      }
    }

    switch (kind) {
      case 'registryKey':
        await ok(
          _run(_reg, <String>[
            'export',
            path,
            p.windows.join(backup, '$n.reg'),
            '/y',
          ]),
        );
        await ok(_run(_reg, <String>['delete', path, '/f']));
      case 'runValue':
        final split = path.lastIndexOf('|');
        final key = path.substring(0, split);
        await ok(
          _run(_reg, <String>[
            'export',
            key,
            p.windows.join(backup, '$n-run.reg'),
            '/y',
          ]),
        );
        await ok(
          _run(_reg, <String>[
            'delete',
            key,
            '/v',
            path.substring(split + 1),
            '/f',
          ]),
        );
      case 'task':
        final xml = await _run(_schtasks, <String>[
          '/Query',
          '/TN',
          path,
          '/XML',
        ]);
        if (xml.exitCode != 0) throw StateError('Task export failed.');
        File(
          p.windows.join(backup, '$n-task.xml'),
        ).writeAsStringSync('${xml.stdout}');
        await ok(_run(_schtasks, <String>['/Delete', '/TN', path, '/F']));
      case 'firewallRule':
        final json = await _powershellWith(
          r'Get-NetFirewallRule -Name $arg | Select-Object Name, DisplayName, Direction, Action, Enabled, Profile, @{n="Program";e={($_ | Get-NetFirewallApplicationFilter).Program}} | ConvertTo-Json',
          path,
        );
        if (json.exitCode != 0) {
          throw StateError('Firewall rule export failed.');
        }
        File(
          p.windows.join(backup, '$n-firewall.json'),
        ).writeAsStringSync('${json.stdout}');
        await ok(
          _powershellWith(
            r'Remove-NetFirewallRule -Name $arg -ErrorAction Stop',
            path,
          ),
        );
      case 'folder' || 'shortcut':
        await _recycle(
          path,
          directory: kind == 'folder',
          linksBackup: p.windows.join(backup, '$n-links.json'),
        );
    }
  }

  /// Moves [path] to the Recycle Bin while its parents are pinned.
  Future<void> _recycle(
    String path, {
    required bool directory,
    required String linksBackup,
  }) async {
    // Without an interactive desktop the shell has no Recycle Bin and a
    // "recycle" silently deletes for good: refuse before touching anything.
    final session = await _powershellWith(
      r'if (-not [Environment]::UserInteractive) { exit 3 }',
      path,
    );
    if (session.exitCode != 0) {
      throw StateError(
        'Recycle Bin unavailable in a non-interactive session; nothing was deleted.',
      );
    }
    final pins = _pinParents(path, directory: directory);
    try {
      if (directory) _detachLinks(path, linksBackup);
      // SHFileOperation with FOF_ALLOWUNDO | FOF_NOCONFIRMATION |
      // FOF_WANTNUKEWARNING: no "are you sure" per item, but Windows warns
      // and asks before deleting for good anything the bin cannot hold;
      // declining aborts the move.
      final result = await _powershellWith(_recycleScript, path);
      if (result.exitCode != 0) {
        throw StateError(
          '${result.stderr}'.trim().isEmpty
              ? 'Not moved to the Recycle Bin (code ${result.exitCode}).'
              : '${result.stderr}'.trim(),
        );
      }
      if (FileSystemEntity.typeSync(path, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw StateError('Still present after the Recycle Bin move.');
      }
    } finally {
      for (final handle in pins.reversed) {
        CloseHandle(handle);
      }
    }
  }

  /// Junctions and symlinks inside a folder: the shell cannot recycle them.
  /// Each link itself is removed (its target is never entered or touched)
  /// and its target is written to [backupFile] so it can be recreated.
  static void _detachLinks(String folder, String backupFile) {
    final links = <Map<String, String>>[];
    for (final entity in Directory(
      folder,
    ).listSync(recursive: true, followLinks: false)) {
      if (entity is! Link) continue;
      // Record before removing, so a failure halfway loses nothing.
      links.add(<String, String>{
        'link': entity.path,
        'target': entity.targetSync(),
      });
      File(backupFile).writeAsStringSync(jsonEncode(links));
      final name = entity.path.toNativeUtf16();
      try {
        final attributes = GetFileAttributes(name);
        final ok =
            attributes != 0xffffffff &&
                attributes & FILE_ATTRIBUTE_DIRECTORY != 0
            ? RemoveDirectory(name) != 0
            : DeleteFile(name) != 0;
        if (!ok) {
          throw FileSystemException(
            'Cannot detach link (Win32 ${GetLastError()})',
            entity.path,
          );
        }
      } finally {
        calloc.free(name);
      }
    }
  }

  /// Moves `$arg` to the Recycle Bin. Exit 0 moved; 4 aborted (the user
  /// declined a permanent delete); otherwise the SHFileOperation code.
  static const _recycleScript = r'''
Add-Type -TypeDefinition @"
using System; using System.Runtime.InteropServices;
public static class ZtRecycle {
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
  struct Op { public IntPtr hwnd; public uint func; public string from; public string to; public ushort flags; public bool aborted; public IntPtr names; public string title; }
  [DllImport("shell32.dll", CharSet = CharSet.Unicode)] static extern int SHFileOperation(ref Op op);
  public static int Move(string path) {
    var op = new Op { func = 3, from = path + "\0\0", flags = 0x40 | 0x10 | 0x4000 | 0x4 };
    int code = SHFileOperation(ref op);
    return code != 0 ? code : (op.aborted ? 4 : 0);
  }
}
"@
exit [ZtRecycle]::Move($arg)
''';

  /// Opens every parent of [path] (and checks [path] itself) refusing links,
  /// junctions and any reparse point, and verifies the final path. Parents
  /// stay open without FILE_SHARE_DELETE, so they cannot be renamed or
  /// replaced until the handles are closed.
  static List<int> _pinParents(String path, {required bool directory}) {
    final absolute = p.windows.normalize(path);
    final chain = <String>[];
    for (
      var dir = p.windows.dirname(absolute);
      dir != p.windows.dirname(dir);
      dir = p.windows.dirname(dir)
    ) {
      chain.insert(0, dir);
    }
    final handles = <int>[];
    try {
      for (final dir in chain) {
        handles.add(_openChecked(dir, directory: true, keep: true));
      }
      CloseHandle(_openChecked(absolute, directory: directory, keep: false));
      return handles;
    } catch (_) {
      for (final handle in handles.reversed) {
        CloseHandle(handle);
      }
      rethrow;
    }
  }

  static int _openChecked(
    String path, {
    required bool directory,
    required bool keep,
  }) {
    final name = path.toNativeUtf16();
    final info = calloc<BY_HANDLE_FILE_INFORMATION>();
    final resolved = calloc<Uint16>(32768).cast<Utf16>();
    try {
      final handle = CreateFile(
        name,
        FILE_READ_ATTRIBUTES,
        keep
            ? FILE_SHARE_READ | FILE_SHARE_WRITE
            : FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        nullptr,
        OPEN_EXISTING,
        FILE_FLAG_OPEN_REPARSE_POINT | FILE_FLAG_BACKUP_SEMANTICS,
        0,
      );
      if (handle == INVALID_HANDLE_VALUE) {
        throw FileSystemException(
          'Cannot open (Win32 ${GetLastError()})',
          path,
        );
      }
      try {
        if (GetFileInformationByHandle(handle, info) == 0 ||
            info.ref.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT != 0 ||
            (info.ref.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY != 0) !=
                directory) {
          throw FileSystemException(
            'Link, junction or changed type refused',
            path,
          );
        }
        final length = GetFinalPathNameByHandle(handle, resolved, 32768, 0);
        var finalPath = resolved.toDartString();
        if (finalPath.startsWith(r'\\?\')) finalPath = finalPath.substring(4);
        if (length == 0 || !p.windows.equals(finalPath, path)) {
          throw FileSystemException(
            'Final path differs from the preview',
            path,
          );
        }
        return handle;
      } catch (_) {
        CloseHandle(handle);
        rethrow;
      }
    } finally {
      calloc.free(name);
      calloc.free(info);
      calloc.free(resolved);
    }
  }

  /// Runs a fixed script with [argument] delivered as base64, never as text.
  Future<ProcessResult> _powershellWith(String script, String argument) {
    final payload = base64Encode(utf8.encode(argument));
    return _run(_powershell, <String>[
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "\$arg = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$payload')); $script",
    ]);
  }

  static Future<ProcessResult> _runSystem(
    String executable,
    List<String> arguments,
  ) => Process.run(executable, arguments, runInShell: false);

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError(
        'Restore from the Recycle Bin and the .reg/XML/JSON backups.',
      );

  @override
  String get id =>
      machine ? 'app.leftovers.remove' : 'app.leftovers.remove_user';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'leftoverRemovalTitle';
  @override
  String get descriptionKey => 'leftoverRemovalDescription';
  @override
  String get domain => 'apps';
  @override
  String get destination => 'Apps';
  @override
  OperationScope get scope => OperationScope.app;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege =>
      machine ? OperationPrivilege.administrator : OperationPrivilege.user;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.manual;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.inferred;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.unverified;
  @override
  String? get evidenceBinaryVersion => null;
  @override
  String? get evidenceSha256 => null;
  @override
  List<String> get supportedEditions => const <String>['Home', 'Pro'];
  @override
  List<String> get supportedArchitectures => const <String>['x64'];
  @override
  List<String> get technicalSources => const <String>[
    'https://learn.microsoft.com/windows-server/administration/windows-commands/reg-export',
    'https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks-delete',
    'https://learn.microsoft.com/powershell/module/netsecurity/remove-netfirewallrule',
    'https://learn.microsoft.com/dotnet/api/microsoft.visualbasic.fileio.filesystem.deletedirectory',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
