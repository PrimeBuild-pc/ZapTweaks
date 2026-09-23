import 'dart:typed_data';

import '../../features/drivers/domain/device_identity.dart';
import '../../platform/windows/hardware_capability_validators.dart';
import '../../platform/windows/processor_topology.dart';
import '../../platform/windows/registry_value_store.dart';
import 'device_msi_operation.dart';
import 'operation.dart';

class DeviceInterruptAffinityOperation implements OperationDefinition {
  const DeviceInterruptAffinityOperation({
    required this.registry,
    required this.inventory,
    required this.topology,
  });

  final RegistryValueStore registry;
  final InterruptCapabilityInventory inventory;
  final ProcessorTopology Function() topology;
  static const _classes = <String>{
    '4d36e968-e325-11ce-bfc1-08002be10318',
    '4d36e972-e325-11ce-bfc1-08002be10318',
    '4d36e96c-e325-11ce-bfc1-08002be10318',
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

  String _path(PciInterruptCapability capability) {
    final key = capability.device.driverKey;
    if (key == null ||
        !RegExp(r'^\{[0-9a-fA-F-]{36}\}\\[0-9]{4}$').hasMatch(key)) {
      throw StateError('The device has no stable driver registry key.');
    }
    return 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\$key\\Interrupt Management\\Affinity Policy';
  }

  ({int policy, int? group, BigInt? mask}) _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value is! Map || value['devicePolicy'] is! int) {
      throw StateError('A typed interrupt affinity policy is required.');
    }
    final policy = value['devicePolicy']! as int;
    if (policy < 0 || policy > 5) {
      throw StateError('Interrupt policy must be between 0 and 5.');
    }
    if (policy != 4) {
      if (value.length != 1) {
        throw StateError(
          'Only the specified-processors policy accepts a mask.',
        );
      }
      return (policy: policy, group: null, mask: null);
    }
    if (value.length != 3 ||
        value['processorGroup'] is! int ||
        value['maskHex'] is! String) {
      throw StateError('Specified processors require a group and mask.');
    }
    final group = value['processorGroup']! as int;
    if (group != 0) {
      throw StateError(
        'Only explicit group-0 affinity is safely representable.',
      );
    }
    final mask = BigInt.tryParse(value['maskHex']! as String, radix: 16);
    if (mask == null || value['maskHex'] != mask.toRadixString(16)) {
      throw StateError(
        'Affinity mask must be canonical lowercase hexadecimal.',
      );
    }
    final error = HardwareCapabilityValidators.validateAffinity(
      processorGroup: group,
      mask: mask,
      logicalProcessorsPerGroup: topology().processorsPerGroup,
    );
    if (error != null || mask.bitLength > 64) {
      throw StateError(error ?? 'Affinity mask exceeds 64 bits.');
    }
    return (policy: policy, group: group, mask: mask);
  }

  Future<RawRegistryValue?> _read(String path, String name) =>
      registry.read(path, name);

  static Map<String, Object?>? _raw(RawRegistryValue? value) => value == null
      ? null
      : <String, Object?>{'type': value.type, 'bytes': value.bytes};

  static String? _mask(RawRegistryValue? value) {
    if (value == null) return null;
    if (value.type != 3 || value.bytes.length != 8) {
      throw StateError('AssignmentSetOverride has an unexpected type or size.');
    }
    var result = BigInt.zero;
    for (var index = 7; index >= 0; index--) {
      result = (result << 8) | BigInt.from(value.bytes[index]);
    }
    return result.toRadixString(16);
  }

  static int? _policy(RawRegistryValue? value) {
    if (value == null) return null;
    if (value.type != 4 || value.bytes.length != 4) {
      throw StateError('DevicePolicy has an unexpected type or size.');
    }
    return ByteData.sublistView(value.bytes).getUint32(0, Endian.little);
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
          'Only display, network, and media devices are supported.',
        );
      }
      _path(device);
      _desired(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final path = _path(_device(request));
      final desired = _desired(request);
      return OperationState(
        OperationStateKind.configured,
        value: <String, Object?>{
          'devicePolicy': _policy(await _read(path, 'DevicePolicy')),
          if (desired.policy == 4) 'processorGroup': 0,
          if (desired.policy == 4)
            'maskHex': _mask(await _read(path, 'AssignmentSetOverride')),
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
    final policy = await _read(path, 'DevicePolicy');
    final mask = await _read(path, 'AssignmentSetOverride');
    return OperationSnapshot(
      type: 'deviceInterruptAffinity',
      data: <String, Object?>{
        'path': path,
        'policy': _raw(policy),
        'mask': _raw(mask),
      },
      expectedAfterRollback: await inspect(request),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final desired = _desired(request);
    final path = _path(_device(request));
    final policyBytes = Uint8List(4);
    ByteData.sublistView(
      policyBytes,
    ).setUint32(0, desired.policy, Endian.little);
    await registry.write(
      path,
      'DevicePolicy',
      RawRegistryValue(type: 4, bytes: policyBytes),
    );
    if (desired.mask == null) {
      await registry.delete(path, 'AssignmentSetOverride');
    } else {
      final maskBytes = Uint8List(8);
      var mask = desired.mask!;
      for (var index = 0; index < 8; index++) {
        maskBytes[index] = (mask & BigInt.from(0xff)).toInt();
        mask >>= 8;
      }
      await registry.write(
        path,
        'AssignmentSetOverride',
        RawRegistryValue(type: 3, bytes: maskBytes),
      );
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
    if (snapshot.type != 'deviceInterruptAffinity' ||
        snapshot.data['path'] != path) {
      throw StateError('Invalid interrupt affinity snapshot.');
    }
    await _restore(path, 'DevicePolicy', snapshot.data['policy']);
    await _restore(path, 'AssignmentSetOverride', snapshot.data['mask']);
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
  String get id => 'device.interrupt_affinity.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'deviceInterruptAffinityTitle';
  @override
  String get descriptionKey => 'deviceInterruptAffinityDescription';
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
    'https://learn.microsoft.com/windows-hardware/drivers/kernel/interrupt-affinity-and-priority',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
