import 'package:shared_preferences/shared_preferences.dart';

import '../models/restore_point_result.dart';
import '../models/safety_gate_result.dart';
import 'logging_service.dart';
import 'permission_service.dart';
import 'restore_point_service.dart';

class SafetyGateService {
  SafetyGateService({
    required PermissionService permissionService,
    required RestorePointService restorePointService,
    required SharedPreferences preferences,
    LoggingService? loggingService,
  }) : _permissionService = permissionService,
       _restorePointService = restorePointService,
       _preferences = preferences,
       _loggingService = loggingService ?? LoggingService.instance;

  final PermissionService _permissionService;
  final RestorePointService _restorePointService;
  final SharedPreferences _preferences;
  final LoggingService _loggingService;

  static const String _lastRestorePointAt = 'lastRestorePointAt';

  /// The one restore-point question of this app run. Concurrent callers await
  /// the same future, so nothing starts changing the system behind an open
  /// dialog or a checkpoint still being written. The prompt is always
  /// skippable, so declining it never blocks the requested operation.
  Future<SafetyGateResult>? _sessionPrompt;

  Future<SafetyGateResult> ensureSafety({
    required bool requireRestorePoint,
    required Future<bool> Function() askUserToCreateRestorePoint,
  }) async {
    final isAdmin = await _permissionService.isRunningElevated();
    if (!isAdmin) {
      return const SafetyGateResult(
        status: SafetyGateStatus.blockedMissingAdmin,
        message: 'Administrator privileges are required.',
      );
    }

    if (!requireRestorePoint) {
      return const SafetyGateResult(status: SafetyGateStatus.proceed);
    }

    if (_sessionPrompt != null) {
      return _sessionPrompt!;
    }

    if (_hasRecentRestorePoint()) {
      return const SafetyGateResult(status: SafetyGateStatus.proceed);
    }

    return _sessionPrompt = _promptAndCreateRestorePoint(
      askUserToCreateRestorePoint,
    );
  }

  /// Offers the restore point and, when accepted, writes it.
  ///
  /// Every branch returns [SafetyGateStatus.proceed]: the offer is a
  /// convenience, never a gate. Declining it, dismissing the dialog, a
  /// checkpoint Windows refuses to write, and an outright failure of either
  /// step all let the requested action run.
  Future<SafetyGateResult> _promptAndCreateRestorePoint(
    Future<bool> Function() askUserToCreateRestorePoint,
  ) async {
    final bool confirmed;
    try {
      confirmed = await askUserToCreateRestorePoint();
    } catch (error) {
      await _loggingService.logWarning(
        'Restore point prompt failed: $error',
        source: 'SafetyGateService',
      );
      return const SafetyGateResult(status: SafetyGateStatus.proceed);
    }

    if (!confirmed) {
      return const SafetyGateResult(status: SafetyGateStatus.proceed);
    }

    final RestorePointResult result;
    try {
      result = await _restorePointService.createRestorePoint(
        description: 'ZapTweaks_PreChange',
      );
    } catch (error) {
      await _loggingService.logWarning(
        'Restore point creation threw: $error',
        source: 'SafetyGateService',
      );
      return SafetyGateResult(
        status: SafetyGateStatus.proceed,
        message: error.toString(),
      );
    }

    if (!result.success) {
      // A failed checkpoint (System Protection off, or Windows' once-per-24h
      // limit) must not block the action the user asked for.
      await _loggingService.logWarning(
        'Restore point creation failed: ${result.message ?? 'unknown error'}',
        source: 'SafetyGateService',
      );
      return SafetyGateResult(
        status: SafetyGateStatus.proceed,
        message: result.message ?? 'Failed to create a restore point.',
      );
    }

    await _preferences.setString(
      _lastRestorePointAt,
      DateTime.now().toUtc().toIso8601String(),
    );

    return const SafetyGateResult(status: SafetyGateStatus.proceed);
  }

  bool _hasRecentRestorePoint() {
    final raw = _preferences.getString(_lastRestorePointAt);
    if (raw == null || raw.isEmpty) {
      return false;
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return false;
    }

    return DateTime.now().toUtc().difference(parsed).inHours < 24;
  }
}
