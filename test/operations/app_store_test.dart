import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/app_store_catalog.dart';
import 'package:script_utility/features/apps/application/app_store_service.dart';
import 'package:script_utility/features/apps/domain/store_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'older remote catalogs cannot remove the two bundled external tools',
    () async {
      final remote =
          jsonDecode(
                await rootBundle.loadString('assets/catalog/app_catalog.json'),
              )
              as Map<String, dynamic>;
      remote['apps'] = (remote['apps'] as List)
          .where(
            (app) => !const {'app_mvolt', 'app_sparkle'}.contains(app['id']),
          )
          .toList();
      final client = MockClient(
        (_) async => http.Response(jsonEncode(remote), 200),
      );
      addTearDown(client.close);
      final catalog = await AppStoreCatalog.load(
        bundle: rootBundle,
        client: client,
      );
      expect(catalog.apps, hasLength(467));
      for (final id in ['app_mvolt', 'app_sparkle']) {
        final tool = catalog.apps.singleWhere((app) => app.id == id);
        expect(tool.wingetId, isNull);
        expect(tool.url?.scheme, 'https');
        expect(tool.requirements, isNotEmpty);
        expect(tool.warnings, isNotEmpty);
      }
    },
  );

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

      expect(catalog.apps, hasLength(467));
      expect(catalog.apps.map((app) => app.id).toSet(), hasLength(467));
      expect(normalizedNames, hasLength(467));
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
      final nvUvPlay = catalog.apps.singleWhere(
        (app) => app.name == 'NV-UV-Play',
      );
      expect(nvUvPlay.category, 'GPU & Display');
      expect(nvUvPlay.author, 'christianp403-spec');
      expect(nvUvPlay.wingetId, isNull);
      expect(
        nvUvPlay.url.toString(),
        'https://github.com/christianp403-spec/NV-UV-Play/releases',
      );
      final dlssNr = catalog.apps.singleWhere(
        (app) => app.name == 'DLSS-NR-on-AMD',
      );
      expect(dlssNr.category, 'Gaming & Input');
      expect(dlssNr.author, 'danielblnc');
      expect(dlssNr.wingetId, isNull);
      expect(
        dlssNr.url.toString(),
        'https://github.com/danielblnc/DLSS-NR-on-AMD',
      );
      expect(
        names,
        containsAll(<String>[
          'CUDA-Z',
          'mVolt',
          'Sparkle',
          'Universal x86 Tuning Utility',
          'WTools',
          'CompactGUI',
          'Special K',
          'Snappy Driver Installer Origin',
          'Logitech Onboard Memory Manager',
          'Maxwell II BIOS Tweaker',
          'OpenMouse',
          'RadeonTuner',
          'NV-UV-Play',
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

  test(
    'source launch rejects malformed or credential-bearing HTTPS links',
    () async {
      final service = AppStoreService(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
      );
      for (final url in [
        'https:calc.exe',
        'https://user:password@example.test/tool',
      ]) {
        await expectLater(
          service.openSource(
            StoreApp(
              id: 'bad',
              name: 'Bad',
              category: 'Test',
              wingetId: null,
              url: Uri.parse(url),
              author: 'Test',
              sources: ['test'],
            ),
          ),
          throwsStateError,
        );
      }
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
