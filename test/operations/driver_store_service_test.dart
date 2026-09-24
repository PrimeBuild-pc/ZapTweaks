import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/drivers/application/driver_store_service.dart';
import 'package:script_utility/features/drivers/domain/driver_package.dart';

const _package = DriverPackage(
  publishedName: 'oem42.inf',
  infName: 'vendor.inf',
  version: '01/02/2026 3.4.5.6',
  publisher: 'Vendor Inc.',
  hardwareIds: <String>{r'PCI\VEN_1234&DEV_ABCD'},
  signed: true,
);

void main() {
  test('Driver Store export is hashed and restores through PnPUtil', () async {
    final backup = await Directory.systemTemp.createTemp('zap-driver-');
    addTearDown(() => backup.delete(recursive: true));
    var installed = true;
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async {
        if (arguments.first == '/export-driver') {
          final directory = Directory(arguments.last);
          final packageDirectory = Directory(
            path.join(directory.path, 'vendor.inf_amd64_test'),
          );
          await packageDirectory.create();
          await File(
            path.join(packageDirectory.path, 'vendor.inf'),
          ).writeAsString('[Version]');
          await File(
            path.join(packageDirectory.path, 'vendor.cat'),
          ).writeAsString('catalog');
        } else if (arguments.first == '/delete-driver') {
          installed = false;
        } else if (arguments.first == '/add-driver') {
          installed = true;
        } else if (arguments.first == '/enum-drivers') {
          final output = File(arguments[arguments.indexOf('/output-file') + 1]);
          await output.writeAsString(
            installed
                ? '''<PnpUtil><Driver DriverName="oem42.inf"><OriginalName>vendor.inf</OriginalName><ProviderName>Vendor Inc.</ProviderName><DriverVersion>01/02/2026 3.4.5.6</DriverVersion><SignerName>Microsoft Windows Hardware Compatibility Publisher</SignerName></Driver></PnpUtil>'''
                : '<PnpUtil/>',
          );
        }
        return ProcessResult(1, 0, '', '');
      },
    );
    final service = DriverStoreService(
      processRunner: runner,
      backupRoot: backup,
      secureDirectory: (_) async {},
    );

    final export = await service.exportPackage(_package);
    await service.removePackage(_package.publishedName);
    await service.restoreReference(export.toReferenceJson());

    expect(
      export.sha256.keys,
      containsAll(<String>[
        path.join('vendor.inf_amd64_test', 'vendor.inf'),
        path.join('vendor.inf_amd64_test', 'vendor.cat'),
      ]),
    );
    expect(installed, isTrue);
  });

  test('Driver Store restore rejects a modified exported payload', () async {
    final backup = await Directory.systemTemp.createTemp('zap-driver-');
    addTearDown(() => backup.delete(recursive: true));
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async {
        if (arguments.first == '/export-driver') {
          final directory = Directory(arguments.last);
          await File(
            path.join(directory.path, 'vendor.inf'),
          ).writeAsString('[Version]');
          await File(
            path.join(directory.path, 'vendor.cat'),
          ).writeAsString('catalog');
        }
        return ProcessResult(1, 0, '', '');
      },
    );
    final service = DriverStoreService(
      processRunner: runner,
      backupRoot: backup,
      secureDirectory: (_) async {},
    );
    final export = await service.exportPackage(_package);
    await File(
      path.join(export.directory, 'vendor.cat'),
    ).writeAsString('tampered');

    expect(
      service.restoreReference(export.toReferenceJson()),
      throwsStateError,
    );
  });
}
