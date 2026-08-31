import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:script_utility/app/zap_tweaks_app.dart';
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

  @override
  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async => const RestorePointResult(success: true);
}

class _UpdateService extends SystemActionService {
  _UpdateService(this._update) : super(processRunner: _NoopProcessRunner());

  final UpdateInfo? _update;

  @override
  Future<UpdateCheckResult> checkUpdateAvailability({
    required String currentVersion,
    required String latestReleaseApiUrl,
    required String releasesPageUrl,
  }) async => UpdateCheckResult(success: true, update: _update);
}

class _NoopProcessRunner extends ProcessRunner {
  _NoopProcessRunner()
    : super(mode: ProcessExecutionMode.dryRun, dryRunDelay: Duration.zero);
}

class _FastMetricsSamplingService extends MetricsSamplingService {
  _FastMetricsSamplingService() : super(processRunner: _NoopProcessRunner());
}

class _EmptyTweakCatalogService extends TweakCatalogService {
  @override
  List<TweakDescriptor> buildCatalog() => const <TweakDescriptor>[];
}

class _FakeTweakManager extends TweakManager {
  @override
  Future<Map<String, bool>> detectCurrentTweakStates() async =>
      <String, bool>{};
}

Future<TweakController> _buildController({UpdateInfo? update}) async {
  final prefs = await SharedPreferences.getInstance();
  final runner = _NoopProcessRunner();
  ProcessRunner.configureShared(runner);
  return TweakController(
    tweakManager: _FakeTweakManager(),
    permissionService: _AdminPermissionService(),
    hardwareDetectionService: _FakeHardwareDetectionService(),
    safetyGateService: SafetyGateService(
      permissionService: _AdminPermissionService(),
      restorePointService: _FakeRestorePointService(),
      preferences: prefs,
    ),
    systemActionService: _UpdateService(update),
    tweakCatalogService: _EmptyTweakCatalogService(),
    metricsSamplingService: _FastMetricsSamplingService(),
    preferences: prefs,
    processRunner: runner,
    appVersion: '1.8.0',
  );
}

Future<NavigationView> _pumpApp(
  WidgetTester tester,
  TweakController controller,
) async {
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
  return tester.widget<NavigationView>(find.byType(NavigationView));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'executionMode': 'dryRun',
      'automaticUpdateChecks': false,
    });
  });

  testWidgets('the loading screen renders every step while loading', (
    tester,
  ) async {
    // Regression: the loading view read Localizations/FluentTheme from the
    // State's context, which sits above FluentApp. It threw on every build and
    // the window came up grey until loading finished.
    final controller = await _buildController();
    expect(controller.isLoading, isTrue);

    await _pumpApp(tester, controller);

    expect(tester.takeException(), isNull);
    for (final step in TweakController.loadingSteps) {
      expect(
        find.text(step),
        findsOneWidget,
        reason: '$step is missing from the loading screen',
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 150));
  });

  testWidgets('the updates item is hidden until an update is found', (
    tester,
  ) async {
    final controller = await _buildController();
    await controller.initialize();

    var navigation = await _pumpApp(tester, controller);
    expect(
      navigation.pane!.footerItems,
      isEmpty,
      reason: 'no update detected, so nothing to show',
    );

    await controller.checkForUpdates();
    await tester.pump();

    navigation = tester.widget<NavigationView>(find.byType(NavigationView));
    expect(
      navigation.pane!.footerItems,
      isEmpty,
      reason: 'the fake reports no newer release',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 150));
  });

  testWidgets('the updates item appears once a release is detected', (
    tester,
  ) async {
    final controller = await _buildController(
      update: const UpdateInfo(
        version: '9.9.9',
        releaseUrl: 'https://example.invalid/release',
        installerUrl: 'https://example.invalid/setup.exe',
        releaseNotes: 'Notes',
      ),
    );
    await controller.initialize();
    await controller.checkForUpdates();

    final navigation = await _pumpApp(tester, controller);

    expect(controller.isUpdateAvailable, isTrue);
    expect(navigation.pane!.footerItems, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 150));
  });

  test('every startup step is reported and completed', () async {
    final controller = await _buildController();

    expect(
      controller.isLoadingStepDone(TweakController.loadingSteps.first),
      isFalse,
    );

    await controller.initialize();

    expect(controller.isLoading, isFalse);
    expect(controller.loadingStatus, 'Ready');
    for (final step in TweakController.loadingSteps) {
      expect(
        controller.isLoadingStepDone(step),
        isTrue,
        reason: '$step never reported completion',
      );
    }
    controller.dispose();
  });
}
