import 'package:shared_preferences/shared_preferences.dart';

import '../models/safety_gate_result.dart';
import 'permission_service.dart';
import 'restore_point_service.dart';

class SafetyGateService {
  SafetyGateService({
    required PermissionService permissionService,
    required RestorePointService restorePointService,
    required SharedPreferences preferences,
  }) : _permissionService = permissionService,
       _restorePointService = restorePointService,
       _preferences = preferences;

  final PermissionService _permissionService;
  final RestorePointService _restorePointService;
  final SharedPreferences _preferences;

  static const String _lastRestorePointAt = 'lastRestorePointAt';

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

    if (_hasRecentRestorePoint()) {
      return const SafetyGateResult(status: SafetyGateStatus.proceed);
    }

    final confirmed = await askUserToCreateRestorePoint();
    if (!confirmed) {
      return const SafetyGateResult(
        status: SafetyGateStatus.cancelled,
        message: 'Operation cancelled by user.',
      );
    }

    final result = await _restorePointService.createRestorePoint(
      description: 'ZapTweaks_PreChange',
    );

    if (!result.success) {
      return SafetyGateResult(
        status: SafetyGateStatus.restorePointFailed,
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
