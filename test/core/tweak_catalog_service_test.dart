import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/models/action_tweaks.dart';
import 'package:script_utility/models/recovered_script_tweaks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('navigation categories are non-overlapping and include Home', () {
    final categories = TweakCatalogService.navigationCategories;

    expect(categories.first, 'Home');
    expect(categories.toSet().length, categories.length);
  });

  test('catalog descriptors map to exactly one known category', () {
    final service = TweakCatalogService();
    final categories = TweakCatalogService.navigationCategories.toSet();

    final catalog = service.buildCatalog();
    for (final descriptor in catalog) {
      expect(categories.contains(descriptor.category), isTrue);
      expect(descriptor.category, isNot('Home'));
    }
  });

  test(
    'catalog baseline has unique stable ids and explicit category totals',
    () {
      final catalog = TweakCatalogService().buildCatalog();
      final categoryTotals = <String, int>{};

      for (final descriptor in catalog) {
        categoryTotals.update(
          descriptor.category,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      expect(catalog.map((item) => item.id).toSet(), hasLength(catalog.length));
      expect(categoryTotals, <String, int>{
        'Shortcuts': 29,
        'Gaming': 14,
        'Networking': 15,
        'Power & CPU': 16,
        'Graphics': 19,
        'Windows': 45,
        'System Checks': 17,
        'Services': 31,
        'Refresh & Recovery': 24,
        'Setup': 12,
        'Advanced': 23,
        'Privacy': 12,
        'Visuals': 14,
        'Tools': 101,
      });
    },
  );

  test('zoicware and stress tools use authoritative HTTPS links only', () {
    final byId = <String, dynamic>{
      for (final item in TweakCatalogService().buildCatalog()) item.id: item,
    };
    const ids = <String>{
      'tool_zoicware_suite',
      'tool_zoicware_defender_pro_tools',
      'tool_zoicware_remove_windows_ai',
      'tool_zoicware_pbo_tuner_2',
      'tool_zoicware_remove_cbs_apps',
      'tool_zoicware_ultimate_disk_cleanup',
      'tool_benchmate',
      'tool_linpack_xtreme',
      'tool_occt',
      'tool_y_cruncher',
      'tool_cinebench_2024',
      'tool_memtest86',
      'tool_corecycler',
    };

    for (final id in ids) {
      final tool = byId[id].scriptTweak as ExternalUrlLauncherTweak;
      expect(Uri.parse(tool.url).scheme, 'https', reason: id);
    }
    expect(byId, isNot(contains('tool_zoicware_iso_tweaker')));
  });

  test('startup app launchers expose their different Windows surfaces', () {
    final byId = <String, dynamic>{
      for (final descriptor in TweakCatalogService().buildCatalog())
        descriptor.id: descriptor,
    };

    expect(byId['setup_startup_apps_7'].title, 'Startup Apps Settings');
    expect(byId['setup_startup_apps_8'].title, 'Startup Apps in Task Manager');
    expect(
      byId['setup_startup_apps_7'].description,
      isNot(byId['setup_startup_apps_8'].description),
    );
  });

  test('safe presets exclude security-reducing and destructive tweaks', () {
    final byId = <String, dynamic>{
      for (final descriptor in TweakCatalogService().buildCatalog())
        descriptor.id: descriptor,
    };

    for (final id in <String>[
      'checks_uac_off',
      'checks_firewall_off',
      'checks_spectre_meltdown_off',
      'checks_dep_off',
      'checks_core_isolation_off',
      'network_ipv4_only',
      'privacy_safe_debloat',
    ]) {
      expect(byId[id]?.isAggressive, isTrue, reason: id);
    }
    expect(byId['privacy_safe_debloat']?.isScriptAction, isTrue);
    expect(byId, isNot(contains('power_min_processor_state')));
  });

  test(
    'modern graphics and power-saving replacements are catalogued safely',
    () {
      final byId = {
        for (final descriptor in TweakCatalogService().buildCatalog())
          descriptor.id: descriptor,
      };

      expect(byId, contains('gaming_windowed_optimizations_on'));
      expect(byId, contains('gaming_mpo_off'));
      expect(byId, contains('device_power_savings_off'));
      expect(byId, contains('gaming_amd_gpu_safe_profile'));
      expect(byId, contains('gaming_amd_gpu_extreme_profile'));
      expect(byId, isNot(contains('gaming_mpo_windowed_optimizations_off')));
      expect(byId['gaming_mpo_off']!.isAggressive, isTrue);
      expect(byId['gaming_mpo_off']!.restartRequired, isTrue);
      expect(
        byId['gaming_amd_gpu_safe_profile']!.requiredGpuVendors,
        contains('amd'),
      );
      expect(byId['gaming_amd_gpu_extreme_profile']!.isAggressive, isTrue);
    },
  );

  test('runtimes and GPU/Power pill tweaks use their intended sections', () {
    final catalog = TweakCatalogService().buildCatalog();
    final byId = {for (final descriptor in catalog) descriptor.id: descriptor};

    for (final id in <String>[
      'gpu_nvidia_optimizations',
      'gpu_amd_optimizations',
      'gpu_intel_optimizations',
      'gaming_amd_gpu_safe_profile',
      'gaming_amd_gpu_extreme_profile',
      'gaming_amd_ulps_off',
    ]) {
      expect(byId[id]!.category, 'Graphics', reason: id);
      expect(byId[id]!.isScriptAction, isFalse, reason: id);
    }

    expect(
      catalog
          .where((item) => item.category == 'Power & CPU')
          .every((item) => !item.isScriptAction),
      isTrue,
    );
    expect(byId['graphics_directx']!.scriptTweak!.actionLabel, 'Install');
    expect(byId['graphics_cpp_runtime']!.scriptTweak!.actionLabel, 'Install');
    expect(
      byId['graphics_cpp_runtime']!.title,
      'Visual C++ All-in-One Runtimes',
    );
  });

  test('new privacy, shell, and network toggles are catalogued safely', () {
    final byId = {
      for (final descriptor in TweakCatalogService().buildCatalog())
        descriptor.id: descriptor,
    };

    for (final id in <String>[
      'privacy_online_search_suggestions',
      'privacy_powershell_telemetry',
      'network_prefer_ipv4',
      'ui_folder_discovery_off',
      'ui_taskbar_end_task',
      'ui_hide_explorer_gallery',
    ]) {
      expect(byId, contains(id), reason: id);
    }

    expect(
      byId['network_prefer_ipv4']!.conflictingTweakIds,
      contains('network_ipv4_only'),
    );
    expect(
      byId['network_ipv4_only']!.conflictingTweakIds,
      contains('network_prefer_ipv4'),
    );
    expect(byId['ui_taskbar_end_task']!.minimumWindowsBuild, 22631);
    expect(byId['ui_hide_explorer_gallery']!.minimumWindowsBuild, 22631);
  });

  test('compact recovered script table preserves every action', () {
    final tweaks = createRecoveredScriptTweaks();

    expect(tweaks, hasLength(90));
    expect(tweaks.map((item) => item.id).toSet(), hasLength(90));
    expect(tweaks.whereType<ScriptInteractiveTweak>(), hasLength(86));
    expect(tweaks.whereType<ExternalUrlLauncherTweak>(), hasLength(4));
    expect(
      tweaks.whereType<ScriptInteractiveTweak>(),
      everyElement(
        predicate<ScriptInteractiveTweak>(
          (item) => item.scriptSegments.length >= 3,
        ),
      ),
    );
  });
}
