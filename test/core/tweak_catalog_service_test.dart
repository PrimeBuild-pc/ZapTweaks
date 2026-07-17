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

    expect(tweaks, hasLength(92));
    expect(tweaks.map((item) => item.id).toSet(), hasLength(92));
    expect(tweaks, everyElement(isA<ScriptInteractiveTweak>()));
    expect(
      tweaks.cast<ScriptInteractiveTweak>(),
      everyElement(
        predicate<ScriptInteractiveTweak>(
          (item) => item.scriptSegments.length >= 3,
        ),
      ),
    );
  });
}
