import 'dart:typed_data';

import '../../features/drivers/domain/device_identity.dart';
import 'registry_value_store.dart';

String interruptManagementRegistryPath(PciInterruptCapability capability) {
  final instanceId = capability.device.instanceId.toUpperCase();
  if (!RegExp(
    r'^PCI\\[A-Z0-9_&.-]{1,240}\\[A-Z0-9_&.-]{1,240}$',
  ).hasMatch(instanceId)) {
    throw StateError('The device has no valid PCI instance ID.');
  }
  return 'HKLM\\SYSTEM\\CurrentControlSet\\Enum\\$instanceId\\Device Parameters\\Interrupt Management';
}

class DeviceInterruptConfiguration {
  const DeviceInterruptConfiguration({
    required this.msiSupported,
    required this.messageNumberLimit,
    required this.devicePriority,
    required this.devicePolicy,
    required this.assignmentMaskHex,
  });

  final int? msiSupported;
  final int? messageNumberLimit;
  final int? devicePriority;
  final int? devicePolicy;
  final String? assignmentMaskHex;
}

class InterruptConfigurationService {
  const InterruptConfigurationService(this.registry);

  final RegistryValueStore registry;

  Future<DeviceInterruptConfiguration> read(
    PciInterruptCapability capability,
  ) async {
    final root = _root(capability);
    final message = '$root\\MessageSignaledInterruptProperties';
    final affinity = '$root\\Affinity Policy';
    return DeviceInterruptConfiguration(
      msiSupported: await _dword(message, 'MSISupported'),
      messageNumberLimit: await _dword(message, 'MessageNumberLimit'),
      devicePriority: await _dword(affinity, 'DevicePriority'),
      devicePolicy: await _dword(affinity, 'DevicePolicy'),
      assignmentMaskHex: _mask(
        await registry.read(affinity, 'AssignmentSetOverride'),
      ),
    );
  }

  String _root(PciInterruptCapability capability) =>
      interruptManagementRegistryPath(capability);

  Future<int?> _dword(String path, String name) async {
    final raw = await registry.read(path, name);
    if (raw == null) return null;
    if (raw.type != 4 || raw.bytes.length != 4) {
      throw StateError('$name has an unexpected registry type.');
    }
    return ByteData.sublistView(raw.bytes).getUint32(0, Endian.little);
  }

  static String? _mask(RawRegistryValue? value) {
    if (value == null) return null;
    if (value.type != 3 || value.bytes.isEmpty || value.bytes.length > 8) {
      throw StateError(
        'AssignmentSetOverride has an unexpected registry type.',
      );
    }
    var result = BigInt.zero;
    for (var index = value.bytes.length - 1; index >= 0; index--) {
      result = (result << 8) | BigInt.from(value.bytes[index]);
    }
    return result.toRadixString(16);
  }
}
