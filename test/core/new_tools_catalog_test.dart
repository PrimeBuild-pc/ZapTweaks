import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/models/action_tweaks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog includes new fixes and utilities entries', () async {
    final catalog = TweakCatalogService().buildCatalog();
    final ids = catalog.map((item) => item.id).toSet();

    expect(ids.contains('tool_rtl_utility'), isTrue);
    expect(ids.contains('tool_fix_tools_runner'), isTrue);
    expect(ids.contains('tool_fix_tools_fastclean'), isTrue);
    expect(ids.contains('tool_gaming_net_diagnostic'), isTrue);
    expect(ids.contains('tool_nvidia_profile_inspector_nip_profile'), isTrue);
    expect(ids.contains('tool_nvidia_profile_inspector_download'), isTrue);
    expect(ids.contains('tool_wtools_setup'), isTrue);
    expect(ids.contains('tool_wtools_official_page'), isTrue);
    expect(ids.contains('tool_ctt_winutil'), isTrue);
    expect(ids.contains('tool_windows_11_fix_tweaks_kubaam'), isTrue);
    expect(ids.contains('recovery_repair_bad_tweaks_zoicware'), isTrue);
    expect(ids.contains('tool_install_winhance'), isTrue);
    expect(ids.contains('tool_star_ethernet_analyzer_video'), isTrue);
    expect(
      ids.intersection(<String>{
        'refresh_network_driver',
        'installers_nvidia_profile_inspector',
        'hardware_background_polling_rate_cap_script',
        'hardware_mouse_polling_rate_test_script',
        'hardware_controller_polling_rate_script',
        'check_hw_info',
        'tool_star_ethernet_analyzer_start_bat',
      }),
      isEmpty,
    );

    expect(
      catalog.any((item) => item.id == 'tool_nvidia_profile_inspector_folder'),
      isTrue,
    );
    expect(
      catalog.any(
        (item) => item.id == 'tool_nvidia_profile_inspector_nip_profile',
      ),
      isTrue,
    );

    final ctt = catalog.singleWhere((item) => item.id == 'tool_ctt_winutil');
    expect(ctt.title, contains('by Chris Titus Tech'));
    expect(ctt.scriptTweak, isA<ExternalUrlLauncherTweak>());

    final w11Fix = catalog.singleWhere(
      (item) => item.id == 'tool_windows_11_fix_tweaks_kubaam',
    );
    expect(w11Fix.title, contains('by kubaam'));
    expect(w11Fix.scriptTweak, isA<ExternalUrlLauncherTweak>());

    final repair = catalog.singleWhere(
      (item) => item.id == 'recovery_repair_bad_tweaks_zoicware',
    );
    expect(repair.title, contains('by zoicware'));
    expect(repair.scriptTweak, isA<ExternalUrlLauncherTweak>());

    final profileImport = catalog.singleWhere(
      (item) => item.id == 'tool_nvidia_profile_inspector_nip_profile',
    );
    expect(profileImport.scriptTweak, isA<ExternalUrlLauncherTweak>());
  });
}
