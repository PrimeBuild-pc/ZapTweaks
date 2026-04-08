import 'action_tweaks.dart';
import 'system_tweak.dart';

List<SystemTweak> createRecoveredScriptTweaks() {
  return <SystemTweak>[
    // Converted/native parity entries kept as direct interactive resources
    _script(
      id: 'setup_memory_compression_script',
      title: 'Memory Compression (Script Variant)',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '2 Memory Compression.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'setup_activation_script',
      title: 'Activation (Script Variant)',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '5 Activation.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'setup_background_apps_script',
      title: 'Background Apps (Script Variant)',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '9 Background Apps.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'setup_edge_settings_script',
      title: 'Edge Settings (Script Variant)',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '10 Edge Settings.ps1',
      ],
    ),
    _script(
      id: 'setup_store_settings_script',
      title: 'Store Settings (Script Variant)',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '11 Store Settings.ps1',
      ],
    ),

    // 2 Refresh
    _script(
      id: 'refresh_factory_reset',
      title: 'Factory Reset',
      category: 'Refresh & Recovery',
      relativePath: <String>[
        'interactive_scripts',
        '2 Refresh',
        '1 Factory Reset.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'refresh_account_local',
      title: 'Account Local',
      category: 'Refresh & Recovery',
      relativePath: <String>[
        'interactive_scripts',
        '2 Refresh',
        '2 Account Local.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'refresh_reinstall',
      title: 'Reinstall',
      category: 'Refresh & Recovery',
      relativePath: <String>[
        'interactive_scripts',
        '2 Refresh',
        '3 Reinstall.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'refresh_autounattend',
      title: 'Autounattend',
      category: 'Refresh & Recovery',
      relativePath: <String>[
        'interactive_scripts',
        '2 Refresh',
        '4 Autounattend.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'refresh_updates_drivers_block',
      title: 'Updates Drivers Block',
      category: 'Refresh & Recovery',
      relativePath: <String>[
        'interactive_scripts',
        '2 Refresh',
        '5 Updates Drivers Block.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'refresh_network_driver',
      title: 'Network Driver',
      category: 'Refresh & Recovery',
      relativePath: <String>[
        'interactive_scripts',
        '2 Refresh',
        '6 Network Driver.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'refresh_to_bios',
      title: 'To BIOS',
      category: 'Refresh & Recovery',
      relativePath: <String>[
        'interactive_scripts',
        '2 Refresh',
        '7 To Bios.ps1',
      ],
      aggressive: true,
    ),

    // 3 Setup (remaining scripts)
    _script(
      id: 'setup_bitlocker',
      title: 'BitLocker',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '1 BitLocker.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'setup_convert_home_to_pro',
      title: 'Convert Home To Pro',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '3 Convert Home To Pro.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'setup_keys',
      title: 'Keys',
      category: 'Setup Scripts',
      relativePath: <String>['interactive_scripts', '3 Setup', '4 Keys.ps1'],
      aggressive: true,
    ),
    _script(
      id: 'setup_date_language_region_time',
      title: 'Date Language Region Time',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '6 Date Language Region Time.ps1',
      ],
    ),
    _script(
      id: 'setup_startup_apps_7',
      title: 'Startup Apps (7)',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '7 Startup Apps.ps1',
      ],
    ),
    _script(
      id: 'setup_startup_apps_8',
      title: 'Startup Apps (8)',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '8 Startup Apps.ps1',
      ],
    ),
    _script(
      id: 'setup_updates_pause',
      title: 'Updates Pause',
      category: 'Setup Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '3 Setup',
        '12 Updates Pause.ps1',
      ],
      aggressive: true,
    ),

    // 4 Installers
    _script(
      id: 'installers_menu',
      title: 'Installers Menu',
      category: 'Drivers & Installers',
      relativePath: <String>[
        'interactive_scripts',
        '4 Installers',
        '1 Installers.ps1',
      ],
    ),
    _script(
      id: 'installers_msi_afterburner',
      title: 'MSI Afterburner Script Installer',
      category: 'Drivers & Installers',
      relativePath: <String>[
        'interactive_scripts',
        '4 Installers',
        '2 MSI Afterburner.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'installers_nvidia_profile_inspector',
      title: 'NVIDIA Profile Inspector Script Installer',
      category: 'Drivers & Installers',
      relativePath: <String>[
        'interactive_scripts',
        '4 Installers',
        '3 Nvidia Profile Inspector.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'installers_more_clock_tool',
      title: 'More Clock Tool Script Installer',
      category: 'Drivers & Installers',
      relativePath: <String>[
        'interactive_scripts',
        '4 Installers',
        '4 More Clock Tool.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'installers_cru_sre',
      title: 'CRU SRE Script Installer',
      category: 'Drivers & Installers',
      relativePath: <String>[
        'interactive_scripts',
        '4 Installers',
        '5 CRU SRE.ps1',
      ],
      aggressive: true,
    ),

    // 5 Graphics (remaining scripts)
    _script(
      id: 'graphics_driver_clean',
      title: 'Driver Clean',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '1 Driver Clean.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_driver_install_latest',
      title: 'Driver Install Latest',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '2 Driver Install Latest.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_driver_install_debloat_settings',
      title: 'Driver Install Debloat & Settings',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '3 Driver Install Debloat & Settings.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_nvidia_settings',
      title: 'NVIDIA Settings',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '4 Nvidia Settings.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_amd_settings',
      title: 'AMD Settings',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '5 Amd Settings.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_intel_settings',
      title: 'Intel Settings',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '6 Intel Settings.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_hdcp',
      title: 'HDCP',
      category: 'Graphics Scripts',
      relativePath: <String>['interactive_scripts', '5 Graphics', '7 Hdcp.ps1'],
      aggressive: true,
    ),
    _script(
      id: 'graphics_p0_state',
      title: 'P0 State',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '8 P0 State.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_msi_mode_script',
      title: 'MSI Mode (Script Variant)',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '9 Msi Mode.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_directx',
      title: 'DirectX Runtime',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '10 DirectX.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'graphics_cpp_runtime',
      title: 'C++ Runtime',
      category: 'Graphics Scripts',
      relativePath: <String>['interactive_scripts', '5 Graphics', '11 C++.ps1'],
      aggressive: true,
    ),
    _script(
      id: 'graphics_resolution_refresh_rate',
      title: 'Resolution Refresh Rate',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '12 Resolution Refresh Rate.ps1',
      ],
    ),
    _script(
      id: 'graphics_hags_windowed',
      title: 'HAGS Windowed',
      category: 'Graphics Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '5 Graphics',
        '13 Hags Windowed.ps1',
      ],
      aggressive: true,
    ),

    // 6 Windows (remaining scripts)
    _script(
      id: 'windows_start_menu_taskbar_script',
      title: 'Start Menu Taskbar (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '1 Start Menu Taskbar.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_start_menu_layout_script',
      title: 'Start Menu Layout (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '2 Start Menu Layout.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_start_menu_shortcuts_script',
      title: 'Start Menu Shortcuts (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '3 Start Menu Shortcuts.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_context_menu_script',
      title: 'Context Menu (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '4 Context Menu.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_theme_black_script',
      title: 'Theme Black (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '5 Theme Black.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_signout_lockscreen_wallpaper_black',
      title: 'Signout Lockscreen Wallpaper Black',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '6 Signout Lockscreen Wallpaper Black.ps1',
      ],
    ),
    _script(
      id: 'windows_user_account_pictures_black',
      title: 'User Account Pictures Black',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '7 User Account Pictures Black.ps1',
      ],
    ),
    _script(
      id: 'windows_widgets_script',
      title: 'Widgets (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '8 Widgets.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_copilot_script',
      title: 'Copilot (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '9 Copilot.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_gamemode',
      title: 'Gamemode',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '10 Gamemode.ps1',
      ],
    ),
    _script(
      id: 'windows_pointer_precision_script',
      title: 'Pointer Precision (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '11 Pointer Precision.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_scaling',
      title: 'Scaling',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '12 Scaling.ps1',
      ],
    ),
    _script(
      id: 'windows_notepad_settings',
      title: 'Notepad Settings',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '13 Notepad Settings.ps1',
      ],
    ),
    _script(
      id: 'windows_control_panel_settings_script',
      title: 'Control Panel Settings (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '14 Control Panel Settings.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_sound',
      title: 'Sound',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '15 Sound.ps1',
      ],
    ),
    _script(
      id: 'windows_loudness_eq',
      title: 'Loudness EQ',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '16 Loudness EQ.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_device_manager_power_savings_wake',
      title: 'Device Manager Power Savings & Wake',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '17 Device Manager Power Savings & Wake.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_nvme_faster_driver',
      title: 'NVME Faster Driver',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '20 NVME Faster Driver.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_write_cache_buffer_flushing',
      title: 'Write Cache Buffer Flushing',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '21 Write Cache Buffer Flushing.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_network_adapter_power_savings_script',
      title: 'Network Adapter Power Savings & Wake (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '18 Network Adapter Power Savings & Wake.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_network_ipv4_only_script',
      title: 'Network IPv4 Only (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '19 Network IPv4 Only.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_gamebar_script',
      title: 'Gamebar (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '22 Gamebar.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_edge_webview_script',
      title: 'Edge & WebView (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '23 Edge & WebView.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_bloatware_script',
      title: 'Bloatware (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '24 Bloatware.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_bloatware_legacy_apps_check_script',
      title: 'Bloatware Legacy Apps Check (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '25 Bloatware Legacy Apps Check.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_bloatware_legacy_features_check_script',
      title: 'Bloatware Legacy Features Check (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '26 Bloatware Legacy Features Check.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_bloatware_uwp_apps_check_script',
      title: 'Bloatware UWP Apps Check (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '27 Bloatware UWP Apps Check.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_bloatware_uwp_features_check_script',
      title: 'Bloatware UWP Features Check (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '28 Bloatware UWP Features Check.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_bloatware_taskmgr_check_script',
      title: 'Bloatware TaskMgr Check (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '29 Bloatware TaskMgr Check.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_power_plan_script',
      title: 'Power Plan (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '30 Power Plan.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_timer_resolution_script',
      title: 'Timer Resolution (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '31 Timer Resolution.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_uac_script',
      title: 'UAC (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>['interactive_scripts', '6 Windows', '32 UAC.ps1'],
      aggressive: true,
    ),
    _script(
      id: 'windows_core_isolation_script',
      title: 'Core Isolation (Script Variant)',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '33 Core Isolation.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_defender_optimize',
      title: 'Defender Optimize',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '34 Defender Optimize.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_autoruns_startup_tasks_apps_check',
      title: 'Autoruns Startup Tasks & Apps Check',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '35 Autoruns Startup Tasks & Apps Check.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_cleanup',
      title: 'Cleanup',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '36 Cleanup.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'windows_restore_point',
      title: 'Restore Point',
      category: 'Windows Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '6 Windows',
        '37 Restore Point.ps1',
      ],
      aggressive: true,
    ),

    // 8 Advanced (remaining scripts)
    _script(
      id: 'advanced_defender',
      title: 'Defender',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '1 Defender.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_firewall_script',
      title: 'Firewall (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '2 Firewall.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_spectre_meltdown_script',
      title: 'Spectre Meltdown (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '3 Spectre Meltdown.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_dep_script',
      title: 'Data Execution Prevention (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '4 Data Execution Prevention.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_file_download_security_warning',
      title: 'File Download Security Warning',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '5 File Download Security Warning.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_mmagent_features_script',
      title: 'MMAgent Features (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '6 MMAgent Features.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_rebar_force',
      title: 'ReBar Force',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '7 ReBar Force.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_smt_ht',
      title: 'SMT HT',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '8 Smt Ht.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_core_1_thread_1',
      title: 'Core 1 Thread 1',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '9 Core 1 Thread 1.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_priority',
      title: 'Priority',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '10 Priority.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_mpo_script',
      title: 'MPO (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>['interactive_scripts', '8 Advanced', '11 Mpo.ps1'],
      aggressive: true,
    ),
    _script(
      id: 'advanced_hardware_legacy_flip_script',
      title: 'Hardware Legacy Flip (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '12 Hardware Legacy Flip.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_hardware_composed_flip_script',
      title: 'Hardware Composed Independent Flip (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '13 Hardware Composed Independent Flip.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_ulps_script',
      title: 'ULPS (Script Variant)',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '14 Ulps.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_driver_whql_secure_boot_bypass',
      title: 'Driver WHQL Secure Boot Bypass',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '15 Driver Whql Secure Boot Bypass.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_keyboard_shortcuts',
      title: 'Keyboard Shortcuts',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '16 Keyboard Shortcuts.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_services',
      title: 'Services',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '17 Services.ps1',
      ],
      aggressive: true,
    ),
    _script(
      id: 'advanced_start_search_shell_mobsync',
      title: 'Start Search Shell Mobsync',
      category: 'Advanced Scripts',
      relativePath: <String>[
        'interactive_scripts',
        '8 Advanced',
        '18 Start Search Shell Mobsync.ps1',
      ],
      aggressive: true,
    ),
  ];
}

SystemTweak _script({
  required String id,
  required String title,
  required String category,
  required List<String> relativePath,
  bool aggressive = false,
}) {
  return ScriptInteractiveTweak(
    id: id,
    title: title,
    description: 'Interactive script by Fr33thy.',
    category: category,
    scriptSegments: relativePath,
    isAggressive: aggressive,
  );
}
