import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/appx_removal_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/domain/appx_candidate_policy.dart';
import 'package:script_utility/features/apps/domain/microsoft_restore_catalog.dart';

import 'appx_test_fixtures.dart';

class _Runner extends ProcessRunner {
  Map<String, dynamic> inventory = appxInventory();
  String? appliedScript;
  final queries = <String>[];
  bool failQuery = false;

  @override
  Future<String> runPowerShellForOutput(String script) async {
    queries.add(script);
    if (failQuery) throw StateError('Access denied');
    return jsonEncode(inventory);
  }

  @override
  Future<void> runPowerShellScript(
    String script, {
    bool elevated = false,
  }) async {
    appliedScript = script;
    inventory = appxInventory(installed: [], system: true);
  }
}

OperationRequest _request(String scope, {String target = feedbackHub}) =>
    OperationRequest(
      operationId: scope == 'currentUser'
          ? 'app.appx.remove_current_user'
          : 'app.appx.remove_system',
      target: target,
      desiredValue: null,
      parameters: <String, Object?>{'scope': scope},
    );

AppxRemovalOperation _operation(_Runner runner, String scope) =>
    AppxRemovalOperation(
      id: scope == 'currentUser'
          ? 'app.appx.remove_current_user'
          : 'app.appx.remove_system',
      systemScopes: scope != 'currentUser',
      processRunner: runner,
    );

void main() {
  const context = OperationContext(windowsBuild: 26100, edition: 'Pro');
  const scopes = [
    'currentUser',
    'allUsers',
    'provisioned',
    'allUsersAndProvisioned',
  ];

  for (final scope in scopes) {
    test(
      '$scope validates exact metadata, snapshots restore source and verifies absence',
      () async {
        final runner = _Runner()
          ..inventory = appxInventory(
            system: scope != 'currentUser',
            provisioned:
                scope == 'provisioned' || scope == 'allUsersAndProvisioned'
                ? [appxProvision(appxMetadata())]
                : [],
          );
        final operation = _operation(runner, scope);
        final request = _request(scope);
        expect((await operation.supports(context, request)).supported, isTrue);
        final snapshot = await operation.captureSnapshot(request);
        await operation.apply(request);
        expect(snapshot.data['scope'], scope);
        expect(snapshot.data['restorePackageId'], '9NBLGGH4R32N');
        expect(snapshot.data['restoreSource'], 'msstore');
        expect(snapshot.data['rollbackAvailable'], false);
        expect(operation.rollbackCapability, RollbackCapability.none);
        expect(
          () => operation.rollback(request, snapshot),
          throwsUnsupportedError,
        );
        expect(runner.appliedScript, contains("if (\$actualHash -cne '"));
        expect(runner.appliedScript, isNot(contains('Get-AppxPackage -Name')));
        expect(runner.appliedScript, isNot(contains('| Remove-AppxPackage')));
        if (scope != 'provisioned') {
          expect(
            runner.appliedScript,
            contains(
              "Remove-AppxPackage -Package 'Microsoft.WindowsFeedbackHub_1.0.0.0_x64__8wekyb3d8bbwe'",
            ),
          );
        }
        if (scope == 'provisioned' || scope == 'allUsersAndProvisioned') {
          expect(
            runner.appliedScript,
            contains('Remove-AppxProvisionedPackage -Online -PackageName'),
          );
        }
        expect(
          (await operation.verify(request)).kind,
          OperationStateKind.absent,
        );
      },
    );

    for (final change in <String, Object?>{
      'Publisher': 'CN=Attacker',
      'PublisherId': 'attacker12345',
      'PackageFamilyName': 'Microsoft.Fake_8wekyb3d8bbwe',
      'PackageFullName':
          "Microsoft.WindowsFeedbackHub_1.0.0.0_x64_'evil_8wekyb3d8bbwe",
      'Version': '9.9.9.9',
      'IsFramework': true,
      'NonRemovable': true,
      'IsPartiallyStaged': true,
      'IsDevelopmentMode': true,
      'SignatureKind': 'Developer',
      'Status': 'Tampered',
      'DependenciesComplete': false,
      'Dependencies': null,
    }.entries) {
      test('$scope fails closed for ${change.key}', () async {
        final row = appxMetadata()..[change.key] = change.value;
        final runner = _Runner()
          ..inventory = appxInventory(
            installed: [row],
            system: scope != 'currentUser',
            provisioned:
                scope == 'provisioned' || scope == 'allUsersAndProvisioned'
                ? [appxProvision(row)]
                : [],
          );
        final operation = _operation(runner, scope);
        expect(
          (await operation.inspect(_request(scope))).kind,
          OperationStateKind.error,
        );
        await expectLater(operation.apply(_request(scope)), throwsStateError);
        expect(runner.appliedScript, isNull);
      });
    }

    test(
      '$scope rejects incomplete inverse dependencies and live dependents',
      () async {
        final unrelated = appxMetadata(name: 'Microsoft.OtherApp');
        final runner = _Runner()
          ..inventory = appxInventory(
            installed: [appxMetadata(), unrelated],
            system: scope != 'currentUser',
            provisioned:
                scope == 'provisioned' || scope == 'allUsersAndProvisioned'
                ? [appxProvision(appxMetadata())]
                : [],
          );
        final operation = _operation(runner, scope);
        unrelated.remove('DependenciesComplete');
        await expectLater(operation.apply(_request(scope)), throwsStateError);
        unrelated['DependenciesComplete'] = true;
        unrelated['Dependencies'] = [
          <String, dynamic>{
            'Name': feedbackHub,
            'PackageFullName': appxMetadata()['PackageFullName'],
            'PublisherId': '8wekyb3d8bbwe',
          },
        ];
        await expectLater(operation.apply(_request(scope)), throwsStateError);
        expect(runner.appliedScript, isNull);
      },
    );
  }

  test(
    'Store, frameworks, security, shell, auth and legacy remain protected',
    () async {
      final runner = _Runner();
      final operation = _operation(runner, 'currentUser');
      for (final target in [
        'Microsoft.WindowsStore',
        'Microsoft.StorePurchaseApp',
        'Microsoft.DesktopAppInstaller',
        'Microsoft.VCLibs.140.00',
        'Microsoft.UI.Xaml.2.8',
        'Microsoft.NET.Native.Runtime.2.2',
        'Microsoft.SecHealthUI',
        'Microsoft.Windows.ShellExperienceHost',
        'Microsoft.AAD.BrokerPlugin',
        'Microsoft.AccountsControl',
        'Microsoft.XboxIdentityProvider',
        'Microsoft.Family',
        'Microsoft.OneDrive',
        'Microsoft.DevHome',
        'Microsoft.WindowsCommunicationsApps',
        '*',
        'Microsoft.WindowsFeedbackHub*',
        'microsoft.windowsfeedbackhub',
        "Microsoft.WindowsFeedbackHub'; Remove-Item C:\\ -Recurse; '",
      ]) {
        final request = _request('currentUser', target: target);
        expect(
          (await operation.supports(context, request)).supported,
          isFalse,
          reason: target,
        );
        await expectLater(
          operation.apply(request),
          throwsStateError,
          reason: target,
        );
      }
      expect(runner.queries, isEmpty);
      expect(runner.appliedScript, isNull);
    },
  );

  test('restore catalog injection cannot broaden removal policy', () async {
    final runner = _Runner();
    final operation = AppxRemovalOperation(
      id: 'app.appx.remove_current_user',
      systemScopes: false,
      processRunner: runner,
      allowedPackages: {
        'Microsoft.WindowsStore':
            microsoftRestoreCatalog['Microsoft.WindowsStore']!,
      },
    );
    await expectLater(
      operation.apply(
        _request('currentUser', target: 'Microsoft.WindowsStore'),
      ),
      throwsStateError,
    );
    expect(runner.appliedScript, isNull);
  });

  test(
    'request operation ID, desired value, fields and elevation scopes are exact',
    () async {
      final runner = _Runner();
      final operation = _operation(runner, 'currentUser');
      for (final request in [
        _request('allUsers'),
        _request('provisioned'),
        _request('allUsersAndProvisioned'),
        const OperationRequest(
          operationId: 'wrong',
          target: feedbackHub,
          desiredValue: null,
          parameters: {'scope': 'currentUser'},
        ),
        const OperationRequest(
          operationId: 'app.appx.remove_current_user',
          target: feedbackHub,
          desiredValue: true,
          parameters: {'scope': 'currentUser'},
        ),
        const OperationRequest(
          operationId: 'app.appx.remove_current_user',
          target: feedbackHub,
          desiredValue: null,
          parameters: {'scope': 'currentUser', 'command': 'Remove-Item C:\\'},
        ),
      ]) {
        expect((await operation.supports(context, request)).supported, isFalse);
        await expectLater(operation.apply(request), throwsStateError);
      }
      expect(
        (await operation.supports(
          const OperationContext(windowsBuild: 19045, edition: 'Pro'),
          _request('currentUser'),
        )).supported,
        isFalse,
      );
      expect(runner.queries, isEmpty);
    },
  );

  test('apply does not trust an earlier preview or snapshot', () async {
    final runner = _Runner();
    final operation = _operation(runner, 'currentUser');
    await operation.captureSnapshot(_request('currentUser'));
    (runner.inventory['Installed'] as List).single['NonRemovable'] = true;
    await expectLater(
      operation.apply(_request('currentUser')),
      throwsStateError,
    );
    expect(runner.queries, hasLength(2));
    expect(runner.appliedScript, isNull);
  });

  test('combined preflights both inventories before any mutation', () async {
    final runner = _Runner()..inventory = appxInventory(system: true);
    final operation = _operation(runner, 'allUsersAndProvisioned');
    runner.inventory['ProvisionedComplete'] = false;
    await expectLater(
      operation.apply(_request('allUsersAndProvisioned')),
      throwsStateError,
    );
    runner.inventory['ProvisionedComplete'] = true;
    runner.inventory['Provisioned'] = [
      <String, dynamic>{
        'DisplayName': feedbackHub,
        'PackageName': '${feedbackHub}_2.0.0.0_x64__8wekyb3d8bbwe',
      },
    ];
    await expectLater(
      operation.apply(_request('allUsersAndProvisioned')),
      throwsStateError,
    );
    runner.inventory['Provisioned'] = [appxProvision(appxMetadata())];
    runner.inventory['AllUsersComplete'] = false;
    await expectLater(
      operation.apply(_request('allUsersAndProvisioned')),
      throwsStateError,
    );
    expect(runner.appliedScript, isNull);
  });

  test(
    'unknown provisioning inverse dependencies fail closed, even for another app',
    () async {
      final runner = _Runner()
        ..inventory = appxInventory(
          system: true,
          provisioned: [
            appxProvision(appxMetadata(name: 'Microsoft.UnregisteredApp')),
          ],
        );
      await expectLater(
        _operation(runner, 'provisioned').apply(_request('provisioned')),
        throwsStateError,
      );
      expect(runner.appliedScript, isNull);
    },
  );

  test('resource companions are never directly removed', () async {
    final resource = appxMetadata()
      ..['IsResourcePackage'] = true
      ..['PackageFullName'] =
          '${feedbackHub}_1.0.0.0_neutral_en-us_8wekyb3d8bbwe';
    final runner = _Runner()
      ..inventory = appxInventory(installed: [appxMetadata(), resource]);
    await _operation(runner, 'currentUser').apply(_request('currentUser'));
    expect(
      runner.appliedScript,
      isNot(contains("-Package '${resource['PackageFullName']}'")),
    );
  });

  test('query failures cannot become absence or permit mutation', () async {
    final runner = _Runner()..failQuery = true;
    final operation = _operation(runner, 'currentUser');
    expect(
      (await operation.inspect(_request('currentUser'))).kind,
      OperationStateKind.error,
    );
    await expectLater(
      operation.captureSnapshot(_request('currentUser')),
      throwsStateError,
    );
    await expectLater(
      operation.apply(_request('currentUser')),
      throwsStateError,
    );
    expect(runner.appliedScript, isNull);
  });

  test(
    'native mutation-process revalidation aborts both writes on drift (mock cmdlets only)',
    () async {
      final runner = _Runner()
        ..inventory = appxInventory(
          system: true,
          provisioned: [appxProvision(appxMetadata())],
        );
      await _operation(
        runner,
        'allUsersAndProvisioned',
      ).apply(_request('allUsersAndProvisioned'));
      // Every AppX cmdlet is shadowed: this invokes no Windows inventory or mutation.
      final result = await ProcessRunner().runPowerShellForOutput('''
\$script:writes = 0
function Get-AppxPackage { param([switch]\$AllUsers, [string[]]\$PackageTypeFilter, \$ErrorAction) @() }
function Get-AppxProvisionedPackage { param([switch]\$Online, \$ErrorAction) @() }
function Remove-AppxPackage { param(\$Package, [switch]\$AllUsers, \$ErrorAction) \$script:writes++ }
function Remove-AppxProvisionedPackage { param([switch]\$Online, \$PackageName, \$ErrorAction) \$script:writes++ }
try { ${runner.appliedScript!} } catch { Write-Output 'blocked' }
Write-Output "writes=\$script:writes"
''');
      expect(result, contains('blocked'));
      expect(result, contains('writes=0'));
    },
    skip: !Platform.isWindows,
  );

  test(
    'bundle removal tolerates a captured main identity disappearing (mock cmdlets only)',
    () async {
      final bundle = appxMetadata()
        ..['PackageFullName'] =
            '${feedbackHub}_1.0.0.0_neutral_~_8wekyb3d8bbwe';
      final runner = _Runner()
        ..inventory = appxInventory(installed: [bundle, appxMetadata()]);
      final encoded = base64Encode(utf8.encode(jsonEncode(runner.inventory)));
      await _operation(runner, 'currentUser').apply(_request('currentUser'));
      final output = await ProcessRunner().runPowerShellForOutput('''
\$script:packages = @(([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encoded')) | ConvertFrom-Json).Installed)
\$script:writes = 0
function Get-AppxPackage { param([switch]\$AllUsers, [string[]]\$PackageTypeFilter, \$ErrorAction) \$script:packages }
function Get-AppxProvisionedPackage { param([switch]\$Online, \$ErrorAction) @() }
function Remove-AppxPackage {
  param(\$Package, [switch]\$AllUsers, \$ErrorAction)
  if (@(\$script:packages | Where-Object { \$_.PackageFullName -ceq \$Package }).Count -eq 0) { throw 'Already absent' }
  \$script:writes++
  \$script:packages = @()
}
function Remove-AppxProvisionedPackage { param([switch]\$Online, \$PackageName, \$ErrorAction) throw 'Unexpected provisioned mutation' }
${runner.appliedScript!}
Write-Output "writes=\$script:writes"
''');
      expect(output, contains('writes=1'));
    },
    skip: !Platform.isWindows,
  );

  test(
    'policy explicitly covers requested low-risk and optional names, not aliases',
    () {
      expect(
        appxCandidatePolicy.values.where(
          (entry) => entry.group == AppxCandidateGroup.lowRisk,
        ),
        hasLength(7),
      );
      for (final entry in appxCandidatePolicy.entries.where(
        (entry) => entry.value.removable,
      )) {
        expect(
          isRemovableAppxMetadata(appxMetadata(name: entry.key)),
          isTrue,
          reason: entry.key,
        );
      }
      expect(
        appxCandidatePolicy['Microsoft.Windows.DevHome']!.removable,
        isTrue,
      );
      expect(appxCandidatePolicy['Windows.DevHome'], isNull);
      expect(appxCandidatePolicy['Microsoft.DevHome']!.removable, isFalse);
      expect(
        appxCandidatePolicy.containsKey('Microsoft.WindowsStore'),
        isFalse,
      );
    },
  );
}
