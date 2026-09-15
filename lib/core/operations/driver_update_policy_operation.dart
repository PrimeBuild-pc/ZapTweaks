import 'dart:typed_data';

import '../../features/drivers/application/driver_update_policy_store.dart';
import '../../platform/windows/registry_value_store.dart';
import 'operation.dart';

class DriverUpdatePolicyOperation implements OperationDefinition {
  DriverUpdatePolicyOperation({
    required this.registry,
    required this.policyStore,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  static const path = r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate';
  static const valueName = 'ExcludeWUDriversInQualityUpdate';
  static const regDword = 4;

  final RegistryValueStore registry;
  final DriverUpdatePolicyStore policyStore;
  final DateTime Function() now;

  Future<DateTime?> _validate(OperationRequest request) async {
    if (request.target != null ||
        (request.desiredValue != null &&
            request.desiredValue != 0 &&
            request.desiredValue != 1)) {
      throw StateError('Invalid driver update policy request.');
    }
    if (request.desiredValue == 1) {
      if (request.parameters.length != 1 ||
          request.parameters['expiresAt'] is! String) {
        throw StateError('A policy expiration is required.');
      }
      final expiry = DateTime.parse(
        request.parameters['expiresAt']! as String,
      ).toUtc();
      final duration = expiry.difference(now().toUtc());
      if (duration < const Duration(hours: 1) ||
          duration > const Duration(days: 31)) {
        throw StateError('Policy expiration must be within 31 days.');
      }
      return expiry;
    }
    if (request.parameters.isNotEmpty) {
      throw StateError('Resume requests cannot contain parameters.');
    }
    final record = await policyStore.read();
    if (record == null || record.previousValue != request.desiredValue) {
      throw StateError('No matching temporary policy can be restored.');
    }
    return null;
  }

  Future<RawRegistryValue?> _raw() => registry.read(path, valueName);

  static int? _dword(RawRegistryValue? value) {
    if (value == null) return null;
    if (value.type != regDword || value.bytes.length != 4) {
      throw StateError('The existing driver policy is not a DWORD.');
    }
    final result = ByteData.sublistView(
      value.bytes,
    ).getUint32(0, Endian.little);
    if (result != 0 && result != 1) {
      throw StateError('The existing driver policy has an unsupported value.');
    }
    return result;
  }

  static RawRegistryValue _value(int value) {
    final bytes = Uint8List(4);
    ByteData.sublistView(bytes).setUint32(0, value, Endian.little);
    return RawRegistryValue(type: regDword, bytes: bytes);
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.architecture != 'x64' || context.windowsBuild < 22000) {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      await _validate(request);
      final current = _dword(await _raw());
      if (request.desiredValue == 1 &&
          (current == 1 || await policyStore.read() != null)) {
        return const SupportResult.unsupported(
          'Driver updates are already excluded or a pause is already tracked.',
        );
      }
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final value = _dword(await _raw());
      return value == null
          ? const OperationState(OperationStateKind.absent)
          : OperationState(OperationStateKind.configured, value: value);
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    await _validate(request);
    final raw = await _raw();
    final marker = await policyStore.read();
    return OperationSnapshot(
      type: 'temporaryDriverUpdatePolicy',
      data: <String, Object?>{
        'existed': raw != null,
        if (raw != null) 'registryType': raw.type,
        if (raw != null) 'bytes': raw.bytes,
        if (marker != null) 'marker': marker.toJson(),
      },
      expectedAfterRollback: raw == null
          ? const OperationState(OperationStateKind.absent)
          : OperationState(OperationStateKind.configured, value: _dword(raw)),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final expiry = await _validate(request);
    if (request.desiredValue == 1) {
      final previous = _dword(await _raw());
      await registry.write(path, valueName, _value(1));
      await policyStore.write(
        DriverUpdatePolicyRecord(expiresAt: expiry!, previousValue: previous),
      );
      return;
    }
    final desired = request.desiredValue as int?;
    if (desired == null) {
      await registry.delete(path, valueName);
    } else {
      await registry.write(path, valueName, _value(desired));
    }
    await policyStore.clear();
  }

  @override
  Future<OperationState> verify(OperationRequest request) async {
    final state = await inspect(request);
    if (request.desiredValue == 1) {
      final record = await policyStore.read();
      if (record == null || record.isExpired(now().toUtc())) {
        return const OperationState(
          OperationStateKind.drifted,
          message: 'The temporary driver policy marker is missing or expired.',
        );
      }
    }
    return state;
  }

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'temporaryDriverUpdatePolicy') {
      throw StateError('Invalid driver policy snapshot.');
    }
    if (snapshot.data['existed'] == true) {
      final type = snapshot.data['registryType'];
      final bytes = snapshot.data['bytes'];
      if (type is! int || bytes is! Uint8List) {
        throw StateError('Invalid driver policy registry snapshot.');
      }
      await registry.write(
        path,
        valueName,
        RawRegistryValue(type: type, bytes: bytes),
      );
    } else {
      await registry.delete(path, valueName);
    }
    final marker = snapshot.data['marker'];
    if (marker is Map) {
      await policyStore.write(
        DriverUpdatePolicyRecord.fromJson(Map<String, dynamic>.from(marker)),
      );
    } else {
      await policyStore.clear();
    }
  }

  @override
  String get id => 'toggle_automatic_driver_updates_off';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[
    'refresh_updates_drivers_block',
  ];
  @override
  String get titleKey => 'temporaryDriverUpdatesPause';
  @override
  String get descriptionKey => 'temporaryDriverUpdatesPauseDescription';
  @override
  String get domain => 'drivers';
  @override
  String get destination => 'Drivers';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.unverified;
  @override
  String? get evidenceBinaryVersion => null;
  @override
  String? get evidenceSha256 => null;
  @override
  List<String> get supportedEditions => const <String>['Home', 'Pro'];
  @override
  List<String> get supportedArchitectures => const <String>['x64'];
  @override
  List<String> get technicalSources => const <String>[
    'https://learn.microsoft.com/windows/deployment/update/waas-wu-settings',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
