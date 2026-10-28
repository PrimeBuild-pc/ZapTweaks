import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/features/apps/application/leftover_scanner.dart';
import 'package:script_utility/features/apps/presentation/leftover_review_dialog.dart';
import 'package:script_utility/l10n/app_localizations.dart';

void main() {
  testWidgets('Good items start selected; user and machine go apart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final requests = <OperationRequest>[];
    await tester.pumpWidget(
      FluentApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LeftoverReviewDialog(
          load: () async => const <Leftover>[
            Leftover(
              kind: LeftoverKind.registryKey,
              path: r'HKCU\Software\Contoso\Paint',
              confidence: LeftoverConfidence.good,
              machine: false,
            ),
            Leftover(
              kind: LeftoverKind.task,
              path: r'\Contoso\Update',
              confidence: LeftoverConfidence.good,
              machine: true,
            ),
            Leftover(
              kind: LeftoverKind.registryKey,
              path: r'HKCU\Software\Contoso',
              confidence: LeftoverConfidence.medium,
              machine: false,
            ),
          ],
          execute: (batch) async {
            requests.add(batch.single);
            return OperationPlan(
              id: 'p',
              createdAt: DateTime(2026),
              user: 'u',
              appVersion: 't',
              windowsBuild: 26100,
              status: PlanStatus.completed,
              items: [
                PlanItem(
                  operationId: batch.single.operationId,
                  request: batch.single,
                  before: const OperationState(OperationStateKind.configured),
                  status: PlanItemStatus.verified,
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rimuovi selezionati (2)'), findsOneWidget);
    await tester.tap(find.text('Rimuovi selezionati (2)'));
    await tester.pumpAndSettle();

    expect(requests.map((r) => r.operationId), [
      'app.leftovers.remove_user',
      'app.leftovers.remove',
    ]);
    expect(requests.first.parameters['items'], [
      {'kind': 'registryKey', 'path': r'HKCU\Software\Contoso\Paint'},
    ]);
    expect(find.textContaining('Residui rimossi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
