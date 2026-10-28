import 'dart:convert';

import '../../../core/services/process_runner.dart';
import '../domain/service_safety_policy.dart';

class ServiceEntry {
  const ServiceEntry({
    required this.name,
    required this.displayName,
    required this.description,
    required this.startType,
    required this.delayed,
    required this.running,
    required this.path,
    required this.company,
    this.dependents = 0,
    this.securityProduct = false,
  });

  final String name;
  final String displayName;
  final String? description;

  /// SCM start type: 2 automatic, 3 manual, 4 disabled.
  final int startType;
  final bool delayed;
  final bool running;

  /// Executable with environment variables expanded; null when unreadable.
  final String? path;
  final String? company;

  /// Services that depend on this one; Windows refuses to disable it.
  final int dependents;

  /// Installed with an antivirus, antispyware or firewall product that
  /// Windows Security Center lists.
  final bool securityProduct;
}

const _startTypes = <String, int>{
  'boot': 0,
  'system': 1,
  'auto': 2,
  'manual': 3,
  'disabled': 4,
};

/// Parses `{"Services": [...], "Security": [exe, ...]}`.
List<ServiceEntry> parseServiceInventory(String json) {
  final decoded = jsonDecode(json) as Map;
  final services = decoded['Services'];
  final rows = services is List ? services : <dynamic>[services];
  final security = _strings(decoded['Security']);
  String? text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
  return <ServiceEntry>[
    for (final row in rows)
      if (row is Map &&
          row['Name'] is String &&
          _startTypes.containsKey('${row['StartMode']}'.toLowerCase()))
        ServiceEntry(
          name: row['Name'] as String,
          displayName: text(row['DisplayName']) ?? row['Name'] as String,
          description: text(row['Description']),
          startType: _startTypes['${row['StartMode']}'.toLowerCase()]!,
          delayed: row['Delayed'] == true,
          running: row['Running'] == true,
          path: text(row['Path']),
          company: text(row['Company']),
          dependents: row['Dependents'] is int ? row['Dependents'] as int : 0,
          securityProduct: isSecurityProductPath(text(row['Path']), security),
        ),
  ];
}

List<String> _strings(Object? value) => <String>[
  for (final item in value is List ? value : <Object?>[value])
    if (item is String) item,
];

/// Read-only. Executables Windows Security Center lists for antivirus,
/// antispyware and firewall products; empty where it is missing (Server).
const _securityProductExes = r'''
@('AntiVirusProduct','AntiSpywareProduct','FirewallProduct' | ForEach-Object { Get-CimInstance -Namespace root/SecurityCenter2 -ClassName $_ -ErrorAction SilentlyContinue } | ForEach-Object { $_.pathToSignedProductExe; $_.pathToSignedReportingExe } | Where-Object { $_ } | ForEach-Object { [Environment]::ExpandEnvironmentVariables([string]$_) })''';

Future<List<String>> listSecurityProductExes(ProcessRunner runner) async =>
    _strings(
      jsonDecode(
        await runner.runPowerShellForOutput(
          'ConvertTo-Json -Compress -InputObject $_securityProductExes',
        ),
      ),
    );

/// Read-only. Win32_Service lists services only (drivers are elsewhere).
/// The executable is cut from PathName and %VAR% expanded; company comes
/// from its version info, read once per file.
final serviceInventoryScript =
    r'''
$info = @{}
$deps = @{}
Get-CimInstance Win32_DependentService -ErrorAction SilentlyContinue | ForEach-Object { $n = [string]$_.Antecedent.Name; $deps[$n] = 1 + [int]$deps[$n] }
$services = @(Get-CimInstance Win32_Service -Property Name,DisplayName,Description,StartMode,State,PathName,DelayedAutoStart -ErrorAction Stop | ForEach-Object {
  $pn = [string]$_.PathName
  $exe = if ($pn -match '^\s*"([^"]+)"') { $Matches[1] } elseif ($pn -match '^\s*(.+?\.exe)(\s|$)') { $Matches[1] } else { $pn }
  $exe = [Environment]::ExpandEnvironmentVariables($exe)
  if ($exe -and -not $info.ContainsKey($exe)) { $info[$exe] = try { [Diagnostics.FileVersionInfo]::GetVersionInfo($exe).CompanyName } catch { $null } }
  [pscustomobject]@{ Name = $_.Name; DisplayName = $_.DisplayName; Description = $_.Description; StartMode = $_.StartMode; Delayed = [bool]$_.DelayedAutoStart; Running = ($_.State -eq 'Running'); Path = $exe; Company = $info[$exe]; Dependents = [int]$deps[$_.Name] }
})
ConvertTo-Json -Compress -Depth 4 -InputObject ([pscustomobject]@{ Services = $services; Security = $SECURITY })
'''
        .replaceFirst(r'$SECURITY', _securityProductExes);

Future<List<ServiceEntry>> listServices(ProcessRunner runner) async =>
    parseServiceInventory(
      await runner.runPowerShellForOutput(serviceInventoryScript),
    );
