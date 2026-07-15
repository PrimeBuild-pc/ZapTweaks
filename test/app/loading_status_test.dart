import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:script_utility/app/zap_tweaks_app.dart';
import 'package:script_utility/core/models/hardware_profile.dart';
import 'package:script_utility/core/models/system_metrics_snapshot.dart';
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
import 'package:script_utility/models/system_tweak.dart';

class _NoopProcessRunner extends ProcessRunner {
  _NoopProcessRunner()
    : super(mode: ProcessExecutionMode.dryRun, dryRunDelay: Duration.zero);
}

class _FastMetricsSamplingService extends MetricsSamplingService {
  _FastMetricsSamplingService() : super(processRunner: _NoopProcessRunner());

  @override
  Future<SystemMetricsSnapshot> sample() async {
    return const SystemMetricsSnapshot(
      timestamp: null,
      cpuUsagePercent: 1,
      gpuUsagePercent: 2,
      memoryUsagePercent: 3,
      memoryUsedBytes: 4,
      memoryTotalBytes: 5,
      vramUsagePercent: 6,
      vramUsedBytes: 7,
      vramTotalBytes: 8,
    );
  }
}

class _FakePermissionService extends PermissionService {
  _FakePermissionService() : super(processRunner: ProcessRunner());

  @override
  Future<bool> isRunningElevated() async => false;
}

class _AdminPermissionService extends PermissionService {
  _AdminPermissionService() : super(processRunner: ProcessRunner());

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
}

class _FakeSystemActionService extends SystemActionService {
  _FakeSystemActionService() : super(processRunner: _NoopProcessRunner());

  @override
  Future<UpdateCheckResult> checkUpdateAvailability({
    required String currentVersion,
    required String latestReleaseApiUrl,
    required String releasesPageUrl,
  }) async => const UpdateCheckResult(success: true, message: 'No update.');
}

class _FakeTweakManager extends TweakManager {
  _FakeTweakManager() : super(processRunner: _NoopProcessRunner());

  @override
  Future<Map<String, bool>> detectCurrentTweakStates() async {
    return <String, bool>{};
  }
}

class _EmptyTweakCatalogService extends TweakCatalogService {
  @override
  List<TweakDescriptor> buildCatalog() => const <TweakDescriptor>[];
}

class _ConcurrencyTracker {
  int active = 0;
  int maximum = 0;
}

class _DelayedTweak extends SystemTweak {
  _DelayedTweak(this.index, this.tracker)
    : super(
        id: 'delayed_$index',
        title: 'Delayed $index',
        description: 'Test',
        category: 'Gaming Optimizations',
      );

  final int index;
  final _ConcurrencyTracker tracker;

  @override
  Future<bool> checkState() async {
    tracker.active++;
    if (tracker.active > tracker.maximum) {
      tracker.maximum = tracker.active;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
    tracker.active--;
    return false;
  }

  @override
  Future<void> onApply() async {}

  @override
  Future<void> onRevert() async {}
}

class _DelayedTweakCatalogService extends TweakCatalogService {
  _DelayedTweakCatalogService(this.tracker);

  final _ConcurrencyTracker tracker;

  @override
  List<TweakDescriptor> buildCatalog() =>
      List<TweakDescriptor>.generate(12, (index) {
        final tweak = _DelayedTweak(index, tracker);
        return TweakDescriptor(
          id: tweak.id,
          title: tweak.title,
          description: tweak.description,
          category: 'Gaming',
          scriptTweak: tweak,
        );
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('controller loading status ends at ready', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final runner = _NoopProcessRunner();
    ProcessRunner.configureShared(runner);

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
      tweakCatalogService: _EmptyTweakCatalogService(),
      metricsSamplingService: _FastMetricsSamplingService(),
      preferences: prefs,
      processRunner: runner,
      appVersion: '1.3.0',
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(controller.isLoading, isFalse);
    expect(controller.loadingStatus, 'Ready');
    expect(controller.hardwareProfile, isA<HardwareProfile>());
  });

  testWidgets('all navigation sections are reachable', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'automaticUpdateChecks': false,
    });
    final prefs = await SharedPreferences.getInstance();
    final runner = _NoopProcessRunner();
    ProcessRunner.configureShared(runner);

    final adminPermissionService = _AdminPermissionService();
    final controller = TweakController(
      tweakManager: _FakeTweakManager(),
      permissionService: adminPermissionService,
      hardwareDetectionService: _FakeHardwareDetectionService(),
      safetyGateService: SafetyGateService(
        permissionService: adminPermissionService,
        restorePointService: _FakeRestorePointService(),
        preferences: prefs,
      ),
      systemActionService: _FakeSystemActionService(),
      tweakCatalogService: _EmptyTweakCatalogService(),
      metricsSamplingService: _FastMetricsSamplingService(),
      preferences: prefs,
      processRunner: runner,
      appVersion: '1.5.0',
    );
    await controller.initialize();

    await tester.binding.setSurfaceSize(const Size(1280, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ZapTweaksApp(
        controller: controller,
        useNativeTitleBar: false,
        autoInitializeController: false,
      ),
    );
    await tester.pump();

    final navigation = tester.widget<NavigationView>(
      find.byType(NavigationView),
    );
    expect(navigation.pane!.items.whereType<PaneItemSeparator>(), hasLength(1));
    for (final category in controller.categories) {
      final item = find.text(category).first;
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pump();
      expect(controller.selectedCategory, category);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 150));
  });

  test('script state checks use at most eight concurrent workers', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final runner = _NoopProcessRunner();
    final tracker = _ConcurrencyTracker();
    ProcessRunner.configureShared(runner);

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
      tweakCatalogService: _DelayedTweakCatalogService(tracker),
      metricsSamplingService: _FastMetricsSamplingService(),
      preferences: prefs,
      processRunner: runner,
      appVersion: '1.5.0',
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(tracker.maximum, 8);
  });
}
