import 'dart:io';
import 'dart:math';

import '../../../core/services/process_runner.dart';
import '../domain/driver_package.dart';
import 'driver_inventory_parser.dart';

class DriverInventoryResult {
  const DriverInventoryResult({
    required this.packages,
    required this.complete,
    this.message,
  });

  final List<DriverPackage> packages;
  final bool complete;
  final String? message;
}

class WindowsDriverInventoryService {
  WindowsDriverInventoryService({
    required ProcessRunner processRunner,
    DriverInventoryParser parser = const DriverInventoryParser(),
  }) : _processRunner = processRunner,
       _parser = parser;

  final ProcessRunner _processRunner;
  final DriverInventoryParser _parser;

  Future<DriverInventoryResult> scan() async {
    final suffix = Random.secure().nextInt(0x7fffffff).toRadixString(16);
    final output = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'zaptweaks-drivers-$suffix.xml',
    );
    try {
      final result = await _processRunner.run('pnputil.exe', <String>[
        '/enum-drivers',
        '/ids',
        '/format',
        'xml',
        '/output-file',
        output.path,
      ]);
      if (!result.success || !await output.exists()) {
        throw StateError(
          result.details.isEmpty ? 'Driver inventory failed.' : result.details,
        );
      }
      return DriverInventoryResult(
        packages: _parser.parse(await output.readAsString()),
        complete: true,
      );
    } catch (error) {
      return DriverInventoryResult(
        packages: const <DriverPackage>[],
        complete: false,
        message: error.toString(),
      );
    } finally {
      if (await output.exists()) await output.delete();
    }
  }
}
