enum AppProvider { winget, appx }

enum AppInstallScope { currentUser, allUsers, provisioned }

class AppPackage {
  const AppPackage({
    required this.provider,
    required this.packageId,
    required this.name,
    required this.version,
    required this.publisher,
    required this.scopes,
    required this.source,
    required this.reinstallable,
  });

  final AppProvider provider;
  final String packageId;
  final String name;
  final String? version;
  final String? publisher;
  final Set<AppInstallScope> scopes;
  final String source;
  final bool reinstallable;

  Map<String, Object?> toJson() => <String, Object?>{
    'provider': provider.name,
    'packageId': packageId,
    'name': name,
    'version': version,
    'publisher': publisher,
    'scopes': scopes.map((scope) => scope.name).toList(growable: false),
    'source': source,
    'reinstallable': reinstallable,
  };

  factory AppPackage.fromJson(Map<String, dynamic> json) => AppPackage(
    provider: AppProvider.values.byName(json['provider']! as String),
    packageId: json['packageId']! as String,
    name: json['name']! as String,
    version: json['version'] as String?,
    publisher: json['publisher'] as String?,
    scopes: (json['scopes']! as List)
        .map((scope) => AppInstallScope.values.byName(scope as String))
        .toSet(),
    source: json['source']! as String,
    reinstallable: json['reinstallable']! as bool,
  );
}

class AppRemovalPreview {
  const AppRemovalPreview({
    required this.package,
    required this.affectedScopes,
    required this.sharedDependencies,
  });

  final AppPackage package;
  final Set<AppInstallScope> affectedScopes;
  final List<String> sharedDependencies;

  bool get canRemove => affectedScopes.isNotEmpty;
}
