import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../../core/services/process_runner.dart';
import '../domain/driver_package.dart';
import 'windows_driver_inventory_service.dart';

typedef DriverSignatureVerifier = Future<String?> Function(File catalog);

class VerifiedLocalDriver {
  const VerifiedLocalDriver._({
    required this.infPath,
    required this.catalogPath,
    required this.publisher,
    required this.hardwareIds,
    required this.infSha256,
    required this.catalogSha256,
  });

  final String infPath;
  final String catalogPath;
  final String publisher;
  final Set<String> hardwareIds;
  final String infSha256;
  final String catalogSha256;
}

class LocalDriverPackageService {
  const LocalDriverPackageService({
    required ProcessRunner processRunner,
    required WindowsDriverInventoryService inventory,
    required DriverSignatureVerifier verifySignature,
  }) : _processRunner = processRunner,
       _inventory = inventory,
       _verifySignature = verifySignature;

  final ProcessRunner _processRunner;
  final WindowsDriverInventoryService _inventory;
  final DriverSignatureVerifier _verifySignature;

  Future<VerifiedLocalDriver> verify(
    File inf, {
    required Set<String> deviceHardwareIds,
  }) async {
    if (!inf.isAbsolute || p.extension(inf.path).toLowerCase() != '.inf') {
      throw ArgumentError.value(
        inf.path,
        'inf',
        'Expected an absolute INF path.',
      );
    }
    if (!await inf.exists()) throw StateError('The INF file does not exist.');
    if (deviceHardwareIds.isEmpty) {
      throw StateError('At least one device hardware ID is required.');
    }
    final text = await _readInf(inf);
    final catalogName = RegExp(
      r'^\s*CatalogFile(?:\.[^=]+)?\s*=\s*([^;\r\n]+)',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(text)?.group(1)?.trim();
    if (catalogName == null ||
        catalogName.isEmpty ||
        p.basename(catalogName) != catalogName) {
      throw StateError('The INF does not name a local catalog file.');
    }
    final catalog = File(p.join(inf.parent.path, catalogName));
    if (!await catalog.exists()) {
      throw StateError('The driver catalog file is missing.');
    }
    final ids = RegExp(
      r'(?:PCI|USB|HID|ACPI|ROOT)\\[A-Z0-9_&.\\-]+',
      caseSensitive: false,
    ).allMatches(text).map((match) => match.group(0)!.toUpperCase()).toSet();
    final expected = deviceHardwareIds.map((id) => id.toUpperCase()).toSet();
    if (!ids.any(
      (candidate) => expected.any(
        (device) => candidate == device || device.startsWith('$candidate&'),
      ),
    )) {
      throw StateError(
        'The INF does not match the selected device hardware IDs.',
      );
    }
    final publisher = await _verifySignature(catalog);
    if (publisher == null || publisher.trim().isEmpty) {
      throw StateError(
        'The driver catalog has no valid Authenticode signature.',
      );
    }
    return VerifiedLocalDriver._(
      infPath: inf.path,
      catalogPath: catalog.path,
      publisher: publisher.trim(),
      hardwareIds: ids,
      infSha256: await _sha256(inf),
      catalogSha256: await _sha256(catalog),
    );
  }

  Future<DriverPackage> install(VerifiedLocalDriver driver) async {
    final inf = File(driver.infPath);
    final catalog = File(driver.catalogPath);
    if (await _sha256(inf) != driver.infSha256 ||
        await _sha256(catalog) != driver.catalogSha256 ||
        await _verifySignature(catalog) != driver.publisher) {
      throw StateError(
        'The verified driver payload changed before installation.',
      );
    }
    final result = await _processRunner.run('pnputil.exe', <String>[
      '/add-driver',
      driver.infPath,
      '/install',
    ]);
    if (!result.success) {
      throw StateError('PnPUtil failed (${result.exitCode}): ${result.stderr}');
    }
    final inventory = await _inventory.scan();
    if (!inventory.complete) {
      throw StateError(inventory.message ?? 'Driver inventory failed.');
    }
    final infName = p.basename(driver.infPath).toLowerCase();
    return inventory.packages.firstWhere(
      (package) =>
          package.infName.toLowerCase() == infName &&
          package.signed &&
          package.hardwareIds.any(driver.hardwareIds.contains),
      orElse: () => throw StateError(
        'The installed driver could not be verified in the Driver Store.',
      ),
    );
  }

  static Future<String?> verifyAuthenticode(
    File catalog, {
    ProcessRunner? processRunner,
  }) async {
    final path = base64Encode(utf8.encode(catalog.path));
    try {
      final publisher = await (processRunner ?? ProcessRunner.shared)
          .runPowerShellForOutput(
            "\$p=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$path'));"
            '\$s=Get-AuthenticodeSignature -LiteralPath \$p;'
            "if(\$s.Status -eq 'Valid' -and \$s.SignerCertificate){\$s.SignerCertificate.Subject}else{exit 2}",
          );
      return publisher.isEmpty ? null : publisher;
    } on Exception {
      return null;
    }
  }

  static Future<String> _readInf(File file) async {
    final bytes = await file.readAsBytes();
    if (bytes.length >= 2 && bytes[0] == 0xff && bytes[1] == 0xfe) {
      return String.fromCharCodes(<int>[
        for (var i = 2; i + 1 < bytes.length; i += 2)
          bytes[i] | (bytes[i + 1] << 8),
      ]);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  static Future<String> _sha256(File file) async =>
      sha256.convert(await file.readAsBytes()).toString();
}
