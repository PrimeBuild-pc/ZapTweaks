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
