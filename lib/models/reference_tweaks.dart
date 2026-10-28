import '../core/registry_manager.dart';
import '../core/services/process_runner.dart';
import '../features/apps/domain/microsoft_restore_catalog.dart';
import '../platform/windows/service_control_manager.dart';
import 'system_tweak.dart';

const _graphicsDrivers =
    r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers';
const _systemPolicies = r'HKLM\SOFTWARE\Policies\Microsoft\Windows\System';

/// Missing, individually controllable Windows options found during the
/// reference-feature audit. Existing bundled profiles remain the source for
/// their broader equivalents; these entries intentionally expose only knobs
/// that were not already available on their own.
List<SystemTweak> createReferenceTweaks() => <SystemTweak>[
  PowerShellStateTweak(
    id: 'network_llmnr_off',
    title: 'LLMNR Off',
    description: 'Disables legacy local multicast name resolution.',
    category: 'Networking',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name EnableMulticast -Type DWord -Value 0''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name EnableMulticast -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient',
          'EnableMulticast',
        ) ==
        0,
  ),
  PowerShellStateTweak(
    id: 'network_delivery_optimization_off',
    title: 'Delivery Optimization P2P Off',
    description: 'Stops Windows Update peer-to-peer uploads and downloads.',
    category: 'Networking',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name DODownloadMode -Type DWord -Value 0''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name DODownloadMode -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization',
          'DODownloadMode',
        ) ==
        0,
  ),
  PowerShellStateTweak(
    id: 'network_fast_udp_datagram_send',
    title: 'Fast UDP Datagram Send',
    description: 'Raises the AFD datagram send threshold for UDP workloads.',
    category: 'Networking',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Afd\Parameters' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Afd\Parameters' -Name FastSendDatagramThreshold -Type DWord -Value 65536''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Afd\Parameters' -Name FastSendDatagramThreshold -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SYSTEM\CurrentControlSet\Services\Afd\Parameters',
          'FastSendDatagramThreshold',
        ) ==
        65536,
  ),
  PowerShellStateTweak(
    id: 'gaming_variable_refresh_rate_on',
    title: 'Variable Refresh Rate On',
    description:
        'Enables the Windows variable refresh rate preference for compatible games.',
    category: 'Gaming',
    applyScript:
        r'''$path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
$current = [string](Get-ItemProperty -Path $path -Name DirectXUserGlobalSettings -ErrorAction SilentlyContinue).DirectXUserGlobalSettings
$next = [regex]::Replace($current, 'VRROptimizeEnable=\d+;', '')
Set-ItemProperty -Path $path -Name DirectXUserGlobalSettings -Type String -Value ($next + 'VRROptimizeEnable=1;')''',
    revertScript:
        r'''$path = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
$current = [string](Get-ItemProperty -Path $path -Name DirectXUserGlobalSettings -ErrorAction SilentlyContinue).DirectXUserGlobalSettings
Set-ItemProperty -Path $path -Name DirectXUserGlobalSettings -Type String -Value ([regex]::Replace($current, 'VRROptimizeEnable=\d+;', 'VRROptimizeEnable=0;'))''',
    check: () async =>
        (await RegistryManager.readString(
          r'HKCU\Software\Microsoft\DirectX\UserGpuPreferences',
          'DirectXUserGlobalSettings',
        ))?.contains('VRROptimizeEnable=1;') ??
        false,
  ),
  PowerShellStateTweak(
    id: 'gaming_extended_gpu_timeout',
    title: 'Extended GPU Timeout',
    description:
        'Sets a 10-second GPU timeout detection delay for troubleshooting unstable heavy GPU workloads.',
    category: 'Gaming',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name TdrDelay -Type DWord -Value 10
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name TdrDdiDelay -Type DWord -Value 20''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name TdrDelay -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name TdrDdiDelay -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(_graphicsDrivers, 'TdrDelay') == 10 &&
        await RegistryManager.readDword(_graphicsDrivers, 'TdrDdiDelay') == 20,
  ),
  PowerShellStateTweak(
    id: 'ui_sticky_keys_shortcut_off',
    title: 'Sticky Keys Shortcut Off',
    description:
        'Prevents the Shift five-times shortcut from opening Sticky Keys.',
    category: 'Visuals',
    applyScript:
        r'''Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name Flags -Type String -Value '506' ''',
    revertScript:
        r'''Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name Flags -Type String -Value '510' ''',
    check: () async =>
        await RegistryManager.readString(
          r'HKCU\Control Panel\Accessibility\StickyKeys',
          'Flags',
        ) ==
        '506',
  ),
  PowerShellStateTweak(
    id: 'windows_ntfs_last_access_updates_off',
    title: 'NTFS Last-Access Updates Off',
    description:
        'Stops NTFS from updating a timestamp every time a file is read.',
    category: 'Windows',
    applyScript: r'''fsutil behavior set disablelastaccess 1 | Out-Null''',
    revertScript: r'''fsutil behavior set disablelastaccess 2 | Out-Null''',
    checkScript:
        r'''(fsutil behavior query disablelastaccess | Out-String) -match 'DisableLastAccess\s*=\s*1' | ForEach-Object { $_.ToString().ToLower() }''',
  ),
  PowerShellStateTweak(
    id: 'windows_automatic_maintenance_off',
    title: 'Automatic Maintenance Off',
    description:
        'Disables scheduled automatic maintenance while preserving manual maintenance tools.',
    category: 'Windows',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance' -Name MaintenanceDisabled -Type DWord -Value 1''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance' -Name MaintenanceDisabled -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance',
          'MaintenanceDisabled',
        ) ==
        1,
  ),
  PowerShellStateTweak(
    id: 'windows_auto_reboot_after_bsod_off',
    title: 'Auto-reboot After BSOD Off',
    description:
        'Keeps a stop code on screen instead of automatically restarting after a crash.',
    category: 'Windows',
    applyScript:
        r'''Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name AutoReboot -Type DWord -Value 0''',
    revertScript:
        r'''Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name AutoReboot -Type DWord -Value 1''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl',
          'AutoReboot',
        ) ==
        0,
  ),
  PowerShellStateTweak(
    id: 'checks_vbs_off',
    title: 'Virtualization-Based Security Off',
    description:
        'Disables VBS policy. This weakens Windows isolation protections and requires a restart.',
    category: 'System Checks',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard' -Name EnableVirtualizationBasedSecurity -Type DWord -Value 0''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard' -Name EnableVirtualizationBasedSecurity -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard',
          'EnableVirtualizationBasedSecurity',
        ) ==
        0,
  ),
  PowerShellStateTweak(
    id: 'checks_smart_screen_off',
    title: 'SmartScreen Off',
    description:
        'Disables Windows reputation checks. Use only for controlled testing.',
    category: 'System Checks',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name EnableSmartScreen -Type DWord -Value 0''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name EnableSmartScreen -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(_systemPolicies, 'EnableSmartScreen') ==
        0,
  ),
  PowerShellStateTweak(
    id: 'toggle_printing_off',
    title: 'Printing Off',
    description: 'Disables the Print Spooler service until reverted.',
    category: 'Services',
    aggressive: true,
    applyScript:
        r'''Set-Service -Name Spooler -StartupType Disabled; Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue''',
    revertScript: r'''Set-Service -Name Spooler -StartupType Manual''',
    check: () async => serviceDisabled('Spooler'),
  ),
  PowerShellStateTweak(
    id: 'toggle_location_off',
    title: 'Location Off',
    description: 'Disables Windows location services through policy.',
    category: 'Privacy',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Name DisableLocation -Type DWord -Value 1''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Name DisableLocation -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors',
          'DisableLocation',
        ) ==
        1,
  ),
  PowerShellStateTweak(
    id: 'toggle_automatic_driver_updates_off',
    title: 'Automatic Driver Updates Off',
    description:
        'Prevents Windows Update from automatically installing driver updates.',
    category: 'Windows',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name ExcludeWUDriversInQualityUpdate -Type DWord -Value 1''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name ExcludeWUDriversInQualityUpdate -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate',
          'ExcludeWUDriversInQualityUpdate',
        ) ==
        1,
  ),
  PowerShellStateTweak(
    id: 'toggle_storage_sense_off',
    title: 'Storage Sense Off',
    description: 'Disables automatic temporary-file cleanup.',
    category: 'Windows',
    applyScript:
        r'''Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name 01 -Type DWord -Value 0''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name 01 -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy',
          '01',
        ) ==
        0,
  ),
  PowerShellStateTweak(
    id: 'toggle_activity_history_off',
    title: 'Activity History Off',
    description:
        'Stops Windows from publishing and uploading activity history.',
    category: 'Privacy',
    aggressive: true,
    applyScript:
        r'''New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name EnableActivityFeed -Type DWord -Value 0
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name PublishUserActivities -Type DWord -Value 0
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name UploadUserActivities -Type DWord -Value 0''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name EnableActivityFeed,PublishUserActivities,UploadUserActivities -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
              _systemPolicies,
              'EnableActivityFeed',
            ) ==
            0 &&
        await RegistryManager.readDword(
              _systemPolicies,
              'PublishUserActivities',
            ) ==
            0 &&
        await RegistryManager.readDword(
              _systemPolicies,
              'UploadUserActivities',
            ) ==
            0,
  ),
  PowerShellStateTweak(
    id: 'toggle_scheduled_defrag_off',
    title: 'Scheduled Defrag / TRIM Off',
    description:
        'Disables the scheduled Optimize Drives task; manual optimization remains available.',
    category: 'Windows',
    aggressive: true,
    applyScript:
        r'''Disable-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName ScheduledDefrag -ErrorAction Stop | Out-Null''',
    revertScript:
        r'''Enable-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName ScheduledDefrag -ErrorAction Stop | Out-Null''',
    checkScript:
        r'''((Get-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName ScheduledDefrag -ErrorAction SilentlyContinue).State -eq 'Disabled').ToString().ToLower()''',
  ),
  PowerShellStateTweak(
    id: 'toggle_center_taskbar_icons',
    title: 'Center Taskbar Icons',
    description: 'Uses the Windows 11 centered taskbar icon alignment.',
    category: 'Visuals',
    applyScript:
        r'''Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarAl -Type DWord -Value 1''',
    revertScript:
        r'''Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarAl -Type DWord -Value 0''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
          'TaskbarAl',
        ) ==
        1,
  ),
  PowerShellStateTweak(
    id: 'checks_vulnerable_driver_blocklist_off',
    title: 'Vulnerable Driver Blocklist Off',
    description:
        'Disables Microsoft\'s vulnerable driver blocklist. This weakens kernel protection and requires a restart.',
    category: 'System Checks',
    aggressive: true,
    applyScript:
        r'''Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Config' -Name VulnerableDriverBlocklistEnable -Type DWord -Value 0''',
    revertScript:
        r'''Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Config' -Name VulnerableDriverBlocklistEnable -ErrorAction SilentlyContinue''',
    check: () async =>
        await RegistryManager.readDword(
          r'HKLM\SYSTEM\CurrentControlSet\Control\CI\Config',
          'VulnerableDriverBlocklistEnable',
        ) ==
        0,
  ),
  WindowsSettingsLauncherTweak(
    id: 'shortcut_device_manager',
    title: 'Device Manager',
    description: 'Opens Device Manager.',
    command: 'devmgmt.msc',
  ),
  WindowsSettingsLauncherTweak(
    id: 'shortcut_hosts_file',
    title: 'Hosts File',
    description: 'Opens the hosts file in Notepad.',
    command: r'notepad.exe %SystemRoot%\System32\drivers\etc\hosts',
  ),
  ..._shortcutTweaks(),
  ..._serviceTweaks(),
  ..._restoreTweaks(),
  WingetInteractiveTweak(),
];

List<SystemTweak> _shortcutTweaks() => <SystemTweak>[
  _settingsShortcut(
    'shortcut_display',
    'Display',
    'Resolution, scaling, HDR and refresh rate.',
    'ms-settings:display',
  ),
  _settingsShortcut(
    'shortcut_sound',
    'Sound',
    'Output, input and volume settings.',
    'ms-settings:sound',
  ),
  _settingsShortcut(
    'shortcut_network',
    'Network',
    'Ethernet, Wi-Fi, VPN and proxy settings.',
    'ms-settings:network-status',
  ),
  _settingsShortcut(
    'shortcut_bluetooth',
    'Bluetooth and devices',
    'Paired devices, printers and mouse settings.',
    'ms-settings:bluetooth',
  ),
  _settingsShortcut(
    'shortcut_power_battery',
    'Power and battery',
    'Sleep, screen timeout and battery settings.',
    'ms-settings:powersleep',
  ),
  _settingsShortcut(
    'shortcut_installed_apps',
    'Installed Apps',
    'Uninstall and repair installed applications.',
    'ms-settings:appsfeatures',
  ),
  _settingsShortcut(
    'shortcut_personalization',
    'Personalization',
    'Background, colors and lock-screen settings.',
    'ms-settings:personalization',
  ),
  _settingsShortcut(
    'shortcut_privacy_security',
    'Privacy and security',
    'Privacy permissions and Windows security.',
    'ms-settings:privacy',
  ),
  _settingsShortcut(
    'shortcut_windows_update',
    'Windows Update',
    'Check for and install updates.',
    'ms-settings:windowsupdate',
  ),
  _settingsShortcut(
    'shortcut_graphics_settings',
    'Graphics Settings',
    'Per-app GPU preference and HAGS.',
    'ms-settings:display-advancedgraphics',
  ),
  _settingsShortcut(
    'shortcut_game_mode',
    'Game Mode Settings',
    'Windows Game Mode settings.',
    'ms-settings:gaming-gamemode',
  ),
  _settingsShortcut(
    'shortcut_optional_features',
    'Optional Features',
    'Manage Windows optional features.',
    'ms-settings:optionalfeatures',
  ),
  _toolShortcut(
    'shortcut_disk_management',
    'Disk Management',
    'Partitions, volumes and drive letters.',
    'diskmgmt.msc',
  ),
  _toolShortcut(
    'shortcut_services',
    'Services',
    'Start, stop and configure Windows services.',
    'services.msc',
  ),
  _toolShortcut(
    'shortcut_task_scheduler',
    'Task Scheduler',
    'Scheduled tasks and triggers.',
    'taskschd.msc',
  ),
  _toolShortcut(
    'shortcut_event_viewer',
    'Event Viewer',
    'System and application logs.',
    'eventvwr.msc',
  ),
  _toolShortcut(
    'shortcut_computer_management',
    'Computer Management',
    'Unified console for system tools.',
    'compmgmt.msc',
  ),
  _toolShortcut(
    'shortcut_performance_monitor',
    'Performance Monitor',
    'Live counters and data sets.',
    'perfmon.msc',
  ),
  _toolShortcut(
    'shortcut_resource_monitor',
    'Resource Monitor',
    'CPU, memory, disk and network activity.',
    'resmon.exe',
  ),
  _toolShortcut(
    'shortcut_system_configuration',
    'System Configuration',
    'Boot options and startup services.',
    'msconfig.exe',
  ),
  _toolShortcut(
    'shortcut_advanced_system_settings',
    'Advanced System Settings',
    'Performance, visual effects and environment settings.',
    'sysdm.cpl',
  ),
  _toolShortcut(
    'shortcut_directx_diagnostic',
    'DirectX Diagnostic',
    'GPU, DirectX version and audio diagnostics.',
    'dxdiag.exe',
  ),
  _toolShortcut(
    'shortcut_reliability_history',
    'Reliability History',
    'Crashes, failures and stability history.',
    'perfmon /rel',
  ),
  _toolShortcut(
    'shortcut_windows_features',
    'Windows Features',
    'Turn Windows features on or off.',
    'optionalfeatures.exe',
  ),
  _toolShortcut(
    'shortcut_environment_variables',
    'Environment Variables',
    'System and user PATH, TEMP and other variables.',
    'rundll32.exe sysdm.cpl,EditEnvironmentVariables',
  ),
  _toolShortcut(
    'shortcut_registry_editor',
    'Registry Editor',
    'Direct registry access.',
    'regedit.exe',
  ),
  _toolShortcut(
    'shortcut_startup_folder',
    'Startup Folder',
    'Per-user startup applications.',
    'explorer.exe shell:startup',
  ),
];

WindowsSettingsLauncherTweak _settingsShortcut(
  String id,
  String title,
  String description,
  String uri,
) => WindowsSettingsLauncherTweak(
  id: id,
  title: title,
  description: description,
  command: 'start "" $uri',
);

WindowsSettingsLauncherTweak _toolShortcut(
  String id,
  String title,
  String description,
  String command,
) => WindowsSettingsLauncherTweak(
  id: id,
  title: title,
  description: description,
  command: command,
);

List<SystemTweak> _restoreTweaks() => <SystemTweak>[
  for (final app in microsoftRestoreCatalog.entries)
    WingetRestoreTweak(
      legacyPackageName: switch (app.key) {
        'Microsoft.MicrosoftStickyNotes' => 'Microsoft.StickyNotes',
        'MicrosoftCorporationII.QuickAssist' => 'Microsoft.QuickAssist',
        _ => app.key,
      },
      packageId: app.value.packageId,
      source: app.value.source,
      title: app.value.name,
    ),
];

List<SystemTweak> _serviceTweaks() => <SystemTweak>[
  for (final entry in <(String, String)>[
    ('DiagTrack', 'Connected User Experiences and Telemetry'),
    ('dmwappushservice', 'WAP Push Message Routing Service'),
    ('diagsvc', 'Diagnostic Execution Service'),
    ('TroubleshootingSvc', 'Recommended Troubleshooting Service'),
    ('WerSvc', 'Windows Error Reporting Service'),
    ('PcaSvc', 'Program Compatibility Assistant Service'),
    ('InventorySvc', 'Inventory and Compatibility Appraisal'),
    ('XblAuthManager', 'Xbox Live Auth Manager'),
    ('XblGameSave', 'Xbox Live Game Save'),
    ('XboxNetApiSvc', 'Xbox Live Networking Service'),
    ('RemoteRegistry', 'Remote Registry'),
    ('RemoteAccess', 'Routing and Remote Access'),
    ('lmhosts', 'TCP/IP NetBIOS Helper'),
    ('WMPNetworkSvc', 'Windows Media Player Network Sharing'),
    ('MapsBroker', 'Downloaded Maps Manager'),
    ('SCardSvr', 'Smart Card'),
    ('ScDeviceEnum', 'Smart Card Device Enumeration'),
    ('SEMgrSvc', 'Payments and NFC/SE Manager'),
    ('WpnService', 'Windows Push Notifications System Service'),
    ('TrkWks', 'Distributed Link Tracking Client'),
    ('EFS', 'Encrypting File System'),
    ('WpcMonSvc', 'Parental Controls'),
    ('Wecsvc', 'Windows Event Collector'),
    ('shpamsvc', 'Shared PC Account Manager'),
    ('svsvc', 'Spot Verifier'),
    ('wisvc', 'Windows Insider Service'),
    ('DevQueryBroker', 'DevQuery Background Discovery Broker'),
    ('PimIndexMaintenanceSvc', 'Contact Data'),
    ('MessagingService', 'Text Messaging'),
    ('RetailDemo', 'Retail Demo Service'),
  ])
    ServiceDisabledTweak(serviceName: entry.$1, title: entry.$2),
];

class PowerShellStateTweak extends SystemTweak {
  PowerShellStateTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.applyScript,
    required this.revertScript,
    this.checkScript,
    this.check,
    bool aggressive = false,
  }) : assert((checkScript == null) != (check == null)),
       super(isAggressive: aggressive);

  final String applyScript;
  final String revertScript;

  /// PowerShell that prints `true`; only for states the registry or SCM
  /// cannot answer, since every check starts a PowerShell at launch.
  final String? checkScript;

  /// Native check (registry, SCM): no process at startup.
  final Future<bool> Function()? check;

  @override
  Future<void> onApply() => runSilentPowerShell(applyScript, elevated: true);

  @override
  Future<void> onRevert() => runSilentPowerShell(revertScript, elevated: true);

  @override
  Future<bool> checkState() async =>
      await check?.call() ??
      (await runPowerShellForOutput(checkScript!)).trim().toLowerCase() ==
          'true';
}

/// Start type Disabled, read from the Service Control Manager.
/// Missing or unreadable services count as not disabled.
Future<bool> serviceDisabled(String name) async {
  try {
    return const ServiceControlManager().inspect(name).startType == 4;
  } catch (_) {
    return false;
  }
}

class WingetRestoreTweak extends ActionSystemTweak {
  WingetRestoreTweak({
    required String legacyPackageName,
    required this.packageId,
    required this.source,
    required String title,
  }) : super(
         id: 'restore_${legacyPackageName.toLowerCase().replaceAll('.', '_')}',
         title: 'Restore $title',
         description:
             'Installs $title from the configured Windows package sources.',
         category: 'Refresh & Recovery',
         type: TweakUiType.launcher,
         actionLabel: 'Restore',
       );

  final String packageId;
  final String source;

  @override
  bool get requiresSafetyPrompt => false;

  @override
  Future<void> onApply() async {
    final result = await ProcessRunner.shared.run('winget', <String>[
      'install',
      '--exact',
      '--id',
      packageId,
      '--source',
      source,
      '--accept-package-agreements',
      '--accept-source-agreements',
    ], timeout: const Duration(minutes: 5));
    if (!result.success) {
      throw Exception('Unable to restore $title (${result.details}).');
    }
  }
}

class WingetInteractiveTweak extends ActionSystemTweak {
  WingetInteractiveTweak()
    : super(
        id: 'tool_winget_interactive_uninstaller',
        title: 'Interactive App Uninstaller',
        description:
            'Lists installed Winget applications in a terminal so you can select one to remove.',
        category: 'Drivers & Installers',
        type: TweakUiType.interactiveScript,
        actionLabel: 'Open',
        isAggressive: true,
        warningMessage:
            'Uninstall only software you recognize. Removed desktop applications cannot be restored by ZapTweaks.',
      );

  @override
  bool get requiresSafetyPrompt => false;

  @override
  Future<void> onApply() async {
    final result = await ProcessRunner.shared
        .launch('powershell', const <String>[
          '-NoExit',
          '-NoProfile',
          '-Command',
          'winget list; Write-Host "Use: winget uninstall --id <package-id>"',
        ]);
    if (!result.success) {
      throw Exception(
        'Unable to open the app uninstaller (${result.details}).',
      );
    }
  }
}

class ServiceDisabledTweak extends SystemTweak {
  ServiceDisabledTweak({required this.serviceName, required String title})
    : super(
        id: 'service_${serviceName.toLowerCase()}_off',
        title: '$title Off',
        description:
            'Disables $title and restores its exact previous startup state when reverted.',
        category: 'Services',
        isAggressive: true,
      );

  final String serviceName;

  String get _backupPath =>
      '\$env:ProgramData\\ZapTweaks\\backups\\service-$serviceName.xml';

  @override
  Future<void> onApply() => runSilentPowerShell(
    r'''
$service = Get-CimInstance Win32_Service -Filter "Name='__SERVICE__'" -ErrorAction Stop
$backup = __BACKUP__
New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
$service | Select-Object Name, StartMode, State | Export-Clixml -LiteralPath $backup -Force
Set-Service -Name $service.Name -StartupType Disabled -ErrorAction Stop
if ($service.State -eq 'Running') { Stop-Service -Name $service.Name -Force -ErrorAction SilentlyContinue }
'''
        .replaceAll('__SERVICE__', serviceName)
        .replaceAll('__BACKUP__', _backupPath),
    elevated: true,
  );

  @override
  Future<void> onRevert() => runSilentPowerShell(
    r'''
$backup = __BACKUP__
if (-not (Test-Path -LiteralPath $backup)) { return }
$state = Import-Clixml -LiteralPath $backup
$startup = if ($state.StartMode -eq 'Auto') { 'Automatic' } elseif ($state.StartMode -eq 'Disabled') { 'Disabled' } else { 'Manual' }
Set-Service -Name $state.Name -StartupType $startup -ErrorAction Stop
if ($state.State -eq 'Running') { Start-Service -Name $state.Name -ErrorAction SilentlyContinue }
Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue
'''
        .replaceAll('__BACKUP__', _backupPath),
    elevated: true,
  );

  @override
  Future<bool> checkState() => serviceDisabled(serviceName);
}

class WindowsSettingsLauncherTweak extends ActionSystemTweak {
  WindowsSettingsLauncherTweak({
    required super.id,
    required super.title,
    required super.description,
    required this.command,
  }) : super(
         category: 'Shortcuts',
         type: TweakUiType.launcher,
         actionLabel: 'Open',
       );

  final String command;

  @override
  bool get requiresSafetyPrompt => false;

  @override
  Future<void> onApply() async {
    final result = await ProcessRunner.shared.run('cmd', <String>[
      '/c',
      command,
    ]);
    if (!result.success) {
      throw Exception('Unable to open $title (${result.details}).');
    }
  }
}
