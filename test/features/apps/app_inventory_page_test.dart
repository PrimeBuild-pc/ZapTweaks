import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/presentation/app_inventory_page.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';
import 'package:script_utility/l10n/app_localizations.dart';

import '../../operations/appx_test_fixtures.dart';

class _Inventory extends ProcessRunner {
  _Inventory()
    : super(mode: ProcessExecutionMode.dryRun, dryRunDelay: Duration.zero);

  @override
  Future<String> runPowerShellForOutput(String script) async =>
      jsonEncode(appxInventory());

  @override
  Future<CommandResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Duration timeout = const Duration(minutes: 2),
  }) async => const CommandResult(
    exitCode: 1,
    stdout: '',
    stderr: 'Mock Winget unavailable.',
  );
}

class _Controller extends ChangeNotifier implements TweakController {
  int attempts = 0;

  @override
  Future<OperationPlan> executeNativeRequests(
    List<OperationRequest> requests,
  ) async {
    attempts++;
    return OperationPlan(
      id: 'blocked',
      createdAt: DateTime(2026),
      user: 'test',
      appVersion: 'test',
      windowsBuild: 26100,
      status: PlanStatus.completed,
      items: [
        PlanItem(
          operationId: requests.single.operationId,
          request: requests.single,
          before: const OperationState(OperationStateKind.error),
          status: PlanItemStatus.skipped,
          error: 'Fresh protection preflight rejected removal.',
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'unsupported skipped AppX removal is never reported as completed',
    (tester) async {
      final previous = ProcessRunner.shared;
      ProcessRunner.configureShared(_Inventory());
      addTearDown(() => ProcessRunner.configureShared(previous));
      final controller = _Controller();
      addTearDown(controller.dispose);
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        FluentApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppInventoryPage(controller: controller),
        ),
      );
      // Winget's mocked export still checks a temporary file asynchronously.
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uninstall'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Current user').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Uninstall'));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(controller.attempts, 1);
      expect(
        find.textContaining('Fresh protection preflight rejected removal.'),
        findsOneWidget,
      );
      expect(find.textContaining('Feedback Hub · failed'), findsOneWidget);
      expect(find.textContaining('Feedback Hub · completed'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
