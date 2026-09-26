import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/app_store_catalog.dart';
import 'package:script_utility/features/apps/application/app_store_service.dart';
import 'package:script_utility/features/apps/domain/store_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'app store freezes unique attributed entries and requested tools',
    () async {
      final catalog = await AppStoreCatalog.load(bundle: rootBundle);
      final names = catalog.apps.map((app) => app.name).toSet();
      final normalizedNames = catalog.apps
          .map(
            (app) =>
                app.name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '),
          )
          .toSet();
      final wingetIds = catalog.apps
          .map((app) => app.wingetId?.trim().toLowerCase())
          .whereType<String>()
          .toList(growable: false);
      final githubRepositories = catalog.apps
          .map((app) => app.url)
          .whereType<Uri>()
          .where((url) => url.host.toLowerCase() == 'github.com')
          .map((url) => url.path.replaceFirst(RegExp(r'/$'), '').toLowerCase())
          .toList(growable: false);

      expect(catalog.apps, hasLength(464));
      expect(catalog.apps.map((app) => app.id).toSet(), hasLength(464));
      expect(normalizedNames, hasLength(464));
      expect(wingetIds.toSet(), hasLength(wingetIds.length));
      expect(githubRepositories.toSet(), hasLength(githubRepositories.length));
      expect(
        catalog.apps.every(
          (app) =>
              app.attribution.startsWith('by ') &&
              app.sources.isNotEmpty &&
              (app.wingetId != null || app.url?.scheme == 'https'),
        ),
        isTrue,
      );
      expect(
        catalog.apps.singleWhere((app) => app.name == 'CUDA-Z').attribution,
        'by Igor Bushin',
      );
      expect(
        catalog.apps
            .singleWhere((app) => app.name == 'OptiScaler Client')
            .url
            .toString(),
        'https://github.com/Optiscaler-Client/Optiscaler-Client',
      );
      expect(
        catalog.apps.singleWhere((app) => app.name == 'RadeonTuner').author,
        'dumbie',
      );
      expect(
        catalog.apps.singleWhere((app) => app.name == 'Upscale It').author,
        'NODIX-TECH',
      );
      expect(
        names,
        containsAll(<String>[
          'CUDA-Z',
          'Universal x86 Tuning Utility',
          'WTools',
          'CompactGUI',
          'Special K',
          'Snappy Driver Installer Origin',
          'Logitech Onboard Memory Manager',
          'Maxwell II BIOS Tweaker',
          'OpenMouse',
          'RadeonTuner',
          'DLSS 5 Manager',
          'DLSS Enabler Manager',
          'Upscale It',
          'DLSS-NR-on-AMD',
          'OptiScaler Client',
          'OpenLogi',
        ]),
      );
    },
  );

  test('bulk uninstall preview accepts installed packages only', () {
    final service = AppStoreService(
      processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
    );
    const apps = <StoreApp>[
      StoreApp(
        id: 'one',
        name: 'One',
        category: 'Test',
        wingetId: 'Vendor.One',
        url: null,
        author: 'Vendor',
        sources: <String>['test'],
      ),
      StoreApp(
        id: 'three',
        name: 'Three',
        category: 'Test',
        wingetId: 'Vendor.Three',
        url: null,
        author: 'Vendor',
        sources: <String>['test'],
      ),
    ];

    final preview = service.previewUninstall(apps, <String>{'vendor.one'});

    expect(preview.apps.map((app) => app.id), <String>['one']);
  });
}
