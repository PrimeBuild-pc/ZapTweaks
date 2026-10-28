import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/sparkle_operations.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/features/windows/presentation/sparkle_manual_page.dart';
import 'package:script_utility/features/windows/presentation/sparkle_manual_strings.dart';
import 'package:script_utility/platform/windows/service_control_manager.dart';
import 'package:script_utility/platform/windows/sparkle_service_preview.dart';

OperationPlan _plan(
  List<OperationRequest> requests, {
  PlanStatus status = PlanStatus.completed,
}) => OperationPlan(
  id: 'mock',
  createdAt: DateTime.utc(2026),
  user: 'mock',
  appVersion: 'test',
  windowsBuild: 26100,
  status: status,
  items: [
    for (final request in requests)
      PlanItem(
        operationId: request.operationId,
        request: request,
        before: const OperationState(OperationStateKind.absent),
        status: PlanItemStatus.verified,
      ),
  ],
);

Future<void> _pump(
  WidgetTester tester, {
  bool expert = false,
  String language = 'en',
  double scale = 1,
  ThemeMode theme = ThemeMode.light,
  required Future<OperationPlan> Function(List<OperationRequest>) execute,
  Future<void> Function(Uri)? external,
  Future<List<SparkleServicePreview>> Function()? scan,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    FluentApp(
      themeMode: theme,
      darkTheme: FluentThemeData(brightness: Brightness.dark),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: SparkleManualPage(
        expertEnabled: expert,
        executeRequests: execute,
        localize: (key) => (language == 'it'
            ? sparkleManualItalian
            : sparkleManualEnglish)[key]!,
        openExternal: external ?? (_) async {},
        scanServices: scan,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _show(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester, {bool expert = false}) async {
  final dialog = find.byType(ContentDialog);
  if (expert) {
    final consent = find.descendant(
      of: dialog,
      matching: find.byType(Checkbox),
    );
    await tester.ensureVisible(consent);
    await tester.tap(consent);
    await tester.pumpAndSettle();
  }
  final apply = find.descendant(
    of: dialog,
    matching: find.byType(FilledButton),
  );
  await tester.tap(apply);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'EN/IT integration key sets match and security notices are explicit',
    () {
      expect(
        sparkleManualItalian.keys.toSet(),
        sparkleManualEnglish.keys.toSet(),
      );
      expect(
        sparkleManualEnglish['sparkleHvciWarning'],
        contains('VBS or Secure Boot'),
      );
      expect(
        sparkleManualEnglish['sparkleDefenderUnavailable'],
        contains('provider-only'),
      );
      expect(
        sparkleManualEnglish['sparkleEdgeUnavailable'],
        contains('profile deletion unchecked'),
      );
    },
  );

  for (final language in ['en', 'it']) {
    testWidgets(
      '$language at 150% scaling, no auto execution/defaults and external-only source',
      (tester) async {
        var executed = 0;
        final urls = <Uri>[];
        await _pump(
          tester,
          language: language,
          scale: 1.5,
          theme: language == 'it' ? ThemeMode.dark : ThemeMode.light,
          execute: (requests) async {
            executed++;
            return _plan(requests);
          },
          external: (url) async => urls.add(url),
        );
        expect(executed, 0);
        expect(urls, isEmpty);
        for (final checkbox in tester.widgetList<Checkbox>(
          find.byType(Checkbox),
        )) {
          expect(checkbox.checked, isFalse);
        }
        final preview = find.byKey(const ValueKey('sparkleSafePreview'));
        await _show(tester, preview);
        expect(tester.widget<Button>(preview).onPressed, isNull);
        final strings = language == 'it'
            ? sparkleManualItalian
            : sparkleManualEnglish;
        await _show(tester, find.text(strings['sparkleExpertLocked']!));
        expect(
          find.byKey(const ValueKey('sparkle.security.hvci_configured_off')),
          findsNothing,
        );
        await _show(tester, find.text(strings['sparkleNvidiaUnavailable']!));
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings['sparkleExternal']!).first);
        await tester.pumpAndSettle();
        expect(urls, [Uri.parse(sparkleSourceUrl)]);
        expect(executed, 0);
      },
    );
  }

  testWidgets(
    'safe requests require preview and preserve typed values; cancel never executes',
    (tester) async {
      final calls = <List<OperationRequest>>[];
      await _pump(
        tester,
        execute: (requests) async {
          calls.add(requests);
          return _plan(requests);
        },
      );
      await _show(tester, find.byKey(const ValueKey('sparkleClock')));
      await tester.tap(find.byKey(const ValueKey('sparkleClock')));
      await tester.pumpAndSettle();
      final preview = find.byKey(const ValueKey('sparkleSafePreview'));
      await _show(tester, preview);
      await tester.tap(preview);
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(
        find.textContaining('sparkle.clock.short_time → HH:mm'),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await tester.tap(preview);
      await tester.pumpAndSettle();
      await _confirm(tester);
      expect(calls, hasLength(1));
      expect(calls.single.map((r) => r.operationId), [
        'sparkle.clock.short_time',
        'sparkle.clock.time_format',
      ]);
      expect(calls.single.map((r) => r.desiredValue), ['HH:mm', 'HH:mm:ss']);
    },
  );

  testWidgets(
    'menu delay rejects invalid values in the page and submits REG_SZ not int',
    (tester) async {
      final calls = <List<OperationRequest>>[];
      await _pump(
        tester,
        execute: (requests) async {
          calls.add(requests);
          return _plan(requests);
        },
      );
      await _show(tester, find.byKey(const ValueKey('sparkleMenuDelay')));
      await tester.tap(find.byKey(const ValueKey('sparkleMenuDelay')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('sparkleMenuDelayInput')),
        '4001',
      );
      final preview = find.byKey(const ValueKey('sparkleSafePreview'));
      await _show(tester, preview);
      expect(tester.widget<Button>(preview).onPressed, isNull);
      await _show(tester, find.byKey(const ValueKey('sparkleMenuDelayInput')));
      await tester.enterText(
        find.byKey(const ValueKey('sparkleMenuDelayInput')),
        '0',
      );
      await _show(tester, preview);
      await tester.tap(preview);
      await tester.pumpAndSettle();
      await _confirm(tester);
      expect(calls.single.single.desiredValue, '0');
    },
  );

  testWidgets(
    'Expert action requires separate destructive consent and never mixes safe/admin requests',
    (tester) async {
      final calls = <List<OperationRequest>>[];
      await _pump(
        tester,
        expert: true,
        execute: (requests) async {
          calls.add(requests);
          return _plan(requests);
        },
      );
      final hvci = find.byKey(
        const ValueKey('sparkle.security.hvci_configured_off'),
      );
      await _show(tester, hvci);
      await tester.tap(hvci);
      await tester.pumpAndSettle();
      final apply = find.descendant(
        of: find.byType(ContentDialog),
        matching: find.byType(FilledButton),
      );
      expect(tester.widget<FilledButton>(apply).onPressed, isNull);
      expect(calls, isEmpty);
      await _confirm(tester, expert: true);
      expect(
        calls.single.single.operationId,
        'sparkle.security.hvci_configured_off',
      );
      expect(calls.single.single.desiredValue, 0);
    },
  );

  testWidgets(
    'service preview is manual, shows dependencies and no startup defaults',
    (tester) async {
      var scans = 0;
      final calls = <List<OperationRequest>>[];
      await _pump(
        tester,
        expert: true,
        execute: (requests) async {
          calls.add(requests);
          return _plan(requests);
        },
        scan: () async {
          scans++;
          return [
            const SparkleServicePreview(
              name: 'DiagTrack',
              service: WindowsServiceInfo(
                name: 'DiagTrack',
                displayName: 'Diagnostics',
                startType: 2,
                delayedAutoStart: true,
                state: 4,
                account: 'LocalSystem',
                dependencies: ['RpcSs'],
                dependents: ['ExampleDependent'],
                processId: 1,
              ),
            ),
          ];
        },
      );
      expect(scans, 0);
      await _show(tester, find.text('Inspect allowlisted services'));
      await tester.tap(find.text('Inspect allowlisted services'));
      await tester.pumpAndSettle();
      expect(scans, 1);
      final combo = find.byKey(const ValueKey('service:DiagTrack'));
      await _show(tester, combo);
      expect(tester.widget<ComboBox<int>>(combo).value, isNull);
      expect(find.textContaining('RpcSs'), findsOneWidget);
      expect(find.textContaining('ExampleDependent'), findsOneWidget);
      expect(calls, isEmpty);
      tester.widget<ComboBox<int>>(combo).onChanged!(4);
      await tester.pumpAndSettle();
      final preview = find.byKey(const ValueKey('sparkleServicePreview'));
      await _show(tester, preview);
      await tester.tap(preview);
      await tester.pumpAndSettle();
      await _confirm(tester, expert: true);
      expect(calls.single.single.target, 'DiagTrack');
      expect(calls.single.single.operationId, 'service.start.configure');
      expect(calls.single.single.desiredValue, {
        'startType': 4,
        'delayedAutoStart': false,
      });
    },
  );

  testWidgets('dry run is clearly not reported as a real Windows change', (
    tester,
  ) async {
    await _pump(
      tester,
      execute: (requests) async =>
          _plan(requests, status: PlanStatus.dryRunComplete),
    );
    await _show(tester, find.byKey(const ValueKey('sparkleClock')));
    await tester.tap(find.byKey(const ValueKey('sparkleClock')));
    await tester.pumpAndSettle();
    final preview = find.byKey(const ValueKey('sparkleSafePreview'));
    await _show(tester, preview);
    await tester.tap(preview);
    await tester.pumpAndSettle();
    await _confirm(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await tester.pumpAndSettle();
    expect(find.text(sparkleManualEnglish['sparkleDryRun']!), findsOneWidget);
    expect(find.text(sparkleManualEnglish['sparkleDone']!), findsNothing);
  });
}
