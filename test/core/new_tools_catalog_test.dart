import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/services/tweak_catalog_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog includes new fixes and utilities entries', () {
    final catalog = TweakCatalogService().buildCatalog();
    final ids = catalog.map((item) => item.id).toSet();

    expect(ids.contains('tool_rtl_utility'), isTrue);
    expect(ids.contains('tool_fix_tools_runner'), isTrue);
    expect(ids.contains('tool_fix_tools_fastclean'), isTrue);
    expect(ids.contains('tool_gaming_net_diagnostic'), isTrue);
    expect(ids.contains('tool_nvidia_profile_inspector_nip_profile'), isTrue);
    expect(ids.contains('tool_ctt_winutil'), isTrue);
    expect(ids.contains('tool_install_winhance'), isTrue);
    expect(ids.contains('tool_star_ethernet_analyzer_video'), isTrue);

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
  });
}
