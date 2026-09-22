import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/core/services/tweak_collections.dart';
import 'package:script_utility/core/services/tweak_text_localizer.dart';
import 'package:script_utility/models/action_tweaks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final catalog = TweakCatalogService().buildCatalog();

  test('every entry lands in a known, non-empty collection', () {
    for (final descriptor in catalog) {
      expect(
        descriptor.collection.trim(),
        isNotEmpty,
        reason: '${descriptor.id} has no collection',
      );
      expect(
        TweakCollections.displayOrder,
        contains(descriptor.collection),
        reason:
            '${descriptor.id} uses "${descriptor.collection}", which is not in '
            'the display order and would sort last',
      );
    }
  });

  test('no category is one oversized flat list', () {
    final perCategory = <String, Map<String, int>>{};
    for (final descriptor in catalog) {
      final collections = perCategory.putIfAbsent(
        descriptor.category,
        () => <String, int>{},
      );
      collections[descriptor.collection] =
          (collections[descriptor.collection] ?? 0) + 1;
    }

    for (final entry in perCategory.entries) {
      final total = entry.value.values.fold<int>(0, (sum, item) => sum + item);
      if (total <= 30) {
        continue;
      }
      expect(
        entry.value.length,
        greaterThan(1),
        reason: '${entry.key} has $total entries in a single collection',
      );
      expect(
        entry.value.values.reduce((a, b) => a > b ? a : b),
        lessThan(total),
        reason: '${entry.key} groups everything into one collection',
      );
    }
  });

  test('entries in a category are contiguous per collection', () {
    // The page groups by iteration order, so the catalog must not interleave
    // collections inside a category.
    final seen = <String, Set<String>>{};
    String? previousKey;
    for (final descriptor in catalog) {
      final key = '${descriptor.category}/${descriptor.collection}';
      if (key == previousKey) {
        continue;
      }
      final collections = seen.putIfAbsent(
        descriptor.category,
        () => <String>{},
      );
      expect(
        collections.add(descriptor.collection),
        isTrue,
        reason: '${descriptor.category} revisits ${descriptor.collection}',
      );
      previousKey = key;
    }
  });

  test('only entries that change the system ask for a restore point', () {
    final byId = <String, dynamic>{
      for (final descriptor in catalog) descriptor.id: descriptor,
    };

    for (final id in <String>[
      'tool_gpuz',
      'tool_winslopr_releases',
      'tool_winsux_debloat',
      'tool_device_tweaker_script',
      'restore_microsoft_windowsstore',
      'shortcut_device_manager',
    ]) {
      expect(
        byId[id].scriptTweak.requiresSafetyPrompt,
        isFalse,
        reason: '$id only hands off to another program',
      );
    }

    final registryImport =
        byId['tool_import_minimal_services_profile'].scriptTweak
            as RegistryImportTweak;
    expect(registryImport.requiresSafetyPrompt, isTrue);

    // Repair scripts offer a restore point before they run. The offer itself
    // is always skippable, which safety_gate_service_test.dart pins down.
    for (final id in <String>[
      'tool_fix_tools_runner',
      'tool_fix_tools_sfc_dism',
      'tool_fix_tools_reset_network',
      'tool_fix_tools_fastclean',
      'tool_fix_tools_permessi',
      'tool_fix_tools_ripristina_anteprime',
      'windows_cleanup',
      'windows_restore_point',
      'refresh_factory_reset',
      'refresh_reinstall',
    ]) {
      expect(byId[id].scriptTweak.requiresSafetyPrompt, isTrue, reason: id);
    }

    // Scripted hand-offs follow the aggressive flag; official source/page
    // links never ask for a restore point.
    for (final id in <String>['tool_install_win11_debloat_raphire']) {
      expect(byId[id].scriptTweak.requiresSafetyPrompt, isTrue, reason: id);
    }
    for (final id in <String>[
      'tool_marius_deeppoll_script',
      'tool_fix_tools_battery_report',
      'tool_ctt_winutil',
      'tool_windows_11_fix_tweaks_kubaam',
    ]) {
      expect(byId[id].scriptTweak.requiresSafetyPrompt, isFalse, reason: id);
    }
  });

  test('removed entries are gone from the catalog', () {
    final ids = catalog.map((item) => item.id).toSet();

    expect(ids.contains('tool_fortnite_diagnostic_ping'), isFalse);
    expect(ids.contains('tool_interrupt_affinity_policy_x86'), isFalse);
    expect(ids.contains('tool_interrupt_affinity_policy_ia64'), isFalse);
    expect(ids.contains('tool_interrupt_affinity_policy'), isTrue);
    expect(ids.contains('tool_device_tweaker_script'), isTrue);
  });

  test('every collection header is translated into every language', () {
    final used = catalog.map((item) => item.collection).toSet();

    for (final locale in <String>['it', 'de', 'es', 'fr', 'ru', 'zh']) {
      for (final collection in used) {
        expect(
          TweakTextLocalizer.collection(collection, locale),
          isNot(collection),
          reason: '$collection is missing $locale copy',
        );
      }
    }
  });
}
