import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart' show Size;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, runApp;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_metadata.dart';
import 'app/zap_tweaks_app.dart';
import 'app/window_effect_coordinator.dart';
import 'app/window_placement.dart';
import 'core/services/hardware_detection_service.dart';
import 'core/services/logging_service.dart';
import 'core/services/metrics_sampling_service.dart';
import 'core/services/permission_service.dart';
import 'core/services/process_runner.dart';
import 'core/services/restore_point_service.dart';
import 'core/services/safety_gate_service.dart';
import 'core/services/system_action_service.dart';
import 'core/services/tweak_catalog_service.dart';
import 'core/security/elevated_helper.dart';
import 'core/tweak_manager.dart';
import 'features/tweaks/application/tweak_controller.dart';
import 'legacy/adapters/legacy_catalog_adapter.dart';

Future<void> _initWindowIfNeeded() async {
  if (!Platform.isWindows) {
    return;
  }

  await Window.initialize();
  await Window.hideWindowControls();
  WindowEffectCoordinator.instance.attach();
  await WindowEffectCoordinator.instance.applyNow();
}

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (arguments.length == 3 && arguments.first == '--zaptweaks-helper') {
    final processRunner = ProcessRunner();
    ProcessRunner.configureShared(processRunner);
    final exitCode = await ElevatedHelperHost(
      allowedDirectory: defaultElevatedHelperDirectory(),
      catalogService: TweakCatalogService(),
      tweakManager: TweakManager(
        loggingService: LoggingService.instance,
        processRunner: processRunner,
      ),
      restorePointService: RestorePointService(processRunner: processRunner),
    ).run(File(utf8.decode(base64Url.decode(arguments[1]))), arguments[2]);
    exit(exitCode);
  }

  final bootstrapResults = await Future.wait<dynamic>(<Future<dynamic>>[
    _initWindowIfNeeded(),
    LoggingService.instance.initialize(),
    SharedPreferences.getInstance(),
  ]);

  final prefs = bootstrapResults[2] as SharedPreferences;
  final legacyCatalogAdapter = await LegacyCatalogAdapter.load();

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
    metricsSamplingService: MetricsSamplingService(
      processRunner: processRunner,
    ),
    preferences: prefs,
    processRunner: processRunner,
    loggingService: LoggingService.instance,
    appVersion: AppMetadata.semanticVersion,
    legacyCatalogAdapterLoader: () async => legacyCatalogAdapter,
    elevatedHelperClient: ElevatedHelperClient(
      directory: defaultElevatedHelperDirectory(),
    ),
  );

  runApp(ZapTweaksApp(controller: controller));

  doWhenWindowReady(() {
    const initialSize = Size(1280, 820);
    appWindow.minSize = const Size(1100, 720);
    appWindow.size = initialSize;
    appWindow.title = AppMetadata.productName;
    appWindow.show();
    appWindow.position = primaryWindowPosition(
      windowsPrimaryDisplaySize(),
      initialSize,
    );
  });
}
