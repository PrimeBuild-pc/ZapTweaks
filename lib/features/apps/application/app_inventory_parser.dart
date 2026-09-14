import 'dart:convert';

import '../domain/app_package.dart';
import '../domain/microsoft_restore_catalog.dart';

class AppInventoryParser {
  const AppInventoryParser();

  List<AppPackage> parseWinget(String json) {
    final root = jsonDecode(json);
    final rows = root is List ? root : (root as Map)['Sources'] ?? const [];
    final packages = <AppPackage>[];
    for (final source in rows as List) {
      final sourceMap = Map<String, dynamic>.from(source as Map);
      final items = sourceMap['Packages'] is List
          ? sourceMap['Packages'] as List
          : <dynamic>[sourceMap];
      for (final item in items) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = (map['PackageIdentifier'] ?? map['Id']) as String?;
        if (id == null || id.isEmpty) continue;
        packages.add(
          AppPackage(
            provider: AppProvider.winget,
            packageId: id,
            name: (map['PackageName'] ?? map['Name'] ?? id) as String,
            version: (map['InstalledVersion'] ?? map['Version']) as String?,
            publisher: map['Publisher'] as String?,
            scopes: const <AppInstallScope>{AppInstallScope.currentUser},
            source: _wingetSource(map, sourceMap),
            reinstallable: true,
          ),
        );
      }
    }
    return packages;
  }

  List<AppPackage> parseAppx(String json) {
    final decoded = jsonDecode(json);
    final rows = decoded is List
        ? decoded
        : decoded is Map
        ? <dynamic>[decoded]
        : const <dynamic>[];
    final packages = <String, AppPackage>{};
    for (final row in rows) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = map['Name'] as String?;
      if (id == null || id.isEmpty) continue;
      final scopes = <AppInstallScope>{
        if (map['CurrentUser'] == true) AppInstallScope.currentUser,
        if (map['AllUsers'] == true) AppInstallScope.allUsers,
        if (map['Provisioned'] == true) AppInstallScope.provisioned,
      };
      final previous = packages[id];
      packages[id] = AppPackage(
        provider: AppProvider.appx,
        packageId: id,
        name: (map['DisplayName'] ?? previous?.name ?? id) as String,
        version: map['Version'] as String? ?? previous?.version,
        publisher: map['Publisher'] as String? ?? previous?.publisher,
        scopes: <AppInstallScope>{...?previous?.scopes, ...scopes},
        source: 'Microsoft Store',
        reinstallable:
            previous?.reinstallable == true ||
            map['Reinstallable'] == true ||
            microsoftRestoreCatalog.containsKey(id),
      );
    }
    return packages.values.toList(growable: false);
  }

  static String _wingetSource(
    Map<String, dynamic> package,
    Map<String, dynamic> source,
  ) {
    final explicit = package['Source'];
    if (explicit != null) return explicit.toString();
    final details = source['SourceDetails'];
    if (details is Map) {
      return (details['Name'] ?? details['Identifier'] ?? 'winget').toString();
    }
    return details?.toString() ?? 'winget';
  }

  AppRemovalPreview previewRemoval(
    AppPackage package, {
    required Set<AppInstallScope> scopes,
    List<String> sharedDependencies = const <String>[],
  }) => AppRemovalPreview(
    package: package,
    affectedScopes: scopes.intersection(package.scopes),
    sharedDependencies: sharedDependencies,
  );
}
