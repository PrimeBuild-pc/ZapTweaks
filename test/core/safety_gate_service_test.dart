import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:script_utility/core/models/restore_point_result.dart';
import 'package:script_utility/core/models/safety_gate_result.dart';
import 'package:script_utility/core/services/permission_service.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/core/services/restore_point_service.dart';
import 'package:script_utility/core/services/safety_gate_service.dart';

class _FakePermissionService extends PermissionService {
  _FakePermissionService(this._isAdmin) : super(processRunner: ProcessRunner());

  final bool _isAdmin;

  @override
  Future<bool> isRunningElevated() async => _isAdmin;
}

class _FakeRestorePointService extends RestorePointService {
  _FakeRestorePointService(this._result)
    : super(processRunner: ProcessRunner());

  final RestorePointResult _result;

  @override
  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async {
    return _result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SafetyGateService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('blocks when admin privileges are missing', () async {
      final preferences = await SharedPreferences.getInstance();

      final service = SafetyGateService(
        permissionService: _FakePermissionService(false),
        restorePointService: _FakeRestorePointService(
          const RestorePointResult(success: true),
        ),
        preferences: preferences,
      );

      final result = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: () async => true,
      );

      expect(result.status, SafetyGateStatus.blockedMissingAdmin);
    });

    test(
      'creates restore point when required and missing in last 24h',
      () async {
        final preferences = await SharedPreferences.getInstance();

        final service = SafetyGateService(
          permissionService: _FakePermissionService(true),
          restorePointService: _FakeRestorePointService(
            const RestorePointResult(success: true),
          ),
          preferences: preferences,
        );

        var promptCalled = false;

        final result = await service.ensureSafety(
          requireRestorePoint: true,
          askUserToCreateRestorePoint: () async {
            promptCalled = true;
            return true;
          },
        );

        expect(promptCalled, isTrue);
        expect(result.status, SafetyGateStatus.proceed);
        expect(preferences.getString('lastRestorePointAt'), isNotNull);
      },
    );

    test('skips prompt if restore point is recent', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lastRestorePointAt': now,
      });

      final preferences = await SharedPreferences.getInstance();
      final service = SafetyGateService(
        permissionService: _FakePermissionService(true),
        restorePointService: _FakeRestorePointService(
          const RestorePointResult(success: true),
        ),
        preferences: preferences,
      );

      var promptCalled = false;
      final result = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: () async {
          promptCalled = true;
          return true;
        },
      );

      expect(promptCalled, isFalse);
      expect(result.status, SafetyGateStatus.proceed);
    });
  });
}
