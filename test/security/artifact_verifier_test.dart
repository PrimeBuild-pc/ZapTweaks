import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/downloads/artifact_verifier.dart';

void main() {
  test('unverified or redirected driver packages are blocked', () async {
    final directory = await Directory.systemTemp.createTemp('zap-artifact-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/driver.exe');
    final bytes = <int>[1, 2, 3, 4];
    await file.writeAsBytes(bytes);
    final entry = ArtifactManifestEntry(
      id: 'driver.sample',
      version: '1.0',
      url: Uri.https('vendor.example', '/driver.exe'),
      publisher: 'Vendor Inc.',
      sha256: sha256.convert(bytes).toString(),
      requireAuthenticode: true,
      license: 'Vendor EULA',
      redistributable: false,
      allowedArguments: const <String>['/silent'],
      size: bytes.length,
      verifiedAt: DateTime.utc(2026),
      allowedRedirectHosts: const <String>{'cdn.vendor.example'},
    );
    final verifier = ArtifactVerifier(
      verifyPublisher: (_) async => 'Vendor Inc.',
    );

    expect((await verifier.verify(entry, file)).valid, isTrue);
    expect(
      (await verifier.verify(
        entry,
        file,
        finalUrl: Uri.https('attacker.example', '/driver.exe'),
      )).valid,
      isFalse,
    );
    await file.writeAsBytes(<int>[4, 3, 2, 1]);
    expect((await verifier.verify(entry, file)).valid, isFalse);
  });
}
