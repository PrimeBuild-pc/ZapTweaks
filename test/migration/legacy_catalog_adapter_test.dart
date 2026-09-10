import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/legacy/adapters/legacy_catalog_adapter.dart';
import 'package:script_utility/legacy/catalog/legacy_catalog_manifest.dart';

void main() {
  test('legacy adapter maps every ID into the one-app navigation', () async {
    final manifest = LegacyCatalogManifest.fromJson(
      await File('assets/catalog/legacy_catalog.json').readAsString(),
    );
    final adapted = LegacyCatalogAdapter(
      manifest,
    ).adapt(TweakCatalogService().buildCatalog());

    expect(adapted, hasLength(346));
    expect(adapted.map((item) => item.id).toSet(), hasLength(346));
    expect(adapted.map((item) => item.category).toSet(), <String>{
      'Guided Setup',
      'Apps',
      'Drivers',
      'Gaming & Performance',
      'Windows',
      'Diagnostics & Recovery',
      'Expert',
    });
    expect(adapted.where((item) => item.isAlias), hasLength(23));
    expect(
      adapted.where((item) => item.isRejected).single.id,
      'advanced_driver_whql_secure_boot_bypass',
    );
    expect(
      adapted
          .where((item) => item.migrationDisposition == 'external')
          .every((item) => item.category == 'Expert'),
      isTrue,
    );
  });
}
