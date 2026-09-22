import '../../models/action_tweaks.dart';
import '../../models/reference_tweaks.dart';
import '../../models/system_tweak.dart';

/// Intermediate grouping between a sidebar category and its individual
/// entries. Every descriptor resolves to exactly one collection, so a category
/// page renders as a short list of collapsible collections instead of one long
/// flat list.
class TweakCollections {
  const TweakCollections._();

  /// Render order. Collections not listed here sort alphabetically at the end.
  static const List<String> displayOrder = <String>[
    // Toggle-style collections first: they are the primary content.
    'Core Optimizations',
    'Additional Toggles',
    'Windows Toggles',
    'Interface Toggles',
    'Privacy Toggles',
    'Security Toggles',
    'Service Toggles',
    'Telemetry & Diagnostics',
    'Network & Sharing Services',
    'Cards & Payment Services',
    'Shell & Account Services',
    'Xbox Services',
    'Advanced Toggles',
    // Then scripted and launcher content.
    'Windows Shortcuts',
    'Input & Peripherals',
    'Monitoring & Diagnostics',
    'GPU & Display',
    'Network Tools',
    'Stress Testing',
    'System Maintenance',
    'Debloat & Suites',
    'Driver Scripts',
    'Hardware Checks',
    'Windows Scripts',
    'Shell & Appearance Scripts',
    'Devices & Audio Scripts',
    'System Configuration Scripts',
    'Debloat & Cleanup Scripts',
    'Setup Scripts',
    'Recovery Scripts',
    'Restore Apps',
    'Advanced Scripts',
    'Firmware Tools',
    'Debloat Tools',
    'Scripts & Tools',
  ];

  static int orderIndex(String collection) {
    final index = displayOrder.indexOf(collection);
    return index < 0 ? displayOrder.length : index;
  }

  /// Curated grouping for the categories large enough that a purpose-based
  /// split matters (Tools, Services, Windows scripts). Anything not listed
  /// falls back to [_byKind], so new entries always land somewhere sensible.
  static const Map<String, List<String>> _curatedGroups =
      <String, List<String>>{
        'Shell & Appearance Scripts': <String>[
          'windows_context_menu_script',
          'windows_control_panel_settings_script',
          'windows_notepad_settings',
          'windows_scaling',
          'windows_signout_lockscreen_wallpaper_black',
          'windows_start_menu_layout_script',
          'windows_start_menu_shortcuts_script',
          'windows_start_menu_taskbar_script',
          'windows_theme_black_script',
          'windows_user_account_pictures_black',
          'windows_widgets_script',
        ],
        'Debloat & Cleanup Scripts': <String>[
          'windows_autoruns_startup_tasks_apps_check',
          'windows_bloatware_legacy_apps_check_script',
          'windows_bloatware_legacy_features_check_script',
          'windows_bloatware_script',
          'windows_bloatware_taskmgr_check_script',
          'windows_bloatware_uwp_apps_check_script',
          'windows_bloatware_uwp_features_check_script',
          'windows_cleanup',
          'windows_copilot_script',
          'windows_edge_webview_script',
        ],
        'Devices & Audio Scripts': <String>[
          'windows_device_manager_power_savings_wake',
          'windows_loudness_eq',
          'windows_network_adapter_power_savings_script',
          'windows_network_ipv4_only_script',
          'windows_nvme_faster_driver',
          'windows_pointer_precision_script',
          'windows_sound',
          'windows_write_cache_buffer_flushing',
        ],
        'System Configuration Scripts': <String>[
          'windows_core_isolation_script',
          'windows_defender_optimize',
          'windows_gamebar_script',
          'windows_gamemode',
          'windows_power_plan_script',
          'windows_restore_point',
          'windows_timer_resolution_script',
          'windows_uac_script',
        ],
        'Telemetry & Diagnostics': <String>[
          'service_diagsvc_off',
          'service_diagtrack_off',
          'service_dmwappushservice_off',
          'service_inventorysvc_off',
          'service_pcasvc_off',
          'service_retaildemo_off',
          'service_svsvc_off',
          'service_troubleshootingsvc_off',
          'service_wecsvc_off',
          'service_wersvc_off',
          'service_wisvc_off',
        ],
        'Xbox Services': <String>[
          'service_xblauthmanager_off',
          'service_xblgamesave_off',
          'service_xboxnetapisvc_off',
        ],
        'Network & Sharing Services': <String>[
          'service_devquerybroker_off',
          'service_lmhosts_off',
          'service_mapsbroker_off',
          'service_remoteaccess_off',
          'service_remoteregistry_off',
          'service_wmpnetworksvc_off',
        ],
        'Cards & Payment Services': <String>[
          'service_efs_off',
          'service_scardsvr_off',
          'service_scdeviceenum_off',
          'service_semgrsvc_off',
        ],
        'Shell & Account Services': <String>[
          'service_messagingservice_off',
          'service_pimindexmaintenancesvc_off',
          'service_shpamsvc_off',
          'service_trkwks_off',
          'service_wpcmonsvc_off',
          'service_wpnservice_off',
          'toggle_printing_off',
        ],
        'Input & Peripherals': <String>[
          'hardware_background_polling_rate_cap',
          'hardware_controller_overclock_script',
          'tool_beyond_performance_device_tweaker_discord',
          'tool_controller_polling',
          'tool_device_tweaker_script',
          'tool_hidusbf_folder',
          'tool_interrupt_affinity_policy',
          'tool_marius_cpudirect_script',
          'tool_marius_cpudirect_web',
          'tool_marius_deeplog_script',
          'tool_marius_deeplog_web',
          'tool_marius_deeppoll_script',
          'tool_marius_deeppoll_web',
          'tool_marius_heier_tools_hub',
          'tool_marius_step_count_noise_web',
          'tool_marius_usb_hid_analyzer_web',
          'tool_mouse_flat_curve',
          'tool_mouse_movement_recorder',
          'tool_msi_util_folder',
          'tool_polling_rate_tester_app',
        ],
        'Monitoring & Diagnostics': <String>[
          'tool_autoruns_folder',
          'tool_cpuz_folder',
          'tool_fix_tools_battery_report',
          'tool_gaming_net_diagnostic',
          'tool_gpuz',
          'tool_hwinfo_folder',
          'tool_marius_rig_script',
          'tool_marius_rig_web',
          'tool_rammap_folder',
          'tool_star_ethernet_analyzer_folder',
          'tool_star_ethernet_analyzer_script',
          'tool_star_ethernet_analyzer_video',
        ],
        'Stress Testing': <String>[
          'tool_zoicware_pbo_tuner_2',
          'tool_benchmate',
          'tool_cinebench_2024',
          'tool_corecycler',
          'tool_furmark_setup',
          'tool_linpack_xtreme',
          'tool_memtest86',
          'tool_occt',
          'tool_prime95_folder',
          'tool_testmem5_folder',
          'tool_y_cruncher',
        ],
        'GPU & Display': <String>[
          'installers_cru_sre',
          'installers_more_clock_tool',
          'installers_msi_afterburner',
          'tool_cru_folder',
          'tool_gpu_dword_manager',
          'tool_more_clock_tool',
          'tool_more_power_tool_setup',
          'tool_msi_afterburner_setup',
          'tool_zoicware_override_edid',
          'tool_nvidia_profile_inspector_download',
          'tool_nvidia_profile_inspector_folder',
          'tool_nvidia_profile_inspector_nip_profile',
          'tool_radeon_tuner_folder',
          'tool_wtools_official_page',
          'tool_wtools_setup',
        ],
        'Network Tools': <String>[
          'tool_fix_tools_reset_network',
          'tool_rtl_utility',
          'tool_tcp_optimizer_folder',
        ],
        'System Maintenance': <String>[
          'tool_cleanmgrplus_folder',
          'tool_device_cleanup_folder',
          'tool_dismpp_folder',
          'tool_driver_store_explorer_folder',
          'tool_fix_tools_change_name',
          'tool_fix_tools_fastclean',
          'tool_fix_tools_permessi',
          'tool_fix_tools_ripristina_anteprime',
          'tool_fix_tools_runner',
          'tool_fix_tools_sfc_dism',
          'tool_power_settings_explorer',
          'tool_queue_size_tuner',
          'tool_unpark_cpu',
          'tool_vivetool_folder',
          'tool_zoicware_hosts_builder',
          'tool_zoicware_power_plan_settings_editor',
          'tool_zoicware_service_manager_plus',
          'tool_zoicware_tweak_fth',
          'tool_zoicware_ultimate_disk_cleanup',
          'tool_zoicware_windows_device_remover',
          'tool_zoicware_windows_update_manager',
        ],
        'Debloat & Suites': <String>[
          'installers_menu',
          'tool_ctt_winutil',
          'tool_import_disable_advanced_services_profile',
          'tool_import_minimal_services_profile',
          'tool_install_win11_debloat_raphire',
          'tool_install_winhance',
          'tool_sysinternals_suite_winget',
          'tool_winget_interactive_uninstaller',
          'tool_winscript_batch',
          'tool_winslopr_releases',
          'tool_zoicware_defender_pro_tools',
          'tool_zoicware_dynamic_min_services',
          'tool_zoicware_remove_apps_policy_editor',
          'tool_zoicware_remove_cbs_apps',
          'tool_zoicware_remove_windows_ai',
          'tool_zoicware_suite',
          'tool_zoicware_zscripts',
          'tool_zoicware_zturbo',
        ],
      };

  static final Map<String, String> _curatedCollectionById = <String, String>{
    for (final entry in _curatedGroups.entries)
      for (final id in entry.value) id: entry.key,
  };

  /// Resolves the collection for one catalog entry.
  ///
  /// [tweak] is null for registry-backed system toggles.
  static String resolve({
    required String id,
    required String category,
    required SystemTweak? tweak,
  }) {
    final curated = _curatedCollectionById[id];
    if (curated != null) {
      return curated;
    }

    return _byKind(category, tweak);
  }

  static String _byKind(String category, SystemTweak? tweak) {
    if (tweak == null) {
      // Registry-backed system toggles are the built-in optimization profiles.
      return category == 'Advanced' ? 'Advanced Toggles' : 'Core Optimizations';
    }

    if (tweak is WingetRestoreTweak) {
      return 'Restore Apps';
    }
    if (tweak is WindowsSettingsLauncherTweak) {
      return 'Windows Shortcuts';
    }
    if (tweak is ExternalUrlLauncherTweak) {
      return category == 'Advanced' ? 'Firmware Tools' : 'Debloat & Suites';
    }

    if (tweak.hasState) {
      switch (category) {
        case 'Windows':
          return 'Windows Toggles';
        case 'Visuals':
          return 'Interface Toggles';
        case 'Privacy':
          return 'Privacy Toggles';
        case 'System Checks':
          return 'Security Toggles';
        case 'Services':
          return 'Service Toggles';
        case 'Advanced':
          return 'Advanced Toggles';
        default:
          return 'Additional Toggles';
      }
    }

    switch (category) {
      case 'Windows':
        return 'Windows Scripts';
      case 'Graphics':
        return 'Driver Scripts';
      case 'System Checks':
        return 'Hardware Checks';
      case 'Setup':
        return 'Setup Scripts';
      case 'Refresh & Recovery':
        return 'Recovery Scripts';
      case 'Advanced':
        return 'Advanced Scripts';
      case 'Privacy':
        return 'Debloat Tools';
      default:
        return 'Scripts & Tools';
    }
  }
}
