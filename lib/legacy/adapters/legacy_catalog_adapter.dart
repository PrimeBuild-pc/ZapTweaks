import '../../core/models/tweak_descriptor.dart';
import '../../core/services/tweak_catalog_service.dart';
import '../../core/services/tweak_collections.dart';
import '../catalog/legacy_catalog_manifest.dart';

class LegacyCatalogAdapter {
  const LegacyCatalogAdapter(this.manifest);

  static const LegacyCatalogAdapter identity = LegacyCatalogAdapter(
    LegacyCatalogManifest(<LegacyCatalogEntry>[]),
  );

  static Future<LegacyCatalogAdapter> load() async =>
      LegacyCatalogAdapter(await LegacyCatalogManifest.load());

  static const Map<String, String> _destinations = <String, String>{
    'Setup guidato': 'Guided Setup',
    'App': 'Apps',
    'Driver': 'Drivers',
    'Gaming & Prestazioni': 'Gaming & Performance',
    'Windows': 'Windows',
    'Diagnostica & Ripristino': 'Diagnostics & Recovery',
    'Esperto': 'Expert',
  };

  static const Map<String, String> _additionalDestinations = <String, String>{
    'Refresh & Recovery': 'Diagnostics & Recovery',
    'Tools': 'Expert',
  };

  final LegacyCatalogManifest manifest;

  List<TweakDescriptor> adapt(List<TweakDescriptor> legacyCatalog) {
    final entries = <String, LegacyCatalogEntry>{
      for (final entry in manifest.entries) entry.id: entry,
    };
    final adapted = legacyCatalog
        .map((descriptor) {
          final entry = entries[descriptor.id];
          if (entry == null) {
            final destination = _additionalDestinations[descriptor.category];
            return destination == null
                ? descriptor
                : descriptor.copyWith(category: destination);
          }
          return descriptor.copyWith(
            category: _destinations[entry.destination] ?? entry.destination,
            migrationDisposition: entry.disposition,
            aliasTarget: entry.aliasTarget,
          );
        })
        .toList(growable: false);

    adapted.sort((left, right) {
      final category = TweakCatalogService.oneAppNavigationCategories
          .indexOf(left.category)
          .compareTo(
            TweakCatalogService.oneAppNavigationCategories.indexOf(
              right.category,
            ),
          );
      if (category != 0) return category;
      final collection = TweakCollections.orderIndex(
        left.collection,
      ).compareTo(TweakCollections.orderIndex(right.collection));
      if (collection != 0) return collection;
      return left.title.compareTo(right.title);
    });
    return adapted;
  }
}
