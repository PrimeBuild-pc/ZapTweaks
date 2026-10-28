import 'dart:convert';

import '../../../core/services/process_runner.dart';

class ProcessEntry {
  const ProcessEntry({
    required this.pid,
    required this.name,
    required this.path,
    required this.description,
    required this.company,
    required this.memoryBytes,
    required this.cpuPercent,
    required this.sessionId,
    this.signer,
  });

  final int pid;
  final String name;

  /// Null for protected and elevated processes Windows does not expose.
  final String? path;
  final String? description;
  final String? company;
  final int memoryBytes;

  /// Share of the whole CPU (all cores = 100), from one counter sample.
  final double cpuPercent;
  final int sessionId;

  /// Authenticode signer, filled in after the list shows.
  final String? signer;

  ProcessEntry withSigner(String? value) => ProcessEntry(
    pid: pid,
    name: name,
    path: path,
    description: description,
    company: company,
    memoryBytes: memoryBytes,
    cpuPercent: cpuPercent,
    sessionId: sessionId,
    signer: value,
  );
}

enum ProcessKind { windows, microsoftApp, thirdParty }

enum ProcessReason { critical, windowsFolder, service, self, userApp }

typedef ProcessVerdict = ({
  ProcessKind kind,
  bool canClose,
  ProcessReason reason,
});

/// Processes Windows needs to keep running; closing one can log the user
/// out or crash the system, so they are never offered.
const _critical = <String>{
  'system',
  'idle',
  'registry',
  'secure system',
  'memory compression',
  'smss',
  'csrss',
  'wininit',
  'winlogon',
  'services',
  'lsass',
  'lsaiso',
  'svchost',
  'fontdrvhost',
  'dwm',
  'sihost',
  'ctfmon',
  'explorer',
  'audiodg',
  'spoolsv',
  'msmpeng',
  'securityhealthservice',
  'wmiprvse',
  'dllhost',
  'conhost',
  'taskhostw',
  'runtimebroker',
  'startmenuexperiencehost',
  'searchhost',
  'shellexperiencehost',
  'textinputhost',
  'lockapp',
  'userinit',
};

ProcessVerdict classifyProcess(
  ProcessEntry entry, {
  required String systemRoot,
  required int selfPid,
}) {
  final name = entry.name.toLowerCase();
  final path = entry.path?.toLowerCase();
  // The signer is verified; the company field is whatever the file claims.
  final microsoft = (entry.signer ?? entry.company ?? '')
      .toLowerCase()
      .contains('microsoft');
  if (_critical.contains(name)) {
    return (
      kind: ProcessKind.windows,
      canClose: false,
      reason: ProcessReason.critical,
    );
  }
  if (path == null || path.startsWith('${systemRoot.toLowerCase()}\\')) {
    return (
      kind: ProcessKind.windows,
      canClose: false,
      reason: ProcessReason.windowsFolder,
    );
  }
  final kind = microsoft ? ProcessKind.microsoftApp : ProcessKind.thirdParty;
  if (entry.pid == selfPid) {
    return (kind: kind, canClose: false, reason: ProcessReason.self);
  }
  // Session 0 holds services: ending one stops the service behind it.
  if (entry.sessionId == 0) {
    return (kind: kind, canClose: false, reason: ProcessReason.service);
  }
  return (kind: kind, canClose: true, reason: ProcessReason.userApp);
}

List<ProcessEntry> parseProcessInventory(String json) {
  final decoded = jsonDecode(json);
  final rows = decoded is List ? decoded : <dynamic>[decoded];
  String? text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
  return <ProcessEntry>[
    for (final row in rows)
      if (row is Map && row['Id'] is int && row['Name'] is String)
        ProcessEntry(
          pid: row['Id'] as int,
          name: row['Name'] as String,
          path: text(row['Path']),
          description: text(row['Description']),
          company: text(row['Company']),
          memoryBytes: row['WorkingSet'] is num
              ? (row['WorkingSet'] as num).toInt()
              : 0,
          cpuPercent: row['Cpu'] is num ? (row['Cpu'] as num).toDouble() : 0,
          sessionId: row['SessionId'] is int ? row['SessionId'] as int : -1,
        ),
  ];
}

/// Read-only. CPU comes from the per-process perf class (locale independent)
/// divided by the logical processor count. Paths come from Win32_Process and
/// version info is read once per file: Get-Process .Path/.Description took
/// ~12 s on 230 processes (one failed module read per protected process).
const processInventoryScript = r'''
$cores = [Environment]::ProcessorCount
$cpu = @{}
Get-CimInstance Win32_PerfFormattedData_PerfProc_Process -Property IDProcess,PercentProcessorTime -ErrorAction SilentlyContinue | ForEach-Object { $cpu[[int]$_.IDProcess] = [double]$_.PercentProcessorTime / $cores }
$paths = @{}
Get-CimInstance Win32_Process -Property ProcessId,ExecutablePath -ErrorAction SilentlyContinue | ForEach-Object { if ($_.ExecutablePath) { $paths[[int]$_.ProcessId] = $_.ExecutablePath } }
$info = @{}
foreach ($p in ($paths.Values | Select-Object -Unique)) { try { $info[$p] = [Diagnostics.FileVersionInfo]::GetVersionInfo($p) } catch {} }
ConvertTo-Json -Compress -InputObject @(Get-Process | ForEach-Object {
  $path = $paths[$_.Id]; $v = if ($path) { $info[$path] } else { $null }
  [pscustomobject]@{ Id = $_.Id; Name = $_.ProcessName; Path = $path; Description = $v.FileDescription; Company = $v.CompanyName; WorkingSet = $_.WorkingSet64; Cpu = [Math]::Round([double]$cpu[$_.Id], 2); SessionId = $_.SessionId }
})
''';

Future<List<ProcessEntry>> listProcesses(ProcessRunner runner) async =>
    parseProcessInventory(
      await runner.runPowerShellForOutput(processInventoryScript),
    );

/// Signer subject (CN) for each path; paths travel as base64 JSON.
Future<Map<String, String>> fetchSigners(
  ProcessRunner runner,
  Iterable<String> paths,
) async {
  final unique = paths.toSet().toList();
  if (unique.isEmpty) return const <String, String>{};
  final payload = base64Encode(utf8.encode(jsonEncode(unique)));
  try {
    final output = await runner.runPowerShellForOutput('''
\$paths = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$payload')) | ConvertFrom-Json
\$out = @{}
foreach (\$p in \$paths) {
  \$s = Get-AuthenticodeSignature -LiteralPath \$p -ErrorAction SilentlyContinue
  if (\$s -and \$s.Status -eq 'Valid' -and \$s.SignerCertificate) { \$out[\$p] = (\$s.SignerCertificate.Subject -replace '^CN="?([^",]+)"?.*\$', '\$1') }
}
\$out | ConvertTo-Json -Compress
''');
    final decoded = jsonDecode(output);
    return <String, String>{
      if (decoded is Map)
        for (final entry in decoded.entries)
          if (entry.value is String) entry.key as String: entry.value as String,
    };
  } catch (_) {
    return const <String, String>{};
  }
}

/// Ends [pid] only if it is still [name]: the PID may have been reused
/// since the list was read. Prints `ok` or `changed`; an elevated process
/// throws (access denied).
String endProcessScript(int pid, String name) {
  final encoded = base64Encode(utf8.encode(name));
  return '''
\$expected = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encoded'))
\$p = Get-Process -Id $pid -ErrorAction SilentlyContinue
if (-not \$p -or \$p.ProcessName -ne \$expected) { 'changed'; exit 0 }
try { \$p.Kill(); 'ok' } catch { 'failed' }
''';
}

Future<bool> endProcess(ProcessRunner runner, ProcessEntry entry) async =>
    await runner.runPowerShellForOutput(
      endProcessScript(entry.pid, entry.name),
    ) ==
    'ok';

Uri processSearchUri(String name) =>
    Uri.https('duckduckgo.com', '/', {'q': '"$name" process'});
