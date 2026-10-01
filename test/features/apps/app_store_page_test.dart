import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/app_store_catalog.dart';
import 'package:script_utility/features/apps/application/app_store_service.dart';
import 'package:script_utility/features/apps/domain/store_app.dart';
import 'package:script_utility/features/apps/presentation/app_store_page.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';
import 'package:script_utility/l10n/app_localizations.dart';

class _Controller extends ChangeNotifier implements TweakController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Inventory extends AppStoreService {
  _Inventory()
    : super(processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun));
  Set<String>? ids;
  int opens = 0;
  @override
  Future<Set<String>> installedWingetIds() async =>
      ids ?? (throw StateError('inventory unavailable'));
  @override
  Future<void> openSource(StoreApp app) async {
    opens++;
  }
}

void main() {
  testWidgets(
    'external tools remain launchable while unknown package state disables installs',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 820);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = _Inventory();
      final controller = _Controller();
      addTearDown(controller.dispose);
      final bundled = (await tester.runAsync(
        () => AppStoreCatalog.load(bundle: rootBundle),
      ))!;
      final nvUv = bundled.apps.singleWhere((app) => app.name == 'NV-UV-Play');
      var apps = [
        nvUv,
        const StoreApp(
          id: 'one',
          name: 'One',
          category: 'Test',
          wingetId: 'Vendor.One',
          url: null,
          author: 'Vendor',
          sources: ['test'],
        ),
      ];
      await tester.pumpWidget(
        FluentApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppStorePage(
            controller: controller,
            service: service,
            catalogLoader: () async => AppStoreCatalog(apps),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('External download'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.text('Not installed'), findsNothing);
      expect(find.text('Requirements'), findsOneWidget);
      expect(find.text('Warnings'), findsOneWidget);
      final install = tester.widget<Button>(
        find.widgetWithText(Button, 'Install'),
      );
      expect(install.onPressed, isNull);
      await tester.tap(find.text('Open official page'));
      await tester.pumpAndSettle();
      expect(service.opens, 1);
      service.ids = {'vendor.one'};
      await tester.tap(find.text('Refresh inventory'));
      await tester.pumpAndSettle();
      expect(find.text('Installed'), findsOneWidget);
      final selection = find.byWidgetPredicate(
        (widget) =>
            widget is Checkbox &&
            widget.content == null &&
            widget.onChanged != null,
      );
      await tester.tap(selection);
      await tester.pumpAndSettle();
      apps = [nvUv];
      await tester.tap(find.text('Refresh inventory'));
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
