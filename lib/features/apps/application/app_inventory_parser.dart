import 'dart:convert';

import '../domain/app_package.dart';
import '../domain/appx_candidate_policy.dart';
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
    if (decoded is! List && decoded is! Map) {
      throw const FormatException('Invalid AppX inventory.');
    }
    final rows = decoded is List
        ? decoded
        : (decoded as Map).containsKey('Installed')
        ? <dynamic>[
            ...(decoded['Installed'] as List),
            for (final provision in decoded['Provisioned'] as List)
              <String, dynamic>{
                for (final app in decoded['Installed'] as List)
                  if (app['Name'] == provision['DisplayName'] &&
                      app['PackageFullName'] == provision['PackageName'])
                    ...Map<String, dynamic>.from(app as Map),
                'Name': provision['DisplayName'],
                'DisplayName': provision['DisplayName'],
                'Version': provision['Version'],
                'CurrentUser': false,
                'AllUsers': false,
                'Provisioned': true,
              },
          ]
        : <dynamic>[decoded];
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
        name:
            appxCandidatePolicy[id]?.name ??
            (map['DisplayName'] ?? previous?.name ?? id) as String,
        version: map['Version'] as String? ?? previous?.version,
        publisher: map['Publisher'] as String? ?? previous?.publisher,
        scopes: <AppInstallScope>{...?previous?.scopes, ...scopes},
        source: 'Microsoft Store',
        reinstallable:
            microsoftRestoreCatalog.containsKey(id) ||
            appxCandidatePolicy[id]?.restore != null,
        appxMetadata: <Map<String, dynamic>>[...?previous?.appxMetadata, map],
      );
    }
    return packages.values.toList(growable: false);
  }

  /// Rows from [uninstallRegistryScript]. Nameless keys are skipped; a 32-bit
  /// twin of a 64-bit entry (same hive, name and version) is dropped.
  List<AppPackage> parseUninstallEntries(String json) {
    final decoded = jsonDecode(json);
    final rows = decoded is List ? decoded : <dynamic>[decoded];
    final seen = <String, int>{};
    final packages = <AppPackage>[];
    for (final row in rows) {
      if (row is! Map) throw const FormatException('Invalid Uninstall row.');
      String? text(String key) {
        final value = row[key];
        return value is String && value.trim().isNotEmpty ? value.trim() : null;
      }

      bool flag(String key) => row[key] == 1 || row[key] == true;
      final name = text('DisplayName');
      final hive = text('Hive'), view = text('View'), key = text('Key');
      if (name == null || hive == null || view == null || key == null) {
        continue;
      }
      final size = row['EstimatedSize'];
      final release = text('ReleaseType')?.toLowerCase() ?? '';
      final package = (AppPackage(
        provider: AppProvider.win32,
        packageId: '$hive\\$view\\$key',
        name: name,
        version: text('DisplayVersion'),
        publisher: text('Publisher'),
        scopes: <AppInstallScope>{
          hive == 'HKCU'
              ? AppInstallScope.currentUser
              : AppInstallScope.allUsers,
        },
        source: 'Windows',
        reinstallable: false,
        installDate: _yyyymmdd(text('InstallDate')),
        installLocation: text('InstallLocation'),
        sizeBytes: size is int && size > 0 ? size * 1024 : null,
        uninstall: UninstallEntry(
          hive: hive,
          view: view,
          key: key,
          uninstallString: text('UninstallString'),
          quietUninstallString: text('QuietUninstallString'),
          msiProductCode: flag('WindowsInstaller') && _guid.hasMatch(key)
              ? key.toUpperCase()
              : null,
          systemComponent: flag('SystemComponent'),
          noRemove: flag('NoRemove'),
          isUpdate:
              text('ParentKeyName') != null ||
              release.contains('update') ||
              release.contains('hotfix'),
        ),
      ));
      // Twins (64/32-bit view, or an MSI and its bootstrapper) share name and
      // version: keep the visible one that can be uninstalled.
      final twin = '$hive|${name.toLowerCase()}|${text('DisplayVersion')}';
      final previous = seen[twin];
      if (previous == null) {
        seen[twin] = packages.length;
        packages.add(package);
      } else if (_rank(package) > _rank(packages[previous])) {
        packages[previous] = package;
      }
    }
    return packages;
  }

  static int _rank(AppPackage app) =>
      (app.uninstall!.systemComponent ? 0 : 2) +
      (app.labels.contains(AppLabel.missingUninstaller) ? 0 : 1);

  static final _guid = RegExp(
    r'^\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}$',
    caseSensitive: false,
  );

  static DateTime? _yyyymmdd(String? value) {
    final match = RegExp(r'^(\d{4})(\d{2})(\d{2})$').firstMatch(value ?? '');
    if (match == null) return null;
    final [y, m, d] = [for (var i = 1; i <= 3; i++) int.parse(match[i]!)];
    final date = DateTime(y, m, d);
    // DateTime rolls 2026-13-45 over; a real date round-trips.
    return date.month == m && date.day == d ? date : null;
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

/// Gives each Win32 program the winget id that matches it, so it can be
/// reinstalled. `Publisher.Name` matches when the program's name starts with
/// "name" (or "publishername") and its name or publisher contains
/// "publisher". Ids matching more than one program, and winget rows matching
/// none, add nothing: winget is not a second list.
/// shortcut: name matching, not winget's own correlation (`winget list`);
/// a helper such as "Teams Machine-Wide Installer" can still take
/// Microsoft.Teams. Upgrade to `winget list --id` checks before reinstalling.
List<AppPackage> attachWingetIds(
  List<AppPackage> apps,
  List<AppPackage> winget,
) {
  String norm(String? value) =>
      (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  final ids = <int, ({String id, int length})>{};
  for (final package in winget) {
    final parts = package.packageId.split('.');
    if (parts.length < 2) continue;
    final vendor = norm(parts.first), product = norm(parts.sublist(1).join());
    if (vendor.isEmpty || product.isEmpty) continue;
    final matches = <int>[
      for (final (index, app) in apps.indexed)
        if (app.provider == AppProvider.win32 &&
            (norm(app.name).startsWith(product) ||
                norm(app.name).startsWith('$vendor$product')) &&
            (norm(app.name).contains(vendor) ||
                norm(app.publisher).contains(vendor)))
          index,
    ];
    if (matches.length != 1) continue;
    // Two ids can fit one program (VisualStudio vs VisualStudioCode): the
    // longer, more specific product name wins.
    final previous = ids[matches.single];
    if (previous == null || product.length > previous.length) {
      ids[matches.single] = (id: package.packageId, length: product.length);
    }
  }
  return <AppPackage>[
    for (final (index, app) in apps.indexed)
      ids[index] == null ? app : app.copyWith(wingetId: ids[index]!.id),
  ];
}
