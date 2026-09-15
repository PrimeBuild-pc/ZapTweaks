import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../../../core/services/process_runner.dart';
import '../domain/driver_package.dart';
import 'windows_driver_inventory_service.dart';

Directory defaultDriverBackupRoot() => Directory(
  path.join(
    Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path,
    'ZapTweaks',
    'DriverBackups',
  ),
);

class DriverStoreService {
  DriverStoreService({
    required ProcessRunner processRunner,
    required Directory backupRoot,
    Future<void> Function(Directory)? secureDirectory,
  }) : _runner = processRunner,
       _backupRoot = backupRoot,
       _secureDirectory = secureDirectory ?? _secure,
       _inventory = WindowsDriverInventoryService(processRunner: processRunner);

  final ProcessRunner _runner;
  final Directory _backupRoot;
  final Future<void> Function(Directory) _secureDirectory;
  final WindowsDriverInventoryService _inventory;
  static final RegExp _publishedName = RegExp(
    r'^oem[0-9]+\.inf$',
    caseSensitive: false,
  );

  Future<DriverExport> exportPackage(DriverPackage package) async {
    if (!_publishedName.hasMatch(package.publishedName) || !package.signed) {
      throw StateError('Only signed Driver Store packages can be exported.');
    }
    await _backupRoot.create(recursive: true);
    await _secureDirectory(_backupRoot);
    final random = Random.secure();
    final suffix = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    final output = Directory(
      path.join(_backupRoot.path, '${package.publishedName}-$suffix'),
    );
    await output.create();
    try {
      final result = await _runner.run('pnputil.exe', <String>[
        '/export-driver',
        package.publishedName,
        output.path,
      ]);
      if (!result.success) throw StateError(result.details);
      final files = output.listSync(recursive: true).whereType<File>().toList();
      final inf = files.where(
        (file) =>
            path.basename(file.path).toLowerCase() ==
            package.infName.toLowerCase(),
      );
      if (inf.length != 1) {
        throw StateError('Export did not contain the expected INF.');
      }
      final hashes = <String, String>{};
      for (final file in files) {
        hashes[path.relative(file.path, from: output.path)] =
            (await sha256.bind(file.openRead()).first).toString();
      }
      final exportedPackage = DriverPackage(
        publishedName: package.publishedName,
        infName: package.infName,
        version: package.version,
        publisher: package.publisher,
        hardwareIds: package.hardwareIds,
        signed: package.signed,
        exportPath: output.path,
      );
      final manifest = File(path.join(output.path, 'zaptweaks-driver.json'));
      final payload = utf8.encode(
        jsonEncode(<String, Object?>{
          'package': exportedPackage.toJson(),
          'directory': output.path,
          'infPath': inf.single.path,
          'sha256': hashes,
        }),
      );
      await manifest.writeAsBytes(payload, flush: true);
      final manifestDigest = sha256.convert(payload).toString();
      return DriverExport(
        package: exportedPackage,
        directory: output.path,
        infPath: inf.single.path,
        sha256: hashes,
        manifestPath: manifest.path,
        manifestSha256: manifestDigest,
      );
    } catch (_) {
      if (await output.exists()) await output.delete(recursive: true);
      rethrow;
    }
  }

  Future<void> removePackage(String publishedName) async {
    if (!_publishedName.hasMatch(publishedName)) {
      throw StateError('Invalid Driver Store identity.');
    }
    final result = await _runner.run('pnputil.exe', <String>[
      '/delete-driver',
      publishedName,
      '/uninstall',
    ]);
    if (!result.success) throw StateError(result.details);
  }

  Future<void> restoreReference(Map<String, Object?> reference) async {
    final publishedName = reference['publishedName'];
    final manifestPath = reference['manifestPath'];
    final expectedDigest = reference['manifestSha256'];
    if (publishedName is! String ||
        !_publishedName.hasMatch(publishedName) ||
        manifestPath is! String ||
        expectedDigest is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(expectedDigest)) {
      throw StateError('Invalid driver export reference.');
    }
    final manifest = File(manifestPath);
    final root = _canonical(_backupRoot.path);
    final canonicalManifest = _canonical(manifest.path);
    if (!canonicalManifest.startsWith('$root${path.separator}') ||
        !await manifest.exists()) {
      throw StateError('Driver export manifest is outside the backup root.');
    }
    final payload = await manifest.readAsBytes();
    if (sha256.convert(payload).toString() != expectedDigest) {
      throw StateError('Driver export manifest integrity check failed.');
    }
    final json = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(payload)) as Map,
    );
    final export = DriverExport(
      package: DriverPackage.fromJson(
        Map<String, dynamic>.from(json['package']! as Map),
      ),
      directory: json['directory']! as String,
      infPath: json['infPath']! as String,
      sha256: Map<String, String>.from(json['sha256']! as Map),
      manifestPath: manifest.path,
      manifestSha256: expectedDigest,
    );
    if (export.package.publishedName.toLowerCase() !=
        publishedName.toLowerCase()) {
      throw StateError('Driver export target mismatch.');
    }
    await restoreExport(export);
  }

  Future<void> restoreExport(DriverExport export) async {
    await _verifyExport(export);
    final result = await _runner.run('pnputil.exe', <String>[
      '/add-driver',
      export.infPath,
      '/install',
    ]);
    if (!result.success) throw StateError(result.details);
    final inventory = await _inventory.scan();
    if (!inventory.complete ||
        !inventory.packages.any(
          (package) =>
              package.infName.toLowerCase() ==
                  export.package.infName.toLowerCase() &&
              package.version == export.package.version &&
              package.publisher == export.package.publisher &&
              package.signed,
        )) {
      throw StateError('Restored driver package could not be verified.');
    }
  }

  Future<void> _verifyExport(DriverExport export) async {
    final root = _canonical(_backupRoot.path);
    final directory = _canonical(export.directory);
    final inf = _canonical(export.infPath);
    if (!(directory.startsWith('$root${path.separator}') &&
        inf.startsWith('$directory${path.separator}'))) {
      throw StateError('Driver export is outside the protected backup root.');
    }
    for (final entry in export.sha256.entries) {
      final filePath = _canonical(path.join(directory, entry.key));
      if (!filePath.startsWith('$directory${path.separator}')) {
        throw StateError('Invalid driver export entry.');
      }
      final file = File(filePath);
      if (!await file.exists() ||
          (await sha256.bind(file.openRead()).first).toString() !=
              entry.value) {
        throw StateError('Driver export integrity check failed.');
      }
    }
  }

  static String _canonical(String value) {
    final normalized = path.normalize(path.absolute(value));
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static Future<void> _secure(Directory directory) async {
    if (!Platform.isWindows) return;
    final domain = Platform.environment['USERDOMAIN'];
    final user = Platform.environment['USERNAME'];
    if (domain == null || user == null) {
      throw StateError('Unable to identify the driver backup owner.');
    }
    final result = await Process.run('icacls.exe', <String>[
      directory.path,
      '/inheritance:r',
      '/grant:r',
      '$domain\\$user:(OI)(CI)F',
      '*S-1-5-18:(OI)(CI)F',
      '*S-1-5-32-544:(OI)(CI)F',
    ]);
    if (result.exitCode != 0) {
      throw StateError('Unable to secure the driver backup directory.');
    }
  }
}
