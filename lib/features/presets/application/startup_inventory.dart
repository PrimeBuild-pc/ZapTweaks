import 'dart:convert';

import '../../../core/services/process_runner.dart';

/// One Run-key entry; [location] is the `startup.entry.*` parameter.
typedef StartupEntry = ({
  String location,
  bool machine,
  String name,
  String command,
  bool enabled,
});

List<StartupEntry> parseStartupInventory(String json) {
  final decoded = jsonDecode(json.isEmpty ? '[]' : json);
  final rows = decoded is List ? decoded : <dynamic>[decoded];
  return <StartupEntry>[
    for (final row in rows)
      if (row is Map &&
          (row['Location'] == 'run' || row['Location'] == 'run32') &&
          row['Machine'] is bool &&
          row['Name'] is String &&
          (row['Name'] as String).isNotEmpty)
        (
          location: row['Location'] as String,
          machine: row['Machine'] as bool,
          name: row['Name'] as String,
          command: row['Command'] is String ? row['Command'] as String : '',
          enabled: row['Enabled'] != false,
        ),
  ];
}

/// Read-only, plain .NET registry calls (no PowerShell module to load).
/// A flag with an odd first byte under StartupApproved means "turned off".
const startupInventoryScript = r'''
$script:rows = @()
function Add-Run($hive, $view, $machine, $location, $approvedName) {
  $run = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, $view).OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run')
  if (-not $run) { return }
  $approved = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, 'Registry64').OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\$approvedName")
  foreach ($n in $run.GetValueNames()) {
    if (-not $n) { continue }
    $flag = if ($approved) { $approved.GetValue($n) } else { $null }
    $enabled = -not ($flag -is [byte[]] -and $flag.Length -gt 0 -and ($flag[0] -band 1))
    $script:rows += [pscustomobject]@{ Location = $location; Machine = $machine; Name = $n; Command = [string]$run.GetValue($n); Enabled = $enabled }
  }
}
Add-Run 'CurrentUser' 'Registry64' $false 'run' 'Run'
Add-Run 'LocalMachine' 'Registry64' $true 'run' 'Run'
Add-Run 'LocalMachine' 'Registry32' $true 'run32' 'Run32'
ConvertTo-Json -Compress -InputObject @($script:rows)
''';

Future<List<StartupEntry>> listStartupEntries(ProcessRunner runner) async =>
    parseStartupInventory(
      await runner.runPowerShellForOutput(startupInventoryScript),
    );
