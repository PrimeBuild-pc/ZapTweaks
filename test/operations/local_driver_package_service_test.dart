import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/drivers/application/local_driver_package_service.dart';
import 'package:script_utility/features/drivers/application/windows_driver_inventory_service.dart';
import 'package:script_utility/features/drivers/domain/driver_package.dart';

const _hardwareId = r'PCI\VEN_1234&DEV_ABCD';

class _Inventory extends WindowsDriverInventoryService {
  _Inventory() : super(processRunner: ProcessRunner());

  @override
  Future<DriverInventoryResult> scan() async => const DriverInventoryResult(
    packages: <DriverPackage>[
      DriverPackage(
        publishedName: 'oem1.inf',
        infName: 'vendor.inf',
        version: '1.0',
        publisher: 'Vendor',
        hardwareIds: <String>{_hardwareId},
        signed: true,
      ),
    ],
    complete: true,
  );
}

void main() {
  test(
    'local driver install verifies catalog, hardware ID and read-back',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'zap-local-driver-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final inf = File(p.join(directory.path, 'vendor.inf'));
      final catalog = File(p.join(directory.path, 'vendor.cat'));
      await inf.writeAsString('''
[Version]
CatalogFile=vendor.cat
[Models]
%Device%=Install, PCI\\VEN_1234&DEV_ABCD
''');
      await catalog.writeAsString('signed catalog');
      final calls = <List<String>>[];
      final service = LocalDriverPackageService(
        processRunner: ProcessRunner(
          processRunDelegate:
              (executable, arguments, {runInShell = false}) async {
                calls.add(<String>[executable, ...arguments]);
                return ProcessResult(1, 0, '', '');
              },
        ),
        inventory: _Inventory(),
        verifySignature: (_) async => 'CN=Vendor',
      );

      final verified = await service.verify(
        inf,
        deviceHardwareIds: const <String>{_hardwareId},
      );
      final installed = await service.install(verified);

      expect(installed.publishedName, 'oem1.inf');
      expect(calls.single, <String>[
        'pnputil.exe',
        '/add-driver',
        inf.path,
        '/install',
      ]);
    },
  );

  test(
    'local driver install rejects payload changes after verification',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'zap-local-driver-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final inf = File(p.join(directory.path, 'vendor.inf'));
      final catalog = File(p.join(directory.path, 'vendor.cat'));
      await inf.writeAsString(
        '[Version]\nCatalogFile=vendor.cat\nPCI\\VEN_1234&DEV_ABCD',
      );
      await catalog.writeAsString('signed catalog');
      final service = LocalDriverPackageService(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
        inventory: _Inventory(),
        verifySignature: (_) async => 'CN=Vendor',
      );
      final verified = await service.verify(
        inf,
        deviceHardwareIds: const <String>{_hardwareId},
      );
      await catalog.writeAsString('changed');

      expect(service.install(verified), throwsStateError);
    },
  );
}
