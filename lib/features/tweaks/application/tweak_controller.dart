import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/hardware_profile.dart';
import '../../../core/models/operation_result.dart';
import '../../../core/models/safety_gate_result.dart';
import '../../../core/models/system_metrics_snapshot.dart';
import '../../../core/models/tweak_descriptor.dart';
import '../../../core/services/category_preset_service.dart';
import '../../../core/services/hardware_detection_service.dart';
import '../../../core/services/logging_service.dart';
import '../../../core/services/metrics_sampling_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/process_runner.dart';
import '../../../core/services/safety_gate_service.dart';
import '../../../core/services/system_action_service.dart';
import '../../../core/services/tweak_catalog_service.dart';
import '../../../core/tweak_manager.dart';

class TweakController extends ChangeNotifier {
  TweakController({
    required TweakManager tweakManager,
    required PermissionService permissionService,
    required HardwareDetectionService hardwareDetectionService,
    required SafetyGateService safetyGateService,
    required SystemActionService systemActionService,
    required TweakCatalogService tweakCatalogService,
    required CategoryPresetService categoryPresetService,
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
       _categoryPresetService = categoryPresetService,
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
  final CategoryPresetService _categoryPresetService;
  final MetricsSamplingService _metricsSamplingService;
  final SharedPreferences _preferences;
  final ProcessRunner _processRunner;
  final String _appVersion;
  final LoggingService _loggingService;

  static const String _needsRestartKey = 'needsRestart';
  static const String _executionModeKey = 'executionMode';
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
  final Map<String, DateTime> _busyStartedAt = <String, DateTime>{};
  List<TweakDescriptor> _catalog = <TweakDescriptor>[];
  Timer? _busyTicker;
  Timer? _metricsTicker;
  bool _isSamplingMetrics = false;

  final ValueNotifier<SystemMetricsSnapshot> _latestMetrics =
      ValueNotifier<SystemMetricsSnapshot>(SystemMetricsSnapshot.empty);
  final ValueNotifier<List<double>> _cpuHistory = ValueNotifier<List<double>>(
    const <double>[],
  );
  final ValueNotifier<List<double>> _memoryHistory =
      ValueNotifier<List<double>>(const <double>[]);
  final ValueNotifier<List<double>> _gpuHistory = ValueNotifier<List<double>>(
    const <double>[],
  );
  final ValueNotifier<List<double>> _vramHistory = ValueNotifier<List<double>>(
    const <double>[],
  );

  String _loadingStatus = 'Initializing...';
  final Map<String, String> _selectedPresets = <String, String>{};

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  bool get needsRestart => _needsRestart;
  HardwareProfile get hardwareProfile => _hardwareProfile;
  String get selectedCategory => _selectedCategory;
  Map<String, bool> get toggleStates => _toggleStates;
  Set<String> get busyTweaks => _busyTweaks;
  List<String> get categories => TweakCatalogService.navigationCategories;
  bool get isDryRunMode => _processRunner.isDryRun;
  String get loadingStatus => _loadingStatus;
  String get appVersion => _appVersion;
  bool get isInteractionLocked =>
      _busyTweaks.any(_interactionLockingTweaks.contains);
  String get interactionLockMessage =>
      'Applying network profile. Please wait until all changes complete...';
  ValueListenable<SystemMetricsSnapshot> get latestMetricsListenable =>
      _latestMetrics;
  ValueListenable<List<double>> get cpuHistoryListenable => _cpuHistory;
  ValueListenable<List<double>> get memoryHistoryListenable => _memoryHistory;
  ValueListenable<List<double>> get gpuHistoryListenable => _gpuHistory;
  ValueListenable<List<double>> get vramHistoryListenable => _vramHistory;

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

  List<String> presetsForCategory(String category) {
    return _categoryPresetService.availablePresetsForCategory(category);
  }

  String selectedPresetForCategory(String category) {
    return _selectedPresets[category] ?? CategoryPresetService.defaultPreset;
  }

  Duration busyDurationFor(String tweakId) {
    final startedAt = _busyStartedAt[tweakId];
    if (startedAt == null) {
      return Duration.zero;
    }

    return DateTime.now().difference(startedAt);
  }

  List<TweakDescriptor> get visibleTweaks => categoryTweaks(_selectedCategory);

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

      _loadingStatus = 'Detecting hardware...';
      notifyListeners();
      final futures = await Future.wait<dynamic>(<Future<dynamic>>[
        _permissionService.isRunningElevated(),
        _hardwareDetectionService.detect(),
        _tweakManager.detectCurrentTweakStates(),
      ]);

      _isAdmin = futures[0] as bool;
      _hardwareProfile = futures[1] as HardwareProfile;
      final detectedStates = futures[2] as Map<String, bool>;

      _loadingStatus = 'Loading tweaks catalog...';
      notifyListeners();
      _catalog = _tweakCatalogService.buildCatalog();

      for (final descriptor in _catalog) {
        if (descriptor.isSystemToggle) {
          _toggleStates[descriptor.id] =
              detectedStates[descriptor.systemKey] ??
              _preferences.getBool(descriptor.id) ??
              false;
        }
      }

      _needsRestart = _preferences.getBool(_needsRestartKey) ?? false;

      _loadingStatus = 'Checking script states...';
      notifyListeners();
      await _initializeScriptStates();
    } finally {
      _isLoading = false;
      _loadingStatus = 'Ready';
      notifyListeners();
      Future<void>.delayed(Duration.zero, _startMetricsSampling);
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
    for (final descriptor in _catalog.where(
      (item) => item.scriptTweak != null,
    )) {
      final tweak = descriptor.scriptTweak!;
      if (!tweak.hasState) {
        continue;
      }

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

    if (_busyTweaks.contains(descriptor.id)) {
      return const OperationResult(success: false, message: 'Tweak is busy.');
    }

    final gate = await _safetyGateService.ensureSafety(
      requireRestorePoint: descriptor.isAggressive,
      askUserToCreateRestorePoint: confirmRestorePoint,
    );

    if (!gate.allowsExecution) {
      return _mapGateFailure(gate);
    }

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
      _clearBusy(descriptor.id);
    }
  }

  /// Executes a script tweak or toggles a stateful script tweak.
  Future<OperationResult> runScriptAction(
    TweakDescriptor descriptor, {
    required Future<bool> Function() confirmRestorePoint,
  }) async {
    final tweak = descriptor.scriptTweak;
    if (tweak == null) {
      return const OperationResult(
        success: false,
        message: 'Invalid script tweak descriptor.',
      );
    }

    if (_busyTweaks.contains(descriptor.id)) {
      return const OperationResult(success: false, message: 'Tweak is busy.');
    }

    final gate = await _safetyGateService.ensureSafety(
      requireRestorePoint: descriptor.isAggressive,
      askUserToCreateRestorePoint: confirmRestorePoint,
    );

    if (!gate.allowsExecution) {
      return _mapGateFailure(gate);
    }

    _markBusy(descriptor.id);

    try {
      if (tweak.hasState) {
        final previous = tweak.isApplied;
        final target = !tweak.isApplied;
        if (target) {
          await tweak.onApply();
        } else {
          await tweak.onRevert();
        }
        tweak.isApplied = await tweak.checkState();

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
      final current = _toggleStates[descriptor.id] ?? false;
      if (current == enabled) {
        continue;
      }

      final result = await toggleSystemTweak(
        descriptor,
        enabled,
        confirmRestorePoint: () async => true,
      );
      if (!result.success) {
        return result;
      }
    }

    return const OperationResult(success: true);
  }

  /// Applies a preset profile to all available toggles in a category.
  Future<OperationResult> applyPresetToCategory(
    String category,
    String preset,
  ) async {
    final presets = _categoryPresetService.availablePresetsForCategory(
      category,
    );
    if (!presets.contains(preset)) {
      return const OperationResult(
        success: false,
        message: 'Unknown preset selected.',
      );
    }

    final descriptors = categoryTweaks(category)
        .where(
          (item) =>
              (item.isSystemToggle || item.isScriptToggle) &&
              isDescriptorAvailable(item),
        )
        .toList(growable: false);

    for (final descriptor in descriptors) {
      final shouldEnable = _categoryPresetService.shouldEnable(
        category: category,
        preset: preset,
        descriptor: descriptor,
      );

      final current = descriptor.isSystemToggle
          ? (_toggleStates[descriptor.id] ?? false)
          : (descriptor.scriptTweak?.isApplied ?? false);

      if (current == shouldEnable) {
        continue;
      }

      final OperationResult result;
      if (descriptor.isSystemToggle) {
        result = await toggleSystemTweak(
          descriptor,
          shouldEnable,
          confirmRestorePoint: () async => true,
        );
      } else {
        result = await runScriptAction(
          descriptor,
          confirmRestorePoint: () async => true,
        );
      }

      if (!result.success) {
        return result;
      }
    }

    _selectedPresets[category] = preset;
    await _preferences.setString('$_lastSelectedPresetPrefix$category', preset);
    notifyListeners();
    return const OperationResult(success: true);
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

  Future<OperationResult> restartToBios() {
    return _systemActionService.restartToBios();
  }

  Future<OperationResult> restartToSafeMode() {
    return _systemActionService.restartToSafeMode();
  }

  Future<OperationResult> checkForUpdates() {
    return _systemActionService.checkForUpdates(
      currentVersion: _appVersion,
      latestReleaseApiUrl:
          'https://api.github.com/repos/PrimeBuild-pc/ZapTweaks/releases/latest',
      releasesPageUrl: 'https://github.com/PrimeBuild-pc/ZapTweaks/releases',
      autoInstall: true,
    );
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
      final availablePresets = _categoryPresetService
          .availablePresetsForCategory(category);
      _selectedPresets[category] = availablePresets.contains(savedPreset)
          ? savedPreset!
          : CategoryPresetService.defaultPreset;
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
      _latestMetrics.value = snapshot;
      _cpuHistory.value = _pushMetricValue(
        _cpuHistory.value,
        snapshot.cpuUsagePercent,
      );
      _memoryHistory.value = _pushMetricValue(
        _memoryHistory.value,
        snapshot.memoryUsagePercent,
      );
      _gpuHistory.value = _pushMetricValue(
        _gpuHistory.value,
        snapshot.gpuUsagePercent,
      );
      _vramHistory.value = _pushMetricValue(
        _vramHistory.value,
        snapshot.vramUsagePercent,
      );
    } finally {
      _isSamplingMetrics = false;
    }
  }

  Future<void> _startMetricsSampling() async {
    _loadingStatus = 'Sampling system metrics...';
    notifyListeners();
    await _sampleMetrics();
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
    _busyStartedAt[tweakId] = DateTime.now();
    _startBusyTickerIfNeeded();
    notifyListeners();
  }

  void _clearBusy(String tweakId) {
    _busyTweaks.remove(tweakId);
    _busyStartedAt.remove(tweakId);

    if (_busyTweaks.isEmpty) {
      _stopBusyTicker();
    }

    notifyListeners();
  }

  void _startBusyTickerIfNeeded() {
    if (_busyTicker != null) {
      return;
    }

    _busyTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_busyTweaks.isEmpty) {
        _stopBusyTicker();
        return;
      }

      notifyListeners();
    });
  }

  void _stopBusyTicker() {
    _busyTicker?.cancel();
    _busyTicker = null;
  }

  @override
  void dispose() {
    _stopBusyTicker();
    _metricsTicker?.cancel();
    _latestMetrics.dispose();
    _cpuHistory.dispose();
    _memoryHistory.dispose();
    _gpuHistory.dispose();
    _vramHistory.dispose();
    super.dispose();
  }
}
