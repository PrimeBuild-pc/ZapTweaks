import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:script_utility/core/models/hardware_profile.dart';
import 'package:script_utility/core/models/restore_point_result.dart';
import 'package:script_utility/core/models/tweak_descriptor.dart';
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
  Future<bool> isRunningElevated() async => true;
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
  }) async => const RestorePointResult(success: true);
}

class _NoopProcessRunner extends ProcessRunner {
  _NoopProcessRunner()
    : super(mode: ProcessExecutionMode.dryRun, dryRunDelay: Duration.zero);
}

class _FakeTweakCatalogService extends TweakCatalogService {
  @override
  List<TweakDescriptor> buildCatalog() => const <TweakDescriptor>[
    TweakDescriptor(
      id: 'dummy_toggle',
      title: 'Dummy Toggle',
      description: 'Dummy',
      category: 'Gaming',
      collection: 'Core Optimizations',
      systemKey: 'bcd_optimizations',
    ),
  ];
}

class _FakeTweakManager extends TweakManager {
  @override
  Future<Map<String, bool>> detectCurrentTweakStates() async => <String, bool>{
    'bcd_optimizations': false,
  };
}

Future<TweakController> _buildController() async {
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
    systemActionService: SystemActionService(
      processRunner: _NoopProcessRunner(),
    ),
    tweakCatalogService: _FakeTweakCatalogService(),
    metricsSamplingService: MetricsSamplingService(
      processRunner: _NoopProcessRunner(),
    ),
    preferences: prefs,
    processRunner: _NoopProcessRunner(),
    appVersion: '1.8.0',
  );
  await controller.initialize();
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'executionMode': 'dryRun',
    });
  });

  test('collections start closed', () async {
    final controller = await _buildController();
    addTearDown(controller.dispose);

    expect(
      controller.isCollectionExpanded('Tools', 'Input & Peripherals'),
      isFalse,
    );
    expect(
      controller.isCollectionExpanded('Gaming', 'Core Optimizations'),
      isFalse,
    );
  });

  test('expanding is remembered, collapsing forgets it', () async {
    final controller = await _buildController();
    addTearDown(controller.dispose);

    await controller.setCollectionExpanded('Tools', 'GPU & Display', true);
    expect(controller.isCollectionExpanded('Tools', 'GPU & Display'), isTrue);

    await controller.setCollectionExpanded('Tools', 'GPU & Display', false);
    expect(controller.isCollectionExpanded('Tools', 'GPU & Display'), isFalse);
  });

  test('the same collection name in another category stays closed', () async {
    final controller = await _buildController();
    addTearDown(controller.dispose);

    await controller.setCollectionExpanded(
      'Windows',
      'Core Optimizations',
      true,
    );

    expect(
      controller.isCollectionExpanded('Windows', 'Core Optimizations'),
      isTrue,
    );
    expect(
      controller.isCollectionExpanded('Gaming', 'Core Optimizations'),
      isFalse,
      reason: 'expansion is per category, not per collection name',
    );
  });

  test('the choice survives a restart', () async {
    final first = await _buildController();
    await first.setCollectionExpanded('Tools', 'Stress Testing', true);
    first.dispose();

    // A new controller over the same preferences is what a relaunch looks like.
    final second = await _buildController();
    addTearDown(second.dispose);

    expect(second.isCollectionExpanded('Tools', 'Stress Testing'), isTrue);
    expect(second.isCollectionExpanded('Tools', 'Network Tools'), isFalse);
  });
}
