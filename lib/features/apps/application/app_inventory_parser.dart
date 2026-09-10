import 'dart:convert';

import '../domain/app_package.dart';

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
            source: (map['Source'] ?? sourceMap['SourceDetails'] ?? 'winget')
                .toString(),
            reinstallable: true,
          ),
        );
      }
    }
    return packages;
  }

  List<AppPackage> parseAppx(String json) {
    final decoded = jsonDecode(json);
    final rows = decoded is List ? decoded : <dynamic>[decoded];
    return rows
        .map((row) {
          final map = Map<String, dynamic>.from(row as Map);
          final scopes = <AppInstallScope>{};
          if (map['CurrentUser'] == true) {
            scopes.add(AppInstallScope.currentUser);
          }
          if (map['AllUsers'] == true) {
            scopes.add(AppInstallScope.allUsers);
          }
          if (map['Provisioned'] == true) {
            scopes.add(AppInstallScope.provisioned);
          }
          return AppPackage(
            provider: AppProvider.appx,
            packageId: map['Name'] as String,
            name: (map['DisplayName'] ?? map['Name']) as String,
            version: map['Version'] as String?,
            publisher: map['Publisher'] as String?,
            scopes: scopes,
            source: 'Microsoft Store',
            reinstallable: map['Reinstallable'] == true,
          );
        })
        .toList(growable: false);
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
