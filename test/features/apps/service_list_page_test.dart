import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/features/apps/application/service_inventory.dart';
import 'package:script_utility/features/apps/presentation/service_list_page.dart';
import 'package:script_utility/l10n/app_localizations.dart';

ServiceEntry _service(
  String name,
  String display,
  int startType, {
  bool delayed = false,
}) => ServiceEntry(
  name: name,
  displayName: display,
  description: null,
  startType: startType,
  delayed: delayed,
  running: startType == 2,
  path: r'C:\Windows\System32\svchost.exe',
  company: 'Microsoft Corporation',
);

OperationPlan _plan(OperationRequest request) => OperationPlan(
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
      status: PlanItemStatus.verified,
    ),
  ],
);

void main() {
  testWidgets('change asks first, sends a typed request, undo restores', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sent = <OperationRequest>[];
    await tester.pumpWidget(
      FluentApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScaffoldPage(
          content: ServiceListPage(
            load: () async => <ServiceEntry>[
              _service('Spooler', 'Print Spooler', 2),
              _service('wuauserv', 'Windows Update', 3),
            ],
            execute: (requests) async {
              sent.addAll(requests);
              return _plan(requests.single);
            },
            systemRoot: r'C:\Windows',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Depends on use'), findsOneWidget);
    expect(find.text('Keep it'), findsOneWidget);
    // Windows Update gets no menu at all.
    expect(find.byType(DropDownButton), findsOneWidget);

    await tester.tap(find.byType(DropDownButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disable').last);
    await tester.pumpAndSettle();
    expect(sent, isEmpty, reason: 'nothing changes before confirming');
    expect(
      find.descendant(
        of: find.byType(ContentDialog),
        matching: find.textContaining('printing stops working'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Disable'));
    await tester.pumpAndSettle();
    expect(sent.single.target, 'Spooler');
    expect(sent.single.desiredValue, <String, Object?>{
      'startType': 4,
      'delayedAutoStart': false,
    });

    await tester.tap(find.widgetWithText(Button, 'Undo'));
    await tester.pumpAndSettle();
    expect(sent.last.desiredValue, <String, Object?>{
      'startType': 2,
      'delayedAutoStart': false,
    });
    expect(find.widgetWithText(Button, 'Undo'), findsNothing);
  });

  testWidgets('undo of a Manual service shipped with the delayed flag works', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sent = <OperationRequest>[];
    await tester.pumpWidget(
      FluentApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScaffoldPage(
          content: ServiceListPage(
            load: () async => <ServiceEntry>[
              // As Windows ships dmwappushservice: Manual, DelayedAutoStart=1.
              _service('dmwappushservice', 'WAP Push', 3, delayed: true),
            ],
            execute: (requests) async {
              sent.addAll(requests);
              return _plan(requests.single);
            },
            systemRoot: r'C:\Windows',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropDownButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disable').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Disable'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Button, 'Undo'));
    await tester.pumpAndSettle();

    expect(sent.last.desiredValue, <String, Object?>{
      'startType': 3,
      'delayedAutoStart': false,
    });
  });
}
