import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/operations/app_restore_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/plans/plan_engine.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/app_inventory_parser.dart';
import 'package:script_utility/features/apps/application/windows_app_inventory_service.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';
import 'package:script_utility/features/apps/domain/microsoft_restore_catalog.dart';

void main() {
  test('AppX inventory keeps per-user and provisioned state distinct', () {
    final parser = AppInventoryParser();
    final packages = parser.parseAppx('''[
      {"Name":"Microsoft.Sample","CurrentUser":true,"AllUsers":false,
       "Provisioned":true,"Reinstallable":false}
    ]''');
    final package = packages.single;

    expect(package.scopes, contains(AppInstallScope.currentUser));
    expect(package.scopes, contains(AppInstallScope.provisioned));
    expect(package.reinstallable, isFalse);
    final preview = parser.previewRemoval(
      package,
      scopes: const <AppInstallScope>{AppInstallScope.provisioned},
    );
    expect(preview.affectedScopes, <AppInstallScope>{
      AppInstallScope.provisioned,
    });
  });

  test('AppX rows merge without losing user and provisioned scopes', () {
    final packages = const AppInventoryParser().parseAppx('''[
      {"Name":"Microsoft.Sample","CurrentUser":true},
      {"Name":"Microsoft.Sample","Provisioned":true}
    ]''');

    expect(packages, hasLength(1));
    expect(packages.single.scopes, <AppInstallScope>{
      AppInstallScope.currentUser,
      AppInstallScope.provisioned,
    });
  });

  test('current-user scan never claims elevated inventory coverage', () async {
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async =>
          ProcessResult(
            1,
            0,
            '[{"Name":"Microsoft.Sample","CurrentUser":true}]',
            '',
          ),
    );
    final result = await WindowsAppInventoryService(
      processRunner: runner,
    ).scanCurrentUser();

    expect(result.packages.single.packageId, 'Microsoft.Sample');
    expect(result.currentUserComplete, isTrue);
    expect(result.allUsersComplete, isFalse);
    expect(result.provisionedComplete, isFalse);
    expect(result.wingetComplete, isFalse);
  });

  test(
    'winget inventory uses JSON export and removes its temporary file',
    () async {
      String? exportPath;
      final runner = ProcessRunner(
        processRunDelegate:
            (executable, arguments, {runInShell = false}) async {
              exportPath = arguments[arguments.indexOf('--output') + 1];
              await File(exportPath!).writeAsString('''{
              "Sources":[{
                "Packages":[{"PackageIdentifier":"Vendor.App","Version":"1.0"}],
                "SourceDetails":{"Name":"winget"}
              }]
            }''');
              return ProcessResult(1, 0, '', '');
            },
      );

      final result = await WindowsAppInventoryService(
        processRunner: runner,
      ).scanWinget();

      expect(result.wingetComplete, isTrue);
      expect(result.packages.single.packageId, 'Vendor.App');
      expect(result.packages.single.source, 'winget');
      expect(File(exportPath!).existsSync(), isFalse);
    },
  );

  test('app restore uses only its fixed verified source identity', () async {
    var installed = false;
    List<String>? wingetArguments;
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async {
        if (executable == 'winget') {
          wingetArguments = arguments;
          installed = true;
          return ProcessResult(1, 0, '', '');
        }
        return ProcessResult(
          1,
          0,
          installed
              ? '[{"Name":"Microsoft.WindowsStore","CurrentUser":true}]'
              : '[]',
          '',
        );
      },
    );
    final operation = AppRestoreOperation(
      id: 'restore_microsoft_windowsstore',
      legacyPackageName: 'Microsoft.WindowsStore',
      identity: microsoftRestoreCatalog['Microsoft.WindowsStore']!,
      processRunner: runner,
    );
    final engine = PlanEngine(
      registry: OperationRegistry(<OperationDefinition>[operation]),
      context: const OperationContext(windowsBuild: 26100, edition: 'Home'),
      user: 'test-user',
      appVersion: 'test',
    );
    final plan = await engine.plan(const <OperationRequest>[
      OperationRequest(
        operationId: 'restore_microsoft_windowsstore',
        desiredValue: true,
      ),
    ]);

    await engine.execute(plan);

    expect(plan.status, PlanStatus.completed);
    expect(operation.rollbackCapability, RollbackCapability.manual);
    expect(
      wingetArguments,
      containsAllInOrder(<String>[
        'install',
        '--exact',
        '--id',
        '9WZDNCRFJBMP',
        '--source',
        'msstore',
      ]),
    );
  });

  test(
    'all 17 legacy Microsoft app restores have native package identities',
    () {
      expect(microsoftRestoreCatalog, hasLength(17));
      expect(microsoftRestoreCatalog.keys, contains('Microsoft.WindowsStore'));
      expect(microsoftRestoreCatalog.keys, contains('Microsoft.GamingApp'));
      for (final entry in microsoftRestoreCatalog.entries) {
        expect(entry.value.source, anyOf('winget', 'msstore'));
        expect(entry.value.packageId, isNotEmpty, reason: entry.key);
        if (entry.value.source == 'msstore') {
          expect(
            entry.value.packageId,
            matches(RegExp(r'^[A-Z0-9]{12}$')),
            reason: entry.key,
          );
        }
      }
    },
  );
}
