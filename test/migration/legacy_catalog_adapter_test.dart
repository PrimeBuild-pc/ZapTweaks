import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/legacy/adapters/legacy_catalog_adapter.dart';
import 'package:script_utility/legacy/catalog/legacy_catalog_manifest.dart';
import 'package:script_utility/models/action_tweaks.dart';
import 'package:script_utility/models/system_tweak.dart';

void main() {
  test('legacy adapter maps every ID into the one-app navigation', () async {
    final manifest = LegacyCatalogManifest.fromJson(
      await File('assets/catalog/legacy_catalog.json').readAsString(),
    );
    final adapted = LegacyCatalogAdapter(
      manifest,
    ).adapt(TweakCatalogService().buildCatalog());

    expect(adapted, hasLength(348));
    expect(adapted.map((item) => item.id).toSet(), hasLength(348));
    expect(
      manifest.entries.every(
        (entry) => adapted.any((descriptor) => descriptor.id == entry.id),
      ),
      isTrue,
    );
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
    final external = adapted.where(
      (item) => item.migrationDisposition == 'external',
    );
    expect(external.every((item) => item.category == 'Expert'), isTrue);
    expect(
      external.every(
        (item) =>
            item.isBlockedLegacyScript ||
            item.scriptTweak is ExternalUrlLauncherTweak,
      ),
      isTrue,
      reason: external
          .where(
            (item) =>
                !item.isBlockedLegacyScript &&
                item.scriptTweak is! ExternalUrlLauncherTweak,
          )
          .map((item) => '${item.id}:${item.scriptTweak.runtimeType}')
          .join(', '),
    );
    expect(
      adapted
          .where(
            (item) => item.scriptTweak?.type == TweakUiType.interactiveScript,
          )
          .where((item) => item.migrationDisposition != 'external')
          .every((item) => item.isBlockedLegacyScript),
      isTrue,
    );
  });
}
