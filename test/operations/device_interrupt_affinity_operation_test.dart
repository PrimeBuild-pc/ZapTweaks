import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/device_interrupt_affinity_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/features/drivers/domain/device_identity.dart';
import 'package:script_utility/platform/windows/processor_topology.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

class _Registry implements RegistryValueStore {
  final values = <String, RawRegistryValue>{};
  String _key(String path, String name) => '$path/$name';
  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => values.remove(_key(path, name));
  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => values[_key(path, name)];
  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) async => values[_key(path, name)] = RawRegistryValue(
    type: value.type,
    bytes: Uint8List.fromList(value.bytes),
  );
}

const _device = PciInterruptCapability(
  device: DeviceIdentity(
    instanceId: r'PCI\VEN_1234&DEV_ABCD\ONE',
    classGuid: '4d36e972-e325-11ce-bfc1-08002be10318',
    description: 'Network adapter',
    hardwareIds: <String>{r'PCI\VEN_1234&DEV_ABCD'},
    driverKey: r'{4d36e972-e325-11ce-bfc1-08002be10318}\0001',
    driverInf: 'oem1.inf',
  ),
  lineBased: true,
  msi: true,
  msiX: true,
  messageMaximum: 8,
);

void main() {
  test('interrupt affinity snapshots an exact untruncated mask', () async {
    final registry = _Registry();
    final operation = DeviceInterruptAffinityOperation(
      registry: registry,
      inventory: () => const <PciInterruptCapability>[_device],
      topology: () =>
          const ProcessorTopology(processorsPerGroup: <int, int>{0: 8}),
    );
    const request = OperationRequest(
      operationId: 'device.interrupt_affinity.configure',
      target: r'PCI\VEN_1234&DEV_ABCD\ONE',
      desiredValue: <String, Object?>{
        'devicePolicy': 4,
        'processorGroup': 0,
        'maskHex': '81',
      },
    );
    final snapshot = await operation.captureSnapshot(request);
    await operation.apply(request);
    expect(
      registry.values.keys,
      everyElement(contains(r'HKLM\SYSTEM\CurrentControlSet\Enum\PCI\')),
    );
    expect((await operation.verify(request)).value, request.desiredValue);
    await operation.rollback(request, snapshot);
    expect(
      (await operation.inspect(
        request,
      )).sameValue(snapshot.expectedAfterRollback),
      isTrue,
    );
  });

  test('reads variable-width masks written by existing tools', () async {
    final registry = _Registry();
    const path =
        r'HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_1234&DEV_ABCD\ONE\Device Parameters\Interrupt Management\Affinity Policy';
    registry.values['$path/DevicePolicy'] = RawRegistryValue(
      type: 4,
      bytes: Uint8List.fromList(<int>[4, 0, 0, 0]),
    );
    registry.values['$path/AssignmentSetOverride'] = RawRegistryValue(
      type: 3,
      bytes: Uint8List.fromList(<int>[0x81]),
    );
    final operation = DeviceInterruptAffinityOperation(
      registry: registry,
      inventory: () => const <PciInterruptCapability>[_device],
      topology: () =>
          const ProcessorTopology(processorsPerGroup: <int, int>{0: 8}),
    );
    const request = OperationRequest(
      operationId: 'device.interrupt_affinity.configure',
      target: r'PCI\VEN_1234&DEV_ABCD\ONE',
      desiredValue: <String, Object?>{
        'devicePolicy': 4,
        'processorGroup': 0,
        'maskHex': '81',
      },
    );

    expect((await operation.inspect(request)).value, request.desiredValue);
  });

  test('documented automatic affinity policies clear explicit masks', () async {
    final registry = _Registry();
    final operation = DeviceInterruptAffinityOperation(
      registry: registry,
      inventory: () => const <PciInterruptCapability>[_device],
      topology: () =>
          const ProcessorTopology(processorsPerGroup: <int, int>{0: 8}),
    );
    const specified = OperationRequest(
      operationId: 'device.interrupt_affinity.configure',
      target: r'PCI\VEN_1234&DEV_ABCD\ONE',
      desiredValue: <String, Object?>{
        'devicePolicy': 4,
        'processorGroup': 0,
        'maskHex': '3',
      },
    );
    await operation.apply(specified);
    const automatic = OperationRequest(
      operationId: 'device.interrupt_affinity.configure',
      target: r'PCI\VEN_1234&DEV_ABCD\ONE',
      desiredValue: <String, Object?>{'devicePolicy': 5},
    );

    expect(
      (await operation.supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        automatic,
      )).supported,
      isTrue,
    );
    await operation.apply(automatic);
    final state = Map<String, Object?>.from(
      (await operation.inspect(automatic)).value! as Map,
    );
    expect(state['devicePolicy'], 5);
    expect(state['maskHex'], isNull);
  });

  test(
    'interrupt affinity rejects masks outside the processor group',
    () async {
      final operation = DeviceInterruptAffinityOperation(
        registry: _Registry(),
        inventory: () => const <PciInterruptCapability>[_device],
        topology: () =>
            const ProcessorTopology(processorsPerGroup: <int, int>{0: 4}),
      );
      const request = OperationRequest(
        operationId: 'device.interrupt_affinity.configure',
        target: r'PCI\VEN_1234&DEV_ABCD\ONE',
        desiredValue: <String, Object?>{
          'devicePolicy': 4,
          'processorGroup': 0,
          'maskHex': '10',
        },
      );
      expect(
        (await operation.supports(
          const OperationContext(windowsBuild: 26100, edition: 'Pro'),
          request,
        )).supported,
        isFalse,
      );
    },
  );
}
