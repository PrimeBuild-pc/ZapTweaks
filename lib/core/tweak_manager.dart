import 'dart:io';

import 'services/logging_service.dart';
import 'services/process_runner.dart';

import 'registry_manager.dart';

class TweakApplyResult {
  const TweakApplyResult({required this.success, required this.errors});

  final bool success;
  final List<String> errors;
}

class TweakManager {
  TweakManager({LoggingService? loggingService, ProcessRunner? processRunner})
    : _loggingService = loggingService ?? LoggingService.instance,
      _processRunner = processRunner ?? ProcessRunner.shared;

  final LoggingService _loggingService;
  final ProcessRunner _processRunner;

  bool _commandBatchHasFailure = false;
  final List<String> _commandBatchErrors = <String>[];
  static final RegExp _powerSchemeGuidRegex = RegExp(
    r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
    caseSensitive: false,
  );

  static const String _msiEnableScript = r'''
$devs = @()
$devs += Get-PnpDevice -Class Net -PresentOnly | Where-Object { $_.Status -eq "OK" -and $_.Manufacturer -match "Realtek" }
$devs += Get-PnpDevice -Class Display -PresentOnly | Where-Object { $_.Status -eq "OK" -and ($_.Manufacturer -match "NVIDIA|Advanced Micro Devices|AMD") }
$devs += Get-PnpDevice -PresentOnly | Where-Object { $_.Status -eq "OK" -and ($_.FriendlyName -match "NVMe" -or $_.InstanceId -match "NVME") }
$devs += Get-PnpDevice -PresentOnly | Where-Object { $_.Status -eq "OK" -and ($_.FriendlyName -match "xHCI|USB 3\.|USB3|USB eXtensible Host Controller") }
$devs = $devs | Sort-Object InstanceId -Unique
foreach ($dev in $devs) {
  $base = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($dev.InstanceId)\Device Parameters\Interrupt Management"
  $msi = Join-Path $base "MessageSignaledInterruptProperties"
  $aff = Join-Path $base "Affinity Policy"
  if (-not (Test-Path $msi)) { New-Item -Path $msi -Force | Out-Null }
  if (-not (Test-Path $aff)) { New-Item -Path $aff -Force | Out-Null }
  New-ItemProperty -Path $msi -Name MSISupported -PropertyType DWord -Value 1 -Force | Out-Null
  New-ItemProperty -Path $aff -Name DevicePolicy -PropertyType DWord -Value 5 -Force | Out-Null
}
''';

  static const String _msiDisableScript = r'''
$devs = @()
$devs += Get-PnpDevice -Class Net -PresentOnly | Where-Object { $_.Status -eq "OK" -and $_.Manufacturer -match "Realtek" }
$devs += Get-PnpDevice -Class Display -PresentOnly | Where-Object { $_.Status -eq "OK" -and ($_.Manufacturer -match "NVIDIA|Advanced Micro Devices|AMD") }
$devs += Get-PnpDevice -PresentOnly | Where-Object { $_.Status -eq "OK" -and ($_.FriendlyName -match "NVMe" -or $_.InstanceId -match "NVME") }
$devs += Get-PnpDevice -PresentOnly | Where-Object { $_.Status -eq "OK" -and ($_.FriendlyName -match "xHCI|USB 3\.|USB3|USB eXtensible Host Controller") }
$devs = $devs | Sort-Object InstanceId -Unique
foreach ($dev in $devs) {
  $base = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($dev.InstanceId)\Device Parameters\Interrupt Management"
  $msi = Join-Path $base "MessageSignaledInterruptProperties"
  $aff = Join-Path $base "Affinity Policy"
  if (Test-Path $msi) { Remove-ItemProperty -Path $msi -Name MSISupported -ErrorAction SilentlyContinue }
  if (Test-Path $aff) { Remove-ItemProperty -Path $aff -Name DevicePolicy -ErrorAction SilentlyContinue }
}
''';

  Future<TweakApplyResult> applyTweak(String key, bool enable) async {
    _resetCommandBatch();

    final handlers = _handlers;
    final handler = handlers[key];

    if (handler == null) {
      _recordCommandFailure(key, reason: 'No handler registered for tweak key');
      return TweakApplyResult(
        success: false,
        errors: List<String>.unmodifiable(_commandBatchErrors),
      );
    }

    try {
      await handler(enable);
    } catch (e) {
      _recordCommandFailure(
        key,
        reason: 'Unhandled tweak exception',
        details: e.toString(),
      );
    }

    return TweakApplyResult(
      success: !_commandBatchHasFailure,
      errors: List<String>.unmodifiable(_commandBatchErrors),
    );
  }

  Future<Map<String, bool>> detectCurrentTweakStates() async {
    final states = <String, bool>{for (final key in _handlers.keys) key: false};

    Future<bool> dwordEquals(
      String keyPath,
      String valueName,
      int expected,
    ) async {
      final currentValue = await RegistryManager.readDword(keyPath, valueName);
      if (currentValue == null) {
        return false;
      }
      return currentValue.toUnsigned(32) == expected.toUnsigned(32);
    }

    Future<bool> stringEquals(
      String keyPath,
      String valueName,
      String expected,
    ) async {
      final currentValue = await RegistryManager.readString(keyPath, valueName);
      if (currentValue == null) {
        return false;
      }
      return currentValue.trim().toLowerCase() == expected.toLowerCase();
    }

    const multimediaProfilePath =
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile';

    states['cpu_unparking'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Control\Power',
      'CoreParkingDisabled',
      1,
    );
    states['cpu_power_management'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling',
      'PowerThrottlingOff',
      1,
    );
    states['cpu_amd_optimizations'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
      'FeatureSettings',
      1,
    );

    states['gpu_nvidia_optimizations'] = await stringEquals(
      r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games',
      'Scheduling Category',
      'High',
    );
    states['gpu_amd_optimizations'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
      'PP_SclkDeepSleepDisable',
      1,
    );
    states['gpu_intel_optimizations'] = await dwordEquals(
      r'HKLM\SOFTWARE\Intel\Display\igfxcui\Media',
      'EnableIntelHWAccel',
      1,
    );

    states['ram_optimizations'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
      'DisablePagingExecutive',
      1,
    );
    states['storage_optimizations'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
      'NtfsDisableLastAccessUpdate',
      1,
    );

    states['network_optimizations'] = await dwordEquals(
      multimediaProfilePath,
      'NetworkThrottlingIndex',
      0xFFFFFFFF,
    );
    states['timer_latency'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel',
      'GlobalTimerResolutionRequests',
      1,
    );
    states['visual_effects'] = await dwordEquals(
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects',
      'VisualFXSetting',
      2,
    );
    states['system_responsiveness'] = await dwordEquals(
      multimediaProfilePath,
      'SystemResponsiveness',
      0,
    );

    states['telemetry_disable'] = await dwordEquals(
      r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
      'AllowTelemetry',
      0,
    );
    states['privacy_tracking'] = await dwordEquals(
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo',
      'Enabled',
      0,
    );
    states['services_disable'] = await dwordEquals(
      r'HKLM\SYSTEM\CurrentControlSet\Services\DPS',
      'Start',
      4,
    );

    // TODO: Check override with resources/interactive_scripts/6 Windows/14 Control Panel Settings.ps1
    states['ui_optimizations'] = await dwordEquals(
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Search',
      'SearchboxTaskbarMode',
      0,
    );
    states['explorer_optimizations'] = await dwordEquals(
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
      'HideFileExt',
      0,
    );
    states['notifications_minimal'] = await dwordEquals(
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications',
      'ToastEnabled',
      0,
    );

    states['game_mode'] = await dwordEquals(
      r'HKCU\System\GameConfigStore',
      'GameDVR_Enabled',
      0,
    );
    states['windows_update'] = await dwordEquals(
      r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU',
      'NoAutoRebootWithLoggedOnUsers',
      1,
    );

    return states;
  }

  Future<Set<String>> detectAggressiveBundledPowerPlans(
    String powerPlansDirectory,
  ) async {
    final directory = Directory(powerPlansDirectory);
    if (!await directory.exists()) {
      return <String>{};
    }

    final powFiles = await directory
        .list(followLinks: false)
        .where(
          (entity) =>
              entity is File && entity.path.toLowerCase().endsWith('.pow'),
        )
        .cast<File>()
        .toList();

    powFiles.sort(
      (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
    );

    final aggressivePlans = <String>{};

    for (final powFile in powFiles) {
      final importedGuid = await _importPowerPlanAndGetGuid(powFile.path);
      if (importedGuid == null) {
        continue;
      }

      try {
        final isAggressive = await _isPowerSchemeAggressive(importedGuid);
        if (isAggressive) {
          aggressivePlans.add(
            _extractPowerPlanBasename(powFile.path).toLowerCase(),
          );
        }
      } finally {
        await _deletePowerScheme(importedGuid);
      }
    }

    return aggressivePlans;
  }

  Future<String?> _importPowerPlanAndGetGuid(String powerPlanPath) async {
    final beforeImport = await _listPowerSchemeGuids();
    final importResult = await _runProcessLogged('powercfg', [
      '/import',
      powerPlanPath,
    ], runInShell: true);

    if (importResult.exitCode != 0) {
      await _loggingService.logWarning(
        'Failed to import power plan for detection: $powerPlanPath',
        source: 'TweakManager',
      );
      return null;
    }

    final afterImport = await _listPowerSchemeGuids();
    for (final guid in afterImport) {
      if (!beforeImport.contains(guid)) {
        return guid;
      }
    }

    return null;
  }

  Future<Set<String>> _listPowerSchemeGuids() async {
    final result = await _runProcessLogged('powercfg', [
      '/list',
    ], runInShell: true);
    if (result.exitCode != 0) {
      return <String>{};
    }

    return _powerSchemeGuidRegex
        .allMatches(result.stdout.toString())
        .map((match) => match.group(0)!.toLowerCase())
        .toSet();
  }

  Future<bool> _isPowerSchemeAggressive(String schemeGuid) async {
    final procMinimumValues = await _queryPowerSettingCurrentValues(
      schemeGuid,
      'PROCTHROTTLEMIN',
    );
    final coreParkingValues = await _queryPowerSettingCurrentValues(
      schemeGuid,
      'CPMINCORES',
    );

    return procMinimumValues.any((value) => value == 100) ||
        coreParkingValues.any((value) => value == 100);
  }

  Future<List<int>> _queryPowerSettingCurrentValues(
    String schemeGuid,
    String settingAlias,
  ) async {
    final result = await _runProcessLogged('powercfg', [
      '/query',
      schemeGuid,
      'sub_processor',
      settingAlias,
    ], runInShell: true);

    if (result.exitCode != 0) {
      return <int>[];
    }

    final output = result.stdout.toString();
    final lines = output.split(RegExp(r'\r?\n'));
    final values = <int>[];

    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      if (!lowerLine.contains('0x')) {
        continue;
      }

      if (!(lowerLine.contains('current') || lowerLine.contains('corrente'))) {
        continue;
      }

      final match = RegExp(r'0x([0-9a-fA-F]+)').firstMatch(line);
      if (match == null) {
        continue;
      }

      final parsedValue = int.tryParse(match.group(1)!, radix: 16);
      if (parsedValue != null) {
        values.add(parsedValue);
      }
    }

    if (values.isNotEmpty) {
      return values;
    }

    final fallbackMatches = RegExp(
      r'0x([0-9a-fA-F]{1,8})',
    ).allMatches(output).toList();
    if (fallbackMatches.length >= 2) {
      for (final match in fallbackMatches.sublist(fallbackMatches.length - 2)) {
        final parsedValue = int.tryParse(match.group(1)!, radix: 16);
        if (parsedValue != null) {
          values.add(parsedValue);
        }
      }
    }

    return values;
  }

  Future<void> _deletePowerScheme(String schemeGuid) async {
    await _runProcessLogged('powercfg', [
      '/delete',
      schemeGuid,
    ], runInShell: true);
  }

  String _extractPowerPlanBasename(String filePath) {
    final normalizedPath = filePath.replaceAll('\\', '/');
    final fileName = normalizedPath.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex <= 0) {
      return fileName;
    }

    return fileName.substring(0, dotIndex);
  }

  Map<String, Future<void> Function(bool)> get _handlers {
    return {
      'bcd_optimizations': _applyBcdOptimizations,
      'cpu_unparking': _applyCpuUnparking,
      'cpu_power_management': _applyCpuPowerManagement,
      'cpu_intel_optimizations': _applyIntelCpuOptimizations,
      'cpu_amd_optimizations': _applyAmdCpuOptimizations,
      'gpu_nvidia_optimizations': _applyNvidiaOptimizations,
      'gpu_amd_optimizations': _applyAmdOptimizations,
      'gpu_intel_optimizations': _applyIntelOptimizations,
      'ram_optimizations': _applyRamOptimizations,
      'storage_optimizations': _applyStorageOptimizations,
      'network_optimizations': _applyNetworkOptimizations,
      'timer_latency': _applyTimerLatency,
      'visual_effects': _applyVisualEffects,
      'system_responsiveness': _applySystemResponsiveness,
      'telemetry_disable': _applyTelemetryDisable,
      'privacy_tracking': _applyPrivacyTracking,
      // TODO: Check override with resources/interactive_scripts/8 Advanced/17 Services.ps1
      'services_disable': _applyServicesDisable,
      'ui_optimizations': _applyUiOptimizations,
      'explorer_optimizations': _applyExplorerOptimizations,
      'notifications_minimal': _applyNotificationsMinimal,
      'game_mode': _applyGameMode,
      'windows_update': _applyWindowsUpdate,
    };
  }

  Future<void> _applyBcdOptimizations(bool enable) async {
    if (enable) {
      await _runCommand('bcdedit /deletevalue useplatformclock');
      await _runCommand('bcdedit /set useplatformtick yes');
      await _runCommand('bcdedit /set tscsyncpolicy enhanced');
      await _runCommand('bcdedit /set configaccesspolicy Default');
      await _runCommand('bcdedit /set MSI Default');
      await _runCommand('bcdedit /set bootux disabled');
      await _runCommand('bcdedit /set quietboot yes');
    } else {
      await _runCommand('bcdedit /deletevalue useplatformtick');
      await _runCommand('bcdedit /deletevalue tscsyncpolicy');
      await _runCommand('bcdedit /deletevalue configaccesspolicy');
      await _runCommand('bcdedit /deletevalue MSI');
      await _runCommand('bcdedit /deletevalue bootux');
      await _runCommand('bcdedit /deletevalue quietboot');
    }
  }

  Future<void> _applyCpuUnparking(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Power',
        'CoreParkingDisabled',
        1,
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 100',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 100',
      );
      await _runCommand('powercfg -setactive scheme_current');
    } else {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Power',
        'CoreParkingDisabled',
        0,
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 0',
      );
      await _runCommand('powercfg -setactive scheme_current');
    }
  }

  Future<void> _applyCpuPowerManagement(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl',
        'Win32PrioritySeparation',
        0x00000026,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling',
        'PowerThrottlingOff',
        1,
      );
      await _runCommand(
        'powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100',
      );
      await _runCommand(
        'powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100',
      );
      await _runCommand('powercfg /setactive scheme_current');
    } else {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl',
        'Win32PrioritySeparation',
        0x00000002,
      );
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling',
        'PowerThrottlingOff',
      );
      await _runCommand(
        'powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 5',
      );
    }
  }

  Future<void> _applyIntelCpuOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'powercfg /setacvalueindex scheme_current sub_processor HETEROPOLICY 4',
      );
      await _runCommand('powercfg /setactive scheme_current');
    } else {
      await _runCommand(
        'powercfg /setacvalueindex scheme_current sub_processor HETEROPOLICY 0',
      );
      await _runCommand('powercfg /setactive scheme_current');
    }
  }

  Future<void> _applyAmdCpuOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'FeatureSettings',
        1,
      );
    } else {
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'FeatureSettings',
      );
    }
  }

  Future<void> _applyNvidiaOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games',
        'GPU Priority',
        8,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games',
        'Priority',
        6,
      );
      await _writeRegistryString(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games',
        'Scheduling Category',
        'High',
      );
      await _writeRegistryString(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games',
        'SFIO Priority',
        'High',
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'HwSchMode',
        2,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'TdrDelay',
        60,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'TdrDdiDelay',
        60,
      );
    } else {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'HwSchMode',
        1,
      );
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'TdrDelay',
      );
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'TdrDdiDelay',
      );
    }
  }

  Future<void> _applyAmdOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games',
        'GPU Priority',
        8,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'HwSchMode',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'TdrDelay',
        60,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'TdrDdiDelay',
        60,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'EnableUlps',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001',
        'EnableUlps',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'PP_SclkDeepSleepDisable',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'PP_ThermalAutoThrottlingEnable',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'DisableDRR',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'PP_MemClockDeepSleepDisable',
        1,
      );
    } else {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'EnableUlps',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001',
        'EnableUlps',
        1,
      );
    }
  }

  Future<void> _applyIntelOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games',
        'GPU Priority',
        8,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'HwSchMode',
        2,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'TdrDelay',
        60,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'Disable_OverlayDSQualityEnhancement',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'DpstEnable',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'KMD_EnableComputePreemption',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'KMD_FRTCEnable',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Intel\Display\igfxcui\Media',
        'EnableIntelHWAccel',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'PP_MemClockStateDisable',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'EnableASPM',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'EnableUlps',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Intel\Display\igfxcui\Media',
        'EnableDeepLink',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'EnableResizableBAR',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'ShaderCache',
        1,
      );
    } else {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000',
        'EnableUlps',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'HwSchMode',
        1,
      );
    }
  }

  Future<void> _applyRamOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'DisablePagingExecutive',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'LargeSystemCache',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'ClearPageFileAtShutdown',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters',
        'EnableSuperfetch',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters',
        'EnablePrefetcher',
        0,
      );
      await _runCommand('sc config "SysMain" start=disabled');
      await _runCommand('net stop "SysMain"');
    } else {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'DisablePagingExecutive',
        0,
      );
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'LargeSystemCache',
      );
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
        'ClearPageFileAtShutdown',
      );
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters',
        'EnableSuperfetch',
      );
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters',
        'EnablePrefetcher',
      );
      await _runCommand('sc config "SysMain" start=auto');
      await _runCommand('net start "SysMain"');
    }
  }

  Future<void> _applyStorageOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters',
        'EnableBootTrace',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        'NtfsDisableLastAccessUpdate',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        'NtfsDisable8dot3NameCreation',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        'NtfsMemoryUsage',
        2,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        'NtfsMftZoneReservation',
        1,
      );
      await _runCommand('fsutil behavior set disablecompression 1');
      await _runCommand('fsutil behavior set encryptpagingfile 0');
      await _runCommand('fsutil behavior set DisableDeleteNotify 0');
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device',
        'EnableHIPM',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device',
        'EnableDIPM',
        0,
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_PCIEXPRESS ASPM 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_PCIEXPRESS ASPM 0',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_USB USBSELECTIVE 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_USB USBSELECTIVE 0',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_DISK DISKIDLE 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_DISK DISKIDLE 0',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 1',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 1',
      );
      await _runCommand('powercfg -setactive scheme_current');
    } else {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        'NtfsDisableLastAccessUpdate',
        0,
      );
      await _runCommand('fsutil behavior set DisableDeleteNotify 1');
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_PCIEXPRESS ASPM 1',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_PCIEXPRESS ASPM 1',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_USB USBSELECTIVE 1',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_USB USBSELECTIVE 1',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_DISK DISKIDLE 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_DISK DISKIDLE 0',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 0',
      );
      await _runCommand('powercfg -setactive scheme_current');
    }
  }

  Future<void> _applyNetworkOptimizations(bool enable) async {
    const multimediaProfilePath =
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile';
    const tcpipParametersPath =
        r'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters';
    const kernelSessionManagerPath =
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel';

    if (enable) {
      await _writeRegistryDword(
        multimediaProfilePath,
        'NetworkThrottlingIndex',
        0xFFFFFFFF,
      );
      await _writeRegistryDword(
        multimediaProfilePath,
        'SystemResponsiveness',
        0,
      );
      await _writeRegistryDword(tcpipParametersPath, 'TcpAckFrequency', 1);
      await _writeRegistryDword(tcpipParametersPath, 'TCPNoDelay', 1);
      await _writeRegistryDword(tcpipParametersPath, 'Tcp1323Opts', 1);
      await _writeRegistryDword(tcpipParametersPath, 'TcpMaxDupAcks', 2);
      await _writeRegistryDword(
        kernelSessionManagerPath,
        'DpcWatchdogProfileOffset',
        10000,
      );
      await _writeRegistryDword(kernelSessionManagerPath, 'DpcTimeout', 0);
    } else {
      await _writeRegistryDword(
        multimediaProfilePath,
        'NetworkThrottlingIndex',
        10,
      );
      await _writeRegistryDword(
        multimediaProfilePath,
        'SystemResponsiveness',
        20,
      );
      await _deleteRegistryValue(tcpipParametersPath, 'TcpAckFrequency');
      await _deleteRegistryValue(tcpipParametersPath, 'TCPNoDelay');
      await _deleteRegistryValue(tcpipParametersPath, 'Tcp1323Opts');
      await _deleteRegistryValue(tcpipParametersPath, 'TcpMaxDupAcks');
      await _deleteRegistryValue(
        kernelSessionManagerPath,
        'DpcWatchdogProfileOffset',
      );
      await _deleteRegistryValue(kernelSessionManagerPath, 'DpcTimeout');
    }
  }

  Future<void> _applyTimerLatency(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel',
        'GlobalTimerResolutionRequests',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'NoLazyMode',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'AlwaysOn',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'LazyModeTimeout',
        10000,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio',
        'Affinity',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio',
        'GPU Priority',
        8,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio',
        'Priority',
        6,
      );
    } else {
      await _deleteRegistryValue(
        r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel',
        'GlobalTimerResolutionRequests',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'NoLazyMode',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'AlwaysOn',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'LazyModeTimeout',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio',
        'Affinity',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio',
        'GPU Priority',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio',
        'Priority',
      );
    }
  }

  Future<void> _applyVisualEffects(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects',
        'VisualFXSetting',
        2,
      );
      await _writeRegistryBinary(
        r'HKCU\Control Panel\Desktop',
        'UserPreferencesMask',
        '9012038010000000',
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop\WindowMetrics',
        'MinAnimate',
        '0',
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'TaskbarAnimations',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'ListviewAlphaSelect',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'ListviewShadow',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\DWM',
        'EnableAeroPeek',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\DWM',
        'AlwaysHibernateThumbnails',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize',
        'EnableTransparency',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DWM',
        'DisallowAnimations',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'DisallowShaking',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'EnableBalloonTips',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize',
        'ColorPrevalence',
        0,
      );
    } else {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects',
        'VisualFXSetting',
        0,
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop\WindowMetrics',
        'MinAnimate',
        '1',
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize',
        'EnableTransparency',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'DisallowShaking',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'EnableBalloonTips',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize',
        'ColorPrevalence',
        1,
      );
    }
  }

  Future<void> _applySystemResponsiveness(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'SystemResponsiveness',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'NetworkThrottlingIndex',
        4294967295,
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop',
        'MenuShowDelay',
        '0',
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop',
        'WaitToKillAppTimeout',
        '2000',
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop',
        'HungAppTimeout',
        '1000',
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop',
        'AutoEndTasks',
        '1',
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop',
        'LowLevelHooksTimeout',
        '1000',
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Mouse',
        'MouseHoverTime',
        '10',
      );
      await _writeRegistryString(
        r'HKLM\SYSTEM\CurrentControlSet\Control',
        'WaitToKillServiceTimeout',
        '2000',
      );
    } else {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'SystemResponsiveness',
        20,
      );
      await _writeRegistryString(
        r'HKCU\Control Panel\Desktop',
        'MenuShowDelay',
        '400',
      );
    }
  }

  Future<void> _applyUiOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Search',
        'SearchboxTaskbarMode',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'ShowTaskViewButton',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'TaskbarDa',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'TaskbarMn',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Dsh',
        'AllowNewsAndInterests',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager',
        'SubscribedContent-338388Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager',
        'SubscribedContent-338389Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        'HideSCAMeetNow',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds',
        'ShellFeedsTaskbarViewMode',
        2,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People',
        'PeopleBand',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'TaskbarBadges',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'TaskbarGlomLevel',
        2,
      );
    } else {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Search',
        'SearchboxTaskbarMode',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'ShowTaskViewButton',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        'HideSCAMeetNow',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds',
        'ShellFeedsTaskbarViewMode',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People',
        'PeopleBand',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'TaskbarBadges',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'TaskbarGlomLevel',
        0,
      );
    }
  }

  Future<void> _applyExplorerOptimizations(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'HideFileExt',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'Hidden',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'ShowSuperHidden',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'SeparateProcess',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'LaunchTo',
        1,
      );
      await _writeRegistryString(
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer',
        'Max Cached Icons',
        '4096',
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'DisableThumbnailCache',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer',
        'DisableThumbsDBOnNetworkFolders',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer',
        'ShowFrequent',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer',
        'ShowRecent',
        0,
      );
    } else {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'HideFileExt',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'Hidden',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer',
        'ShowFrequent',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer',
        'ShowRecent',
        1,
      );
    }
  }

  Future<void> _applyTelemetryDisable(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
        'AllowTelemetry',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
        'AllowTelemetry',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
        'AllowTelemetry',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat',
        'AITEnable',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat',
        'DisableInventory',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat',
        'DisableUAR',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener',
        'Start',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack',
        'Start',
        4,
      );
      await _writeRegistryDword(
        r'HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice',
        'Start',
        4,
      );
      await _runCommand('sc config DiagTrack start=disabled');
      await _runCommand('sc config dmwappushservice start=disabled');
      await _runCommand('sc config WerSvc start=disabled');
      await _runCommand('sc stop DiagTrack');
      await _runCommand('sc stop dmwappushservice');
      await _runCommand('sc stop WerSvc');
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\System',
        'EnableActivityFeed',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\System',
        'PublishUserActivities',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\System',
        'UploadUserActivities',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting',
        'Disabled',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows',
        'CEIPEnable',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\SQMClient',
        'CEIPEnable',
        0,
      );
    } else {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
        'AllowTelemetry',
        3,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
        'AllowTelemetry',
        3,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
        'AllowTelemetry',
        3,
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting',
        'Disabled',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows',
        'CEIPEnable',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Policies\Microsoft\SQMClient',
        'CEIPEnable',
      );
      await _runCommand('sc config DiagTrack start=auto');
      await _runCommand('sc config dmwappushservice start=demand');
      await _runCommand('sc config WerSvc start=demand');
    }
  }

  Future<void> _applyPrivacyTracking(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo',
        'Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo',
        'DisabledByGroupPolicy',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy',
        'TailoredExperiencesWithDiagnosticDataEnabled',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors',
        'DisableLocation',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots',
        'value',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Siuf\Rules',
        'NumberOfSIUFInPeriod',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Siuf\Rules',
        'PeriodInNanoSeconds',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search',
        'AllowCortana',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search',
        'AllowCloudSearch',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications',
        'GlobalUserDisabled',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync',
        'SyncPolicy',
        5,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization',
        'Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings',
        'Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials',
        'Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language',
        'Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility',
        'Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows',
        'Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'Start_TrackProgs',
        0,
      );
    } else {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo',
        'Enabled',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors',
        'DisableLocation',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications',
        'GlobalUserDisabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync',
        'SyncPolicy',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        'Start_TrackProgs',
        1,
      );
    }
  }

  Future<void> _applyServicesDisable(bool enable) async {
    if (enable) {
      await _runCommand('sc config DiagTrack start=disabled');
      await _runCommand('sc config dmwappushservice start=disabled');
      await _runCommand('sc config WerSvc start=disabled');
      await _runCommand('sc config DPS start=disabled');
      await _runCommand('sc config WdiServiceHost start=disabled');
      await _runCommand('sc config WdiSystemHost start=disabled');
      await _runCommand('sc stop DiagTrack');
      await _runCommand('sc stop dmwappushservice');
      await _runCommand('sc stop WerSvc');
      await _runCommand('sc stop DPS');
      await _runCommand('sc stop WdiServiceHost');
      await _runCommand('sc stop WdiSystemHost');
    } else {
      await _runCommand('sc config DiagTrack start=auto');
      await _runCommand('sc config dmwappushservice start=demand');
      await _runCommand('sc config WerSvc start=demand');
      await _runCommand('sc config DPS start=auto');
      await _runCommand('sc config WdiServiceHost start=demand');
      await _runCommand('sc config WdiSystemHost start=demand');
    }
  }

  Future<void> _applyNotificationsMinimal(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications',
        'ToastEnabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings',
        'NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings',
        'NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings',
        'NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount',
        'IsActionCenterQuietHoursEnabled',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount',
        'FocusAssistAutoRules',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance',
        'Enabled',
        0,
      );
    } else {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications',
        'ToastEnabled',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings',
        'NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings',
        'NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK',
        1,
      );
    }
  }

  Future<void> _applyGameMode(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\GameBar',
        'AutoGameModeEnabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\GameBar',
        'AllowAutoGameMode',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\GameBar',
        'UseNexusForGameBarEnabled',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\System\GameConfigStore',
        'GameDVR_Enabled',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR',
        'AllowGameDVR',
        0,
      );
    } else {
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\GameBar',
        'AutoGameModeEnabled',
        1,
      );
      await _writeRegistryDword(
        r'HKCU\System\GameConfigStore',
        'GameDVR_Enabled',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR',
        'AllowGameDVR',
        1,
      );
    }
  }

  Future<void> _applyWindowsUpdate(bool enable) async {
    if (enable) {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU',
        'NoAutoRebootWithLoggedOnUsers',
        1,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU',
        'AUPowerManagement',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config',
        'DODownloadMode',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization',
        'DODownloadMode',
        0,
      );
      await _writeRegistryDword(
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization',
        'SystemSettingsDownloadMode',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings',
        'DownloadMode',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization',
        'PercentageMaxBackgroundBandwidth',
        50,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization',
        'PercentageMaxForegroundBandwidth',
        50,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching',
        'SearchOrderConfig',
        0,
      );
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate',
        'ExcludeWUDriversInQualityUpdate',
        1,
      );
      await _runCommand('sc config wuauserv start=demand');
    } else {
      await _writeRegistryDword(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU',
        'NoAutoRebootWithLoggedOnUsers',
        0,
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching',
        'SearchOrderConfig',
      );
      await _deleteRegistryValue(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate',
        'ExcludeWUDriversInQualityUpdate',
      );
      await _runCommand('sc config wuauserv start=auto');
    }
  }

  Future<void> _runRegistryOperation(
    Future<void> Function() operation,
    String operationName,
  ) async {
    try {
      await operation();
    } on RegistryException catch (e) {
      _recordCommandFailure(
        operationName,
        reason: e.message,
        details: e.exitCode != null ? 'exitCode=${e.exitCode}' : null,
      );
    }
  }

  Future<void> _writeRegistryDword(
    String keyPath,
    String valueName,
    int value,
  ) async {
    await _runRegistryOperation(
      () => RegistryManager.writeDword(keyPath, valueName, value),
      '$keyPath/$valueName',
    );
  }

  Future<void> _writeRegistryString(
    String keyPath,
    String valueName,
    String value,
  ) async {
    await _runRegistryOperation(
      () => RegistryManager.writeString(keyPath, valueName, value),
      '$keyPath/$valueName',
    );
  }

  Future<void> _writeRegistryBinary(
    String keyPath,
    String valueName,
    String hexValue,
  ) async {
    await _runRegistryOperation(
      () => RegistryManager.writeBinary(keyPath, valueName, hexValue),
      '$keyPath/$valueName',
    );
  }

  Future<void> _deleteRegistryValue(String keyPath, String valueName) async {
    await _runRegistryOperation(
      () => RegistryManager.deleteValue(keyPath, valueName),
      '$keyPath/$valueName',
    );
  }

  Future<void> _runPowerShellScript(String script, String operationName) async {
    try {
      final result = await _runProcessLogged('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ], runInShell: true);

      if (result.exitCode != 0) {
        await _loggingService.logError(
          'PowerShell failed: $operationName | ${result.stderr}',
          source: 'TweakManager',
        );
        _recordCommandFailure(operationName, result: result);
      }
    } catch (e) {
      await _loggingService.logError(
        'PowerShell exception for $operationName: $e',
        source: 'TweakManager',
      );
      _recordCommandFailure(
        operationName,
        reason: 'Exception while running PowerShell script',
        details: e.toString(),
      );
    }
  }

  Future<void> _runCommand(String command) async {
    try {
      final result = await _runProcessLogged('cmd', [
        '/c',
        command,
      ], runInShell: true);

      if (result.exitCode != 0) {
        await _loggingService.logError(
          'Command failed: $command | ${result.stderr}',
          source: 'TweakManager',
        );
        if (!_isIgnorableCommandFailure(command, result)) {
          _recordCommandFailure(command, result: result);
        }
      }
    } catch (e) {
      await _loggingService.logError(
        'Exception running command "$command": $e',
        source: 'TweakManager',
      );
      _recordCommandFailure(
        command,
        reason: 'Exception while running command',
        details: e.toString(),
      );
    }
  }

  void _resetCommandBatch() {
    _commandBatchHasFailure = false;
    _commandBatchErrors.clear();
  }

  void _recordCommandFailure(
    String command, {
    CommandResult? result,
    String? reason,
    String? details,
  }) {
    _commandBatchHasFailure = true;

    if (result != null) {
      final stderr = result.stderr.toString().trim();
      final stdout = result.stdout.toString().trim();
      final outputDetails = stderr.isNotEmpty ? stderr : stdout;
      _commandBatchErrors.add(
        '[$command] exitCode=${result.exitCode}${outputDetails.isNotEmpty ? ' | $outputDetails' : ''}',
      );
      return;
    }

    _commandBatchErrors.add(
      '[$command] ${reason ?? 'Unknown failure'}${details != null && details.isNotEmpty ? ' | $details' : ''}',
    );
  }

  bool _isIgnorableCommandFailure(String command, CommandResult result) {
    final cmd = command.toLowerCase();
    final stderr = result.stderr.toString().toLowerCase();
    final stdout = result.stdout.toString().toLowerCase();
    final output = '$stderr\n$stdout';

    if (cmd.startsWith('reg delete') && result.exitCode == 1) {
      if (output.contains('unable to find') ||
          output.contains('non trovato') ||
          output.contains('impossibile trovare')) {
        return true;
      }
    }

    if (cmd.startsWith('sc stop') &&
        (output.contains('has not been started') ||
            output.contains('service has not been started') ||
            output.contains('1062'))) {
      return true;
    }

    if (cmd.startsWith('net stop') &&
        (output.contains('service is not started') ||
            output.contains('non') && output.contains('avviato'))) {
      return true;
    }

    if (cmd.startsWith('bcdedit /deletevalue') &&
        (output.contains('not found') || output.contains('impossibile'))) {
      return true;
    }

    return false;
  }

  Future<CommandResult> _runProcessLogged(
    String executable,
    List<String> arguments, {
    bool runInShell = true,
  }) async {
    return _processRunner.run(
      executable,
      arguments,
      runInShell: runInShell,
      timeout: const Duration(minutes: 2),
    );
  }

  Future<void> applyMsiMode(bool enable) async {
    await _runPowerShellScript(
      enable ? _msiEnableScript : _msiDisableScript,
      enable ? 'msi_enable' : 'msi_disable',
    );
  }
}
