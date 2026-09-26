import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/hardware_profile.dart';
import '../../../core/models/operation_result.dart';
import '../../../core/models/safety_gate_result.dart';
import '../../../core/models/system_metrics_snapshot.dart';
import '../../../core/models/tweak_descriptor.dart';
import '../../../core/models/update_info.dart';
import '../../../core/operations/operation.dart';
import '../../../core/operations/operation_registry.dart';
import '../../../core/persistence/operation_store.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/plans/plan_engine.dart';
import '../../../core/security/elevated_helper.dart';
import '../../../core/search/search_matcher.dart';
import '../../../core/services/app_locale_service.dart';
import '../../../core/services/hardware_detection_service.dart';
import '../../../core/services/logging_service.dart';
import '../../../core/services/metrics_sampling_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/process_runner.dart';
import '../../../core/services/safety_gate_service.dart';
import '../../../core/services/system_action_service.dart';
import '../../../core/services/tweak_catalog_service.dart';
import '../../../core/tweak_manager.dart';
import '../../../legacy/adapters/legacy_catalog_adapter.dart';
import '../../../models/system_tweak.dart';
import '../../../platform/windows/system_uptime.dart';

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
    Future<LegacyCatalogAdapter> Function()? legacyCatalogAdapterLoader,
    ElevatedHelperClient? elevatedHelperClient,
    OperationRegistry? operationRegistry,
    OperationStore? operationStore,
    OperationExecutor? elevatedOperationExecutor,
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
       _loggingService = loggingService ?? LoggingService.instance,
       _legacyCatalogAdapterLoader =
           legacyCatalogAdapterLoader ??
           (() async => LegacyCatalogAdapter.identity),
       _elevatedHelperClient = elevatedHelperClient,
       _operationRegistry = operationRegistry,
       _operationStore = operationStore,
       _elevatedOperationExecutor = elevatedOperationExecutor;

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
  final Future<LegacyCatalogAdapter> Function() _legacyCatalogAdapterLoader;
  final ElevatedHelperClient? _elevatedHelperClient;
  final OperationRegistry? _operationRegistry;
  final OperationStore? _operationStore;
  final OperationExecutor? _elevatedOperationExecutor;
  PlanEngine? _planEngine;

  static const String settingsCategory = 'Settings';

  static const String _needsRestartKey = 'needsRestart';
  static const String _executionModeKey = 'executionMode';
  static const String _automaticUpdateChecksKey = 'automaticUpdateChecks';
  static const String _expandedCollectionsKey = 'expandedCollections';
  static const String _localeCodeKey = AppLocaleService.preferenceKey;
  static const String _startWithWindowsKey = 'startWithWindows';
  static const String _expertModeKey = 'expertMode';
  static const String _themeModeKey = 'themeMode';
  static const int _maxMetricsPoints = 40;
  static const Set<String> _interactionLockingTweaks = <String>{
    'network_low_latency_bandwidth_profile',
  };
  static const Map<String, Object> _nativeToggleEnabledValues =
      <String, Object>{
        'ui_taskbar_end_task': 1,
        'power_throttling_off': 1,
        'power_processor_boost_mode': <String, int>{'ac': 2, 'dc': 2},
        'power_max_processor_state': <String, int>{'ac': 100, 'dc': 100},
      };
  static const Map<String, Object?> _nativeToggleDisabledValues =
      <String, Object?>{
        'ui_taskbar_end_task': null,
        'power_throttling_off': null,
        'power_processor_boost_mode': <String, int>{'ac': 1, 'dc': 1},
        'power_max_processor_state': <String, int>{'ac': 99, 'dc': 99},
      };

  bool _isLoading = true;
  bool _isAdmin = false;
  bool _needsRestart = false;
  HardwareProfile _hardwareProfile = HardwareProfile.unknown;
  String _selectedCategory =
      TweakCatalogService.oneAppNavigationCategories.first;

  final Map<String, bool> _toggleStates = <String, bool>{};
  final Set<String> _busyTweaks = <String>{};
  final Set<String> _pendingStateTweaks = <String>{};
  List<TweakDescriptor> _catalog = <TweakDescriptor>[];
  Timer? _metricsTicker;
  bool _isSamplingMetrics = false;
  bool _isSystemOperationActive = false;
  Future<bool>? _helperRestorePointDecision;
  bool _helperRestorePointAttempted = false;
  bool _automaticUpdateChecksEnabled = true;
  bool _startWithWindows = false;
  bool _expertModeEnabled = false;
  String _themeMode = 'system';
  String _searchQuery = '';
  int _navigationTab = 0;
  String? _navigationSearchTerm;
  String _localeCode = AppLocaleService.systemCode();
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

  /// Startup work shown in order; hardware and state checks continue after
  /// the interactive shell is ready.
  static const List<String> loadingSteps = <String>[
    'Loading preferences...',
    'Loading tweaks catalog...',
    'Checking administrator rights...',
    'Detecting hardware...',
    'Reading system tweak states...',
    'Reading script tweak states...',
  ];
  final Set<String> _completedLoadingSteps = <String>{};

  /// "category/collection" keys the user has opened. Collections start closed
  /// so a category page opens as a short, scannable list, and the choice is
  /// remembered across restarts.
  final Set<String> _expandedCollections = <String>{};

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  bool get needsRestart => _needsRestart;
  HardwareProfile get hardwareProfile => _hardwareProfile;
  String get selectedCategory => _selectedCategory;
  Map<String, bool> get toggleStates => _toggleStates;
  Set<String> get busyTweaks => <String>{
    ..._busyTweaks,
    ..._pendingStateTweaks,
  };
  List<String> get categories => TweakCatalogService.oneAppNavigationCategories
      .where((category) => category != 'Expert' || _expertModeEnabled)
      .toList(growable: false);
  bool get isDryRunMode => _processRunner.isDryRun;
  String get loadingStatus => _loadingStatus;
  bool isLoadingStepDone(String step) => _completedLoadingSteps.contains(step);
  String get appVersion => _appVersion;
  bool get automaticUpdateChecksEnabled => _automaticUpdateChecksEnabled;
  bool get startWithWindows => _startWithWindows;
  bool get expertModeEnabled => _expertModeEnabled;
  String get themeMode => _themeMode;
  String get searchQuery => _searchQuery;
  int get navigationTab => _navigationTab;
  String? get navigationSearchTerm => _navigationSearchTerm;
  String get localeCode => _localeCode;
  bool get isCheckingForUpdates => _isCheckingForUpdates;
  bool get isUpdateAvailable => _availableUpdate != null;
  UpdateInfo? get availableUpdate => _availableUpdate;
  String? get updateStatusMessage => _updateStatusMessage;
  bool get isInteractionLocked =>
      _busyTweaks.any(_interactionLockingTweaks.contains);
  String get interactionLockMessage =>
      'Applying network profile. Please wait until all changes complete...';
  SystemMetricsSnapshot get latestMetrics => _latestMetrics;
  List<double> get cpuHistory => _cpuHistory;
  List<double> get memoryHistory => _memoryHistory;
  List<double> get gpuHistory => _gpuHistory;
  List<double> get vramHistory => _vramHistory;

  /// Returns true when an action script has been executed at least once.
  bool wasScriptExecuted(String tweakId) {
    return _preferences.getBool('executed:$tweakId') ?? false;
  }

  List<TweakDescriptor> categoryTweaks(String category) {
    return _catalog
        .where(
          (descriptor) =>
              descriptor.category == category && !descriptor.isAlias,
        )
        .toList(growable: false);
  }

  List<TweakDescriptor> searchTweaks(
    String query, {
    bool includeExpert = false,
  }) {
    if (query.trim().isEmpty) return const <TweakDescriptor>[];

    final byId = <String, TweakDescriptor>{
      for (final descriptor in _catalog) descriptor.id: descriptor,
    };
    final results = <String, TweakDescriptor>{};
    for (final descriptor in _catalog) {
      if (!includeExpert &&
          !_expertModeEnabled &&
          descriptor.category == 'Expert') {
        continue;
      }
      final haystack =
          '${descriptor.id} ${descriptor.title} ${descriptor.description} '
          '${descriptor.category} ${descriptor.collection}';
      if (!SearchMatcher.matches(query, haystack)) continue;
      final resolved = descriptor.aliasTarget == null
          ? descriptor
          : (byId[descriptor.aliasTarget!] ?? descriptor);
      results[resolved.id] = resolved;
    }
    return results.values.toList(growable: false);
  }

  Future<void> initialize() async {
    _isLoading = true;
    _loadingStatus = 'Initializing UI...';
    _completedLoadingSteps.clear();
    notifyListeners();

    try {
      _beginLoadingStep('Loading preferences...');
      _restoreExecutionModeFromPreferences();
      _restoreExpandedCollections();
      _automaticUpdateChecksEnabled =
          _preferences.getBool(_automaticUpdateChecksKey) ?? true;
      _startWithWindows = _preferences.getBool(_startWithWindowsKey) ?? false;
      _expertModeEnabled = _preferences.getBool(_expertModeKey) ?? false;
      _themeMode = _normalizedThemeMode(_preferences.getString(_themeModeKey));
      _localeCode = AppLocaleService.normalize(
        _preferences.getString(_localeCodeKey) ?? AppLocaleService.systemCode(),
      );
      _needsRestart = _preferences.getBool(_needsRestartKey) ?? false;
      _completeLoadingStep('Loading preferences...');

      _beginLoadingStep('Loading tweaks catalog...');
      final adapter = await _legacyCatalogAdapterLoader();
      _catalog = adapter.adapt(_tweakCatalogService.buildCatalog());
      _pendingStateTweaks.addAll(
        _catalog
            .where(
              (descriptor) =>
                  descriptor.isSystemToggle ||
                  descriptor.scriptTweak?.hasState == true,
            )
            .map((descriptor) => descriptor.id),
      );
      unawaited(
        _loggingService.logInfo(
          'Loaded ${_catalog.length} tweak catalog entries.',
          source: 'TweakController',
        ),
      );
      _completeLoadingStep('Loading tweaks catalog...');

      _beginLoadingStep('Checking administrator rights...');
      _isAdmin = await _trackLoadingStep(
        'Checking administrator rights...',
        _permissionService.isRunningElevated(),
      );

      _isLoading = false;
      _loadingStatus = 'Ready';
      notifyListeners();
      unawaited(_startMetricsSampling());
      if (_automaticUpdateChecksEnabled) {
        unawaited(_checkForUpdatesAfterStartup());
      }

      unawaited(
        _loggingService.logInfo(
          'Detecting hardware profile and current tweak states in background.',
          source: 'TweakController',
        ),
      );
      final futures = await Future.wait<dynamic>(<Future<dynamic>>[
        _trackLoadingStep(
          'Detecting hardware...',
          _hardwareDetectionService.detect(),
        ),
        _trackLoadingStep(
          'Reading system tweak states...',
          _tweakManager.detectCurrentTweakStates(),
        ),
        _trackLoadingStep(
          'Reading script tweak states...',
          _initializeScriptStates(),
        ),
      ]);

      _hardwareProfile = futures[0] as HardwareProfile;
      final detectedStates = futures[1] as Map<String, bool>;
      for (final descriptor in _catalog.where(
        (descriptor) => descriptor.isSystemToggle,
      )) {
        _toggleStates[descriptor.id] =
            detectedStates[descriptor.systemKey] ??
            _preferences.getBool(descriptor.id) ??
            false;
        _pendingStateTweaks.remove(descriptor.id);
      }

      if (_operationRegistry != null) {
        _planEngine = PlanEngine(
          registry: _operationRegistry,
          context: OperationContext(
            windowsBuild: _hardwareProfile.windowsBuild,
            edition: 'Home/Pro',
          ),
          user: Platform.environment['USERNAME'] ?? 'current-user',
          appVersion: _appVersion,
          store: _operationStore,
          elevatedExecutor: _elevatedOperationExecutor,
        );
        try {
          await _planEngine!.reconcileAfterRestart(
            domain: 'drivers',
            rebootedSince: windowsRebootedSince,
          );
        } catch (error) {
          unawaited(
            _loggingService.logError(
              'Driver post-restart verification failed: $error',
              source: 'TweakController',
            ),
          );
        }
      }

      unawaited(
        _loggingService.logInfo(
          'Detection complete: elevation=$_isAdmin, CPU=${_hardwareProfile.cpuName}, GPUs=${_hardwareProfile.gpuNames.length}, system tweaks=${detectedStates.length}.',
          source: 'TweakController',
        ),
      );
    } finally {
      _isLoading = false;
      _pendingStateTweaks.clear();
      _completedLoadingSteps.addAll(loadingSteps);
      _loadingStatus = 'Ready';
      notifyListeners();
    }
  }

  Future<void> setLocaleCode(String code) async {
    final nextCode = AppLocaleService.normalize(code);
    if (_localeCode == nextCode) {
      return;
    }

    _localeCode = nextCode;
    await _preferences.setString(_localeCodeKey, nextCode);
    notifyListeners();
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
    unawaited(
      _loggingService.logInfo(
        'Detecting ${tweaks.length} stateful script tweaks.',
        source: 'TweakController',
      ),
    );
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
        } finally {
          _pendingStateTweaks.remove(tweak.id);
          notifyListeners();
        }
      }
    }

    final workerCount = tweaks.length < 8 ? tweaks.length : 8;
    await Future.wait<void>(List.generate(workerCount, (_) => worker()));
    final appliedCount = tweaks.where((tweak) => tweak.isApplied).length;
    unawaited(
      _loggingService.logInfo(
        'Script tweak detection complete: $appliedCount/${tweaks.length} applied.',
        source: 'TweakController',
      ),
    );
  }

  void selectCategory(String category) {
    navigateTo(category);
  }

  void navigateTo(String category, {int tab = 0, String? searchTerm}) {
    if (!categories.contains(category)) return;
    if (_selectedCategory == category &&
        _searchQuery.isEmpty &&
        _navigationTab == tab &&
        _navigationSearchTerm == searchTerm) {
      return;
    }
    _selectedCategory = category;
    _searchQuery = '';
    _navigationTab = tab;
    _navigationSearchTerm = searchTerm;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setExpertModeEnabled(bool enabled) async {
    if (_expertModeEnabled == enabled) return;
    _expertModeEnabled = enabled;
    await _preferences.setBool(_expertModeKey, enabled);
    if (!enabled && _selectedCategory == 'Expert') {
      _selectedCategory = TweakCatalogService.oneAppNavigationCategories.first;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(String value) async {
    final normalized = _normalizedThemeMode(value);
    if (_themeMode == normalized) return;
    _themeMode = normalized;
    await _preferences.setString(_themeModeKey, normalized);
    notifyListeners();
  }

  static String _normalizedThemeMode(String? value) =>
      const <String>{'system', 'light', 'dark'}.contains(value)
      ? value!
      : 'system';

  bool isDescriptorAvailable(TweakDescriptor descriptor) {
    if (descriptor.isRejected || descriptor.isBlockedLegacyScript) return false;
    if (descriptor.isSystemToggle &&
        _operationRegistry?.contains(descriptor.id) != true) {
      return false;
    }
    if (_isDescriptorEnabled(descriptor)) {
      return true;
    }

    final minimumBuild = descriptor.minimumWindowsBuild;
    final supported =
        _hardwareProfile.supportsCpu(descriptor.requiredCpuVendor) &&
        _hardwareProfile.supportsAnyGpu(descriptor.requiredGpuVendors) &&
        (minimumBuild == null || _hardwareProfile.windowsBuild >= minimumBuild);
    if (!supported) {
      return false;
    }

    return _activeConflicts(descriptor).isEmpty;
  }

  bool _isDescriptorEnabled(TweakDescriptor descriptor) =>
      descriptor.isSystemToggle
      ? (_toggleStates[descriptor.id] ?? false)
      : (descriptor.scriptTweak?.isApplied ?? false);

  List<TweakDescriptor> _activeConflicts(TweakDescriptor descriptor) {
    if (descriptor.conflictingTweakIds.isEmpty) {
      return const <TweakDescriptor>[];
    }

    return _catalog
        .where(
          (candidate) =>
              descriptor.conflictingTweakIds.contains(candidate.id) &&
              _isDescriptorEnabled(candidate),
        )
        .toList(growable: false);
  }

  String availabilityHint(TweakDescriptor descriptor) {
    if (descriptor.isRejected) {
      return 'Documented for compatibility, but intentionally not automated.';
    }
    if (descriptor.isBlockedLegacyScript) {
      return 'Legacy interactive script execution is blocked; use its native or assisted replacement.';
    }
    if (descriptor.isSystemToggle &&
        _operationRegistry?.contains(descriptor.id) != true) {
      return 'Legacy mutation is blocked until a typed native operation replaces it.';
    }
    if (descriptor.requiredCpuVendor != null &&
        !_hardwareProfile.supportsCpu(descriptor.requiredCpuVendor)) {
      return 'Available only on ${descriptor.requiredCpuVendor!.toUpperCase()} CPUs.';
    }

    if (descriptor.requiredGpuVendors.isNotEmpty &&
        !_hardwareProfile.supportsAnyGpu(descriptor.requiredGpuVendors)) {
      return 'No compatible GPU detected for this tweak.';
    }

    final minimumBuild = descriptor.minimumWindowsBuild;
    if (minimumBuild != null && _hardwareProfile.windowsBuild < minimumBuild) {
      return 'Requires Windows build $minimumBuild or newer.';
    }

    final conflicts = _activeConflicts(descriptor);
    if (conflicts.isNotEmpty) {
      return 'Disable ${conflicts.map((item) => item.title).join(', ')} first.';
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
    // Mark busy up front: creating a restore point can take a while and the
    // user needs a spinner for the whole operation, not just the apply step.
    if (_processRunner.isDryRun) {
      return _setSystemTweak(descriptor, nextValue);
    }

    if (!_isAdmin && _elevatedHelperClient != null) {
      try {
        _helperRestorePointDecision ??= confirmRestorePoint();
        final createRestorePoint =
            !_helperRestorePointAttempted && await _helperRestorePointDecision!;
        _helperRestorePointAttempted |= createRestorePoint;
        return await _setSystemTweak(
          descriptor,
          nextValue,
          createRestorePoint: createRestorePoint,
        );
      } catch (error) {
        _helperRestorePointDecision = null;
        return OperationResult(success: false, message: error.toString());
      }
    }

    _markBusy(descriptor.id);
    try {
      final gate = await _safetyGateService.ensureSafety(
        requireRestorePoint: true,
        askUserToCreateRestorePoint: confirmRestorePoint,
      );
      if (!gate.allowsExecution) {
        return _mapGateFailure(gate);
      }
    } finally {
      _clearBusy(descriptor.id);
    }

    return _setSystemTweak(descriptor, nextValue);
  }

  Future<OperationResult> _setSystemTweak(
    TweakDescriptor descriptor,
    bool nextValue, {
    bool createRestorePoint = false,
  }) async {
    if (nextValue && !isDescriptorAvailable(descriptor)) {
      return OperationResult(
        success: false,
        message: availabilityHint(descriptor),
      );
    }
    if (busyTweaks.contains(descriptor.id) || _isSystemOperationActive) {
      return const OperationResult(
        success: false,
        message: 'Another system tweak is being applied.',
      );
    }

    _isSystemOperationActive = true;
    final previous = _toggleStates[descriptor.id] ?? false;
    if (_processRunner.isDryRun) {
      _isSystemOperationActive = false;
      return const OperationResult(
        success: true,
        message: 'Dry run completed without changing Windows.',
      );
    }
    _markBusy(descriptor.id);
    _toggleStates[descriptor.id] = nextValue;
    notifyListeners();

    try {
      if (_operationRegistry?.contains(descriptor.id) != true) {
        _toggleStates[descriptor.id] = previous;
        return const OperationResult(
          success: false,
          message:
              'Legacy mutation is blocked until a typed native operation replaces it.',
        );
      }
      final desired = nextValue
          ? (_nativeToggleEnabledValues[descriptor.id] ?? 1)
          : _nativeToggleDisabledValues[descriptor.id];
      final plan = await executeNativeRequests(<OperationRequest>[
        OperationRequest(operationId: descriptor.id, desiredValue: desired),
      ]);
      if (plan.status == PlanStatus.dryRunComplete) {
        _toggleStates[descriptor.id] = previous;
        return const OperationResult(
          success: true,
          message: 'Dry run completed without changing Windows.',
        );
      }
      final item = plan.items.single;
      if (plan.status != PlanStatus.completed ||
          item.status != PlanItemStatus.verified) {
        _toggleStates[descriptor.id] = previous;
        return OperationResult(
          success: false,
          message: item.error ?? item.before.message ?? 'Operation failed.',
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

  Future<OperationPlan> executeNativeRequests(
    List<OperationRequest> requests,
  ) async {
    final engine = _planEngine;
    if (engine == null || requests.isEmpty) {
      throw StateError('Native operation engine is unavailable.');
    }
    final privileges = requests
        .map(
          (request) => engine.registry.resolve(request.operationId).privilege,
        )
        .toSet();
    if (privileges.length != 1) {
      throw StateError(
        'User and administrator operations require separate plans.',
      );
    }
    if (privileges.single == OperationPrivilege.administrator &&
        !_processRunner.isDryRun) {
      final helper = _elevatedHelperClient;
      if (helper == null) throw StateError('Elevated helper is unavailable.');
      return helper.executeNativePlan(
        requests: requests,
        user: Platform.environment['USERNAME'] ?? 'current-user',
        appVersion: _appVersion,
      );
    }
    final plan = await engine.plan(requests);
    await engine.execute(plan, dryRun: _processRunner.isDryRun);
    return plan;
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
    if (descriptor.isBlockedLegacyScript) {
      return const OperationResult(
        success: false,
        message:
            'Legacy payload execution is blocked; use its native or assisted replacement.',
      );
    }
    if (busyTweaks.contains(descriptor.id)) {
      return const OperationResult(success: false, message: 'Tweak is busy.');
    }
    if (_nativeToggleEnabledValues.containsKey(descriptor.id)) {
      return _runNativeToggle(descriptor);
    }
    if (_operationRegistry?.contains(descriptor.id) == true) {
      return _runNativeAction(descriptor);
    }

    _markBusy(descriptor.id);
    try {
      final gate = await _safetyGateService.ensureSafety(
        requireRestorePoint: descriptor.scriptTweak!.requiresSafetyPrompt,
        askUserToCreateRestorePoint: confirmRestorePoint,
      );
      if (!gate.allowsExecution) {
        return _mapGateFailure(gate);
      }
    } finally {
      _clearBusy(descriptor.id);
    }

    return _runScriptTweak(descriptor);
  }

  Future<OperationResult> _runNativeAction(TweakDescriptor descriptor) async {
    final engine = _planEngine;
    if (engine == null) {
      return const OperationResult(
        success: false,
        message: 'Native operation engine is unavailable.',
      );
    }
    _markBusy(descriptor.id);
    try {
      final plan = await engine.plan(<OperationRequest>[
        OperationRequest(operationId: descriptor.id, desiredValue: true),
      ]);
      await engine.execute(plan, dryRun: _processRunner.isDryRun);
      if (plan.status == PlanStatus.dryRunComplete) {
        return const OperationResult(
          success: true,
          message: 'Dry run completed without changing Windows.',
        );
      }
      final item = plan.items.single;
      if (plan.status != PlanStatus.completed ||
          item.status != PlanItemStatus.verified) {
        return OperationResult(
          success: false,
          message: item.error ?? item.before.message ?? 'Operation failed.',
        );
      }
      await _preferences.setBool('executed:${descriptor.id}', true);
      return const OperationResult(success: true);
    } catch (error) {
      return OperationResult(success: false, message: error.toString());
    } finally {
      _clearBusy(descriptor.id);
    }
  }

  Future<OperationResult> _runNativeToggle(
    TweakDescriptor descriptor, {
    bool? target,
  }) async {
    final engine = _planEngine;
    if (engine == null || !engine.registry.contains(descriptor.id)) {
      return const OperationResult(
        success: false,
        message: 'Native operation engine is unavailable.',
      );
    }
    final tweak = descriptor.scriptTweak!;
    final desired = target ?? !tweak.isApplied;
    _markBusy(descriptor.id);
    try {
      final request = OperationRequest(
        operationId: descriptor.id,
        desiredValue: desired
            ? _nativeToggleEnabledValues[descriptor.id]
            : _nativeToggleDisabledValues[descriptor.id],
      );
      final definition = engine.registry.resolve(descriptor.id);
      final helper = _elevatedHelperClient;
      final plan =
          definition.privilege == OperationPrivilege.administrator &&
              helper != null &&
              !_processRunner.isDryRun
          ? await helper.executeNativePlan(
              requests: <OperationRequest>[request],
              user: engine.user,
              appVersion: engine.appVersion,
            )
          : await engine.plan(<OperationRequest>[request]);
      if (definition.privilege != OperationPrivilege.administrator ||
          helper == null ||
          _processRunner.isDryRun) {
        await engine.execute(plan, dryRun: _processRunner.isDryRun);
      }
      if (plan.status == PlanStatus.dryRunComplete) {
        return const OperationResult(
          success: true,
          message: 'Dry run completed without changing Windows.',
        );
      }
      final item = plan.items.single;
      if (plan.status != PlanStatus.completed ||
          item.status != PlanItemStatus.verified) {
        return OperationResult(
          success: false,
          message: item.error ?? item.before.message ?? 'Operation failed.',
        );
      }
      tweak.isApplied = desired;
      return const OperationResult(success: true);
    } catch (error) {
      return OperationResult(success: false, message: error.toString());
    } finally {
      _clearBusy(descriptor.id);
    }
  }

  Future<OperationResult> _runScriptTweak(
    TweakDescriptor descriptor, {
    bool? target,
  }) async {
    if (_nativeToggleEnabledValues.containsKey(descriptor.id)) {
      return _runNativeToggle(descriptor, target: target);
    }
    final tweak = descriptor.scriptTweak!;
    final desiredState = tweak.hasState ? target ?? !tweak.isApplied : null;
    if (desiredState == true && !isDescriptorAvailable(descriptor)) {
      return OperationResult(
        success: false,
        message: availabilityHint(descriptor),
      );
    }
    if (busyTweaks.contains(descriptor.id)) {
      return const OperationResult(success: false, message: 'Tweak is busy.');
    }

    _markBusy(descriptor.id);
    try {
      if (tweak.hasState) {
        final previous = tweak.isApplied;
        if (desiredState!) {
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

  Future<OperationResult> restartSystem() async {
    final result = await _systemActionService.restartSystem();
    if (result.success) {
      _needsRestart = false;
      await _preferences.setBool(_needsRestartKey, false);
      notifyListeners();
    }
    return result;
  }

  Future<OperationResult> setStartWithWindows(bool enabled) async {
    final executable = Platform.resolvedExecutable;
    final result = enabled
        ? await _processRunner.run('reg', <String>[
            'add',
            r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run',
            '/v',
            'ZapTweaks',
            '/t',
            'REG_SZ',
            '/d',
            executable,
            '/f',
          ])
        : await _processRunner.run('powershell', <String>[
            '-NoProfile',
            '-Command',
            "Remove-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run' -Name ZapTweaks -ErrorAction SilentlyContinue",
          ]);
    if (!result.success) {
      return OperationResult(success: false, message: result.details);
    }
    _startWithWindows = enabled;
    await _preferences.setBool(_startWithWindowsKey, enabled);
    notifyListeners();
    return const OperationResult(success: true);
  }

  Future<OperationResult> openLogFolder() async {
    final result = await _processRunner.launch('explorer', <String>[
      _loggingService.logDirectoryPath,
    ]);
    return result.success
        ? const OperationResult(success: true)
        : OperationResult(success: false, message: result.details);
  }

  Future<OperationResult> redetectSystemState() async {
    try {
      _hardwareProfile = await _hardwareDetectionService.detect();
      final states = await _tweakManager.detectCurrentTweakStates();
      for (final descriptor in _catalog.where((item) => item.isSystemToggle)) {
        _toggleStates[descriptor.id] = states[descriptor.systemKey] ?? false;
      }
      await _initializeScriptStates();
      notifyListeners();
      return const OperationResult(success: true);
    } catch (error) {
      return OperationResult(success: false, message: error.toString());
    }
  }

  Future<OperationResult> resetAppSettings() async {
    try {
      await setStartWithWindows(false);
      await _preferences.clear();
      _processRunner.setMode(ProcessExecutionMode.production);
      _automaticUpdateChecksEnabled = true;
      _startWithWindows = false;
      _expertModeEnabled = false;
      _themeMode = 'system';
      _searchQuery = '';
      _localeCode = AppLocaleService.systemCode();
      _needsRestart = false;
      notifyListeners();
      return const OperationResult(success: true);
    } catch (error) {
      return OperationResult(success: false, message: error.toString());
    }
  }

  Future<OperationResult> exportProfile() async {
    try {
      final values = <String, Object?>{};
      for (final key in _preferences.getKeys()) {
        final value = _preferences.get(key);
        if (value is bool ||
            value is int ||
            value is double ||
            value is String ||
            value is List<String>) {
          values[key] = value;
        }
      }
      final directory = Directory(
        path.join(
          Platform.environment['APPDATA'] ?? Directory.current.path,
          'ZapTweaks',
          'profiles',
        ),
      );
      await directory.create(recursive: true);
      final profile = File(path.join(directory.path, 'ZapTweaks-profile.json'));
      await profile.writeAsString(
        jsonEncode(<String, Object?>{'version': 1, 'preferences': values}),
      );
      return OperationResult(success: true, message: profile.path);
    } catch (error) {
      return OperationResult(success: false, message: error.toString());
    }
  }

  Future<OperationResult> importProfile() async {
    try {
      final profile = File(
        path.join(
          Platform.environment['APPDATA'] ?? Directory.current.path,
          'ZapTweaks',
          'profiles',
          'ZapTweaks-profile.json',
        ),
      );
      final payload = jsonDecode(await profile.readAsString());
      final values = payload is Map<String, dynamic>
          ? payload['preferences']
          : null;
      if (values is! Map<String, dynamic>) {
        return const OperationResult(
          success: false,
          message: 'Invalid profile file.',
        );
      }
      for (final entry in values.entries) {
        final value = entry.value;
        if (value is bool) await _preferences.setBool(entry.key, value);
        if (value is int) await _preferences.setInt(entry.key, value);
        if (value is double) await _preferences.setDouble(entry.key, value);
        if (value is String) await _preferences.setString(entry.key, value);
        if (value is List<dynamic> && value.every((item) => item is String)) {
          await _preferences.setStringList(entry.key, value.cast<String>());
        }
      }
      _restoreExecutionModeFromPreferences();
      _automaticUpdateChecksEnabled =
          _preferences.getBool(_automaticUpdateChecksKey) ?? true;
      _expertModeEnabled = _preferences.getBool(_expertModeKey) ?? false;
      _themeMode = _normalizedThemeMode(_preferences.getString(_themeModeKey));
      _localeCode = AppLocaleService.normalize(
        _preferences.getString(_localeCodeKey),
      );
      final startWithWindows =
          _preferences.getBool(_startWithWindowsKey) ?? false;
      final startResult = await setStartWithWindows(startWithWindows);
      if (!startResult.success) return startResult;
      notifyListeners();
      return const OperationResult(success: true);
    } catch (error) {
      return OperationResult(success: false, message: error.toString());
    }
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

  /// True when the user has opened this collection before. Closed by default.
  bool isCollectionExpanded(String category, String collection) =>
      _expandedCollections.contains(_collectionKey(category, collection));

  /// Remembers an expand/collapse so the layout survives a restart. The
  /// Expander owns its own visual state, so this does not notify listeners.
  Future<void> setCollectionExpanded(
    String category,
    String collection,
    bool expanded,
  ) async {
    final key = _collectionKey(category, collection);
    if (expanded
        ? !_expandedCollections.add(key)
        : !_expandedCollections.remove(key)) {
      return;
    }

    await _preferences.setStringList(
      _expandedCollectionsKey,
      _expandedCollections.toList(growable: false),
    );
  }

  String _collectionKey(String category, String collection) =>
      '$category/$collection';

  void _beginLoadingStep(String step) {
    _loadingStatus = step;
    notifyListeners();
  }

  void _completeLoadingStep(String step) {
    _completedLoadingSteps.add(step);
    notifyListeners();
  }

  /// Marks [step] done when [work] settles and moves the caption to the next
  /// step still running, so parallel work reads as steady progress.
  Future<T> _trackLoadingStep<T>(String step, Future<T> work) async {
    try {
      return await work;
    } finally {
      _completedLoadingSteps.add(step);
      final next = loadingSteps.firstWhere(
        (candidate) => !_completedLoadingSteps.contains(candidate),
        orElse: () => 'Ready',
      );
      _loadingStatus = next;
      notifyListeners();
    }
  }

  void _restoreExpandedCollections() {
    _expandedCollections
      ..clear()
      ..addAll(
        _preferences.getStringList(_expandedCollectionsKey) ?? const <String>[],
      );
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
    final target = source.isEmpty
        ? <double>[nextValue, nextValue]
        : (List<double>.from(source)..add(nextValue));

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
    _metricsSamplingService.dispose();
    super.dispose();
  }
}
