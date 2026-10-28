import 'dart:convert';

import '../../../core/services/process_runner.dart';
import 'folder_size_cache.dart' show isAppOwnedFolder, normalizeFolder;

typedef RunningProcess = ({String name, String path});

/// Processes of the current session with a readable image path. Elevated
/// processes have none and are left out.
Future<List<RunningProcess>> listRunningProcesses(ProcessRunner runner) async {
  try {
    final output = await runner.runPowerShellForOutput(
      // Win32_Process: Get-Process .Path takes ~12 s on a busy PC.
      r'ConvertTo-Json -Compress -InputObject @(Get-CimInstance Win32_Process -Property Name,ExecutablePath | Where-Object ExecutablePath | ForEach-Object { [pscustomobject]@{ Name = [IO.Path]::GetFileNameWithoutExtension($_.Name); Path = $_.ExecutablePath } })',
    );
    return <RunningProcess>[
      for (final row in jsonDecode(output) as List)
        if (row is Map && row['Name'] is String && row['Path'] is String)
          (name: row['Name'] as String, path: row['Path'] as String),
    ];
  } catch (_) {
    return const <RunningProcess>[];
  }
}

/// Names of processes started from inside [folder]. Shared folders (Program
/// Files itself, Common Files…) never match, so a stray InstallLocation does
/// not flag half the system.
List<String> processesUnder(Iterable<RunningProcess> processes, String folder) {
  if (!isAppOwnedFolder(folder)) return const <String>[];
  final prefix = '${normalizeFolder(folder).toLowerCase()}\\';
  return <String>{
    for (final process in processes)
      if (process.path.toLowerCase().startsWith(prefix)) process.name,
  }.toList()..sort();
}
