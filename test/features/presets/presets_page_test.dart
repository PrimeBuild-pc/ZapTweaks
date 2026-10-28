import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/features/apps/application/service_inventory.dart';
import 'package:script_utility/features/presets/application/preset_preview.dart';
import 'package:script_utility/features/presets/domain/preset_catalog.dart';
import 'package:script_utility/features/presets/presentation/presets_page.dart';
import 'package:script_utility/l10n/app_localizations.dart';

OperationPlan _plan(List<OperationRequest> requests, PlanItemStatus status) =>
    OperationPlan(
      id: 'p${requests.first.operationId}',
      createdAt: DateTime(2026),
      user: 'u',
      appVersion: 't',
      windowsBuild: 26100,
      status: PlanStatus.completed,
      items: [
        for (final request in requests)
          PlanItem(
            operationId: request.operationId,
            request: request,
            before: const OperationState(OperationStateKind.configured),
            status: status,
            error: status == PlanItemStatus.failed ? 'off' : null,
          ),
      ],
    );

void main() {
  testWidgets('every preset tweak has its own label', (tester) async {
    final strings = await AppLocalizations.delegate.load(const Locale('it'));
    for (final item in builtInPresets.expand((p) => p.items)) {
      if (item is TweakPresetItem) {
        expect(tweakLabel(strings, item.operationId), isNot(item.operationId));
      }
    }
  });

  testWidgets(
    'Competitive: consent, restore point first, three plans, undo settings',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final folder = Directory.systemTemp.createTempSync('zt_presets_ui');
      addTearDown(() => folder.deleteSync(recursive: true));
      final executed = <List<OperationRequest>>[];
      final rolledBack = <String>[];
      var restoreFails = true;

      await tester.pumpWidget(
        FluentApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScaffoldPage(
            content: PresetsPage(
              folder: folder,
              inspect: (_) async => const [],
              loadFacts: (_) async => const PresetFacts(
                installedAppx: {'Microsoft.BingNews'},
                services: <String, ServiceEntry>{
                  'spooler': ServiceEntry(
                    name: 'Spooler',
                    displayName: 'Print Spooler',
                    description: null,
                    startType: 2,
                    delayed: false,
                    running: true,
                    path: null,
                    company: null,
                  ),
                },
                startup: [
                  (
                    location: 'run',
                    machine: false,
                    name: 'Steam',
                    command: r'"C:\Steam\steam.exe" -silent',
                    enabled: true,
                  ),
                ],
                tweaks: {},
              ),
              execute: (requests) async {
                if (requests.single.operationId ==
                        'system.restore_point.create' &&
                    restoreFails) {
                  if (requests.single.parameters['enableProtection'] == true) {
                    restoreFails = false;
                  } else {
                    return _plan(requests, PlanItemStatus.failed);
                  }
                }
                executed.add(requests);
                return _plan(requests, PlanItemStatus.verified);
              },
              rollback: (plan) async {
                rolledBack.add(plan.items.first.operationId);
                return plan..status = PlanStatus.rolledBack;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Competitive'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No FPS, latency'), findsOneWidget);
      expect(find.text('by Fr33thy'), findsOneWidget);

      await tester.tap(find.text('Preview on this PC'));
      await tester.pumpAndSettle();
      final apply = find.widgetWithText(FilledButton, 'Apply preset');
      expect(tester.widget<FilledButton>(apply).onPressed, isNull);
      await tester.tap(
        find.text('I have read the full list and accept the risk.'),
      );
      await tester.pumpAndSettle();

      await tester.tap(apply);
      await tester.pumpAndSettle();
      expect(executed, isEmpty, reason: 'no restore point, no change');
      await tester.tap(find.text('Turn on System Protection and retry'));
      await tester.pumpAndSettle();

      final ops = executed.map((r) => r.map((x) => x.operationId).toSet());
      expect(ops.first, {'system.restore_point.create'});
      expect(ops.elementAt(1), {'service.start.configure'});
      expect(ops.elementAt(2), {'startup.entry.configure_user'});
      expect(ops.elementAt(3), {'app.appx.remove_current_user'});
      expect(find.textContaining('Done: 3 changed'), findsOneWidget);

      await tester.tap(find.text('Undo preset'));
      await tester.pumpAndSettle();
      expect(rolledBack, [
        'startup.entry.configure_user',
        'service.start.configure',
      ], reason: 'apps have no exact rollback');
    },
  );
}
