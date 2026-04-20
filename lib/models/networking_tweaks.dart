import 'dart:convert';
import 'dart:typed_data';

import '../core/registry_manager.dart';
import '../core/services/process_runner.dart';
import 'action_tweaks.dart';
import 'system_tweak.dart';

List<SystemTweak> createNetworkingTweaks() {
  return <SystemTweak>[
    NetworkAdapterPowerSavingsTweak(),
    NetworkIpv4OnlyTweak(),
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

    isApplied = await checkState();
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

    isApplied = await checkState();
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

$rscDisabled = ("$($offload.ReceiveSegmentCoalescing)" -eq 'Disabled')
$pcfDisabled = ("$($offload.PacketCoalescingFilter)" -eq 'Disabled')
$delayedAckLow = ($tcp.DelayedAckFrequency -eq 1)
$autoTuningDisabled = ("$($tcp.AutoTuningLevelLocal)" -eq 'Disabled')

if ($rscDisabled -and $pcfDisabled -and $delayedAckLow -and $autoTuningDisabled) {
  Write-Output 'true'
} else {
  Write-Output 'false'
}
''')).toLowerCase();

    final applied = result.contains('true');
    isApplied = applied;
    return applied;
  }
}

abstract class _NetworkingSystemTweak extends SystemTweak {
  _NetworkingSystemTweak({
    required super.id,
    required super.title,
    required super.description,
    bool aggressive = false,
  }) : super(category: 'Networking', isAggressive: aggressive);

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

class NetworkAdapterPowerSavingsTweak extends _NetworkingSystemTweak {
  NetworkAdapterPowerSavingsTweak()
    : super(
        id: 'network_adapter_power_savings_wake_off',
        title: 'Adapter Power Savings and Wake Off',
        description:
            'Disables adapter-level power saving and wake features on all network class devices.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
$basePath = 'HKLM:\\System\\ControlSet001\\Control\\Class\\{4d36e972-e325-11ce-bfc1-08002be10318}'
$adapterKeys = Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue

foreach ($key in $adapterKeys) {
  if ($key.PSChildName -match '^\d{4}$') {
    $regPath = $key.PSPath

    New-ItemProperty -Path $regPath -Name 'PnPCapabilities' -PropertyType DWord -Value 24 -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'AdvancedEEE' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name '*EEE' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'EEELinkAdvertisement' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'SipsEnabled' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'ULPMode' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'GigaLite' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'EnableGreenEthernet' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'PowerSavingMode' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null

    New-ItemProperty -Path $regPath -Name 'S5WakeOnLan' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name '*WakeOnMagicPacket' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name '*ModernStandbyWoLMagicPacket' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name '*WakeOnPattern' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path $regPath -Name 'WakeOnLink' -PropertyType String -Value '0' -Force -ErrorAction SilentlyContinue | Out-Null
  }
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
$basePath = 'HKLM:\\System\\ControlSet001\\Control\\Class\\{4d36e972-e325-11ce-bfc1-08002be10318}'
$adapterKeys = Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue
$values = @(
  'PnPCapabilities','AdvancedEEE','*EEE','EEELinkAdvertisement','SipsEnabled',
  'ULPMode','GigaLite','EnableGreenEthernet','PowerSavingMode','S5WakeOnLan',
  '*WakeOnMagicPacket','*ModernStandbyWoLMagicPacket','*WakeOnPattern','WakeOnLink'
)

foreach ($key in $adapterKeys) {
  if ($key.PSChildName -match '^\d{4}$') {
    foreach ($name in $values) {
      Remove-ItemProperty -Path $key.PSPath -Name $name -ErrorAction SilentlyContinue
    }
  }
}
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final result = (await runPowerShellForOutput(r'''
$basePath = 'HKLM:\\System\\ControlSet001\\Control\\Class\\{4d36e972-e325-11ce-bfc1-08002be10318}'
$adapterKeys = Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match '^\d{4}$' }

if (-not $adapterKeys -or $adapterKeys.Count -eq 0) {
  Write-Output 'false'
  return
}

foreach ($key in $adapterKeys) {
  $item = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
  if ($null -eq $item) {
    Write-Output 'false'
    return
  }

  if ($item.PnPCapabilities -ne 24) {
    Write-Output 'false'
    return
  }
}

Write-Output 'true'
''')).toLowerCase();

    final applied = result.contains('true');
    isApplied = applied;
    return applied;
  }
}

class NetworkIpv4OnlyTweak extends _NetworkingSystemTweak {
  NetworkIpv4OnlyTweak()
    : super(
        id: 'network_ipv4_only',
        title: 'IPv4 Only Bindings',
        description:
            'Disables non-essential adapter bindings and keeps IPv4 enabled on all adapters.',
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

    isApplied = await checkState();
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

    isApplied = await checkState();
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
    isApplied = applied;
    return applied;
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
    isApplied = true;
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
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _keyPath,
      'NetworkThrottlingIndex',
    );
    final applied = current != null && current.toUnsigned(32) == 0xFFFFFFFF;
    isApplied = applied;
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

    isApplied = await checkState();
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

    isApplied = await checkState();
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

if (-not $m.ApplicationLaunchPrefetching -and -not $m.ApplicationPreLaunch -and -not $m.OperationAPI -and -not $m.PageCombining) {
  Write-Output 'true'
} else {
  Write-Output 'false'
}
''')).toLowerCase();

    final applied = prefetch == 0 && mmAgentState.contains('true');
    isApplied = applied;
    return applied;
  }
}
