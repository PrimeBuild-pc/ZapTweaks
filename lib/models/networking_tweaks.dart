import '../core/registry_manager.dart';
import 'action_tweaks.dart';
import 'system_tweak.dart';

List<SystemTweak> createNetworkingTweaks() {
  return <SystemTweak>[
    NetworkAdapterPowerSavingsTweak(),
    DevicePowerSavingsTweak(),
    NetworkIpv4OnlyTweak(),
    PreferIpv4Tweak(),
    NetworkThrottlingIndexTweak(),
    NetworkMmAgentTweak(),
    NetworkLowLatencyBandwidthProfileTweak(),
    PowerShellTerminalCommandTweak(
      id: 'network_itr_interactive_config',
      title: 'NIC ITR Interactive Config',
      description:
          'Opens an elevated interactive tool to configure NIC Interrupt Throttle Rate (ITR) for supported Realtek/Intel/Killer adapters.',
      category: 'Networking',
      command: r'''
Add-Type -AssemblyName Microsoft.VisualBasic

$root = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}"
$list = Get-ChildItem $root -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match '^\d{4}$' } | ForEach-Object {
  $prop = Get-ItemProperty $_.PSPath
  if ($prop.DriverDesc -match "Realtek|Intel|Killer|Gaming") {
    [PSCustomObject]@{ID=$_.PSChildName; Name=$prop.DriverDesc; Path=$_.PSPath}
  }
}

if (!$list) { Write-Host "No adapter found."; Read-Host; exit }

$target = $list[0]
if ($list.Count -gt 1) {
  Write-Host "Found:"
  for ($i=0; $i -lt $list.Count; $i++) { Write-Host "$($i+1): $($list[$i].Name) ($($list[$i].ID))" }
  $sel = Read-Host "Select #"
  if ($sel -match '^\d+$' -and $sel -le $list.Count -and $sel -gt 0) { $target = $list[$sel-1] } else { exit }
}

Write-Host "Target: $($target.Name)"

$menu = "1: Disabled (0)`n2: Minimal (200)`n3: Low (400)`n4: Medium (950)`n5: High (2000)`n6: Extreme (3600)`n7: Adaptive (65535)"
$in = [Microsoft.VisualBasic.Interaction]::InputBox($menu, "ITR Config", "3")

$val = switch ($in) {
  '1' {0} '2' {200} '3' {400} '4' {950} '5' {2000} '6' {3600} '7' {65535} default {$null}
}

if ($val -ne $null) {
  try {
    Set-ItemProperty -Path $target.Path -Name "ITR" -Value $val -Force
    Set-ItemProperty -Path $target.Path -Name "*ITR" -Value $val -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $target.Path -Name "InterruptModerationRate" -Value $val -Force -ErrorAction SilentlyContinue
    Write-Host "Set to $val. Restart required."
  } catch {
    Write-Host "Error: $_"
  }
}

Read-Host "Done"
''',
      actionLabel: 'Configure ITR',
      isAggressive: true,
      warningMessage:
          'This action changes advanced NIC interrupt moderation registry values. Restart is recommended after applying changes.',
    ),
  ];
}

class NetworkLowLatencyBandwidthProfileTweak extends _NetworkingSystemTweak {
  NetworkLowLatencyBandwidthProfileTweak()
    : super(
        id: 'network_low_latency_bandwidth_profile',
        title: 'Low-Latency Network Profile',
        description:
            'Applies an aggressive low-latency networking profile that may reduce throughput and overall bandwidth efficiency.',
        aggressive: true,
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
Set-NetOffloadGlobalSetting -ReceiveSideScaling Enabled -ReceiveSegmentCoalescing Disabled -Chimney Disabled -TaskOffload Enabled -NetworkDirect Enabled -NetworkDirectAcrossIPSubnets Allowed -PacketCoalescingFilter Disabled -ErrorAction SilentlyContinue

Set-NetTCPSetting -SettingName InternetCustom -MinRtoMs 300 -InitialCongestionWindowMss 10 -CongestionProvider CUBIC -CwndRestart True -DelayedAckTimeoutMs 0 -DelayedAckFrequency 1 -AutoTuningLevelLocal Disabled -EcnCapability Disabled -Timestamps Disabled -InitialRtoMs 2000 -ScalingHeuristics Disabled -MaxSynRetransmissions 2 -ErrorAction SilentlyContinue

Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4 -AutomaticMetric Disabled -InterfaceMetric 1 -NeighborUnreachabilityDetection Disabled -Dhcp Enabled -EcnMarking Disabled -WeakHostReceive Enabled -WeakHostSend Enabled -ErrorAction SilentlyContinue
Set-NetIPInterface -InterfaceAlias "Wi-Fi" -AddressFamily IPv4 -AutomaticMetric Disabled -InterfaceMetric 1 -NeighborUnreachabilityDetection Disabled -Dhcp Enabled -EcnMarking Disabled -WeakHostReceive Enabled -WeakHostSend Enabled -ErrorAction SilentlyContinue

Enable-NetAdapterChecksumOffload -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Disable-NetAdapterLso -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Enable-NetAdapterRdma -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Disable-NetAdapterRsc -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Disable-NetAdapterPowerManagement -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Restart-NetAdapter -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
''', elevated: true);
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
Set-NetOffloadGlobalSetting -ReceiveSideScaling Enabled -ReceiveSegmentCoalescing Enabled -Chimney Disabled -TaskOffload Enabled -NetworkDirect Disabled -NetworkDirectAcrossIPSubnets Blocked -PacketCoalescingFilter Enabled -ErrorAction SilentlyContinue

Set-NetTCPSetting -SettingName InternetCustom -MinRtoMs 300 -InitialCongestionWindowMss 10 -CongestionProvider CUBIC -CwndRestart True -DelayedAckTimeoutMs 40 -DelayedAckFrequency 2 -AutoTuningLevelLocal Normal -EcnCapability Default -Timestamps Enabled -InitialRtoMs 3000 -ScalingHeuristics Enabled -MaxSynRetransmissions 4 -ErrorAction SilentlyContinue

Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4 -AutomaticMetric Enabled -InterfaceMetric 25 -NeighborUnreachabilityDetection Enabled -Dhcp Enabled -EcnMarking AppDecide -WeakHostReceive Disabled -WeakHostSend Disabled -ErrorAction SilentlyContinue
Set-NetIPInterface -InterfaceAlias "Wi-Fi" -AddressFamily IPv4 -AutomaticMetric Enabled -InterfaceMetric 25 -NeighborUnreachabilityDetection Enabled -Dhcp Enabled -EcnMarking AppDecide -WeakHostReceive Disabled -WeakHostSend Disabled -ErrorAction SilentlyContinue

Enable-NetAdapterChecksumOffload -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Enable-NetAdapterLso -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Disable-NetAdapterRdma -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Enable-NetAdapterRsc -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Enable-NetAdapterPowerManagement -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
Restart-NetAdapter -Name "*" -IncludeHidden -ErrorAction SilentlyContinue
''', elevated: true);
  }

  @override
  Future<bool> checkState() async {
    final result = (await runPowerShellForOutput(r'''
$offload = Get-NetOffloadGlobalSetting -ErrorAction SilentlyContinue
$tcp = Get-NetTCPSetting -SettingName InternetCustom -ErrorAction SilentlyContinue

if ($null -eq $offload -or $null -eq $tcp) {
  Write-Output 'false'
  return
}

$offloadApplied =
  ("$($offload.ReceiveSideScaling)" -eq 'Enabled') -and
  ("$($offload.ReceiveSegmentCoalescing)" -eq 'Disabled') -and
  ("$($offload.Chimney)" -eq 'Disabled') -and
  ("$($offload.TaskOffload)" -eq 'Enabled') -and
  ("$($offload.NetworkDirect)" -eq 'Enabled') -and
  ("$($offload.NetworkDirectAcrossIPSubnets)" -eq 'Allowed') -and
  ("$($offload.PacketCoalescingFilter)" -eq 'Disabled')
$tcpApplied =
  ($tcp.MinRtoMs -eq 300) -and
  ($tcp.InitialCongestionWindowMss -eq 10) -and
  ("$($tcp.CongestionProvider)" -eq 'CUBIC') -and
  ($tcp.CwndRestart -eq $true) -and
  ($tcp.DelayedAckTimeoutMs -eq 0) -and
  ($tcp.DelayedAckFrequency -eq 1) -and
  ("$($tcp.AutoTuningLevelLocal)" -eq 'Disabled') -and
  ("$($tcp.EcnCapability)" -eq 'Disabled') -and
  ("$($tcp.Timestamps)" -eq 'Disabled') -and
  ($tcp.InitialRtoMs -eq 2000) -and
  ("$($tcp.ScalingHeuristics)" -eq 'Disabled') -and
  ($tcp.MaxSynRetransmissions -eq 2)

if ($offloadApplied -and $tcpApplied) {
  Write-Output 'true'
} else {
  Write-Output 'false'
}
''')).toLowerCase();

    final applied = result.contains('true');
    return applied;
  }
}

abstract class _NetworkingSystemTweak extends SystemTweak {
  _NetworkingSystemTweak({
    required super.id,
    required super.title,
    required super.description,
    bool aggressive = false,
    super.conflictingTweakIds,
  }) : super(category: 'Networking', isAggressive: aggressive);
}

class NetworkAdapterPowerSavingsTweak extends _NetworkingSystemTweak {
  NetworkAdapterPowerSavingsTweak()
    : super(
        id: 'network_adapter_power_savings_wake_off',
        title: 'Adapter Power Savings and Wake Off',
        description:
            'Disables power-saving and wake features on physical network adapters, with an exact backup for revert.',
        aggressive: true,
      );

  static const String _backupPath =
      r'$env:ProgramData\ZapTweaks\backups\network-power-management.xml';

  @override
  Future<void> onApply() => runSilentPowerShell(
    r'''
$backup = __BACKUP_PATH__
New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
$adapters = @(Get-NetAdapter -Physical -ErrorAction Stop | Where-Object Status -ne 'Disabled')
$states = foreach ($adapter in $adapters) {
  Get-NetAdapterPowerManagement -Name $adapter.Name -ErrorAction SilentlyContinue
}
$states | Export-Clixml -LiteralPath $backup -Force
foreach ($adapter in $adapters) {
  Disable-NetAdapterPowerManagement -Name $adapter.Name -ArpOffload -D0PacketCoalescing -DeviceSleepOnDisconnect -NSOffload -RsnRekeyOffload -SelectiveSuspend -WakeOnMagicPacket -WakeOnPattern -ErrorAction SilentlyContinue | Out-Null
  Restart-NetAdapter -Name $adapter.Name -ErrorAction SilentlyContinue
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
  $parameters = @{ Name = $state.Name; ErrorAction = 'SilentlyContinue' }
  foreach ($name in 'ArpOffload','D0PacketCoalescing','DeviceSleepOnDisconnect','NSOffload','RsnRekeyOffload','SelectiveSuspend','WakeOnMagicPacket','WakeOnPattern') {
    if ($null -ne $state.$name) { $parameters[$name] = $state.$name }
  }
  Set-NetAdapterPowerManagement @parameters | Out-Null
  Restart-NetAdapter -Name $state.Name -ErrorAction SilentlyContinue
}
'''
        .replaceAll('__BACKUP_PATH__', _backupPath),
    elevated: true,
  );

  @override
  Future<bool> checkState() async => (await runPowerShellForOutput(r'''
$states = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Get-NetAdapterPowerManagement -ErrorAction SilentlyContinue)
if ($states.Count -gt 0 -and -not ($states | Where-Object { $_.SelectiveSuspend -ne 'Disabled' -or $_.WakeOnMagicPacket -ne 'Disabled' -or $_.WakeOnPattern -ne 'Disabled' })) { 'true' } else { 'false' }
''')).toLowerCase().contains('true');
}

class DevicePowerSavingsTweak extends _NetworkingSystemTweak {
  DevicePowerSavingsTweak()
    : super(
        id: 'device_power_savings_off',
        title: 'Device Power Saving Off',
        description:
            'Disables WMI device power saving. This increases idle power use and is intended for desktops.',
        aggressive: true,
      );

  static const String _backupPath =
      r'$env:ProgramData\ZapTweaks\backups\device-power-saving.xml';

  @override
  Future<void> onApply() => runSilentPowerShell(
    r'''
$backup = __BACKUP_PATH__
New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
$devices = @(Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable -ErrorAction Stop)
$devices | Select-Object InstanceName, Enable | Export-Clixml -LiteralPath $backup -Force
foreach ($device in $devices) {
  $device.Enable = $false
  Set-CimInstance -InputObject $device -ErrorAction SilentlyContinue | Out-Null
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
$states = @(Import-Clixml -LiteralPath $backup)
$devices = @(Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue)
foreach ($state in $states) {
  $device = $devices | Where-Object { $_.InstanceName -eq $state.InstanceName } | Select-Object -First 1
  if ($null -ne $device) {
    $device.Enable = [bool]$state.Enable
    Set-CimInstance -InputObject $device -ErrorAction SilentlyContinue | Out-Null
  }
}
'''
        .replaceAll('__BACKUP_PATH__', _backupPath),
    elevated: true,
  );

  @override
  Future<bool> checkState() async => (await runPowerShellForOutput(r'''
$devices = @(Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue)
if ($devices.Count -gt 0 -and -not ($devices | Where-Object { $_.Enable -eq $true })) { 'true' } else { 'false' }
''')).toLowerCase().contains('true');
}

class NetworkIpv4OnlyTweak extends _NetworkingSystemTweak {
  NetworkIpv4OnlyTweak()
    : super(
        id: 'network_ipv4_only',
        title: 'IPv4 Only Bindings',
        description:
            'Disables non-essential adapter bindings and keeps IPv4 enabled on all adapters.',
        aggressive: true,
        conflictingTweakIds: const <String>{'network_prefer_ipv4'},
      );

  static const List<String> _disableBindings = <String>[
    'ms_lldp',
    'ms_lltdio',
    'ms_implat',
    'ms_rspndr',
    'ms_tcpip6',
    'ms_server',
    'ms_msclient',
    'ms_pacer',
  ];

  static const List<String> _enableBindings = <String>[
    'ms_lldp',
    'ms_lltdio',
    'ms_implat',
    'ms_tcpip',
    'ms_rspndr',
    'ms_tcpip6',
    'ms_server',
    'ms_msclient',
    'ms_pacer',
  ];

  @override
  Future<void> onApply() async {
    final disableList = _disableBindings.map((id) => "'$id'").join(',');
    final script =
        r'''
$bindingsToDisable = @(__DISABLE_LIST__)
foreach ($binding in $bindingsToDisable) {
  Disable-NetAdapterBinding -Name '*' -ComponentID $binding -ErrorAction SilentlyContinue | Out-Null
}

Enable-NetAdapterBinding -Name '*' -ComponentID 'ms_tcpip' -ErrorAction SilentlyContinue | Out-Null
'''
            .replaceAll('__DISABLE_LIST__', disableList);

    await runSilentPowerShell(script, elevated: true);
  }

  @override
  Future<void> onRevert() async {
    final enableList = _enableBindings.map((id) => "'$id'").join(',');
    final script =
        r'''
$bindingsToEnable = @(__ENABLE_LIST__)
foreach ($binding in $bindingsToEnable) {
  Enable-NetAdapterBinding -Name '*' -ComponentID $binding -ErrorAction SilentlyContinue | Out-Null
}
'''
            .replaceAll('__ENABLE_LIST__', enableList);

    await runSilentPowerShell(script, elevated: true);
  }

  @override
  Future<bool> checkState() async {
    final disableList = _disableBindings.map((id) => "'$id'").join(',');
    final script =
        r'''
$bindingsToDisable = @(__DISABLE_LIST__)
$allBindings = Get-NetAdapterBinding -Name '*' -ErrorAction SilentlyContinue

if (-not $allBindings -or $allBindings.Count -eq 0) {
  Write-Output 'false'
  return
}

$ipv4Enabled = $allBindings | Where-Object { $_.ComponentID -eq 'ms_tcpip' -and $_.Enabled -eq $true }
if (-not $ipv4Enabled) {
  Write-Output 'false'
  return
}

foreach ($bindingId in $bindingsToDisable) {
  $entries = $allBindings | Where-Object { $_.ComponentID -eq $bindingId }
  if ($entries -and ($entries | Where-Object { $_.Enabled -eq $true })) {
    Write-Output 'false'
    return
  }
}

Write-Output 'true'
'''
            .replaceAll('__DISABLE_LIST__', disableList);

    final result = (await runPowerShellForOutput(script)).toLowerCase();

    final applied = result.contains('true');
    return applied;
  }
}

class PreferIpv4Tweak extends _NetworkingSystemTweak {
  PreferIpv4Tweak()
    : super(
        id: 'network_prefer_ipv4',
        title: 'Prefer IPv4 over IPv6',
        description:
            'Keeps IPv6 enabled but gives IPv4 precedence. Cannot be combined with IPv4 Only Bindings.',
        conflictingTweakIds: const <String>{'network_ipv4_only'},
      );

  static const String _tcpip6Parameters =
      r'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters';
  static const int _preferIpv4Mask = 0x20;

  @override
  Future<void> onApply() async {
    final current =
        await RegistryManager.readDword(
          _tcpip6Parameters,
          'DisabledComponents',
        ) ??
        0;
    await RegistryManager.writeDword(
      _tcpip6Parameters,
      'DisabledComponents',
      current | _preferIpv4Mask,
    );
  }

  @override
  Future<void> onRevert() async {
    final current = await RegistryManager.readDword(
      _tcpip6Parameters,
      'DisabledComponents',
    );
    if (current == null) {
      return;
    }

    final restored = current & ~_preferIpv4Mask;
    if (restored == 0) {
      await RegistryManager.deleteValue(
        _tcpip6Parameters,
        'DisabledComponents',
      );
    } else {
      await RegistryManager.writeDword(
        _tcpip6Parameters,
        'DisabledComponents',
        restored,
      );
    }
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _tcpip6Parameters,
      'DisabledComponents',
    );
    return current != null && (current & _preferIpv4Mask) != 0;
  }
}

class NetworkThrottlingIndexTweak extends SystemTweak {
  NetworkThrottlingIndexTweak()
    : super(
        id: 'network_throttling_index_off',
        title: 'Network Throttling Index Off',
        description:
            'Sets NetworkThrottlingIndex to 0xFFFFFFFF to remove multimedia throttling limits.',
        category: 'Networking',
      );

  static const String _keyPath =
      r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _keyPath,
      'NetworkThrottlingIndex',
      0xFFFFFFFF,
    );
  }

  @override
  Future<void> onRevert() async {
    final current = await RegistryManager.readDword(
      _keyPath,
      'NetworkThrottlingIndex',
    );
    if (current != null) {
      await RegistryManager.deleteValue(_keyPath, 'NetworkThrottlingIndex');
    }
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _keyPath,
      'NetworkThrottlingIndex',
    );
    final applied = current != null && current.toUnsigned(32) == 0xFFFFFFFF;
    return applied;
  }
}

class NetworkMmAgentTweak extends _NetworkingSystemTweak {
  NetworkMmAgentTweak()
    : super(
        id: 'network_mmagent_features_off',
        title: 'MMAgent Features Off',
        description:
            'Disables MMAgent prefetch/prelaunch/OperationAPI features and sets Prefetcher to 0.',
      );

  static const String _prefetchKey =
      r'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_prefetchKey, 'EnablePrefetcher', 0);

    await runSilentPowerShell(r'''
Disable-MMAgent -ApplicationLaunchPrefetching -ErrorAction SilentlyContinue | Out-Null
Disable-MMAgent -ApplicationPreLaunch -ErrorAction SilentlyContinue | Out-Null
Set-MMAgent -MaxOperationAPIFiles 1 -ErrorAction SilentlyContinue | Out-Null
Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue | Out-Null
Disable-MMAgent -OperationAPI -ErrorAction SilentlyContinue | Out-Null
Disable-MMAgent -PageCombining -ErrorAction SilentlyContinue | Out-Null
''', elevated: true);
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_prefetchKey, 'EnablePrefetcher', 3);

    await runSilentPowerShell(r'''
Enable-MMAgent -ApplicationLaunchPrefetching -ErrorAction SilentlyContinue | Out-Null
Enable-MMAgent -ApplicationPreLaunch -ErrorAction SilentlyContinue | Out-Null
Set-MMAgent -MaxOperationAPIFiles 512 -ErrorAction SilentlyContinue | Out-Null
Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue | Out-Null
Enable-MMAgent -OperationAPI -ErrorAction SilentlyContinue | Out-Null
Enable-MMAgent -PageCombining -ErrorAction SilentlyContinue | Out-Null
''', elevated: true);
  }

  @override
  Future<bool> checkState() async {
    final prefetch = await RegistryManager.readDword(
      _prefetchKey,
      'EnablePrefetcher',
    );

    final mmAgentState = (await runPowerShellForOutput(r'''
$m = Get-MMAgent -ErrorAction SilentlyContinue
if ($null -eq $m) {
  Write-Output 'false'
  return
}

if (-not $m.ApplicationLaunchPrefetching -and -not $m.ApplicationPreLaunch -and -not $m.MemoryCompression -and -not $m.OperationAPI -and -not $m.PageCombining -and $m.MaxOperationAPIFiles -eq 1) {
  Write-Output 'true'
} else {
  Write-Output 'false'
}
''')).toLowerCase();

    final applied = prefetch == 0 && mmAgentState.contains('true');
    return applied;
  }
}
