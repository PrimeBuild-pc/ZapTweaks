import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/features/drivers/domain/driver_package.dart';

void main() {
  test('driver packages require signature and matching hardware identity', () {
    const package = DriverPackage(
      publishedName: 'oem42.inf',
      infName: 'vendor.inf',
      version: '1.2.3',
      publisher: 'Vendor Inc.',
      hardwareIds: <String>{r'PCI\VEN_1234&DEV_5678'},
      signed: true,
    );

    expect(package.signed, isTrue);
    expect(package.supportsAny(<String>{r'PCI\VEN_1234&DEV_5678'}), isTrue);
    expect(package.supportsAny(<String>{r'PCI\VEN_DEAD&DEV_BEEF'}), isFalse);
    expect(package.exactRollbackAvailable, isFalse);
  });
}
