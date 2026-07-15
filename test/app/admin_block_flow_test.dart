import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:script_utility/core/models/hardware_profile.dart';
import 'package:script_utility/core/models/restore_point_result.dart';
import 'package:script_utility/core/models/tweak_descriptor.dart';
import 'package:script_utility/core/models/update_info.dart';
import 'package:script_utility/core/services/hardware_detection_service.dart';
import 'package:script_utility/core/services/metrics_sampling_service.dart';
import 'package:script_utility/core/services/permission_service.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/core/services/restore_point_service.dart';
import 'package:script_utility/core/services/safety_gate_service.dart';
import 'package:script_utility/core/services/system_action_service.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/core/tweak_manager.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';

class _FakePermissionService extends PermissionService {
  _FakePermissionService() : super(processRunner: ProcessRunner());

  @override
  Future<bool> isRunningElevated() async => false;
}

class _FakeHardwareDetectionService extends HardwareDetectionService {
  _FakeHardwareDetectionService() : super(processRunner: ProcessRunner());

  @override
  Future<HardwareProfile> detect() async => HardwareProfile.unknown;
}

class _FakeRestorePointService extends RestorePointService {
  _FakeRestorePointService() : super(processRunner: ProcessRunner());

  @override
  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async {
    return const RestorePointResult(success: true);
  }
}

class _FakeSystemActionService extends SystemActionService {
  _FakeSystemActionService() : super(processRunner: ProcessRunner());

  @override
  Future<UpdateCheckResult> checkUpdateAvailability({
    required String currentVersion,
    required String latestReleaseApiUrl,
    required String releasesPageUrl,
  }) async {
    return const UpdateCheckResult(success: true, message: 'No update.');
  }
}

class _NoopProcessRunner extends ProcessRunner {
  _NoopProcessRunner()
    : super(mode: ProcessExecutionMode.dryRun, dryRunDelay: Duration.zero);
}

class _FakeTweakCatalogService extends TweakCatalogService {
  @override
  List<TweakDescriptor> buildCatalog() {
    return const <TweakDescriptor>[
      TweakDescriptor(
        id: 'dummy_toggle',
        title: 'Dummy Toggle',
        description: 'Dummy',
        category: 'Gaming',
        systemKey: 'bcd_optimizations',
      ),
    ];
  }
}

class _FakeTweakManager extends TweakManager {
  @override
  Future<Map<String, bool>> detectCurrentTweakStates() async {
    return <String, bool>{'bcd_optimizations': false};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('controller reports non-admin after initialization', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'executionMode': 'dryRun',
    });
    final prefs = await SharedPreferences.getInstance();

    final controller = TweakController(
      tweakManager: _FakeTweakManager(),
      permissionService: _FakePermissionService(),
      hardwareDetectionService: _FakeHardwareDetectionService(),
      safetyGateService: SafetyGateService(
        permissionService: _FakePermissionService(),
        restorePointService: _FakeRestorePointService(),
        preferences: prefs,
      ),
      systemActionService: _FakeSystemActionService(),
      tweakCatalogService: _FakeTweakCatalogService(),
      metricsSamplingService: MetricsSamplingService(
        processRunner: _NoopProcessRunner(),
      ),
      preferences: prefs,
      processRunner: _NoopProcessRunner(),
      appVersion: '1.3.0',
    );

    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.isAdmin, isFalse);
    expect(controller.isLoading, isFalse);
  });
}
