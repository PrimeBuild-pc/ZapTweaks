import 'dart:convert';
import 'dart:typed_data';

import '../core/registry_manager.dart';
import '../core/services/process_runner.dart';
import 'system_tweak.dart';

List<SystemTweak> createGamingOptimizationsTweaks() {
  return <SystemTweak>[
    MpoWindowedOptimizationsOffTweak(),
    LegacyFlipFseTweak(),
    ComposedFlipImmediateModeTweak(),
    AmdUlpsOffTweak(),
    TimerResolutionRequestsTweak(),
  ];
}

abstract class _GamingOptimizationTweak extends SystemTweak {
  _GamingOptimizationTweak({
    required super.id,
    required super.title,
    required super.description,
  }) : super(category: 'Gaming Optimizations');

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

class MpoWindowedOptimizationsOffTweak extends SystemTweak {
  MpoWindowedOptimizationsOffTweak()
    : super(
        id: 'gaming_mpo_windowed_optimizations_off',
        title: 'MPO Off and Windowed Optimizations Off',
        description:
            'Disables Multiplane Overlay and disables swap effect upgrade for windowed mode.',
        category: 'Gaming Optimizations',
      );

  static const String _dwmKey = r'HKLM\SOFTWARE\Microsoft\Windows\Dwm';
  static const String _directXKey =
      r'HKCU\Software\Microsoft\DirectX\UserGpuPreferences';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_dwmKey, 'OverlayTestMode', 5);
    await RegistryManager.writeString(
      _directXKey,
      'DirectXUserGlobalSettings',
      'VRROptimizeEnable=0;SwapEffectUpgradeEnable=0;',
    );
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    final overlay = await RegistryManager.readDword(_dwmKey, 'OverlayTestMode');
    if (overlay != null) {
      await RegistryManager.deleteValue(_dwmKey, 'OverlayTestMode');
    }

    await RegistryManager.writeString(
      _directXKey,
      'DirectXUserGlobalSettings',
      'VRROptimizeEnable=0;SwapEffectUpgradeEnable=1;',
    );
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final overlay = await RegistryManager.readDword(_dwmKey, 'OverlayTestMode');
    final globalSettings = await RegistryManager.readString(
      _directXKey,
      'DirectXUserGlobalSettings',
    );

    final applied =
        overlay == 5 &&
        (globalSettings?.contains('SwapEffectUpgradeEnable=0;') ?? false);
    isApplied = applied;
    return applied;
  }
}

class LegacyFlipFseTweak extends SystemTweak {
  LegacyFlipFseTweak()
    : super(
        id: 'gaming_legacy_flip_fse',
        title: 'Fullscreen Exclusive Legacy Flip',
        description:
            'Switches GameConfigStore to FSE-oriented behavior for legacy fullscreen testing.',
        category: 'Gaming Optimizations',
      );

  static const String _gameConfigStore = r'HKCU\System\GameConfigStore';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _gameConfigStore,
      'GameDVR_DXGIHonorFSEWindowsCompatible',
      1,
    );
    await RegistryManager.writeDword(
      _gameConfigStore,
      'GameDVR_FSEBehaviorMode',
      2,
    );
    await RegistryManager.writeDword(
      _gameConfigStore,
      'GameDVR_FSEBehavior',
      2,
    );
    await RegistryManager.writeDword(
      _gameConfigStore,
      'GameDVR_HonorUserFSEBehaviorMode',
      1,
    );
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(
      _gameConfigStore,
      'GameDVR_DXGIHonorFSEWindowsCompatible',
      0,
    );
    await RegistryManager.writeDword(
      _gameConfigStore,
      'GameDVR_FSEBehaviorMode',
      0,
    );

    final gameDvrFse = await RegistryManager.readDword(
      _gameConfigStore,
      'GameDVR_FSEBehavior',
    );
    if (gameDvrFse != null) {
      await RegistryManager.deleteValue(
        _gameConfigStore,
        'GameDVR_FSEBehavior',
      );
    }

    await RegistryManager.writeDword(
      _gameConfigStore,
      'GameDVR_HonorUserFSEBehaviorMode',
      0,
    );
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final compatible = await RegistryManager.readDword(
      _gameConfigStore,
      'GameDVR_DXGIHonorFSEWindowsCompatible',
    );
    final mode = await RegistryManager.readDword(
      _gameConfigStore,
      'GameDVR_FSEBehaviorMode',
    );
    final honorMode = await RegistryManager.readDword(
      _gameConfigStore,
      'GameDVR_HonorUserFSEBehaviorMode',
    );

    final applied = compatible == 1 && mode == 2 && honorMode == 1;
    isApplied = applied;
    return applied;
  }
}

class ComposedFlipImmediateModeTweak extends SystemTweak {
  ComposedFlipImmediateModeTweak()
    : super(
        id: 'gaming_composed_flip_immediate_mode',
        title: 'Hardware Composed Independent Flip',
        description:
            'Forces ForceFlipTrueImmediateMode=1 in graphics scheduler.',
        category: 'Gaming Optimizations',
      );

  static const String _schedulerKey =
      r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _schedulerKey,
      'ForceFlipTrueImmediateMode',
      1,
    );
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    final current = await RegistryManager.readDword(
      _schedulerKey,
      'ForceFlipTrueImmediateMode',
    );
    if (current != null) {
      await RegistryManager.deleteValue(
        _schedulerKey,
        'ForceFlipTrueImmediateMode',
      );
    }
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _schedulerKey,
      'ForceFlipTrueImmediateMode',
    );
    final applied = current == 1;
    isApplied = applied;
    return applied;
  }
}

class AmdUlpsOffTweak extends _GamingOptimizationTweak {
  AmdUlpsOffTweak()
    : super(
        id: 'gaming_amd_ulps_off',
        title: 'AMD ULPS Off',
        description:
            'Disables EnableUlps on AMD display class keys. Useful for latency testing.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$subkeys = Get-ChildItem -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}' -Force -ErrorAction SilentlyContinue
foreach ($key in $subkeys) {
  if ($key.Name -notlike '*Configuration*') {
    New-ItemProperty -Path $key.PSPath -Name 'EnableUlps' -PropertyType DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
  }
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$subkeys = Get-ChildItem -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}' -Force -ErrorAction SilentlyContinue
foreach ($key in $subkeys) {
  if ($key.Name -notlike '*Configuration*') {
    $item = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
    if ($null -ne $item -and $null -ne $item.EnableUlps) {
      New-ItemProperty -Path $key.PSPath -Name 'EnableUlps' -PropertyType DWord -Value 1 -Force -ErrorAction SilentlyContinue | Out-Null
    }
  }
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final output = (await runPowerShellForOutput(r'''
$subkeys = Get-ChildItem -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}' -Force -ErrorAction SilentlyContinue
$found = $false

foreach ($key in $subkeys) {
  if ($key.Name -like '*Configuration*') {
    continue
  }

  $item = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
  if ($null -ne $item -and $null -ne $item.EnableUlps) {
    $found = $true
    if ([int]$item.EnableUlps -ne 0) {
      Write-Output 'false'
      return
    }
  }
}

if ($found) {
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

class TimerResolutionRequestsTweak extends SystemTweak {
  TimerResolutionRequestsTweak()
    : super(
        id: 'gaming_timer_resolution_requests',
        title: 'Timer Resolution Requests On',
        description:
            'Sets GlobalTimerResolutionRequests=1 in session kernel settings.',
        category: 'Gaming Optimizations',
      );

  static const String _kernelKey =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _kernelKey,
      'GlobalTimerResolutionRequests',
      1,
    );
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    final current = await RegistryManager.readDword(
      _kernelKey,
      'GlobalTimerResolutionRequests',
    );
    if (current != null) {
      await RegistryManager.deleteValue(
        _kernelKey,
        'GlobalTimerResolutionRequests',
      );
    }
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _kernelKey,
      'GlobalTimerResolutionRequests',
    );
    final applied = current == 1;
    isApplied = applied;
    return applied;
  }
}
