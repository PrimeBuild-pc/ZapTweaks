import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/drivers/application/device_driver_correlator.dart';
import 'package:script_utility/features/drivers/domain/device_driver_binding.dart';
import 'package:script_utility/features/drivers/domain/device_identity.dart';
import 'package:script_utility/features/drivers/domain/driver_package.dart';

void main() {
  const package = DriverPackage(
    publishedName: 'oem42.inf',
    infName: 'vendor.inf',
    version: '1.2.3',
    publisher: 'Vendor',
    hardwareIds: <String>{r'PCI\VEN_1234&DEV_5678'},
    signed: true,
  );

  test('device correlation prefers the bound published INF', () {
    const device = DeviceIdentity(
      instanceId: r'PCI\VEN_1234&DEV_5678\ONE',
      classGuid: 'guid',
      description: 'Device',
      hardwareIds: <String>{r'PCI\VEN_DEAD&DEV_BEEF'},
      driverKey: 'key',
      driverInf: 'OEM42.INF',
    );

    final binding = const DeviceDriverCorrelator()
        .correlate(<DeviceIdentity>[device], <DriverPackage>[package])
        .single;

    expect(binding.package, package);
    expect(binding.match, DriverBindingMatch.boundInf);
  });

  test('device correlation uses a unique hardware match as fallback', () {
    const device = DeviceIdentity(
      instanceId: r'PCI\VEN_1234&DEV_5678\ONE',
      classGuid: 'guid',
      description: 'Device',
      hardwareIds: <String>{r'PCI\VEN_1234&DEV_5678'},
      driverKey: null,
      driverInf: null,
    );

    final binding = const DeviceDriverCorrelator()
        .correlate(<DeviceIdentity>[device], <DriverPackage>[package])
        .single;

    expect(binding.package, package);
    expect(binding.match, DriverBindingMatch.hardwareId);
  });
}
