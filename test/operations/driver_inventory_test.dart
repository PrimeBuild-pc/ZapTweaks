import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/drivers/application/driver_inventory_parser.dart';
import 'package:script_utility/features/drivers/application/windows_driver_inventory_service.dart';

const _fixture = '''<?xml version="1.0" encoding="utf-8"?>
<PnpUtil Version="10.0.26100">
  <Driver DriverName="oem42.inf">
    <OriginalName>vendor.inf</OriginalName>
    <ProviderName>Vendor Inc.</ProviderName>
    <DriverVersion>01/02/2026 3.4.5.6</DriverVersion>
    <SignerName>Microsoft Windows Hardware Compatibility Publisher</SignerName>
  </Driver>
</PnpUtil>''';

void main() {
  test('PnPUtil XML inventory is independent from localized labels', () {
    final package = const DriverInventoryParser().parse(_fixture).single;

    expect(package.publishedName, 'oem42.inf');
    expect(package.infName, 'vendor.inf');
    expect(package.version, '01/02/2026 3.4.5.6');
    expect(package.publisher, 'Vendor Inc.');
    expect(package.signed, isTrue);
  });

  test('driver inventory deletes its temporary XML output', () async {
    String? outputPath;
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async {
        outputPath = arguments[arguments.indexOf('/output-file') + 1];
        await File(outputPath!).writeAsString(_fixture);
        return ProcessResult(1, 0, '', '');
      },
    );

    final result = await WindowsDriverInventoryService(
      processRunner: runner,
    ).scan();

    expect(result.complete, isTrue);
    expect(result.packages.single.publishedName, 'oem42.inf');
    expect(File(outputPath!).existsSync(), isFalse);
  });
}
