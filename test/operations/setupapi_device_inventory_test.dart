import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/drivers/application/setupapi_device_inventory_service.dart';

void main() {
  test('SetupAPI returns stable identities for present devices', () {
    if (!Platform.isWindows) return;

    final devices = const SetupApiDeviceInventoryService().scanPresent();

    expect(devices, isNotEmpty);
    expect(
      devices.map((device) => device.instanceId).toSet(),
      hasLength(devices.length),
    );
    expect(devices.every((device) => device.classGuid.isNotEmpty), isTrue);
    expect(devices.any((device) => device.driverInf != null), isTrue);
    expect(
      devices
          .expand((device) => device.hardwareIds)
          .every((id) => id == id.toUpperCase()),
      isTrue,
    );
  });

  test('SetupAPI exposes documented PCI interrupt limits', () {
    final capabilities = const SetupApiDeviceInventoryService()
        .scanPciInterruptCapabilities();

    expect(capabilities, isNotEmpty);
    expect(
      capabilities.every(
        (item) =>
            item.messageMaximum >= 0 &&
            (item.lineBased || item.msi || item.msiX),
      ),
      isTrue,
    );
  });
}
