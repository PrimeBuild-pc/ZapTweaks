import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/device_msi_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/features/drivers/domain/device_identity.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

class _Registry implements RegistryValueStore {
  final values = <String, RawRegistryValue>{};
  String key(String path, String name) => '$path/$name';

  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {
    values.remove(key(path, name));
  }

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => values[key(path, name)];

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) async {
    values[key(path, name)] = RawRegistryValue(
      type: value.type,
      bytes: Uint8List.fromList(value.bytes),
    );
  }
}

PciInterruptCapability _capability({
  int maximum = 8,
  String classGuid = '4d36e972-e325-11ce-bfc1-08002be10318',
  Set<String> hardwareIds = const <String>{r'PCI\VEN_1234&DEV_ABCD'},
}) => PciInterruptCapability(
  device: DeviceIdentity(
    instanceId: r'PCI\VEN_1234&DEV_ABCD\ONE',
    classGuid: classGuid,
    description: 'Network adapter',
    hardwareIds: hardwareIds,
    driverKey: r'{4d36e972-e325-11ce-bfc1-08002be10318}\0001',
    driverInf: 'oem1.inf',
  ),
  lineBased: true,
  msi: true,
  msiX: true,
  messageMaximum: maximum,
);

void main() {
  test('MSI operation enforces hardware limit and exact rollback', () async {
    final registry = _Registry();
    final operation = DeviceMsiOperation(
      registry: registry,
      inventory: () => <PciInterruptCapability>[_capability()],
    );
    const request = OperationRequest(
      operationId: 'device.msi.configure',
      target: r'PCI\VEN_1234&DEV_ABCD\ONE',
      desiredValue: <String, Object?>{
        'msiSupported': 1,
        'messageNumberLimit': 4,
        'devicePriority': 3,
      },
    );

    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      request,
    );
    expect(support.supported, isTrue);
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

  test('undefined priority removes the override', () async {
    final registry = _Registry();
    final operation = DeviceMsiOperation(
      registry: registry,
      inventory: () => <PciInterruptCapability>[_capability()],
    );
    const request = OperationRequest(
      operationId: 'device.msi.configure',
      target: r'PCI\VEN_1234&DEV_ABCD\ONE',
      desiredValue: <String, Object?>{
        'msiSupported': 1,
        'messageNumberLimit': 1,
        'devicePriority': null,
      },
    );
    await operation.apply(request);
    expect((await operation.verify(request)).value, request.desiredValue);
  });

  test('USB host and PCI HD-audio controllers are allowlisted', () {
    expect(
      isAllowedInterruptDevice(
        _capability(classGuid: '36fc9e60-c465-11cf-8056-444553540000'),
      ),
      isTrue,
    );
    expect(
      isAllowedInterruptDevice(
        _capability(
          classGuid: '4d36e97d-e325-11ce-bfc1-08002be10318',
          hardwareIds: const <String>{r'PCI\VEN_1234&DEV_ABCD&CC_040300'},
        ),
      ),
      isTrue,
    );
  });

  test('MSI operation rejects a message count above PCI capability', () async {
    final operation = DeviceMsiOperation(
      registry: _Registry(),
      inventory: () => <PciInterruptCapability>[_capability(maximum: 2)],
    );
    const request = OperationRequest(
      operationId: 'device.msi.configure',
      target: r'PCI\VEN_1234&DEV_ABCD\ONE',
      desiredValue: <String, Object?>{
        'msiSupported': 1,
        'messageNumberLimit': 4,
      },
    );
    expect(
      (await operation.supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request,
      )).supported,
      isFalse,
    );
  });
}
