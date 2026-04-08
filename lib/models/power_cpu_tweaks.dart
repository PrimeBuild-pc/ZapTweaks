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
  ];
}

abstract class _PowerCpuSystemTweak extends SystemTweak {
  _PowerCpuSystemTweak({
    required super.id,
    required super.title,
    required super.description,
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
