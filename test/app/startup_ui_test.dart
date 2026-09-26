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
  _AdminPermissionService() : super();

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
  _FastMetricsSamplingService()
    : super(processRunner: _NoopProcessRunner(), preferNative: false);
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
  TweakController controller, {
  Size size = const Size(1280, 820),
}) async {
  await tester.binding.setSurfaceSize(size);
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

  testWidgets('Italian light and dark themes render at scaled laptop size', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'executionMode': 'dryRun',
      'automaticUpdateChecks': false,
      'localeCode': 'it',
      'themeMode': 'light',
    });
    tester.view.devicePixelRatio = 1.5;
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _buildController();
    await controller.initialize();

    await _pumpApp(tester, controller, size: const Size(1024, 720));
    expect(controller.localeCode, 'it');
    expect(controller.themeMode, 'light');
    expect(
      FluentTheme.of(tester.element(find.byType(NavigationView))).brightness,
      Brightness.light,
    );
    expect(tester.takeException(), isNull);

    await controller.setThemeMode('dark');
    await tester.pumpAndSettle();
    expect(
      FluentTheme.of(tester.element(find.byType(NavigationView))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 150));
  });

  testWidgets(
    'global search finds and opens integrated tools by partial typo',
    (tester) async {
      final controller = await _buildController();
      await controller.initialize();
      await _pumpApp(tester, controller);

      await tester.enterText(find.byType(TextBox).first, 'powre settings');
      await tester.pumpAndSettle();

      expect(find.text('Power Settings Explorer'), findsOneWidget);
      await tester.tap(find.text('Open').first);
      await tester.pumpAndSettle();
      expect(controller.selectedCategory, 'Gaming & Performance');
      expect(controller.navigationTab, 0);
      expect(controller.searchQuery, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      await tester.pump(const Duration(milliseconds: 150));
    },
  );

  testWidgets('TCP Optimizer deep link renders at scaled laptop size', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.5;
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _buildController();
    await controller.initialize();
    await _pumpApp(tester, controller, size: const Size(1024, 720));

    await tester.enterText(find.byType(TextBox).first, 'tcp optimizer');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open').first);
    await tester.pump(const Duration(seconds: 1));

    expect(controller.selectedCategory, 'Gaming & Performance');
    expect(controller.navigationTab, 3);
    expect(
      find.text(
        'No value is recommended automatically. A read-back or one network test does not prove a performance benefit.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 150));
  });

  testWidgets('app search deep links preserve the matched app name', (
    tester,
  ) async {
    final controller = await _buildController();
    await controller.initialize();
    controller.navigateTo('Apps', searchTerm: 'Firefox');
    await _pumpApp(tester, controller);

    expect(controller.selectedCategory, 'Apps');
    expect(
      tester
          .widgetList<TextBox>(find.byType(TextBox))
          .any((box) => box.controller?.text == 'Firefox'),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 150));
  });

  test('Expert navigation is opt-in and persisted', () async {
    final controller = await _buildController();
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.categories, isNot(contains('Expert')));
    expect(controller.categories, <String>[
      'Home',
      'Guided Setup',
      'Apps',
      'Drivers',
      'Gaming & Performance',
      'Windows',
      'Diagnostics & Recovery',
      'Settings',
    ]);

    await controller.setExpertModeEnabled(true);

    expect(controller.categories, contains('Expert'));
    expect(
      (await SharedPreferences.getInstance()).getBool('expertMode'),
      isTrue,
    );
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
