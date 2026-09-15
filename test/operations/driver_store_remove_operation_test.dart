import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/driver_store_remove_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/drivers/application/driver_store_service.dart';
import 'package:script_utility/features/drivers/application/windows_driver_inventory_service.dart';
import 'package:script_utility/features/drivers/domain/device_identity.dart';
import 'package:script_utility/features/drivers/domain/driver_package.dart';

const _package = DriverPackage(
  publishedName: 'oem42.inf',
  infName: 'vendor.inf',
  version: '1.0',
  publisher: 'Vendor',
  hardwareIds: <String>{r'PCI\VEN_1234&DEV_ABCD'},
  signed: true,
);

class _Inventory extends WindowsDriverInventoryService {
  _Inventory() : super(processRunner: ProcessRunner());

  @override
  Future<DriverInventoryResult> scan() async => const DriverInventoryResult(
    packages: <DriverPackage>[_package],
    complete: true,
  );
}

void main() {
  test('driver removal refuses packages bound to a present device', () async {
    final backup = await Directory.systemTemp.createTemp('zap-driver-op-');
    addTearDown(() => backup.delete(recursive: true));
    final operation = DriverStoreRemoveOperation(
      store: DriverStoreService(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
        backupRoot: backup,
        secureDirectory: (_) async {},
      ),
      inventory: _Inventory(),
      deviceInventory: () => const <DeviceIdentity>[
        DeviceIdentity(
          instanceId: r'PCI\VEN_1234&DEV_ABCD\ONE',
          classGuid: 'guid',
          description: 'Device',
          hardwareIds: <String>{r'PCI\VEN_1234&DEV_ABCD'},
          driverKey: 'key',
          driverInf: 'oem42.inf',
        ),
      ],
    );
    const request = OperationRequest(
      operationId: 'driver.store.remove',
      target: 'oem42.inf',
      desiredValue: null,
    );

    expect(operation.captureSnapshot(request), throwsStateError);
  });
}
