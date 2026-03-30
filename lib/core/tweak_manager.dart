import 'dart:io';

import 'package:flutter/foundation.dart';

class TweakApplyResult {
  const TweakApplyResult({required this.success, required this.errors});

  final bool success;
  final List<String> errors;
}

class TweakManager {
  TweakManager();

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
    final importResult = await Process.run('powercfg', [
      '/import',
      powerPlanPath,
    ], runInShell: true);

    if (importResult.exitCode != 0) {
      debugPrint('Failed to import power plan for detection: $powerPlanPath');
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
    final result = await Process.run('powercfg', ['/list'], runInShell: true);
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
    final result = await Process.run('powercfg', [
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
    await Process.run('powercfg', ['/delete', schemeGuid], runInShell: true);
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
      'services_disable': _applyServicesDisable,
      'ui_optimizations': _applyUiOptimizations,
      'explorer_optimizations': _applyExplorerOptimizations,
      'notifications_minimal': _applyNotificationsMinimal,
      'game_mode': _applyGameMode,
      'flip_model_optimizations': _applyFlipModelOptimizations,
      'disable_mpo': _applyDisableMpo,
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
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMax" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMin" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\ControlSet001\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power" /v "CoreParkingDisabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 4',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 100',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100',
      );
      await _runCommand('powercfg -setactive scheme_current');
    } else {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power" /v "CoreParkingDisabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 0',
      );
      await _runCommand(
        'powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 0',
      );
      await _runCommand(
        'powercfg -setdcvalueindex scheme_current sub_processor PROCTHROTTLEMIN 0',
      );
      await _runCommand('powercfg -setactive scheme_current');
    }
  }

  Future<void> _applyCpuPowerManagement(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "0x00000026" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100',
      );
      await _runCommand(
        'powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100',
      );
      await _runCommand('powercfg /setactive scheme_current');
    } else {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "0x00000002" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerThrottling" /v "PowerThrottlingOff" /f',
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
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f',
      );
    } else {
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "FeatureSettings" /f',
      );
    }
  }

  Future<void> _applyNvidiaOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "Priority" /t REG_DWORD /d "6" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d "60" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDdiDelay" /f',
      );
    }
  }

  Future<void> _applyAmdOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d "60" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0001" /v "EnableUlps" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "DisableDRR" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_MemClockDeepSleepDisable" /t REG_DWORD /d "1" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0001" /v "EnableUlps" /t REG_DWORD /d "1" /f',
      );
    }
  }

  Future<void> _applyIntelOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "Disable_OverlayDSQualityEnhancement" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "DpstEnable" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "KMD_EnableComputePreemption" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "KMD_FRTCEnable" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Intel\\Display\\igfxcui\\Media" /v "EnableIntelHWAccel" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_MemClockStateDisable" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableASPM" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Intel\\Display\\igfxcui\\Media" /v "EnableDeepLink" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableResizableBAR" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "ShaderCache" /t REG_DWORD /d "1" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f',
      );
    }
  }

  Future<void> _applyRamOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f',
      );
      await _runCommand('sc config "SysMain" start=disabled');
      await _runCommand('net stop "SysMain"');
    } else {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "LargeSystemCache" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "ClearPageFileAtShutdown" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnableSuperfetch" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnablePrefetcher" /f',
      );
      await _runCommand('sc config "SysMain" start=auto');
      await _runCommand('net start "SysMain"');
    }
  }

  Future<void> _applyStorageOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "2" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d "1" /f',
      );
      await _runCommand('fsutil behavior set disablecompression 1');
      await _runCommand('fsutil behavior set encryptpagingfile 0');
      await _runCommand('fsutil behavior set DisableDeleteNotify 0');
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\storahci\\Parameters\\Device" /v "EnableHIPM" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\storahci\\Parameters\\Device" /v "EnableDIPM" /t REG_DWORD /d "0" /f',
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
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "0" /f',
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
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "0xffffffff" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d "2" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "DpcWatchdogProfileOffset" /t REG_DWORD /d "10000" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "DpcTimeout" /t REG_DWORD /d "0" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "10" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "20" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TcpAckFrequency" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TCPNoDelay" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "Tcp1323Opts" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TcpMaxDupAcks" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "DpcWatchdogProfileOffset" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "DpcTimeout" /f',
      );
    }
  }

  Future<void> _applyTimerLatency(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d "10000" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "Affinity" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "GPU Priority" /t REG_DWORD /d "8" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "Priority" /t REG_DWORD /d "6" /f',
      );
    } else {
      await _runCommand(
        'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "GlobalTimerResolutionRequests" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NoLazyMode" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "AlwaysOn" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "LazyModeTimeout" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "Affinity" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "GPU Priority" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "Priority" /f',
      );
    }
  }

  Future<void> _applyVisualEffects(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "2" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ListviewShadow" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DWM" /v "DisallowAnimations" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "0" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "DisallowShaking" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "1" /f',
      );
    }
  }

  Future<void> _applySystemResponsiveness(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "4294967295" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop" /v "LowLevelHooksTimeout" /t REG_SZ /d "1000" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Mouse" /v "MouseHoverTime" /t REG_SZ /d "10" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "20" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Control Panel\\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f',
      );
    }
  }

  Future<void> _applyUiOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarDa" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\People" /v "PeopleBand" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarBadges" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d "2" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\People" /v "PeopleBand" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarBadges" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d "0" /f',
      );
    }
  }

  Future<void> _applyExplorerOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Hidden" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "SeparateProcess" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "Max Cached Icons" /t REG_SZ /d "4096" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "DisableThumbnailCache" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer" /v "DisableThumbsDBOnNetworkFolders" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "HideFileExt" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Hidden" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowFrequent" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowRecent" /t REG_DWORD /d "1" /f',
      );
    }
  }

  Future<void> _applyTelemetryDisable(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\WMI\\Autologger\\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f',
      );
      await _runCommand('sc config DiagTrack start=disabled');
      await _runCommand('sc config dmwappushservice start=disabled');
      await _runCommand('sc config WerSvc start=disabled');
      await _runCommand('sc stop DiagTrack');
      await _runCommand('sc stop dmwappushservice');
      await _runCommand('sc stop WerSvc');
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\SQMClient\\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\SQMClient" /v "CEIPEnable" /t REG_DWORD /d "0" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting" /v "Disabled" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Policies\\Microsoft\\SQMClient\\Windows" /v "CEIPEnable" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Policies\\Microsoft\\SQMClient" /v "CEIPEnable" /f',
      );
      await _runCommand('sc config DiagTrack start=auto');
      await _runCommand('sc config dmwappushservice start=demand');
      await _runCommand('sc config WerSvc start=demand');
    }
  }

  Future<void> _applyPrivacyTracking(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\default\\WiFi\\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Siuf\\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Siuf\\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Language" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Windows" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "1" /f',
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
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\CloudStore\\Store\\Cache\\DefaultAccount" /v "IsActionCenterQuietHoursEnabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\CloudStore\\Store\\Cache\\DefaultAccount" /v "FocusAssistAutoRules" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings\\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d "0" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "1" /f',
      );
    }
  }

  Future<void> _applyGameMode(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d "0" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d "1" /f',
      );
    }
  }

  Future<void> _applyFlipModelOptimizations(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg delete "HKCU\\System\\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /f',
      );
      await _runCommand(
        'reg delete "HKCU\\System\\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /f',
      );
      await _runCommand(
        'reg delete "HKCU\\System\\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /f',
      );
      await _runCommand(
        'reg delete "HKCU\\System\\GameConfigStore" /v "GameDVR_DSEBehavior" /f',
      );
      await _runCommand(
        'reg delete "HKCU\\System\\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f',
      );
    } else {
      await _runCommand(
        'reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f',
      );
      await _runCommand(
        'reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f',
      );
    }
  }

  Future<void> _applyDisableMpo(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\Dwm" /v "OverlayTestMode" /t REG_DWORD /d 5 /f',
      );
    } else {
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows\\Dwm" /v "OverlayTestMode" /f',
      );
    }
  }

  Future<void> _applyWindowsUpdate(bool enable) async {
    if (enable) {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "1" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU" /v "AUPowerManagement" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\DeliveryOptimization\\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\DeliveryOptimization\\Settings" /v "DownloadMode" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeliveryOptimization" /v "PercentageMaxBackgroundBandwidth" /t REG_DWORD /d "50" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeliveryOptimization" /v "PercentageMaxForegroundBandwidth" /t REG_DWORD /d "50" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f',
      );
      await _runCommand('sc config wuauserv start=demand');
    } else {
      await _runCommand(
        'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "0" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DriverSearching" /v "SearchOrderConfig" /f',
      );
      await _runCommand(
        'reg delete "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /f',
      );
      await _runCommand('sc config wuauserv start=auto');
    }
  }

  Future<void> _runPowerShellScript(String script, String operationName) async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ], runInShell: true);

      if (result.exitCode != 0) {
        debugPrint('PowerShell failed: $operationName');
        debugPrint('Error: ${result.stderr}');
        _recordCommandFailure(operationName, result: result);
      }
    } catch (e) {
      debugPrint('PowerShell exception: $e');
      _recordCommandFailure(
        operationName,
        reason: 'Exception while running PowerShell script',
        details: e.toString(),
      );
    }
  }

  Future<void> _runCommand(String command) async {
    try {
      final result = await Process.run('cmd', [
        '/c',
        command,
      ], runInShell: true);

      if (result.exitCode != 0) {
        debugPrint('Command failed: $command');
        debugPrint('Error: ${result.stderr}');
        if (!_isIgnorableCommandFailure(command, result)) {
          _recordCommandFailure(command, result: result);
        }
      }
    } catch (e) {
      debugPrint('Exception running command: $e');
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
    ProcessResult? result,
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

  bool _isIgnorableCommandFailure(String command, ProcessResult result) {
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

  Future<void> applyMsiMode(bool enable) async {
    await _runPowerShellScript(
      enable ? _msiEnableScript : _msiDisableScript,
      enable ? 'msi_enable' : 'msi_disable',
    );
  }
}
