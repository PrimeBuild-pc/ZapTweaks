import 'dart:convert';
import 'dart:typed_data';

import '../core/registry_manager.dart';
import '../core/services/process_runner.dart';
import 'system_tweak.dart';

List<SystemTweak> createSystemChecksTweaks() {
  return <SystemTweak>[
    MemoryCompressionOffTweak(),
    UacOffTweak(),
    FirewallOffTweak(),
    SpectreMeltdownOffTweak(),
    DataExecutionPreventionOffTweak(),
    CoreIsolationOffTweak(),
  ];
}

abstract class _SystemChecksTweak extends SystemTweak {
  _SystemChecksTweak({
    required super.id,
    required super.title,
    required super.description,
  }) : super(category: 'System Checks');

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

class MemoryCompressionOffTweak extends _SystemChecksTweak {
  MemoryCompressionOffTweak()
    : super(
        id: 'checks_memory_compression_off',
        title: 'Memory Compression Off',
        description:
            'Disables MemoryCompression in MMAgent for lower CPU overhead under burst loads.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(
      r'Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue | Out-Null',
      elevated: true,
    );
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(
      r'Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue | Out-Null',
      elevated: true,
    );
    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final output = (await runPowerShellForOutput(r'''
$m = Get-MMAgent -ErrorAction SilentlyContinue
if ($null -eq $m) {
  Write-Output 'false'
} elseif (-not $m.MemoryCompression) {
  Write-Output 'true'
} else {
  Write-Output 'false'
}
''')).toLowerCase();

    final applied = output.contains('true');
    isApplied = applied;
    return applied;
  }
}

class UacOffTweak extends SystemTweak {
  UacOffTweak()
    : super(
        id: 'checks_uac_off',
        title: 'UAC Off',
        description:
            'Sets User Account Control to disabled. A reboot is required for full effect.',
        category: 'System Checks',
      );

  static const String _keyPath =
      r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_keyPath, 'EnableLUA', 0);
    await RegistryManager.writeDword(_keyPath, 'ConsentPromptBehaviorAdmin', 0);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_keyPath, 'EnableLUA', 1);
    await RegistryManager.writeDword(_keyPath, 'ConsentPromptBehaviorAdmin', 5);
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final enabledLUA = await RegistryManager.readDword(_keyPath, 'EnableLUA');
    final applied = enabledLUA == 0;
    isApplied = applied;
    return applied;
  }
}

class FirewallOffTweak extends SystemTweak {
  FirewallOffTweak()
    : super(
        id: 'checks_firewall_off',
        title: 'Firewall Off',
        description:
            'Disables Public and Standard firewall profiles. Revert restores default enabled state.',
        category: 'System Checks',
      );

  static const String _publicKey =
      r'HKLM\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile';
  static const String _standardKey =
      r'HKLM\System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_publicKey, 'EnableFirewall', 0);
    await RegistryManager.writeDword(_standardKey, 'EnableFirewall', 0);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_publicKey, 'EnableFirewall', 1);
    await RegistryManager.writeDword(_standardKey, 'EnableFirewall', 1);
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final publicFirewall = await RegistryManager.readDword(
      _publicKey,
      'EnableFirewall',
    );
    final standardFirewall = await RegistryManager.readDword(
      _standardKey,
      'EnableFirewall',
    );
    final applied = publicFirewall == 0 && standardFirewall == 0;
    isApplied = applied;
    return applied;
  }
}

class SpectreMeltdownOffTweak extends SystemTweak {
  SpectreMeltdownOffTweak()
    : super(
        id: 'checks_spectre_meltdown_off',
        title: 'Spectre/Meltdown Mitigations Off',
        description:
            'Sets FeatureSettingsOverride and FeatureSettingsOverrideMask to 3.',
        category: 'System Checks',
      );

  static const String _keyPath =
      r'HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _keyPath,
      'FeatureSettingsOverrideMask',
      3,
    );
    await RegistryManager.writeDword(_keyPath, 'FeatureSettingsOverride', 3);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    final mask = await RegistryManager.readDword(
      _keyPath,
      'FeatureSettingsOverrideMask',
    );
    if (mask != null) {
      await RegistryManager.deleteValue(
        _keyPath,
        'FeatureSettingsOverrideMask',
      );
    }

    final value = await RegistryManager.readDword(
      _keyPath,
      'FeatureSettingsOverride',
    );
    if (value != null) {
      await RegistryManager.deleteValue(_keyPath, 'FeatureSettingsOverride');
    }

    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final mask = await RegistryManager.readDword(
      _keyPath,
      'FeatureSettingsOverrideMask',
    );
    final value = await RegistryManager.readDword(
      _keyPath,
      'FeatureSettingsOverride',
    );
    final applied = mask == 3 && value == 3;
    isApplied = applied;
    return applied;
  }
}

class DataExecutionPreventionOffTweak extends _SystemChecksTweak {
  DataExecutionPreventionOffTweak()
    : super(
        id: 'checks_dep_off',
        title: 'Data Execution Prevention Off',
        description:
            'Sets bcdedit nx to AlwaysOff. Revert deletes nx override (Windows default).',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(
      r'cmd /c "bcdedit /set nx AlwaysOff >nul 2>&1"',
      elevated: true,
    );
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(
      r'cmd /c "bcdedit /deletevalue nx >nul 2>&1"',
      elevated: true,
    );
    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final output = (await runPowerShellForOutput(r'''
$current = cmd /c "bcdedit /enum {current}" | Out-String
if ($current -match '(?im)^\s*nx\s+AlwaysOff\s*$') {
  Write-Output 'true'
} else {
  Write-Output 'false'
}
''')).toLowerCase();

    final applied = output.contains('true');
    isApplied = applied;
    return applied;
  }
}

class CoreIsolationOffTweak extends SystemTweak {
  CoreIsolationOffTweak()
    : super(
        id: 'checks_core_isolation_off',
        title: 'Core Isolation Memory Integrity Off',
        description:
            'Disables HVCI memory integrity via DeviceGuard registry scenario.',
        category: 'System Checks',
      );

  static const String _keyPath =
      r'HKLM\System\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_keyPath, 'Enabled', 0);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_keyPath, 'Enabled', 1);
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final enabled = await RegistryManager.readDword(_keyPath, 'Enabled');
    final applied = enabled == 0;
    isApplied = applied;
    return applied;
  }
}
