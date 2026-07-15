import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/hardware_profile.dart';
import '../../../core/models/operation_result.dart';
import '../../../core/models/safety_gate_result.dart';
import '../../../core/models/system_metrics_snapshot.dart';
import '../../../core/models/tweak_descriptor.dart';
import '../../../core/models/update_info.dart';
import '../../../core/services/hardware_detection_service.dart';
import '../../../core/services/logging_service.dart';
import '../../../core/services/metrics_sampling_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/process_runner.dart';
import '../../../core/services/safety_gate_service.dart';
import '../../../core/services/system_action_service.dart';
import '../../../core/services/tweak_catalog_service.dart';
import '../../../core/tweak_manager.dart';
import '../../../models/system_tweak.dart';

class TweakController extends ChangeNotifier {
  TweakController({
    required TweakManager tweakManager,
    required PermissionService permissionService,
    required HardwareDetectionService hardwareDetectionService,
    required SafetyGateService safetyGateService,
    required SystemActionService systemActionService,
    required TweakCatalogService tweakCatalogService,
    required MetricsSamplingService metricsSamplingService,
    required SharedPreferences preferences,
    required ProcessRunner processRunner,
    required String appVersion,
    LoggingService? loggingService,
  }) : _tweakManager = tweakManager,
       _permissionService = permissionService,
       _hardwareDetectionService = hardwareDetectionService,
       _safetyGateService = safetyGateService,
       _systemActionService = systemActionService,
       _tweakCatalogService = tweakCatalogService,
       _metricsSamplingService = metricsSamplingService,
       _preferences = preferences,
       _processRunner = processRunner,
       _appVersion = appVersion,
       _loggingService = loggingService ?? LoggingService.instance;

  final TweakManager _tweakManager;
  final PermissionService _permissionService;
  final HardwareDetectionService _hardwareDetectionService;
  final SafetyGateService _safetyGateService;
  final SystemActionService _systemActionService;
  final TweakCatalogService _tweakCatalogService;
  final MetricsSamplingService _metricsSamplingService;
  final SharedPreferences _preferences;
  final ProcessRunner _processRunner;
  final String _appVersion;
  final LoggingService _loggingService;

  static const String defaultPreset = 'Default';
  static const String safePreset = 'Safe';
  static const String aggressivePreset = 'Aggressive';
  static const String settingsCategory = 'Settings';

  static const String _needsRestartKey = 'needsRestart';
  static const String _executionModeKey = 'executionMode';
  static const String _automaticUpdateChecksKey = 'automaticUpdateChecks';
  static const String _lastSelectedPresetPrefix = 'preset:';
  static const int _maxMetricsPoints = 40;
  static const Set<String> _interactionLockingTweaks = <String>{
    'network_low_latency_bandwidth_profile',
  };

  bool _isLoading = true;
  bool _isAdmin = false;
  bool _needsRestart = false;
  HardwareProfile _hardwareProfile = HardwareProfile.unknown;
  String _selectedCategory = TweakCatalogService.navigationCategories.first;

  final Map<String, bool> _toggleStates = <String, bool>{};
  final Set<String> _busyTweaks = <String>{};
  final Set<String> _busyPresetCategories = <String>{};
  List<TweakDescriptor> _catalog = <TweakDescriptor>[];
  Timer? _metricsTicker;
  bool _isSamplingMetrics = false;
  bool _isSystemOperationActive = false;
  bool _automaticUpdateChecksEnabled = true;
  bool _isCheckingForUpdates = false;
  UpdateInfo? _availableUpdate;
  String? _updateStatusMessage;
  bool _isDisposed = false;

  SystemMetricsSnapshot _latestMetrics = SystemMetricsSnapshot.empty;
  List<double> _cpuHistory = const <double>[];
  List<double> _memoryHistory = const <double>[];
  List<double> _gpuHistory = const <double>[];
  List<double> _vramHistory = const <double>[];

  String _loadingStatus = 'Initializing...';
  final Map<String, String> _selectedPresets = <String, String>{};

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  bool get needsRestart => _needsRestart;
  HardwareProfile get hardwareProfile => _hardwareProfile;
  String get selectedCategory => _selectedCategory;
  Map<String, bool> get toggleStates => _toggleStates;
  Set<String> get busyTweaks => _busyTweaks;
  List<String> get categories => const <String>[
    ...TweakCatalogService.navigationCategories,
    settingsCategory,
  ];
  bool get isDryRunMode => _processRunner.isDryRun;
  String get loadingStatus => _loadingStatus;
  String get appVersion => _appVersion;
  bool get automaticUpdateChecksEnabled => _automaticUpdateChecksEnabled;
  bool get isCheckingForUpdates => _isCheckingForUpdates;
  bool get isUpdateAvailable => _availableUpdate != null;
  UpdateInfo? get availableUpdate => _availableUpdate;
  String? get updateStatusMessage => _updateStatusMessage;
  bool isPresetBusy(String category) =>
      _busyPresetCategories.contains(category);
  bool get isInteractionLocked =>
      _busyTweaks.any(_interactionLockingTweaks.contains);
  String get interactionLockMessage =>
      'Applying network profile. Please wait until all changes complete...';
  SystemMetricsSnapshot get latestMetrics => _latestMetrics;
  List<double> get cpuHistory => _cpuHistory;
  List<double> get memoryHistory => _memoryHistory;
  List<double> get gpuHistory => _gpuHistory;
  List<double> get vramHistory => _vramHistory;

  /// Returns true when a category includes at least one toggle-capable tweak.
  bool categoryHasToggleableItems(String category, {bool systemOnly = false}) {
    return categoryTweaks(category).any((descriptor) {
      if (descriptor.isSystemToggle) {
        return true;
      }

      if (systemOnly) {
        return false;
      }

      return descriptor.scriptTweak?.hasState ?? false;
    });
  }

  /// Returns true when an action script has been executed at least once.
  bool wasScriptExecuted(String tweakId) {
    return _preferences.getBool('executed:$tweakId') ?? false;
  }

  static List<String> availablePresetsForCategory(String category) =>
      category == 'Home' || category == settingsCategory
      ? const <String>[defaultPreset]
      : const <String>[defaultPreset, safePreset, aggressivePreset];

  static bool shouldEnablePreset(String preset, TweakDescriptor descriptor) =>
      preset == aggressivePreset ||
      (preset == safePreset && !descriptor.isAggressive);

  List<String> presetsForCategory(String category) =>
      availablePresetsForCategory(category);

  String selectedPresetForCategory(String category) {
    return _selectedPresets[category] ?? defaultPreset;
  }

  List<TweakDescriptor> categoryTweaks(String category) {
    return _catalog
        .where((descriptor) => descriptor.category == category)
        .toList(growable: false);
  }

  Future<void> initialize() async {
    _isLoading = true;
    _loadingStatus = 'Initializing UI...';
    notifyListeners();

    try {
      _loadingStatus = 'Loading preferences...';
      notifyListeners();
      _restoreExecutionModeFromPreferences();
      _restorePresetSelections();
      _automaticUpdateChecksEnabled =
          _preferences.getBool(_automaticUpdateChecksKey) ?? true;

      _loadingStatus = 'Loading tweaks catalog...';
      notifyListeners();
      _catalog = _tweakCatalogService.buildCatalog();

      _loadingStatus = 'Detecting hardware and tweak states...';
      notifyListeners();
      final futures = await Future.wait<dynamic>(<Future<dynamic>>[
        _permissionService.isRunningElevated(),
        _hardwareDetectionService.detect(),
        _tweakManager.detectCurrentTweakStates(),
        _initializeScriptStates(),
      ]);

      _isAdmin = futures[0] as bool;
      _hardwareProfile = futures[1] as HardwareProfile;
      final detectedStates = futures[2] as Map<String, bool>;

      for (final descriptor in _catalog) {
        if (descriptor.isSystemToggle) {
          _toggleStates[descriptor.id] =
              detectedStates[descriptor.systemKey] ??
              _preferences.getBool(descriptor.id) ??
              false;
        }
      }

      _needsRestart = _preferences.getBool(_needsRestartKey) ?? false;
    } finally {
      _isLoading = false;
      _loadingStatus = 'Ready';
      notifyListeners();
      Future<void>.delayed(Duration.zero, _startMetricsSampling);
      if (_automaticUpdateChecksEnabled) {
        Future<void>.delayed(Duration.zero, _checkForUpdatesAfterStartup);
      }
    }
  }

  Future<void> setDryRunMode(bool enabled) async {
    final nextMode = enabled
        ? ProcessExecutionMode.dryRun
        : ProcessExecutionMode.production;

    if (_processRunner.mode == nextMode) {
      return;
    }

    _processRunner.setMode(nextMode);
    await _preferences.setString(_executionModeKey, nextMode.name);

    await _loggingService.logInfo(
      'Execution mode switched to ${nextMode.name}.',
      source: 'TweakController',
    );

    notifyListeners();
  }

  Future<void> _initializeScriptStates() async {
    final tweaks = _catalog
        .map((descriptor) => descriptor.scriptTweak)
        .whereType<SystemTweak>()
        .where((tweak) => tweak.hasState)
        .toList(growable: false);
    var nextIndex = 0;

    Future<void> worker() async {
      while (nextIndex < tweaks.length) {
        final tweak = tweaks[nextIndex++];
        try {
          tweak.isApplied = await tweak.checkState();
        } catch (error) {
          await _loggingService.logWarning(
            'Unable to detect script tweak ${tweak.id}: $error',
            source: 'TweakController',
          );
          tweak.isApplied = false;
        }
      }
    }

    final workerCount = tweaks.length < 8 ? tweaks.length : 8;
    await Future.wait<void>(List.generate(workerCount, (_) => worker()));
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }

    _selectedCategory = category;
    notifyListeners();
  }

  bool isDescriptorAvailable(TweakDescriptor descriptor) {
    return _hardwareProfile.supportsCpu(descriptor.requiredCpuVendor) &&
        _hardwareProfile.supportsAnyGpu(descriptor.requiredGpuVendors);
  }

  String availabilityHint(TweakDescriptor descriptor) {
    if (descriptor.requiredCpuVendor != null &&
        !_hardwareProfile.supportsCpu(descriptor.requiredCpuVendor)) {
      return 'Available only on ${descriptor.requiredCpuVendor!.toUpperCase()} CPUs.';
    }

    if (descriptor.requiredGpuVendors.isNotEmpty &&
        !_hardwareProfile.supportsAnyGpu(descriptor.requiredGpuVendors)) {
      return 'No compatible GPU detected for this tweak.';
    }

    return 'Unavailable for current hardware.';
  }

  /// Applies or reverts a registry-backed system toggle.
  Future<OperationResult> toggleSystemTweak(
    TweakDescriptor descriptor,
    bool nextValue, {
    required Future<bool> Function() confirmRestorePoint,
  }) async {
    if (!descriptor.isSystemToggle) {
      return const OperationResult(
        success: false,
        message: 'Invalid system tweak descriptor.',
      );
    }
    if (_busyPresetCategories.contains(descriptor.category)) {
      return const OperationResult(
        success: false,
        message: 'A preset is being applied to this category.',
      );
    }

    final gate = await _safetyGateService.ensureSafety(
      requireRestorePoint: descriptor.isAggressive,
      askUserToCreateRestorePoint: confirmRestorePoint,
    );
    return gate.allowsExecution
        ? _setSystemTweak(descriptor, nextValue)
        : _mapGateFailure(gate);
  }

  Future<OperationResult> _setSystemTweak(
    TweakDescriptor descriptor,
    bool nextValue,
  ) async {
    if (_busyTweaks.contains(descriptor.id) || _isSystemOperationActive) {
      return const OperationResult(
        success: false,
        message: 'Another system tweak is being applied.',
      );
    }

    _isSystemOperationActive = true;
    final previous = _toggleStates[descriptor.id] ?? false;
    _markBusy(descriptor.id);
    _toggleStates[descriptor.id] = nextValue;
    notifyListeners();

    try {
      final result = await _tweakManager.applyTweak(
        descriptor.systemKey!,
        nextValue,
      );
      if (!result.success) {
        _toggleStates[descriptor.id] = previous;
        return OperationResult(
          success: false,
          message: result.errors.join('\n'),
        );
      }

      if (!_processRunner.isDryRun &&
          await _tweakManager.detectTweakState(descriptor.systemKey!) !=
              nextValue) {
        _toggleStates[descriptor.id] = previous;
        return OperationResult(
          success: false,
          message: 'State verification failed for ${descriptor.title}.',
        );
      }

      await _preferences.setBool(descriptor.id, nextValue);
      if (descriptor.restartRequired && previous != nextValue) {
        _needsRestart = true;
        await _preferences.setBool(_needsRestartKey, true);
      }
      return const OperationResult(success: true);
    } catch (error) {
      _toggleStates[descriptor.id] = previous;
      return OperationResult(success: false, message: error.toString());
    } finally {
      _isSystemOperationActive = false;
      _clearBusy(descriptor.id);
    }
  }

  /// Executes a script tweak or toggles a stateful script tweak.
  Future<OperationResult> runScriptAction(
    TweakDescriptor descriptor, {
    required Future<bool> Function() confirmRestorePoint,
  }) async {
    if (descriptor.scriptTweak == null) {
      return const OperationResult(
        success: false,
        message: 'Invalid script tweak descriptor.',
      );
    }
    if (_busyPresetCategories.contains(descriptor.category)) {
      return const OperationResult(
        success: false,
        message: 'A preset is being applied to this category.',
      );
    }

    final gate = await _safetyGateService.ensureSafety(
      requireRestorePoint: descriptor.isAggressive,
      askUserToCreateRestorePoint: confirmRestorePoint,
    );
    return gate.allowsExecution
        ? _runScriptTweak(descriptor)
        : _mapGateFailure(gate);
  }

  Future<OperationResult> _runScriptTweak(
    TweakDescriptor descriptor, {
    bool? target,
  }) async {
    final tweak = descriptor.scriptTweak!;
    if (_busyTweaks.contains(descriptor.id)) {
      return const OperationResult(success: false, message: 'Tweak is busy.');
    }

    _markBusy(descriptor.id);
    try {
      if (tweak.hasState) {
        final previous = tweak.isApplied;
        final desiredState = target ?? !previous;
        if (desiredState) {
          await tweak.onApply();
        } else {
          await tweak.onRevert();
        }

        tweak.isApplied = await tweak.checkState();
        if (tweak.isApplied != desiredState) {
          return OperationResult(
            success: false,
            message: 'State verification failed for ${descriptor.title}.',
          );
        }

        if (descriptor.restartRequired && previous != tweak.isApplied) {
          _needsRestart = true;
          await _preferences.setBool(_needsRestartKey, true);
        }
      } else {
        await tweak.runAction();
        await _preferences.setBool('executed:${descriptor.id}', true);
      }
      return const OperationResult(success: true);
    } catch (error) {
      return OperationResult(success: false, message: error.toString());
    } finally {
      _clearBusy(descriptor.id);
    }
  }

  Future<OperationResult> setAllInCategory(
    String category,
    bool enabled, {
    required Future<bool> Function() confirmRestorePoint,
  }) async {
    if (!categoryHasToggleableItems(category, systemOnly: true)) {
      return const OperationResult(
        success: false,
        message: 'Bulk toggle is available only for toggle-based categories.',
      );
    }
    if (_busyPresetCategories.contains(category)) {
      return const OperationResult(
        success: false,
        message: 'A preset is being applied to this category.',
      );
    }

    final toggles = categoryTweaks(category)
        .where((item) => item.isSystemToggle && isDescriptorAvailable(item))
        .toList();
    final gate = await _safetyGateService.ensureSafety(
      requireRestorePoint: true,
      askUserToCreateRestorePoint: confirmRestorePoint,
    );
    if (!gate.allowsExecution) {
      return _mapGateFailure(gate);
    }

    for (final descriptor in toggles) {
      if ((_toggleStates[descriptor.id] ?? false) == enabled) {
        continue;
      }
      final result = await _setSystemTweak(descriptor, enabled);
      if (!result.success) {
        return result;
      }
    }
    return const OperationResult(success: true);
  }

  /// Applies a preset profile to all available toggles in a category.
  Future<OperationResult> applyPresetToCategory(
    String category,
    String preset, {
    required Future<bool> Function() confirmRestorePoint,
  }) async {
    if (!availablePresetsForCategory(category).contains(preset)) {
      return const OperationResult(
        success: false,
        message: 'Unknown preset selected.',
      );
    }
    if (_busyPresetCategories.contains(category)) {
      return const OperationResult(
        success: false,
        message: 'A preset is already being applied.',
      );
    }

    final categoryDescriptors = categoryTweaks(category);
    if (categoryDescriptors.any((item) => _busyTweaks.contains(item.id))) {
      return const OperationResult(
        success: false,
        message: 'Wait for the current category operation to finish.',
      );
    }

    final descriptors = categoryDescriptors
        .where(
          (item) =>
              (item.isSystemToggle || item.isScriptToggle) &&
              isDescriptorAvailable(item),
        )
        .where((item) {
          final current = item.isSystemToggle
              ? (_toggleStates[item.id] ?? false)
              : item.scriptTweak!.isApplied;
          return current != shouldEnablePreset(preset, item);
        })
        .toList(growable: false);

    _busyPresetCategories.add(category);
    notifyListeners();
    try {
      if (descriptors.isNotEmpty) {
        final gate = await _safetyGateService.ensureSafety(
          requireRestorePoint: descriptors.any((item) => item.isAggressive),
          askUserToCreateRestorePoint: confirmRestorePoint,
        );
        if (!gate.allowsExecution) {
          return _mapGateFailure(gate);
        }
      }

      final applied = <String>[];
      for (final descriptor in descriptors) {
        final target = shouldEnablePreset(preset, descriptor);
        final result = descriptor.isSystemToggle
            ? await _setSystemTweak(descriptor, target)
            : await _runScriptTweak(descriptor, target: target);
        if (!result.success) {
          final completed = applied.isEmpty ? 'none' : applied.join(', ');
          return OperationResult(
            success: false,
            message:
                'Preset partially applied (${applied.length}/${descriptors.length}). '
                'Completed: $completed. Failed: ${descriptor.title}. '
                '${result.message ?? ''}',
          );
        }
        applied.add(descriptor.title);
      }

      _selectedPresets[category] = preset;
      await _preferences.setString(
        '$_lastSelectedPresetPrefix$category',
        preset,
      );
      return const OperationResult(success: true);
    } finally {
      _busyPresetCategories.remove(category);
      notifyListeners();
    }
  }

  Future<OperationResult> restartSystem() async {
    final result = await _systemActionService.restartSystem();
    if (result.success) {
      _needsRestart = false;
      await _preferences.setBool(_needsRestartKey, false);
      notifyListeners();
    }
    return result;
  }

  Future<void> setAutomaticUpdateChecksEnabled(bool enabled) async {
    if (_automaticUpdateChecksEnabled == enabled) {
      return;
    }
    _automaticUpdateChecksEnabled = enabled;
    await _preferences.setBool(_automaticUpdateChecksKey, enabled);
    notifyListeners();
    if (enabled) {
      await checkForUpdates();
    }
  }

  Future<UpdateCheckResult> checkForUpdates() async {
    if (_isCheckingForUpdates) {
      return const UpdateCheckResult(
        success: false,
        message: 'An update check is already running.',
      );
    }

    _isCheckingForUpdates = true;
    _updateStatusMessage = 'Checking for updates...';
    notifyListeners();
    try {
      final result = await _systemActionService.checkUpdateAvailability(
        currentVersion: _appVersion,
        latestReleaseApiUrl:
            'https://api.github.com/repos/PrimeBuild-pc/ZapTweaks/releases/latest',
        releasesPageUrl: 'https://github.com/PrimeBuild-pc/ZapTweaks/releases',
      );
      if (result.success) {
        _availableUpdate = result.update;
      }
      _updateStatusMessage = result.message;
      return result;
    } finally {
      _isCheckingForUpdates = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  Future<OperationResult> installAvailableUpdate() {
    final update = _availableUpdate;
    return update == null
        ? Future<OperationResult>.value(
            const OperationResult(
              success: false,
              message: 'No update is currently available.',
            ),
          )
        : _systemActionService.installUpdate(update);
  }

  Future<OperationResult> openAvailableRelease() {
    final update = _availableUpdate;
    return update == null
        ? Future<OperationResult>.value(
            const OperationResult(
              success: false,
              message: 'No update is currently available.',
            ),
          )
        : _systemActionService.openRelease(update);
  }

  Future<void> _checkForUpdatesAfterStartup() async {
    if (!_isDisposed) {
      await checkForUpdates();
    }
  }

  void _restoreExecutionModeFromPreferences() {
    final savedMode = _preferences.getString(_executionModeKey)?.trim();
    final nextMode = savedMode == ProcessExecutionMode.dryRun.name
        ? ProcessExecutionMode.dryRun
        : ProcessExecutionMode.production;
    _processRunner.setMode(nextMode);
  }

  void _restorePresetSelections() {
    for (final category in categories) {
      final savedPreset = _preferences.getString(
        '$_lastSelectedPresetPrefix$category',
      );
      final availablePresets = availablePresetsForCategory(category);
      _selectedPresets[category] = availablePresets.contains(savedPreset)
          ? savedPreset!
          : defaultPreset;
    }
  }

  void _startMetricsTicker() {
    _metricsTicker?.cancel();
    _metricsTicker = Timer.periodic(const Duration(seconds: 2), (_) {
      _sampleMetrics();
    });
  }

  Future<void> _sampleMetrics() async {
    if (_isSamplingMetrics) {
      return;
    }

    _isSamplingMetrics = true;

    try {
      final snapshot = await _metricsSamplingService.sample();
      if (_isDisposed) {
        return;
      }
      _latestMetrics = snapshot;
      _cpuHistory = _pushMetricValue(_cpuHistory, snapshot.cpuUsagePercent);
      _memoryHistory = _pushMetricValue(
        _memoryHistory,
        snapshot.memoryUsagePercent,
      );
      _gpuHistory = _pushMetricValue(_gpuHistory, snapshot.gpuUsagePercent);
      _vramHistory = _pushMetricValue(_vramHistory, snapshot.vramUsagePercent);
      notifyListeners();
    } finally {
      _isSamplingMetrics = false;
    }
  }

  Future<void> _startMetricsSampling() async {
    if (_isDisposed) {
      return;
    }
    _loadingStatus = 'Sampling system metrics...';
    notifyListeners();
    await _sampleMetrics();
    if (_isDisposed) {
      return;
    }
    _startMetricsTicker();
    _loadingStatus = 'Ready';
    notifyListeners();
  }

  List<double> _pushMetricValue(List<double> source, double nextValue) {
    final target = List<double>.from(source)..add(nextValue);

    if (target.length > _maxMetricsPoints) {
      target.removeRange(0, target.length - _maxMetricsPoints);
    }

    return List<double>.unmodifiable(target);
  }

  OperationResult _mapGateFailure(SafetyGateResult result) {
    switch (result.status) {
      case SafetyGateStatus.blockedMissingAdmin:
        return OperationResult(
          success: false,
          message: result.message ?? 'Administrator privileges are required.',
        );
      case SafetyGateStatus.restorePointFailed:
        return OperationResult(
          success: false,
          message: result.message ?? 'Restore point creation failed.',
        );
      case SafetyGateStatus.cancelled:
        return OperationResult(
          success: false,
          message: result.message ?? 'Operation cancelled.',
        );
      case SafetyGateStatus.proceed:
        return const OperationResult(success: true);
    }
  }

  void _markBusy(String tweakId) {
    _busyTweaks.add(tweakId);
    notifyListeners();
  }

  void _clearBusy(String tweakId) {
    _busyTweaks.remove(tweakId);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _metricsTicker?.cancel();
    super.dispose();
  }
}
