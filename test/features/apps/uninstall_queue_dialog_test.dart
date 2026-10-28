import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';
import 'package:script_utility/features/apps/presentation/uninstall_queue_dialog.dart';
import 'package:script_utility/l10n/app_localizations.dart';

AppPackage _app(String name) => AppPackage(
  provider: AppProvider.win32,
  packageId: 'HKLM\\64\\$name',
  name: name,
  version: null,
  publisher: null,
  scopes: const {AppInstallScope.allUsers},
  source: 'Windows',
  reinstallable: false,
  installLocation: 'C:\\Program Files\\$name',
  uninstall: UninstallEntry(
    hive: 'HKLM',
    view: '64',
    key: name,
    uninstallString: '"C:\\Program Files\\$name\\unins000.exe"',
  ),
);

OperationPlan _plan(OperationRequest request, PlanItemStatus status) =>
    OperationPlan(
      id: 'p',
      createdAt: DateTime(2026),
      user: 'u',
      appVersion: 't',
      windowsBuild: 26100,
      status: PlanStatus.completed,
      items: [
        PlanItem(
          operationId: request.operationId,
          request: request,
          before: const OperationState(OperationStateKind.configured),
          status: status,
          error: status == PlanItemStatus.verified ? null : 'Protection off',
        ),
      ],
    );

Future<void> _pump(
  WidgetTester tester,
  Future<OperationPlan> Function(List<OperationRequest>) execute,
) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    FluentApp(
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: UninstallQueueDialog(
        apps: [_app('Alpha'), _app('Beta')],
        execute: execute,
        listProcesses: () async => [
          (name: 'alpha', path: r'C:\Program Files\Alpha\alpha.exe'),
        ],
        environment: const {'SystemRoot': r'C:\Windows'},
        fileExists: (_) => true,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a failed restore point uninstalls nothing; retry enables it', (
    tester,
  ) async {
    final calls = <OperationRequest>[];
    var protectionOn = false;
    await _pump(tester, (requests) async {
      final request = requests.single;
      calls.add(request);
      if (request.operationId == 'system.restore_point.create') {
        protectionOn = request.parameters['enableProtection'] == true;
        return _plan(
          request,
          protectionOn ? PlanItemStatus.verified : PlanItemStatus.failed,
        );
      }
      return _plan(request, PlanItemStatus.verified);
    });

    expect(find.textContaining('Ancora in esecuzione'), findsOneWidget);
    await tester.tap(find.text('Avvia la disinstallazione'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Il punto di ripristino non è stato creato'),
      findsOneWidget,
    );
    expect(calls.map((c) => c.operationId), ['system.restore_point.create']);

    await tester.tap(find.text('Attiva la Protezione sistema e riprova'));
    await tester.pumpAndSettle();

    expect(calls.map((c) => c.operationId), [
      'system.restore_point.create',
      'system.restore_point.create',
      'app.win32.uninstall',
      'app.win32.uninstall',
    ]);
    expect(find.text('Fatta'), findsNWidgets(2));
  });

  testWidgets('simulation never calls the executor', (tester) async {
    var calls = 0;
    await _pump(tester, (requests) async {
      calls++;
      return _plan(requests.single, PlanItemStatus.verified);
    });

    await tester.tap(find.textContaining('Simulazione'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avvia la disinstallazione'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(calls, 0);
    expect(
      find.text('Simulazione: non è stato disinstallato nulla.'),
      findsOneWidget,
    );
  });
}
