import 'dart:convert';
import 'dart:io';

import 'package:script_utility/core/operations/device_msi_operation.dart';
import 'package:script_utility/features/drivers/application/setupapi_device_inventory_service.dart';
import 'package:script_utility/platform/windows/interrupt_configuration_service.dart';
import 'package:script_utility/platform/windows/processor_topology.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

Future<void> main() async {
  if (!Platform.isWindows) throw UnsupportedError('Windows only.');
  final capabilities = const SetupApiDeviceInventoryService()
      .scanPciInterruptCapabilities();
  final configurations = InterruptConfigurationService(
    WindowsRegistryValueStore(),
  );
  final devices = <Map<String, Object?>>[];
  for (final capability in capabilities) {
    final configuration = await configurations.read(capability);
    devices.add(<String, Object?>{
      'description': capability.device.description,
      'instanceId': capability.device.instanceId,
      'classGuid': capability.device.classGuid,
      'driverInf': capability.device.driverInf,
      'hardwareIds': capability.device.hardwareIds.toList()..sort(),
      'appAllowlisted': isAllowedInterruptDevice(capability),
      'capabilities': <String, Object?>{
        'lineBased': capability.lineBased,
        'msi': capability.msi,
        'msiX': capability.msiX,
        'messageMaximum': capability.messageMaximum,
      },
      'configuration': <String, Object?>{
        'msiSupported': configuration.msiSupported,
        'messageNumberLimit': configuration.messageNumberLimit,
        'devicePriority': configuration.devicePriority,
        'devicePolicy': configuration.devicePolicy,
        'assignmentMaskHex': configuration.assignmentMaskHex,
      },
    });
  }
  final topology = ProcessorTopology.inspect();
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'readOnly': true,
      'processorTopology': <String, Object?>{
        'logicalProcessors': topology.logicalProcessorCount,
        'groups': topology.processorsPerGroup.map(
          (group, count) => MapEntry(group.toString(), count),
        ),
        'numaNodes': topology.addresses
            .map((item) => item.numaNode)
            .toSet()
            .length,
      },
      'devices': devices,
    }),
  );
}
