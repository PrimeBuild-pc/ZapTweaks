import 'dart:io';
import 'dart:math';

import '../../../core/services/process_runner.dart';
import '../domain/app_package.dart';
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

  Future<AppInventoryResult> scanCurrentUser() async {
    try {
      final output = await _processRunner.runPowerShellForOutput(r'''
$packages = @(Get-AppxPackage -ErrorAction Stop | ForEach-Object {
  [pscustomobject]@{
    Name = $_.Name
    DisplayName = $_.Name
    Version = $_.Version.ToString()
    Publisher = $_.Publisher
    CurrentUser = $true
    AllUsers = $false
    Provisioned = $false
    Reinstallable = $false
  }
})
ConvertTo-Json -Compress -Depth 3 -InputObject $packages
''');
      return AppInventoryResult(
        packages: _parser.parseAppx(output.isEmpty ? '[]' : output),
        currentUserComplete: true,
        allUsersComplete: false,
        provisionedComplete: false,
        wingetComplete: false,
      );
    } catch (error) {
      return _failure(error);
    }
  }

  Future<AppInventoryResult> scanSystemScopes() async {
    try {
      final output = await _processRunner.runPowerShellForOutput(r'''
$installed = @(Get-AppxPackage -AllUsers -ErrorAction Stop | ForEach-Object {
  [pscustomobject]@{
    Name = $_.Name
    DisplayName = $_.Name
    Version = $_.Version.ToString()
    Publisher = $_.Publisher
    CurrentUser = $false
    AllUsers = $true
    Provisioned = $false
    Reinstallable = $false
  }
})
$provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop | ForEach-Object {
  [pscustomobject]@{
    Name = $_.DisplayName
    DisplayName = $_.DisplayName
    Version = $_.Version.ToString()
    Publisher = $null
    CurrentUser = $false
    AllUsers = $false
    Provisioned = $true
    Reinstallable = $false
  }
})
ConvertTo-Json -Compress -Depth 3 -InputObject @($installed + $provisioned)
''');
      return AppInventoryResult(
        packages: _parser.parseAppx(output.isEmpty ? '[]' : output),
        currentUserComplete: false,
        allUsersComplete: true,
        provisionedComplete: true,
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

  static AppInventoryResult _failure(Object error) => AppInventoryResult(
    packages: const <AppPackage>[],
    currentUserComplete: false,
    allUsersComplete: false,
    provisionedComplete: false,
    wingetComplete: false,
    message: error.toString(),
  );
}
