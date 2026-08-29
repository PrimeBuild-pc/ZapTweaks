import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/core/services/process_runner.dart';
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

    final profileImport =
        catalog
                .singleWhere(
                  (item) =>
                      item.id == 'tool_nvidia_profile_inspector_nip_profile',
                )
                .scriptTweak
            as NvidiaProfileImportTweak;
    final profiles = profileImport.availableProfiles();
    expect(profiles, hasLength(16));
    expect(
      profiles.map((profile) => profile.name),
      containsAll(<String>[
        'nvidia-performance-settings',
        'FortniteDX12_2025Profile_by_Jackpot',
        'NovaOS',
      ]),
    );

    profileImport.selectProfile(profiles.first);
    ProcessRunner.configureShared(
      ProcessRunner(
        mode: ProcessExecutionMode.dryRun,
        dryRunDelay: Duration.zero,
      ),
    );
    await profileImport.onApply();
  });
}
