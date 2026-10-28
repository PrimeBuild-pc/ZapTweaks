import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:script_utility/core/persistence/operation_store.dart';
import 'package:path/path.dart' as p;
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/features/diagnostics/presentation/recovery_page.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';
import 'package:script_utility/l10n/app_localizations.dart';
import 'package:script_utility/platform/windows/cleanup_preview.dart';

class _Controller extends ChangeNotifier implements TweakController {
  final requests = <OperationRequest>[];
  bool skipped = false;
  String? restoredPlanId;

  @override
  bool canRestoreManualPlan(OperationPlan plan) =>
      plan.items.every((item) => item.operationId.startsWith('sparkle.'));

  @override
  Future<OperationPlan> restoreManualPlan(String planId) async {
    restoredPlanId = planId;
    return OperationPlan(
      id: planId,
      createdAt: DateTime(2026),
      user: 'test',
      appVersion: 'test',
      windowsBuild: 26100,
      items: [],
      status: PlanStatus.rolledBack,
    );
  }

  @override
  Future<OperationPlan> executeNativeRequests(
    List<OperationRequest> requests,
  ) async {
    this.requests.addAll(requests);
    return OperationPlan(
      id: 'synthetic-cleanup',
      createdAt: DateTime(2026),
      user: 'test',
      appVersion: 'test',
      windowsBuild: 26100,
      status: PlanStatus.completed,
      items: [
        PlanItem(
          operationId: requests.single.operationId,
          request: requests.single,
          before: const OperationState(OperationStateKind.configured),
          status: skipped ? PlanItemStatus.skipped : PlanItemStatus.verified,
          error: skipped ? 'Approved file changed; cleanup was skipped.' : null,
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Scanner extends CleanupScanner {
  _Scanner(this.preview);
  CleanupPreview preview;
  final categories = <String>[];

  @override
  Future<CleanupPreview> scanDirectory(
    Directory directory, {
    required String category,
    required String reason,
  }) async {
    categories.add(category);
    return preview;
  }
}

Future<void> _show(
  WidgetTester tester,
  _Controller controller,
  _Scanner scanner, {
  OperationStore? journal,
  List<Directory> shaderRoots = const <Directory>[],
  List<Directory> browserRoots = const <Directory>[],
  List<String> openBrowsers = const <String>[],
}) async {
  tester.view.physicalSize = const Size(1280, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    FluentApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RecoveryPage(
        controller: controller,
        cleanupScanner: scanner,
        journal: journal,
        shaderCacheDirectories: () => shaderRoots,
        crashReportDirectories: () => const <Directory>[],
        browserCacheDirectories: () => browserRoots,
        listRunningBrowsers: () async => openBrowsers,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tracePreview(WidgetTester tester) async {
  final card = find.ancestor(
    of: find.text('Delete diagnostic traces'),
    matching: find.byType(Card),
  );
  final action = find.descendant(of: card, matching: find.byType(Button));
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('journal restoration requires a second explicit confirmation', (
    tester,
  ) async {
    final database = sqlite3.openInMemory();
    addTearDown(database.close);
    final journal = OperationStore(database);
    final source = OperationPlan(
      id: 'manual-source',
      createdAt: DateTime(2026),
      user: 'test',
      appVersion: 'test',
      windowsBuild: 26100,
      status: PlanStatus.completed,
      items: [
        PlanItem(
          operationId: 'sparkle.clock.short_time',
          request: const OperationRequest(
            operationId: 'sparkle.clock.short_time',
            desiredValue: 'HH:mm',
          ),
          before: const OperationState(
            OperationStateKind.configured,
            value: 'h:mm tt',
          ),
          written: const OperationState(
            OperationStateKind.configured,
            value: 'HH:mm',
          ),
          status: PlanItemStatus.verified,
          snapshot: const OperationSnapshot(
            type: 'registryValue',
            data: {},
            expectedAfterRollback: OperationState(
              OperationStateKind.configured,
              value: 'h:mm tt',
            ),
          ),
        ),
      ],
    );
    journal.save(source);
    final control = _Controller();
    addTearDown(control.dispose);
    await _show(
      tester,
      control,
      _Scanner(CleanupPreview([])),
      journal: journal,
    );
    await tester.tap(find.text('Open recovery and journal').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Restore original manual settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('HH:mm → h:mm tt'), findsOneWidget);
    expect(control.restoredPlanId, isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(control.restoredPlanId, isNull);
    await tester.tap(find.text('Open recovery and journal').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Restore original manual settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(control.restoredPlanId, source.id);
    expect(control.requests, isEmpty);
    expect(tester.takeException(), isNull);
  });
  late Directory sandbox;
  late CleanupCandidate candidate;
  late _Controller controller;
  late _Scanner scanner;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('zap-cleanup-ui-test-');
    candidate = CleanupCandidate(
      path: p.join(sandbox.path, 'approved.etl'),
      category: 'ZapTweaks traces',
      size: 10,
      reason: 'Synthetic trace for preview testing',
      identity: 'synthetic-file-identity',
      rootCanonical: sandbox.path,
      rootIdentity: 'synthetic-root-identity',
    );
    controller = _Controller();
    scanner = _Scanner(CleanupPreview([candidate]));
  });
  tearDown(() async {
    controller.dispose();
    await sandbox.delete(recursive: true);
  });

  testWidgets(
    'trace preview shows exact paths, reason and irreversibility; cancel never executes',
    (tester) async {
      await _show(tester, controller, scanner);
      await _tracePreview(tester);
      expect(find.text(candidate.path), findsOneWidget);
      expect(find.textContaining('No rollback'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(candidate.reason),
        100,
        scrollable: find
            .descendant(
              of: find.descendant(
                of: find.byType(ContentDialog),
                matching: find.byType(ListView),
              ),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text(candidate.reason), findsOneWidget);
      expect(controller.requests, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(controller.requests, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'explicit confirmation passes only identities from the displayed frozen preview',
    (tester) async {
      await _show(tester, controller, scanner);
      await _tracePreview(tester);
      scanner.preview = CleanupPreview([]);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        controller.requests.single.operationId,
        'diagnostics.trace.cleanup',
      );
      expect(controller.requests.single.parameters, {
        'preview': [candidate.toJson()],
      });
      expect(scanner.categories, ['ZapTweaks traces']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('incomplete scan reports an error without offering deletion', (
    tester,
  ) async {
    scanner.preview = CleanupPreview(
      [candidate],
      errors: ['Synthetic permission denied'],
    );
    await _show(tester, controller, scanner);
    await _tracePreview(tester);
    expect(find.text('Synthetic permission denied'), findsOneWidget);
    expect(find.byType(ContentDialog), findsNothing);
    expect(controller.requests, isEmpty);
  });

  testWidgets('skipped cleanup is not reported as completed', (tester) async {
    controller.skipped = true;
    await _show(tester, controller, scanner);
    await _tracePreview(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('Approved file changed; cleanup was skipped.'),
      findsOneWidget,
    );
    expect(find.text('Operation failed'), findsOneWidget);
  });

  testWidgets(
    'UserTemp requires file selection and Recycle Bin has no empty-all action',
    (tester) async {
      await _show(tester, controller, scanner);
      final action = find.text('Preview and select files');
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Nothing is selected'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(
                of: find.text('Delete'),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).checked, isFalse);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(scanner.categories, ['UserTemp']);
      expect(controller.requests, isEmpty);
      expect(find.text(recycleCleanupUnavailable), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'UserTemp passes only selected frozen identities, never a rescan',
    (tester) async {
      await _show(tester, controller, scanner);
      final action = find.text('Preview and select files');
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).checked, isTrue);
      await tester.pump(const Duration(milliseconds: 400));
      scanner.preview = CleanupPreview([]);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(controller.requests.single.operationId, 'cleanup.user_temp');
      expect(controller.requests.single.parameters, {
        'preview': [candidate.toJson()],
      });
      expect(scanner.categories, ['UserTemp']);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shader cache cleanup shows the per-root total and passes the frozen preview',
    (tester) async {
      await _show(tester, controller, scanner, shaderRoots: [sandbox]);
      final action = find.descendant(
        of: find.ancestor(
          of: find.text('GPU shader cache cleanup'),
          matching: find.byType(Card),
        ),
        matching: find.text('Preview'),
      );
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(candidate.rootCanonical), findsOneWidget);
      expect(find.textContaining('No rollback'), findsOneWidget);
      scanner.preview = CleanupPreview([]);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(controller.requests.single.operationId, 'cleanup.shader_cache');
      expect(controller.requests.single.parameters, {
        'preview': [candidate.toJson()],
      });
      expect(scanner.categories, ['GPU shader cache cleanup']);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('browser cache cleanup refuses to scan while a browser is open', (
    tester,
  ) async {
    await _show(
      tester,
      controller,
      scanner,
      browserRoots: [sandbox],
      openBrowsers: const ['Chrome', 'Edge'],
    );
    // The list builds cards lazily: bring the browser card in before looking for its button.
    await tester.scrollUntilVisible(
      find.text('Browser caches'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    final card = find.ancestor(
      of: find.text('Browser caches'),
      matching: find.byType(Card),
    );
    await tester.tap(find.descendant(of: card, matching: find.byType(Button)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Close Chrome, Edge first'), findsOneWidget);
    expect(scanner.categories, isEmpty, reason: 'nothing is scanned');
    expect(controller.requests, isEmpty);
  });
}
