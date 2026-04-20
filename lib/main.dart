import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart' show Alignment, Size;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, runApp;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_metadata.dart';
import 'app/zap_tweaks_app.dart';
import 'app/window_effect_coordinator.dart';
import 'core/services/hardware_detection_service.dart';
import 'core/services/logging_service.dart';
import 'core/services/metrics_sampling_service.dart';
import 'core/services/category_preset_service.dart';
import 'core/services/permission_service.dart';
import 'core/services/process_runner.dart';
import 'core/services/restore_point_service.dart';
import 'core/services/safety_gate_service.dart';
import 'core/services/system_action_service.dart';
import 'core/services/tweak_catalog_service.dart';
import 'core/tweak_manager.dart';
import 'features/tweaks/application/tweak_controller.dart';

Future<void> _initWindowIfNeeded() async {
  if (!Platform.isWindows) {
    return;
  }

  await Window.initialize();
  await Window.hideWindowControls();
  WindowEffectCoordinator.instance.attach();
  await WindowEffectCoordinator.instance.applyNow();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrapResults = await Future.wait<dynamic>(<Future<dynamic>>[
    _initWindowIfNeeded(),
    LoggingService.instance.initialize(),
    SharedPreferences.getInstance(),
  ]);

  final prefs = bootstrapResults[2] as SharedPreferences;

  await LoggingService.instance.logInfo(
    'Application startup sequence started.',
  );

  final processRunner = ProcessRunner();
  ProcessRunner.configureShared(processRunner);
  final permissionService = PermissionService(processRunner: processRunner);
  final restorePointService = RestorePointService(processRunner: processRunner);
  final safetyGateService = SafetyGateService(
    permissionService: permissionService,
    restorePointService: restorePointService,
    preferences: prefs,
  );

  final controller = TweakController(
    tweakManager: TweakManager(loggingService: LoggingService.instance),
    permissionService: permissionService,
    hardwareDetectionService: HardwareDetectionService(
      processRunner: processRunner,
    ),
    safetyGateService: safetyGateService,
    systemActionService: SystemActionService(
      processRunner: processRunner,
      loggingService: LoggingService.instance,
    ),
    tweakCatalogService: TweakCatalogService(),
    categoryPresetService: CategoryPresetService(),
    metricsSamplingService: MetricsSamplingService(
      processRunner: processRunner,
    ),
    preferences: prefs,
    processRunner: processRunner,
    loggingService: LoggingService.instance,
    appVersion: AppMetadata.semanticVersion,
  );

  runApp(ZapTweaksApp(controller: controller));

  doWhenWindowReady(() {
    appWindow.minSize = const Size(1100, 720);
    appWindow.size = const Size(1280, 820);
    appWindow.alignment = Alignment.center;
    appWindow.title = AppMetadata.productName;
    appWindow.show();
  });
}
