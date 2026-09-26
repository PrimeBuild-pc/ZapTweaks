import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:script_utility/core/models/restore_point_result.dart';
import 'package:script_utility/core/models/safety_gate_result.dart';
import 'package:script_utility/core/services/permission_service.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/core/services/restore_point_service.dart';
import 'package:script_utility/core/services/safety_gate_service.dart';

class _FakePermissionService extends PermissionService {
  _FakePermissionService(this._isAdmin) : super();

  final bool _isAdmin;

  @override
  Future<bool> isRunningElevated() async => _isAdmin;
}

class _FakeRestorePointService extends RestorePointService {
  _FakeRestorePointService(this._result)
    : super(processRunner: ProcessRunner());

  final RestorePointResult _result;
  int calls = 0;

  @override
  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async {
    calls += 1;
    return _result;
  }
}

class _ThrowingRestorePointService extends RestorePointService {
  _ThrowingRestorePointService() : super(processRunner: ProcessRunner());

  @override
  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async {
    throw StateError('Checkpoint-Computer exploded');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SafetyGateService> buildService({
    bool isAdmin = true,
    RestorePointResult restorePoint = const RestorePointResult(success: true),
    _FakeRestorePointService? restorePointService,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    return SafetyGateService(
      permissionService: _FakePermissionService(isAdmin),
      restorePointService:
          restorePointService ?? _FakeRestorePointService(restorePoint),
      preferences: preferences,
    );
  }

  group('SafetyGateService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('blocks when admin privileges are missing', () async {
      final service = await buildService(isAdmin: false);

      final result = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: () async => true,
      );

      expect(result.status, SafetyGateStatus.blockedMissingAdmin);
    });

    test('asks once and creates the restore point when accepted', () async {
      final restorePoints = _FakeRestorePointService(
        const RestorePointResult(success: true),
      );
      final service = await buildService(restorePointService: restorePoints);

      var prompts = 0;
      Future<bool> accept() async {
        prompts += 1;
        return true;
      }

      final first = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: accept,
      );
      final second = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: accept,
      );

      expect(prompts, 1, reason: 'the prompt is once per app session');
      expect(restorePoints.calls, 1);
      expect(first.status, SafetyGateStatus.proceed);
      expect(second.status, SafetyGateStatus.proceed);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('lastRestorePointAt'), isNotNull);
    });

    test('skipping the prompt still proceeds', () async {
      final restorePoints = _FakeRestorePointService(
        const RestorePointResult(success: true),
      );
      final service = await buildService(restorePointService: restorePoints);

      final result = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: () async => false,
      );

      expect(result.status, SafetyGateStatus.proceed);
      expect(restorePoints.calls, 0);
    });

    test('a failed restore point does not block the action', () async {
      final service = await buildService(
        restorePoint: const RestorePointResult(
          success: false,
          message: 'System Protection is off.',
        ),
      );

      final result = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: () async => true,
      );

      expect(result.status, SafetyGateStatus.proceed);
      expect(result.message, 'System Protection is off.');
    });

    test('concurrent callers share the one prompt', () async {
      final restorePoints = _FakeRestorePointService(
        const RestorePointResult(success: true),
      );
      final service = await buildService(restorePointService: restorePoints);

      var prompts = 0;
      final gate = Completer<void>();
      Future<bool> slowPrompt() async {
        prompts += 1;
        await gate.future;
        return true;
      }

      final first = service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: slowPrompt,
      );
      final second = service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: slowPrompt,
      );
      await Future<void>.delayed(Duration.zero);
      gate.complete();

      final results = await Future.wait(<Future<SafetyGateResult>>[
        first,
        second,
      ]);

      expect(prompts, 1);
      expect(restorePoints.calls, 1);
      expect(
        results.every((item) => item.status == SafetyGateStatus.proceed),
        isTrue,
      );
    });

    test('never prompts for entries that do not require it', () async {
      final service = await buildService();

      var prompted = false;
      final result = await service.ensureSafety(
        requireRestorePoint: false,
        askUserToCreateRestorePoint: () async {
          prompted = true;
          return true;
        },
      );

      expect(prompted, isFalse);
      expect(result.status, SafetyGateStatus.proceed);
    });

    test('the restore point offer never blocks the action', () async {
      // Whatever the user answers and whatever Windows does, the action the
      // user asked for must still run. This is the "always skippable" contract.
      final answers = <String, Future<bool> Function()>{
        'declined': () async => false,
        'dismissed': () async => false,
        'accepted': () async => true,
        'prompt threw': () async => throw StateError('no navigator'),
      };

      for (final entry in answers.entries) {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final service = await buildService();
        final result = await service.ensureSafety(
          requireRestorePoint: true,
          askUserToCreateRestorePoint: entry.value,
        );
        expect(
          result.status,
          SafetyGateStatus.proceed,
          reason: 'answer "${entry.key}" must not block the action',
        );
      }

      SharedPreferences.setMockInitialValues(<String, Object>{});
      final throwing = SafetyGateService(
        permissionService: _FakePermissionService(true),
        restorePointService: _ThrowingRestorePointService(),
        preferences: await SharedPreferences.getInstance(),
      );
      final result = await throwing.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: () async => true,
      );
      expect(
        result.status,
        SafetyGateStatus.proceed,
        reason: 'a checkpoint that throws must not block the action',
      );
    });

    test('skips prompt if restore point is recent', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lastRestorePointAt': DateTime.now().toUtc().toIso8601String(),
      });
      final service = await buildService();

      var prompted = false;
      final result = await service.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: () async {
          prompted = true;
          return true;
        },
      );

      expect(prompted, isFalse);
      expect(result.status, SafetyGateStatus.proceed);
    });
  });
}
