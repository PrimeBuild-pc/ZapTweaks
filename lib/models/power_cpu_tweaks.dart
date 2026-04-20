import 'dart:convert';
import 'dart:typed_data';

import '../core/registry_manager.dart';
import '../core/services/process_runner.dart';
import 'system_tweak.dart';

List<SystemTweak> createPowerCpuTweaks() {
  return <SystemTweak>[
    UltimatePerformancePlanTweak(),
    FastStartupHibernateTweak(),
    PowerThrottlingTweak(),
    CpuCoreParkingTweak(),
    ProcessorPerformanceBoostModeTweak(),
    MinProcessorStateTweak(),
    MaxProcessorStateTweak(),
    SystemResponsivenessRegistryTweak(),
    CpuIdlePromoteDemoteTweak(),
    ProcessorTimeCheckIntervalTweak(),
    DisableCStatesTweak(),
    Win32PrioritySeparationTweak(),
    DisableDynamicTickTweak(),
    TscSyncPolicyTweak(),
    GlobalTimerResolutionRequestsTweak(),
    HardwarePStatesTweak(),
    AmdPreferredCoresTweak(),
  ];
}

abstract class _PowerCpuSystemTweak extends SystemTweak {
  _PowerCpuSystemTweak({
    required super.id,
    required super.title,
    required super.description,
    super.isAggressive,
    super.warningMessage,
    super.requiredCpuVendor,
  }) : super(category: 'Power & CPU');

  Future<void> runSilentPowerShell(
    String script, {
    bool elevated = false,
  }) async {
    final encodedScript = _encodePowerShellScript(script);
    final List<String> arguments;

    if (elevated) {
      final elevateCommand =
          "Start-Process -FilePath 'powershell.exe' -Verb RunAs -WindowStyle Hidden -Wait -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-EncodedCommand','${encodedScript.replaceAll("'", "''")}')";

      arguments = <String>[
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-Command',
        elevateCommand,
      ];
    } else {
      arguments = <String>[
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-EncodedCommand',
        encodedScript,
      ];
    }

    final result = await ProcessRunner.shared.run('powershell', arguments);

    if (result.exitCode != 0) {
      final stderr = result.stderr.trim();
      final stdout = result.stdout.trim();
      final details = stderr.isNotEmpty
          ? stderr
          : (stdout.isNotEmpty ? stdout : 'Unknown PowerShell error');
      throw Exception(details);
    }
  }

  Future<String> runPowerShellForOutput(String script) async {
    final encodedScript = _encodePowerShellScript(script);
    final result = await ProcessRunner.shared.run('powershell', <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-WindowStyle',
      'Hidden',
      '-EncodedCommand',
      encodedScript,
    ]);

    if (result.exitCode != 0) {
      final stderr = result.stderr.trim();
      final stdout = result.stdout.trim();
      final details = stderr.isNotEmpty
          ? stderr
          : (stdout.isNotEmpty ? stdout : 'Unknown PowerShell error');
      throw Exception(details);
    }

    return result.stdout.trim();
  }

  Future<String> _getActiveScheme() async {
    final output = await runPowerShellForOutput(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') { $matches[1] }
''');
    return output.trim().toLowerCase();
  }

  Future<int?> _readPowercfgAcValue(String alias) async {
    final scheme = await _getActiveScheme();
    if (scheme.isEmpty) {
      return null;
    }

    final output = await runPowerShellForOutput(
      'powercfg /query $scheme sub_processor $alias',
    );
    final match = RegExp(
      r'Current\s+AC\s+Power\s+Setting\s+Index:\s+0x([0-9a-fA-F]+)',
      caseSensitive: false,
    ).firstMatch(output);

    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1)!, radix: 16);
  }

  String _encodePowerShellScript(String script) {
    final units = script.codeUnits;
    final bytes = Uint8List(units.length * 2);
    for (var i = 0; i < units.length; i++) {
      final unit = units[i];
      bytes[i * 2] = unit & 0xFF;
      bytes[i * 2 + 1] = (unit >> 8) & 0xFF;
    }
    return base64Encode(bytes);
  }
}

class UltimatePerformancePlanTweak extends _PowerCpuSystemTweak {
  UltimatePerformancePlanTweak()
    : super(
        id: 'power_ultimate_performance_plan',
        title: 'Ultimate Performance Power Plan',
        description:
            'Imports and activates Ultimate Performance. Revert switches back to Balanced.',
      );

  static const String _sourceUltimateGuid =
      'e9a42b02-d5df-448d-aa00-03f14749eb61';
  static const String _customUltimateGuid =
      '99999999-9999-9999-9999-999999999999';
  static const String _balancedGuid = '381b4222-f694-41f0-9685-ff5bb260df2e';

  @override
  Future<void> onApply() async {
    final script =
        r'''
$ultimateGuid = '__ULTIMATE_GUID__'
$baseGuid = '__BASE_GUID__'
$schemes = (powercfg /L | Out-String).ToLower()

if (-not $schemes.Contains($ultimateGuid)) {
  powercfg /duplicatescheme $baseGuid $ultimateGuid | Out-Null
}

powercfg /setactive $ultimateGuid | Out-Null
'''
            .replaceAll('__ULTIMATE_GUID__', _customUltimateGuid.toLowerCase())
            .replaceAll('__BASE_GUID__', _sourceUltimateGuid.toLowerCase());

    await runSilentPowerShell(script, elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    final script =
        r'''
$ultimateGuid = '__ULTIMATE_GUID__'
$balancedGuid = '__BALANCED_GUID__'
$schemes = (powercfg /L | Out-String).ToLower()

if ($schemes.Contains($balancedGuid)) {
  powercfg /setactive $balancedGuid | Out-Null
}

if ($schemes.Contains($ultimateGuid)) {
  powercfg /delete $ultimateGuid | Out-Null
}
'''
            .replaceAll('__ULTIMATE_GUID__', _customUltimateGuid.toLowerCase())
            .replaceAll('__BALANCED_GUID__', _balancedGuid.toLowerCase());

    await runSilentPowerShell(script, elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final active = (await runPowerShellForOutput(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $matches[1]
}
''')).toLowerCase();

    final applied = active == _customUltimateGuid;
    isApplied = applied;
    return applied;
  }
}

class FastStartupHibernateTweak extends _PowerCpuSystemTweak {
  FastStartupHibernateTweak()
    : super(
        id: 'power_fast_startup_hibernate_off',
        title: 'Fast Startup and Hibernate Off',
        description:
            'Disables hibernate and Fast Startup for lower latency and cleaner shutdown behavior.',
      );

  static const String _powerKey =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Power';
  static const String _sessionPowerKey =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power';

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(
      'powercfg /hibernate off | Out-Null',
      elevated: true,
    );
    await RegistryManager.writeDword(_powerKey, 'HibernateEnabled', 0);
    await RegistryManager.writeDword(_powerKey, 'HibernateEnabledDefault', 0);
    await RegistryManager.writeDword(_sessionPowerKey, 'HiberbootEnabled', 0);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(
      'powercfg /hibernate on | Out-Null',
      elevated: true,
    );

    final hibernateEnabled = await RegistryManager.readDword(
      _powerKey,
      'HibernateEnabled',
    );
    if (hibernateEnabled != null) {
      await RegistryManager.deleteValue(_powerKey, 'HibernateEnabled');
    }

    await RegistryManager.writeDword(_powerKey, 'HibernateEnabledDefault', 1);
    await RegistryManager.writeDword(_sessionPowerKey, 'HiberbootEnabled', 1);
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final hibernateDefault = await RegistryManager.readDword(
      _powerKey,
      'HibernateEnabledDefault',
    );
    final fastStartup = await RegistryManager.readDword(
      _sessionPowerKey,
      'HiberbootEnabled',
    );

    final applied = hibernateDefault == 0 && fastStartup == 0;
    isApplied = applied;
    return applied;
  }
}

class PowerThrottlingTweak extends SystemTweak {
  PowerThrottlingTweak()
    : super(
        id: 'power_throttling_off',
        title: 'Power Throttling Off',
        description:
            'Disables Windows power throttling for more consistent CPU scheduling under load.',
        category: 'Power & CPU',
      );

  static const String _keyPath =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_keyPath, 'PowerThrottlingOff', 1);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    final current = await RegistryManager.readDword(
      _keyPath,
      'PowerThrottlingOff',
    );
    if (current != null) {
      await RegistryManager.deleteValue(_keyPath, 'PowerThrottlingOff');
    }
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _keyPath,
      'PowerThrottlingOff',
    );
    final applied = current == 1;
    isApplied = applied;
    return applied;
  }
}

class CpuCoreParkingTweak extends _PowerCpuSystemTweak {
  CpuCoreParkingTweak()
    : super(
        id: 'power_cpu_core_parking_off',
        title: 'CPU Core Parking Off',
        description:
            'Unhides and sets active plan core parking min/max cores to 100%.',
      );

  static const String _minCoreAttributesKey =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583';
  static const String _maxCoreAttributesKey =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\ea062031-0e34-4ff1-9b6d-eb1059334028';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_minCoreAttributesKey, 'Attributes', 0);
    await RegistryManager.writeDword(_maxCoreAttributesKey, 'Attributes', 0);

    await runSilentPowerShell(r'''
    $line = powercfg /getactivescheme | Out-String
    if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor CPMINCORES 100 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor CPMINCORES 100 | Out-Null
  powercfg /setacvalueindex $scheme sub_processor CPMAXCORES 100 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor CPMAXCORES 100 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_minCoreAttributesKey, 'Attributes', 1);
    await RegistryManager.writeDword(_maxCoreAttributesKey, 'Attributes', 1);

    await runSilentPowerShell(r'''
    $line = powercfg /getactivescheme | Out-String
    if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor CPMINCORES 10 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor CPMINCORES 10 | Out-Null
  powercfg /setacvalueindex $scheme sub_processor CPMAXCORES 100 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor CPMAXCORES 100 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final minValues = await _readCurrentPowerValues('CPMINCORES');
    final maxValues = await _readCurrentPowerValues('CPMAXCORES');
    final minAttributes = await RegistryManager.readDword(
      _minCoreAttributesKey,
      'Attributes',
    );
    final maxAttributes = await RegistryManager.readDword(
      _maxCoreAttributesKey,
      'Attributes',
    );

    final hasFullMin =
        minValues.isNotEmpty && minValues.every((value) => value == 100);
    final hasFullMax =
        maxValues.isNotEmpty && maxValues.every((value) => value == 100);
    final attributesUnhidden = minAttributes == 0 && maxAttributes == 0;

    final applied = hasFullMin && hasFullMax && attributesUnhidden;
    isApplied = applied;
    return applied;
  }

  Future<List<int>> _readCurrentPowerValues(String settingAlias) async {
    final output = await runPowerShellForOutput(
      r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /query $scheme sub_processor __SETTING_ALIAS__ | Out-String
}
'''
          .replaceAll('__SETTING_ALIAS__', settingAlias),
    );

    final values = <int>[];
    for (final line in output.split(RegExp(r'\r?\n'))) {
      final currentMatch = RegExp(
        r'Current\s+(AC|DC)\s+Power\s+Setting\s+Index:\s+0x([0-9a-fA-F]+)',
      ).firstMatch(line);
      if (currentMatch == null) {
        continue;
      }

      final parsed = int.tryParse(currentMatch.group(2) ?? '', radix: 16);
      if (parsed != null) {
        values.add(parsed);
      }
    }
    return values;
  }
}

class ProcessorPerformanceBoostModeTweak extends _PowerCpuSystemTweak {
  ProcessorPerformanceBoostModeTweak()
    : super(
        id: 'power_processor_boost_mode',
        title: 'Processor Performance Boost Mode',
        description:
            'Enables aggressive CPU boost mode (Intel/AMD). Improves sustained boost clocks on multi-thread workloads. Recommended for well-cooled desktops.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFBOOSTMODE 2 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PERFBOOSTMODE 2 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFBOOSTMODE 1 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PERFBOOSTMODE 1 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final acValue = await _readPowercfgAcValue('PERFBOOSTMODE');
    final applied = acValue == 2;
    isApplied = applied;
    return applied;
  }
}

class MinProcessorStateTweak extends _PowerCpuSystemTweak {
  MinProcessorStateTweak()
    : super(
        id: 'power_min_processor_state',
        title: 'Minimum Processor State (5%)',
        description:
            'Sets minimum CPU frequency to 5% to balance responsiveness and power. Combine with Core Parking for best effect.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PROCTHROTTLEMIN 5 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PROCTHROTTLEMIN 5 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PROCTHROTTLEMIN 5 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PROCTHROTTLEMIN 5 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final acValue = await _readPowercfgAcValue('PROCTHROTTLEMIN');
    final applied = acValue == 5;
    isApplied = applied;
    return applied;
  }
}

class MaxProcessorStateTweak extends _PowerCpuSystemTweak {
  MaxProcessorStateTweak()
    : super(
        id: 'power_max_processor_state',
        title: 'Maximum Processor State (100%)',
        description:
            'Sets maximum CPU frequency to 100% to prevent aggressive downclocking under load.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PROCTHROTTLEMAX 100 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PROCTHROTTLEMAX 100 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PROCTHROTTLEMAX 99 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PROCTHROTTLEMAX 99 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final acValue = await _readPowercfgAcValue('PROCTHROTTLEMAX');
    final applied = acValue == 100;
    isApplied = applied;
    return applied;
  }
}

class SystemResponsivenessRegistryTweak extends SystemTweak {
  SystemResponsivenessRegistryTweak()
    : super(
        id: 'power_system_responsiveness_registry',
        title: 'System Responsiveness (10)',
        description:
            'Sets SystemResponsiveness to 10 (from default 20) - gives more CPU time to foreground apps over system services. Improves gaming and multitasking feel.',
        category: 'Power & CPU',
      );

  static const String _keyPath =
      r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_keyPath, 'SystemResponsiveness', 10);
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_keyPath, 'SystemResponsiveness', 20);
    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final value = await RegistryManager.readDword(_keyPath, 'SystemResponsiveness');
    final applied = value != null && value <= 14;
    isApplied = applied;
    return applied;
  }
}

class CpuIdlePromoteDemoteTweak extends _PowerCpuSystemTweak {
  CpuIdlePromoteDemoteTweak()
    : super(
        id: 'power_cpu_idle_demote_promote',
        title: 'Disable CPU Idle Demote/Promote',
        description:
            'Sets idle demote/promote thresholds to 100% to reduce time CPU spends entering/exiting idle states. Lower latency at higher power cost.',
    isAggressive: true,
    warningMessage:
      'Increases CPU temperature. Recommended only for desktops with good cooling.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor IDLEDEMOTETHR 100 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor IDLEDEMOTETHR 100 | Out-Null
  powercfg /setacvalueindex $scheme sub_processor IDLEPROMOTETHR 100 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor IDLEPROMOTETHR 100 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor IDLEDEMOTETHR 40 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor IDLEDEMOTETHR 40 | Out-Null
  powercfg /setacvalueindex $scheme sub_processor IDLEPROMOTETHR 60 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor IDLEPROMOTETHR 60 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final demote = await _readPowercfgAcValue('IDLEDEMOTETHR');
    final promote = await _readPowercfgAcValue('IDLEPROMOTETHR');
    final applied = demote == 100 && promote == 100;
    isApplied = applied;
    return applied;
  }
}

class ProcessorTimeCheckIntervalTweak extends _PowerCpuSystemTweak {
  ProcessorTimeCheckIntervalTweak()
    : super(
        id: 'power_processor_time_check_interval',
        title: 'Processor Time Check Interval (5ms)',
        description:
            'Reduces CPU scheduler check interval from 15ms to 5ms for faster frequency scaling response.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFCHECK 5 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PERFCHECK 5 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFCHECK 15 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor PERFCHECK 15 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final acValue = await _readPowercfgAcValue('PERFCHECK');
    final applied = acValue == 5;
    isApplied = applied;
    return applied;
  }
}

class DisableCStatesTweak extends _PowerCpuSystemTweak {
  DisableCStatesTweak()
    : super(
        id: 'power_disable_cstates',
        title: 'Disable CPU C-States',
        description:
            'Limits CPU sleep states for maximum responsiveness and instant boost. Desktop only - significantly increases temperature and idle power draw.',
    isAggressive: true,
    warningMessage:
      'HIGH RISK: CPU will run much hotter at idle. Only for desktops with premium cooling. Do NOT use on laptops.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor IDLEDISABLE 1 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor IDLEDISABLE 1 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor IDLEDISABLE 0 | Out-Null
  powercfg /setdcvalueindex $scheme sub_processor IDLEDISABLE 0 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final acValue = await _readPowercfgAcValue('IDLEDISABLE');
    final applied = acValue == 1;
    isApplied = applied;
    return applied;
  }
}

class Win32PrioritySeparationTweak extends SystemTweak {
  Win32PrioritySeparationTweak()
    : super(
        id: 'power_win32_priority_separation',
        title: 'Win32 Priority Separation (Gaming)',
        description:
            'Sets Win32PrioritySeparation to 26 (hex 0x1a) - prioritizes foreground app CPU time. Classic gaming tweak for lower input latency.',
        category: 'Power & CPU',
      );

  static const String _keyPath =
      r'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_keyPath, 'Win32PrioritySeparation', 26);
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_keyPath, 'Win32PrioritySeparation', 2);
    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final value = await RegistryManager.readDword(_keyPath, 'Win32PrioritySeparation');
    final applied = value == 26;
    isApplied = applied;
    return applied;
  }
}

class DisableDynamicTickTweak extends SystemTweak {
  DisableDynamicTickTweak()
    : super(
        id: 'power_disable_dynamic_tick',
        title: 'Disable Dynamic Tick',
        description:
            'Runs bcdedit /set disabledynamictick yes - makes system timer more consistent, reduces micro-stutter in games and low-latency apps. Still effective on Windows 11 in 2026.',
        category: 'Power & CPU',
        isAggressive: true,
        warningMessage:
            'Increases idle power usage and CPU temperature slightly. A restart is required to take effect.',
      );

  @override
  Future<void> onApply() async {
    final result = await ProcessRunner.shared.run('bcdedit', <String>[
      '/set',
      'disabledynamictick',
      'yes',
    ]);
    if (!result.success) {
      throw Exception(result.details.isEmpty ? 'Failed to set disabledynamictick.' : result.details);
    }
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    final result = await ProcessRunner.shared.run('bcdedit', <String>[
      '/deletevalue',
      'disabledynamictick',
    ]);
    if (!result.success) {
      throw Exception(result.details.isEmpty ? 'Failed to clear disabledynamictick.' : result.details);
    }
    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final result = await ProcessRunner.shared.run('bcdedit', <String>[
      '/enum',
      '{current}',
    ]);

    final output = '${result.stdout}\n${result.stderr}'.toLowerCase();
    final applied = output.contains('disabledynamictick') && output.contains('yes');
    isApplied = applied;
    return applied;
  }
}

class TscSyncPolicyTweak extends SystemTweak {
  TscSyncPolicyTweak()
    : super(
        id: 'power_tsc_sync_policy',
        title: 'TSC Sync Policy (Enhanced)',
        description:
            'Sets tscsyncpolicy to Enhanced - improves CPU core timer synchronization on multi-core systems. Low risk, especially useful on older multi-socket systems.',
        category: 'Power & CPU',
      );

  @override
  Future<void> onApply() async {
    final result = await ProcessRunner.shared.run('bcdedit', <String>[
      '/set',
      'tscsyncpolicy',
      'Enhanced',
    ]);
    if (!result.success) {
      throw Exception(result.details.isEmpty ? 'Failed to set tscsyncpolicy.' : result.details);
    }
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    final result = await ProcessRunner.shared.run('bcdedit', <String>[
      '/deletevalue',
      'tscsyncpolicy',
    ]);
    if (!result.success) {
      throw Exception(result.details.isEmpty ? 'Failed to clear tscsyncpolicy.' : result.details);
    }
    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final result = await ProcessRunner.shared.run('bcdedit', <String>[
      '/enum',
      '{current}',
    ]);
    final output = '${result.stdout}\n${result.stderr}'.toLowerCase();
    final applied = output.contains('tscsyncpolicy') && output.contains('enhanced');
    isApplied = applied;
    return applied;
  }
}

class GlobalTimerResolutionRequestsTweak extends SystemTweak {
  GlobalTimerResolutionRequestsTweak()
    : super(
        id: 'power_global_timer_resolution',
        title: 'Global Timer Resolution Requests',
        description:
            'Sets GlobalTimerResolutionRequests=1 - restores system-wide high-resolution timer behavior on Windows 11. Essential for apps/games that rely on 1ms or 0.5ms timer precision.',
        category: 'Power & CPU',
      );

  static const String _keyPath =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_keyPath, 'GlobalTimerResolutionRequests', 1);
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    final existing = await RegistryManager.readDword(
      _keyPath,
      'GlobalTimerResolutionRequests',
    );

    if (existing != null) {
      await RegistryManager.deleteValue(_keyPath, 'GlobalTimerResolutionRequests');
    }

    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final value = await RegistryManager.readDword(
      _keyPath,
      'GlobalTimerResolutionRequests',
    );
    final applied = value == 1;
    isApplied = applied;
    return applied;
  }
}

class HardwarePStatesTweak extends _PowerCpuSystemTweak {
  HardwarePStatesTweak()
    : super(
        id: 'power_hardware_pstates_intel',
        title: 'Intel Hardware P-States (HWP)',
        description:
            'Configures Intel Speed Shift / Hardware P-States for maximum performance bias. Intel CPUs only.',
        requiredCpuVendor: 'intel',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFEPP 0 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFEPP 50 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final acValue = await _readPowercfgAcValue('PERFEPP');
    final applied = acValue == 0;
    isApplied = applied;
    return applied;
  }
}

class AmdPreferredCoresTweak extends _PowerCpuSystemTweak {
  AmdPreferredCoresTweak()
    : super(
        id: 'power_amd_preferred_cores',
        title: 'AMD Preferred Cores',
        description:
            'Enables AMD Precision Boost - lets the CPU prioritize strongest cores for single-threaded workloads. AMD CPUs only.',
        requiredCpuVendor: 'amd',
      );

  static const String _attributesPath =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1e-9b1571e70b29';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_attributesPath, 'Attributes', 0);

    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFAUTONOMOUS 1 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$line = powercfg /getactivescheme | Out-String
if ($line -match '([0-9a-fA-F-]{36})') {
  $scheme = $matches[1]
  powercfg /setacvalueindex $scheme sub_processor PERFAUTONOMOUS 0 | Out-Null
  powercfg /setactive $scheme | Out-Null
}
''', elevated: true);

    await RegistryManager.writeDword(_attributesPath, 'Attributes', 1);
    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final attributes = await RegistryManager.readDword(_attributesPath, 'Attributes');
    final acValue = await _readPowercfgAcValue('PERFAUTONOMOUS');
    final applied = attributes == 0 && acValue == 1;
    isApplied = applied;
    return applied;
  }
}
