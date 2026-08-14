import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';

void main() {
  test(
    'reference-screen controls are available without duplicating equivalents',
    () {
      final catalog = TweakCatalogService().buildCatalog();
      final byId = {for (final item in catalog) item.id: item};

      for (final id in <String>[
        'network_llmnr_off',
        'network_delivery_optimization_off',
        'network_fast_udp_datagram_send',
        'gaming_variable_refresh_rate_on',
        'gaming_extended_gpu_timeout',
        'ui_sticky_keys_shortcut_off',
        'windows_ntfs_last_access_updates_off',
        'checks_vbs_off',
        'checks_smart_screen_off',
        'checks_vulnerable_driver_blocklist_off',
        'toggle_scheduled_defrag_off',
        'service_diagtrack_off',
        'restore_microsoft_windowsstore',
        'tool_winget_interactive_uninstaller',
        'shortcut_device_manager',
        'shortcut_hosts_file',
      ]) {
        expect(byId, contains(id), reason: id);
      }
    },
  );

  test('new disruptive controls are excluded from Safe presets', () {
    final catalog = TweakCatalogService().buildCatalog();
    final byId = {for (final item in catalog) item.id: item};

    for (final id in <String>[
      'network_llmnr_off',
      'network_delivery_optimization_off',
      'checks_vbs_off',
      'checks_smart_screen_off',
    ]) {
      expect(byId[id]!.isAggressive, isTrue, reason: id);
      expect(
        TweakController.shouldEnablePreset(
          TweakController.safePreset,
          byId[id]!,
        ),
        isFalse,
        reason: id,
      );
    }
  });
}
