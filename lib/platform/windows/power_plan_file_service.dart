import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../core/services/process_runner.dart';
import 'power_scheme_service.dart';

class PowerPlanFileService {
  const PowerPlanFileService({
    required this.processRunner,
    required this.schemes,
  });

  final ProcessRunner processRunner;
  final PowerSchemeInventory schemes;

  Future<File> exportScheme(String schemeId, File destination) async {
    _requirePow(destination.path);
    final result = await processRunner.run('powercfg.exe', <String>[
      '/export',
      destination.absolute.path,
      schemeId,
    ]);
    if (!result.success) {
      throw StateError('Power plan export failed: ${result.details}');
    }
    if (!await destination.exists() || await destination.length() == 0) {
      throw StateError('Power plan export produced no data.');
    }
    return destination;
  }

  Future<String> importScheme(File source, Directory stagingDirectory) async {
    _requirePow(source.path);
    if (!await source.exists() ||
        await source.length() == 0 ||
        await source.length() > 64 * 1024 * 1024) {
      throw StateError('Power plan file is missing, empty, or too large.');
    }
    await stagingDirectory.create(recursive: true);
    final beforeHash = await _hash(source);
    final frozen = File(
      '${stagingDirectory.path}${Platform.pathSeparator}import.pow',
    );
    await source.copy(frozen.path);
    if (await _hash(frozen) != beforeHash) {
      throw StateError('Power plan changed while it was staged.');
    }
    final before = schemes.enumerate().map((scheme) => scheme.id).toSet();
    try {
      final result = await processRunner.run('powercfg.exe', <String>[
        '/import',
        frozen.absolute.path,
      ]);
      if (!result.success) {
        throw StateError('Power plan import failed: ${result.details}');
      }
      final added = schemes
          .enumerate()
          .where((scheme) => !before.contains(scheme.id))
          .toList(growable: false);
      if (added.length != 1) {
        throw StateError('Power plan import did not add exactly one scheme.');
      }
      return added.single.id;
    } finally {
      if (await frozen.exists()) {
        await frozen.delete();
      }
    }
  }

  static void _requirePow(String path) {
    if (!path.toLowerCase().endsWith('.pow')) {
      throw ArgumentError('Power plan files must use the .pow extension.');
    }
  }

  static Future<String> _hash(File file) async =>
      sha256.bind(file.openRead()).first.then((digest) => digest.toString());
}
