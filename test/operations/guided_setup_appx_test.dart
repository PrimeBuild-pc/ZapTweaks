import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/models/hardware_profile.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/app_inventory_parser.dart';
import 'package:script_utility/features/apps/application/app_store_catalog.dart';
import 'package:script_utility/features/apps/application/windows_app_inventory_service.dart';
import 'package:script_utility/features/apps/domain/appx_candidate_policy.dart';
import 'package:script_utility/features/setup/presentation/guided_setup_page.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';
import 'package:script_utility/l10n/app_localizations.dart';

import 'appx_test_fixtures.dart';

class _Controller extends ChangeNotifier implements TweakController {
  final batches = <List<OperationRequest>>[];
  @override
  HardwareProfile get hardwareProfile => HardwareProfile.unknown;

  @override
  Future<OperationPlan> executeNativeRequests(
    List<OperationRequest> requests,
  ) async {
    batches.add(requests);
    return OperationPlan(
      id: 'test-${batches.length}',
      createdAt: DateTime.now(),
      user: 'test',
      appVersion: 'test',
      windowsBuild: 26100,
      status: PlanStatus.completed,
      items: [
        for (final request in requests)
          PlanItem(
            operationId: request.operationId,
            request: request,
            before: const OperationState(OperationStateKind.configured),
            status: PlanItemStatus.verified,
            snapshot: OperationSnapshot(
              type: 'appxRemoval',
              data: {
                'restorePackageId':
                    appxCandidatePolicy[request.target]?.restore?.packageId,
                'restoreSource':
                    appxCandidatePolicy[request.target]?.restore?.source,
              },
              expectedAfterRollback: const OperationState(
                OperationStateKind.configured,
              ),
            ),
          ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InventoryRunner extends ProcessRunner {
  @override
  Future<String> runPowerShellForOutput(String script) async => jsonEncode(
    appxInventory(
      installed: [
        appxMetadata(),
        appxMetadata(name: 'Microsoft.WindowsStore'),
      ],
    ),
  );

  @override
  Future<CommandResult> run(
    String executable,
    List<String> arguments, {
    bool elevated = false,
    bool runInShell = false,
    Duration? timeout,
  }) async {
    final output = arguments[arguments.indexOf('--output') + 1];
    await File(output).writeAsString('{"Sources":[]}');
    return const CommandResult(exitCode: 0, stdout: '', stderr: '');
  }
}

void main() {
  test(
    'setup partitions privileges without silently broadening AppX scopes',
    () {
      final requests = <OperationRequest>[
        const OperationRequest(
          operationId: 'app.winget.set',
          target: 'Vendor.App',
          desiredValue: true,
        ),
        const OperationRequest(
          operationId: 'app.appx.remove_current_user',
          target: feedbackHub,
          desiredValue: null,
          parameters: {'scope': 'currentUser'},
        ),
        const OperationRequest(
          operationId: 'ui_taskbar_end_task',
          desiredValue: 1,
        ),
        const OperationRequest(
          operationId: 'app.appx.remove_system',
          target: 'Microsoft.GetHelp',
          desiredValue: null,
          parameters: {'scope': 'allUsersAndProvisioned'},
        ),
      ];
      expect(setupRequestGroups([]), isEmpty);
      final groups = setupRequestGroups(requests);
      expect(groups[OperationPrivilege.user], requests.take(2));
      expect(groups[OperationPrivilege.administrator], requests.skip(2));
      expect(
        groups[OperationPrivilege.user]!.last.parameters['scope'],
        'currentUser',
      );
      expect(
        groups[OperationPrivilege.administrator]!.last.parameters['scope'],
        'allUsersAndProvisioned',
      );
      expect(
        () => setupRequestGroups(const [
          OperationRequest(operationId: 'unknown', desiredValue: null),
        ]),
        throwsStateError,
      );
    },
  );

  testWidgets(
    'wizard starts empty, exposes exact groups/scopes and executes explicit separate plans',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 820);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previousRunner = ProcessRunner.shared;
      ProcessRunner.configureShared(_InventoryRunner());
      addTearDown(() => ProcessRunner.configureShared(previousRunner));
      final controller = _Controller();
      addTearDown(controller.dispose);
      var systemScans = 0;
      await tester.pumpWidget(
        FluentApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GuidedSetupPage(
            controller: controller,
            catalogLoader: () async => AppStoreCatalog([]),
            deviceInventoryLoader: () async => [],
            systemAppsLoader: () async {
              systemScans++;
              final installed =
                  [appxMetadata(), appxMetadata(name: 'Microsoft.GetHelp')]
                      .map(
                        (app) => app
                          ..['CurrentUser'] = false
                          ..['AllUsers'] = true,
                      )
                      .toList();
              return AppInventoryResult(
                packages: const AppInventoryParser().parseAppx(
                  jsonEncode(
                    appxInventory(
                      installed: installed,
                      system: true,
                      provisioned: installed.map(appxProvision).toList(),
                    ),
                  ),
                ),
                currentUserComplete: false,
                allUsersComplete: true,
                provisionedComplete: true,
                wingetComplete: false,
              );
            },
          ),
        ),
      );
      await tester.runAsync(() async {
        await tester.tap(find.text('Run inventory'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      Future<void> next() async {
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
      }

      await next(); // baseline
      await next(); // updates
      final review = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.onChanged != null,
      );
      tester.widget<Checkbox>(review).onChanged!(true);
      await tester.pumpAndSettle();
      await next(); // drivers
      await next(); // apps
      await next(); // debloat
      expect(systemScans, 0);
      expect(controller.batches, isEmpty);
      expect(find.text('Low risk · optional app'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Medium risk · optional functionality'),
        300,
      );
      expect(find.text('Medium risk · optional functionality'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Legacy · inventory only'),
        500,
      );
      expect(find.text('Legacy · inventory only'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Scan all users (UAC)'), -500);
      expect(find.textContaining('Microsoft.WindowsStore'), findsNothing);
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .every((box) => box.checked == false),
        isTrue,
      );
      expect(find.text('All users · existing accounts'), findsNothing);
      await tester.tap(find.text('Scan all users (UAC)'));
      await tester.pumpAndSettle();
      expect(systemScans, 1);
      final current = find.widgetWithText(Checkbox, 'Current user');
      tester.widget<Checkbox>(current).onChanged!(true);
      await tester.pumpAndSettle();
      final combined = find.widgetWithText(
        Checkbox,
        'All users + Provisioned · existing + future accounts',
      );
      expect(combined, findsNWidgets(2));
      tester.widgetList<Checkbox>(combined).last.onChanged!(true); // Get Help.
      await tester.pumpAndSettle();
      await next(); // privacy/interface
      final endTask = find.byType(Checkbox);
      tester.widget<Checkbox>(endTask).onChanged!(true);
      await tester.pumpAndSettle();
      await next(); // preview
      expect(find.text('Plan preview · user'), findsOneWidget);
      expect(find.text('Plan preview · administrator'), findsOneWidget);
      expect(find.textContaining('no cross-plan transaction'), findsOneWidget);
      expect(controller.batches, isEmpty);
      await next(); // apply
      await tester.tap(find.text('Apply plan · user · 1'));
      await tester.pumpAndSettle();
      expect(controller.batches, hasLength(1));
      expect(
        controller.batches.single.single.parameters['scope'],
        'currentUser',
      );
      expect(controller.batches.single.single.target, feedbackHub);
      await tester.tap(find.text('Apply plan · administrator · 2'));
      await tester.pumpAndSettle();
      expect(controller.batches, hasLength(2));
      expect(controller.batches.last.last.target, 'Microsoft.GetHelp');
      expect(
        controller.batches.last.last.parameters['scope'],
        'allUsersAndProvisioned',
      );
      await tester.tap(find.text('Final report'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Restore sources are not rollback'),
        findsOneWidget,
      );
      expect(find.textContaining('9NBLGGH4R32N'), findsOneWidget);
      expect(find.textContaining('9PKDZBMV1H3T'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
