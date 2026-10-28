import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../../core/services/process_runner.dart';
import '../domain/app_package.dart';
import '../domain/appx_candidate_policy.dart';
import 'app_inventory_parser.dart';

class AppInventoryResult {
  const AppInventoryResult({
    required this.packages,
    required this.currentUserComplete,
    required this.allUsersComplete,
    required this.provisionedComplete,
    required this.wingetComplete,
    this.message,
  });

  final List<AppPackage> packages;
  final bool currentUserComplete;
  final bool allUsersComplete;
  final bool provisionedComplete;
  final bool wingetComplete;
  final String? message;
}

class WindowsAppInventoryService {
  WindowsAppInventoryService({
    required ProcessRunner processRunner,
    AppInventoryParser parser = const AppInventoryParser(),
  }) : _processRunner = processRunner,
       _parser = parser;

  final ProcessRunner _processRunner;
  final AppInventoryParser _parser;

  Future<AppInventoryResult> scanCurrentUser() => _scanAppx(system: false);

  Future<AppInventoryResult> scanSystemScopes() => _scanAppx(system: true);

  Future<AppInventoryResult> _scanAppx({required bool system}) async {
    try {
      final output = await _processRunner.runPowerShellForOutput(
        appxInventoryScript(allUsers: system, provisioned: system),
      );
      final inventory = jsonDecode(output);
      if (inventory is! Map ||
          inventory['InstalledComplete'] != true ||
          (system &&
              (inventory['AllUsersComplete'] != true ||
                  inventory['ProvisionedComplete'] != true))) {
        throw const FormatException('Incomplete AppX inventory.');
      }
      return AppInventoryResult(
        packages: _parser.parseAppx(output),
        currentUserComplete: !system,
        allUsersComplete: system,
        provisionedComplete: system,
        wingetComplete: false,
      );
    } catch (error) {
      return _failure(error);
    }
  }

  Future<AppInventoryResult> scanWinget() async {
    final suffix = Random.secure().nextInt(0x7fffffff).toRadixString(16);
    final export = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'zaptweaks-winget-$suffix.json',
    );
    try {
      final result = await _processRunner.run('winget', <String>[
        'export',
        '--output',
        export.path,
        '--include-versions',
        '--accept-source-agreements',
        '--disable-interactivity',
      ]);
      if (!result.success || !await export.exists()) {
        throw StateError(
          result.details.isEmpty ? 'winget export failed.' : result.details,
        );
      }
      return AppInventoryResult(
        packages: _parser.parseWinget(await export.readAsString()),
        currentUserComplete: false,
        allUsersComplete: false,
        provisionedComplete: false,
        wingetComplete: true,
      );
    } catch (error) {
      return _failure(error);
    } finally {
      if (await export.exists()) await export.delete();
    }
  }

  /// Win32/MSI programs from the Uninstall keys (HKLM 64/32-bit, HKCU).
  /// Read-only; values come back as JSON data and are never executed.
  static const uninstallRegistryScript = r'''
$roots = @(
  @{ Hive = 'HKLM'; View = '64'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' },
  @{ Hive = 'HKLM'; View = '32'; Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' },
  @{ Hive = 'HKCU'; View = '64'; Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' }
)
$fields = 'DisplayName','Publisher','DisplayVersion','InstallDate','InstallLocation','EstimatedSize','UninstallString','QuietUninstallString','SystemComponent','NoRemove','ParentKeyName','WindowsInstaller','ReleaseType'
$rows = foreach ($root in $roots) {
  if (-not (Test-Path -LiteralPath $root.Path)) { continue }
  foreach ($key in Get-ChildItem -LiteralPath $root.Path -ErrorAction SilentlyContinue) {
    $row = [ordered]@{ Hive = $root.Hive; View = $root.View; Key = $key.PSChildName }
    foreach ($field in $fields) { $row[$field] = $key.GetValue($field, $null, 'DoNotExpandEnvironmentNames') }
    [pscustomobject]$row
  }
}
ConvertTo-Json -Compress -Depth 3 -InputObject @($rows)
''';

  Future<AppInventoryResult> scanWin32() async {
    try {
      final output = await _processRunner.runPowerShellForOutput(
        uninstallRegistryScript,
      );
      return AppInventoryResult(
        packages: _parser.parseUninstallEntries(output),
        currentUserComplete: true,
        allUsersComplete: false,
        provisionedComplete: false,
        wingetComplete: false,
      );
    } catch (error) {
      return _failure(error);
    }
  }

  /// AppX package name → install folder, for folder sizes. Empty on failure.
  Future<Map<String, String>> appxInstallLocations() async {
    try {
      final output = await _processRunner.runPowerShellForOutput(
        r'ConvertTo-Json -Compress -InputObject @(Get-AppxPackage -PackageTypeFilter Main | ForEach-Object { [pscustomobject]@{ Name = $_.Name; Path = [string]$_.InstallLocation } })',
      );
      return <String, String>{
        for (final row in jsonDecode(output) as List)
          if (row is Map && row['Name'] is String && row['Path'] is String)
            row['Name'] as String: row['Path'] as String,
      };
    } catch (_) {
      return const <String, String>{};
    }
  }

  static AppInventoryResult _failure(Object error) => AppInventoryResult(
    packages: const <AppPackage>[],
    currentUserComplete: false,
    allUsersComplete: false,
    provisionedComplete: false,
    wingetComplete: false,
    message: error.toString(),
  );
}
