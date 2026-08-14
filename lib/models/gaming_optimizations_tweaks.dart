import '../core/registry_manager.dart';
import 'system_tweak.dart';

List<SystemTweak> createGamingOptimizationsTweaks() {
  return <SystemTweak>[
    WindowedOptimizationsOnTweak(),
    MpoOffTweak(),
    LegacyFlipFseTweak(),
    ComposedFlipImmediateModeTweak(),
    AmdGpuSafeProfileTweak(),
    AmdGpuExtremeProfileTweak(),
    AmdUlpsOffTweak(),
  ];
}

abstract class _GamingOptimizationTweak extends SystemTweak {
  _GamingOptimizationTweak({
    required super.id,
    required super.title,
    required super.description,
    super.requiredGpuVendors,
    super.isAggressive,
    super.warningMessage,
  }) : super(category: 'Gaming Optimizations');
}

class WindowedOptimizationsOnTweak extends SystemTweak {
  WindowedOptimizationsOnTweak()
    : super(
        id: 'gaming_windowed_optimizations_on',
        title: 'Optimizations for Windowed Games On',
        description:
            'Enables the Windows 11 swap-effect upgrade for compatible windowed and borderless games.',
        category: 'Gaming Optimizations',
      );

  static const String _directXKey =
      r'HKCU\Software\Microsoft\DirectX\UserGpuPreferences';

  Future<void> _setEnabled(bool enabled) => runSilentPowerShell(
    r'''
$path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
$current = (Get-ItemProperty -Path $path -Name DirectXUserGlobalSettings -ErrorAction SilentlyContinue).DirectXUserGlobalSettings
$current = [string]$current
$next = [regex]::Replace($current, 'SwapEffectUpgradeEnable=\d+;', '')
Set-ItemProperty -Path $path -Name DirectXUserGlobalSettings -Value ($next + 'SwapEffectUpgradeEnable=__VALUE__;') -Type String
'''
        .replaceAll('__VALUE__', enabled ? '1' : '0'),
  );

  @override
  Future<void> onApply() => _setEnabled(true);

  @override
  Future<void> onRevert() => _setEnabled(false);

  @override
  Future<bool> checkState() async =>
      (await RegistryManager.readString(
        _directXKey,
        'DirectXUserGlobalSettings',
      ))?.contains('SwapEffectUpgradeEnable=1;') ??
      false;
}

class MpoOffTweak extends SystemTweak {
  MpoOffTweak()
    : super(
        id: 'gaming_mpo_off',
        title: 'Disable Multiplane Overlay (MPO)',
        description:
            'Troubleshooting-only workaround for display flicker or stutter; restart required.',
        category: 'Gaming Optimizations',
        isAggressive: true,
        warningMessage:
            'Use only to diagnose display issues. MPO is enabled by default in Windows.',
      );

  static const String _dwmKey = r'HKLM\SOFTWARE\Microsoft\Windows\Dwm';

  @override
  Future<void> onApply() =>
      RegistryManager.writeDword(_dwmKey, 'OverlayTestMode', 5);

  @override
  Future<void> onRevert() =>
      RegistryManager.deleteValue(_dwmKey, 'OverlayTestMode');

  @override
  Future<bool> checkState() async =>
      await RegistryManager.readDword(_dwmKey, 'OverlayTestMode') == 5;
}

class LegacyFlipFseTweak extends SystemTweak {
  LegacyFlipFseTweak()
    : super(
        id: 'gaming_legacy_flip_fse',
        title: 'Fullscreen Exclusive Legacy Flip',
        description:
            'Switches GameConfigStore to FSE-oriented behavior for legacy fullscreen testing.',
        category: 'Gaming Optimizations',
        isAggressive: true,
        warningMessage:
            'Legacy compatibility experiment. Test one game at a time and revert if presentation breaks.',
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
        isAggressive: true,
        warningMessage:
            'Experimental graphics scheduler override. Revert if games show flicker, black screens, or instability.',
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
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _schedulerKey,
      'ForceFlipTrueImmediateMode',
    );
    final applied = current == 1;
    return applied;
  }
}

class AmdGpuExtremeProfileTweak extends _GamingOptimizationTweak {
  AmdGpuExtremeProfileTweak()
    : super(
        id: 'gaming_amd_gpu_extreme_profile',
        title: 'AMD GPU Extreme Profile',
        description:
            'Disables AMD thermal throttling, Crash Defender, power gating, clock gating, ULPS, ASPM, and other power-saving behavior. Desktop troubleshooting only.',
        requiredGpuVendors: const <String>{'amd'},
        isAggressive: true,
        warningMessage:
            'HIGH RISK: this can increase temperatures, idle power draw, instability, and GPU damage risk. It disables thermal and crash-recovery safeguards. Create a restore point and monitor temperatures.',
      );

  static const String _backupPath =
      r'$env:ProgramData\ZapTweaks\backups\amd-gpu-extreme-profile.xml';

  @override
  Future<void> onApply() => runSilentPowerShell(
    r'''
$backup = __BACKUP_PATH__
$settings = @{
  ReportAnalytics=0; NotifySubscription=0; AllowSubscription=0; ShowReleaseNotes=0; StutterMode=0
  KMD_EnableAmdFendrOptions=0; KMD_ChillEnabled=0; KMD_DeLagEnabled=1; KMD_FramePacingSupport=0; KMD_RadeonBoostEnabled=0
  DalDisableStutter=1; DisableBlockWrite=1; DisableFBCSupport=1; DisableFBCForFullScreenApp=1
  PP_Force3DPerformanceMode=1; PP_ForceHighDPMLevel=1; PP_SclkDeepSleepDisable=1; PP_GfxOffControl=0; PP_ThermalAutoThrottlingEnable=0; PP_EnableRaceToIdle=0
  EnableUlps=0; PP_DisableULPS=1; KMD_EnableULPS=0; KMD_ForceD3ColdSupport=0
  EnableAspmL0s=0; EnableAspmL1=0; EnableAspmL1SS=0; DisableAspmL0s=1; DisableAspmL1=1
  DisableGfxClockGating=1; DisableVceClockGating=1; DisableSamuClockGating=1; DisableRomMGCGClockGating=1; DisableGfxCoarseGrainClockGating=1; DisableGfxMediumGrainClockGating=1; DisableGfxFineGrainClockGating=1; DisableHdpMGClockGating=1
  EnableVceSwClockGating=0; EnableUvdClockGating=0; EnableGfxClockGatingThruSmu=0; EnableSysClockGatingThruSmu=0; DisableXdmaSclkGating=1; DalFineGrainClockGating=0; DisableRomMediumGrainClockGating=1; DisableNbioMediumGrainClockGating=1; DisableMcMediumGrainClockGating=1; IRQMgrDisableIHClockGating=1
  DisableGfxMGLS=1; DisableHdpClockPowerGating=1; DisableUVDPowerGating=1; DisableVCEPowerGating=1; DisableAcpPowerGating=1; DisableDrmdmaPowerGating=1; DisableGfxCGPowerGating=1; DisableStaticGfxMGPowerGating=1; DisableDynamicGfxMGPowerGating=1; DisableCpPowerGating=1; DisableGDSPowerGating=1; DisableXdmaPowerGating=1; DisableGFXPipelinePowerGating=1; DisableQuickGfxMGPowerGating=1; DisablePowerGating=1
  SMU_DisableMmhubPowerGating=1; SMU_DisableAthubPowerGating=1
  DalForceMaxDisplayClock=1; DalDisableClockGating=1; DalDisableDeepSleep=1; DalDisableDiv2=1; EnableSpreadSpectrum=0; EnableVcePllSpreadSpectrum=0
}
$root = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$targets = @(Get-ChildItem $root -ErrorAction Stop | Where-Object {
  $_.PSChildName -match '^\d{4}$' -and ((Get-ItemProperty $_.PSPath -Name ProviderName -ErrorAction SilentlyContinue).ProviderName -like '*Advanced Micro Devices*')
})
if ($targets.Count -eq 0) { throw 'No AMD display driver registry key was found.' }
New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
$driverServices = @('AMD Crash Defender Service','amdfendr','amdfendrmgr','amdlog')
$states = foreach ($target in $targets) {
  $item = Get-ItemProperty -Path $target.PSPath
  $values = @{}
  foreach ($name in $settings.Keys) {
    $property = $item.PSObject.Properties[$name]
    $values[$name] = [PSCustomObject]@{ Exists = $null -ne $property; Value = $null }
    if ($null -ne $property) { $values[$name].Value = [uint32]$property.Value }
  }
  [PSCustomObject]@{ Path = $target.PSPath; Values = $values }
}
$services = foreach ($name in $driverServices) {
  $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$name"
  $start = (Get-ItemProperty -Path $path -Name Start -ErrorAction SilentlyContinue).Start
  if ($null -ne $start) { [PSCustomObject]@{ Path = $path; Start = [uint32]$start } }
}
[PSCustomObject]@{ Targets = $states; Services = $services } | Export-Clixml -LiteralPath $backup -Force
foreach ($state in $states) {
  foreach ($entry in $settings.GetEnumerator()) {
    New-ItemProperty -Path $state.Path -Name $entry.Key -PropertyType DWord -Value $entry.Value -Force | Out-Null
  }
}
foreach ($service in $services) { Set-ItemProperty -Path $service.Path -Name Start -Value 4 -Type DWord }
'''
        .replaceAll('__BACKUP_PATH__', _backupPath),
    elevated: true,
  );

  @override
  Future<void> onRevert() => runSilentPowerShell(
    r'''
$backup = __BACKUP_PATH__
if (-not (Test-Path -LiteralPath $backup)) { return }
$backupState = Import-Clixml -LiteralPath $backup
foreach ($state in @($backupState.Targets)) {
  foreach ($name in $state.Values.Keys) {
    $value = $state.Values[$name]
    if ($value.Exists) {
      New-ItemProperty -Path $state.Path -Name $name -PropertyType DWord -Value ([uint32]$value.Value) -Force | Out-Null
    } else {
      Remove-ItemProperty -Path $state.Path -Name $name -ErrorAction SilentlyContinue
    }
  }
}
foreach ($service in @($backupState.Services)) { Set-ItemProperty -Path $service.Path -Name Start -Value ([uint32]$service.Start) -Type DWord }
'''
        .replaceAll('__BACKUP_PATH__', _backupPath),
    elevated: true,
  );

  @override
  Future<bool> checkState() async => (await runPowerShellForOutput(r'''
$root = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$targets = @(Get-ChildItem $root -ErrorAction SilentlyContinue | Where-Object {
  $_.PSChildName -match '^\d{4}$' -and ((Get-ItemProperty $_.PSPath -Name ProviderName -ErrorAction SilentlyContinue).ProviderName -like '*Advanced Micro Devices*')
})
if ($targets.Count -eq 0) { 'false'; return }
foreach ($target in $targets) {
  $item = Get-ItemProperty -Path $target.PSPath
  if ($item.PP_ThermalAutoThrottlingEnable -ne 0 -or $item.PP_Force3DPerformanceMode -ne 1 -or $item.DisablePowerGating -ne 1) { 'false'; return }
}
'true'
''')).toLowerCase().contains('true');
}

class AmdGpuSafeProfileTweak extends _GamingOptimizationTweak {
  AmdGpuSafeProfileTweak()
    : super(
        id: 'gaming_amd_gpu_safe_profile',
        title: 'AMD GPU Safe Profile',
        description:
            'Applies a reversible AMD driver profile without disabling thermal protection, Crash Defender, clock gating, or power gating.',
        requiredGpuVendors: const <String>{'amd'},
      );

  static const String _backupPath =
      r'$env:ProgramData\ZapTweaks\backups\amd-gpu-safe-profile.xml';

  @override
  Future<void> onApply() => runSilentPowerShell(
    r'''
$backup = __BACKUP_PATH__
$names = @('ReportAnalytics','NotifySubscription','AllowSubscription','ShowReleaseNotes','StutterMode','KMD_ChillEnabled','KMD_DeLagEnabled','KMD_RadeonBoostEnabled','DalDisableStutter')
$root = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$targets = @(Get-ChildItem $root -ErrorAction Stop | Where-Object {
  $_.PSChildName -match '^\d{4}$' -and ((Get-ItemProperty $_.PSPath -Name ProviderName -ErrorAction SilentlyContinue).ProviderName -like '*Advanced Micro Devices*')
})
if ($targets.Count -eq 0) { throw 'No AMD display driver registry key was found.' }
New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
$states = foreach ($target in $targets) {
  $item = Get-ItemProperty -Path $target.PSPath
  $values = @{}
  foreach ($name in $names) {
    $property = $item.PSObject.Properties[$name]
    $values[$name] = [PSCustomObject]@{ Exists = $null -ne $property; Value = $null }
    if ($null -ne $property) { $values[$name].Value = [uint32]$property.Value }
  }
  [PSCustomObject]@{ Path = $target.PSPath; Values = $values }
}
$states | Export-Clixml -LiteralPath $backup -Force
foreach ($state in $states) {
  foreach ($entry in @{ ReportAnalytics=0; NotifySubscription=0; AllowSubscription=0; ShowReleaseNotes=0; StutterMode=0; KMD_ChillEnabled=0; KMD_DeLagEnabled=1; KMD_RadeonBoostEnabled=0; DalDisableStutter=1 }.GetEnumerator()) {
    New-ItemProperty -Path $state.Path -Name $entry.Key -PropertyType DWord -Value $entry.Value -Force | Out-Null
  }
}
'''
        .replaceAll('__BACKUP_PATH__', _backupPath),
    elevated: true,
  );

  @override
  Future<void> onRevert() => runSilentPowerShell(
    r'''
$backup = __BACKUP_PATH__
if (-not (Test-Path -LiteralPath $backup)) { return }
foreach ($state in @(Import-Clixml -LiteralPath $backup)) {
  foreach ($name in $state.Values.Keys) {
    $value = $state.Values[$name]
    if ($value.Exists) {
      New-ItemProperty -Path $state.Path -Name $name -PropertyType DWord -Value ([uint32]$value.Value) -Force | Out-Null
    } else {
      Remove-ItemProperty -Path $state.Path -Name $name -ErrorAction SilentlyContinue
    }
  }
}
'''
        .replaceAll('__BACKUP_PATH__', _backupPath),
    elevated: true,
  );

  @override
  Future<bool> checkState() async => (await runPowerShellForOutput(r'''
$root = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$targets = @(Get-ChildItem $root -ErrorAction SilentlyContinue | Where-Object {
  $_.PSChildName -match '^\d{4}$' -and ((Get-ItemProperty $_.PSPath -Name ProviderName -ErrorAction SilentlyContinue).ProviderName -like '*Advanced Micro Devices*')
})
if ($targets.Count -eq 0) { 'false'; return }
foreach ($target in $targets) {
  $item = Get-ItemProperty -Path $target.PSPath
  if ($item.KMD_DeLagEnabled -ne 1 -or $item.KMD_ChillEnabled -ne 0 -or $item.KMD_RadeonBoostEnabled -ne 0) { 'false'; return }
}
'true'
''')).toLowerCase().contains('true');
}

class AmdUlpsOffTweak extends _GamingOptimizationTweak {
  AmdUlpsOffTweak()
    : super(
        id: 'gaming_amd_ulps_off',
        title: 'AMD ULPS Off',
        description:
            'Disables EnableUlps on AMD display class keys. Useful for latency testing.',
        requiredGpuVendors: const <String>{'amd'},
        isAggressive: true,
        warningMessage:
            'Increases AMD GPU idle power and can reduce stability on laptops.',
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
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _kernelKey,
      'GlobalTimerResolutionRequests',
    );
    final applied = current == 1;
    return applied;
  }
}
