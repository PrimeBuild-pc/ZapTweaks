import 'dart:io';

import 'package:crypto/crypto.dart';

class ArtifactManifestEntry {
  const ArtifactManifestEntry({
    required this.id,
    required this.version,
    required this.url,
    required this.publisher,
    required this.sha256,
    required this.requireAuthenticode,
    required this.license,
    required this.redistributable,
    required this.allowedArguments,
    required this.size,
    required this.verifiedAt,
    required this.allowedRedirectHosts,
  });

  final String id;
  final String version;
  final Uri url;
  final String publisher;
  final String sha256;
  final bool requireAuthenticode;
  final String license;
  final bool redistributable;
  final List<String> allowedArguments;
  final int size;
  final DateTime verifiedAt;
  final Set<String> allowedRedirectHosts;
}

class ArtifactVerificationResult {
  const ArtifactVerificationResult(this.valid, {this.reason});

  final bool valid;
  final String? reason;
}

typedef SignatureVerifier = Future<String?> Function(File file);

class ArtifactVerifier {
  const ArtifactVerifier({required this.verifyPublisher});

  final SignatureVerifier verifyPublisher;

  Future<ArtifactVerificationResult> verify(
    ArtifactManifestEntry entry,
    File file, {
    Uri? finalUrl,
  }) async {
    final resolvedUrl = finalUrl ?? entry.url;
    if (entry.url.scheme != 'https' || resolvedUrl.scheme != 'https') {
      return const ArtifactVerificationResult(
        false,
        reason: 'HTTPS is required.',
      );
    }
    if (resolvedUrl.host != entry.url.host &&
        !entry.allowedRedirectHosts.contains(resolvedUrl.host)) {
      return const ArtifactVerificationResult(
        false,
        reason: 'Redirect host is not allowlisted.',
      );
    }
    if (await file.length() != entry.size) {
      return const ArtifactVerificationResult(
        false,
        reason: 'Artifact size mismatch.',
      );
    }
    final digest = await sha256.bind(file.openRead()).first;
    if (digest.toString().toLowerCase() != entry.sha256.toLowerCase()) {
      return const ArtifactVerificationResult(
        false,
        reason: 'Artifact SHA-256 mismatch.',
      );
    }
    if (entry.requireAuthenticode) {
      final publisher = await verifyPublisher(file);
      if (publisher != entry.publisher) {
        return const ArtifactVerificationResult(
          false,
          reason: 'Authenticode publisher mismatch.',
        );
      }
    }
    return const ArtifactVerificationResult(true);
  }
}
