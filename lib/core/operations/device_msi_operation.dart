import 'dart:typed_data';

import '../../features/drivers/domain/device_identity.dart';
import '../../platform/windows/hardware_capability_validators.dart';
import '../../platform/windows/registry_value_store.dart';
import 'operation.dart';

typedef InterruptCapabilityInventory = List<PciInterruptCapability> Function();

class DeviceMsiOperation implements OperationDefinition {
  const DeviceMsiOperation({required this.registry, required this.inventory});

  final RegistryValueStore registry;
  final InterruptCapabilityInventory inventory;
  static const _classes = <String>{
    '4d36e968-e325-11ce-bfc1-08002be10318', // Display
    '4d36e972-e325-11ce-bfc1-08002be10318', // Net
    '4d36e96c-e325-11ce-bfc1-08002be10318', // Media
  };

  PciInterruptCapability _device(OperationRequest request) {
    final target = request.target?.toUpperCase();
    if (target == null ||
        target.length > 512 ||
        target.runes.any((r) => r < 32)) {
      throw StateError('Invalid device instance ID.');
    }
    return inventory().singleWhere(
      (item) => item.device.instanceId.toUpperCase() == target,
      orElse: () => throw StateError('The PCI device is not present.'),
    );
  }

  ({int enabled, int? limit}) _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value is! Map || value['msiSupported'] is! int) {
      throw StateError('A typed MSI configuration is required.');
    }
    final enabled = value['msiSupported']! as int;
    final limit = value['messageNumberLimit'];
    if ((enabled != 0 && enabled != 1) || (limit != null && limit is! int)) {
      throw StateError('Invalid MSI configuration.');
    }
    return (enabled: enabled, limit: limit as int?);
  }

  String _path(PciInterruptCapability capability) {
    final key = capability.device.driverKey;
    if (key == null ||
        !RegExp(r'^\{[0-9a-fA-F-]{36}\}\\[0-9]{4}$').hasMatch(key)) {
      throw StateError('The device has no stable driver registry key.');
    }
    return 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\$key\\Interrupt Management\\MessageSignaledInterruptProperties';
  }

  Future<int?> _readDword(String path, String name) async {
    final raw = await registry.read(path, name);
    if (raw == null) return null;
    if (raw.type != 4 || raw.bytes.length != 4) {
      throw StateError('$name has an unexpected Registry type.');
    }
    return ByteData.sublistView(raw.bytes).getUint32(0, Endian.little);
  }

  static RawRegistryValue _dword(int value) {
    final bytes = Uint8List(4);
    ByteData.sublistView(bytes).setUint32(0, value, Endian.little);
    return RawRegistryValue(type: 4, bytes: bytes);
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      final device = _device(request);
      if (!_classes.contains(
        device.device.classGuid.replaceAll(RegExp(r'[{}]'), ''),
      )) {
        return const SupportResult.unsupported(
          'Only present display, network, and media devices are supported.',
        );
      }
      final desired = _desired(request);
      if (desired.enabled == 1) {
        final error = HardwareCapabilityValidators.validateMsiMessageCount(
          msiSupported: device.msi || device.msiX,
          requested: desired.limit ?? 1,
          hardwareMaximum: device.messageMaximum,
        );
        if (error != null) return SupportResult.unsupported(error);
      } else if (desired.limit != null) {
        return const SupportResult.unsupported(
          'MessageNumberLimit must be absent when MSI is disabled.',
        );
      }
      _path(device);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final path = _path(_device(request));
      return OperationState(
        OperationStateKind.configured,
        value: <String, Object?>{
          'msiSupported': await _readDword(path, 'MSISupported'),
          'messageNumberLimit': await _readDword(path, 'MessageNumberLimit'),
        },
      );
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    _desired(request);
    final path = _path(_device(request));
    final enabled = await registry.read(path, 'MSISupported');
    final limit = await registry.read(path, 'MessageNumberLimit');
    final before = await inspect(request);
    return OperationSnapshot(
      type: 'deviceMsi',
      data: <String, Object?>{
        'path': path,
        'enabled': _rawJson(enabled),
        'limit': _rawJson(limit),
      },
      expectedAfterRollback: before,
    );
  }

  static Map<String, Object?>? _rawJson(RawRegistryValue? value) =>
      value == null
      ? null
      : <String, Object?>{'type': value.type, 'bytes': value.bytes};

  @override
  Future<void> apply(OperationRequest request) async {
    final desired = _desired(request);
    final path = _path(_device(request));
    await registry.write(path, 'MSISupported', _dword(desired.enabled));
    if (desired.limit == null) {
      await registry.delete(path, 'MessageNumberLimit');
    } else {
      await registry.write(path, 'MessageNumberLimit', _dword(desired.limit!));
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final path = _path(_device(request));
    if (snapshot.type != 'deviceMsi' || snapshot.data['path'] != path) {
      throw StateError('Invalid MSI snapshot.');
    }
    await _restore(path, 'MSISupported', snapshot.data['enabled']);
    await _restore(path, 'MessageNumberLimit', snapshot.data['limit']);
  }

  Future<void> _restore(String path, String name, Object? data) async {
    if (data == null) return registry.delete(path, name);
    final value = Map<String, Object?>.from(data as Map);
    await registry.write(
      path,
      name,
      RawRegistryValue(
        type: value['type']! as int,
        bytes: value['bytes']! as Uint8List,
      ),
    );
  }

  @override
  String get id => 'device.msi.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'deviceMsiTitle';
  @override
  String get descriptionKey => 'deviceMsiDescription';
  @override
  String get domain => 'drivers';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.device;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.reboot;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.runtimeObserved;
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
    'https://learn.microsoft.com/windows-hardware/drivers/kernel/enabling-message-signaled-interrupts-in-the-registry',
    'https://learn.microsoft.com/windows-hardware/drivers/install/devpkey-pcidevice-interruptsupport',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
