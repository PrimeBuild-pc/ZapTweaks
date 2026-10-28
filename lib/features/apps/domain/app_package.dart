import 'appx_candidate_policy.dart';

enum AppProvider { winget, appx, win32 }

/// Facts shown as tags next to an app.
enum AppLabel {
  missingUninstaller,
  protected,
  systemComponent,
  update,
  storeApp,
}

/// One Uninstall registry key (HKLM 64/32-bit or HKCU). Every string here
/// comes from the registry and is untrusted: it is data, never a command line.
class UninstallEntry {
  const UninstallEntry({
    required this.hive,
    required this.view,
    required this.key,
    this.uninstallString,
    this.quietUninstallString,
    this.msiProductCode,
    this.systemComponent = false,
    this.noRemove = false,
    this.isUpdate = false,
  });

  final String hive;
  final String view;
  final String key;
  final String? uninstallString;
  final String? quietUninstallString;
  final String? msiProductCode;
  final bool systemComponent;
  final bool noRemove;
  final bool isUpdate;

  Map<String, Object?> toJson() => <String, Object?>{
    'hive': hive,
    'view': view,
    'key': key,
    'uninstallString': uninstallString,
    'quietUninstallString': quietUninstallString,
    'msiProductCode': msiProductCode,
    'systemComponent': systemComponent,
    'noRemove': noRemove,
    'isUpdate': isUpdate,
  };

  factory UninstallEntry.fromJson(Map<String, dynamic> json) => UninstallEntry(
    hive: json['hive']! as String,
    view: json['view']! as String,
    key: json['key']! as String,
    uninstallString: json['uninstallString'] as String?,
    quietUninstallString: json['quietUninstallString'] as String?,
    msiProductCode: json['msiProductCode'] as String?,
    systemComponent: json['systemComponent'] == true,
    noRemove: json['noRemove'] == true,
    isUpdate: json['isUpdate'] == true,
  );
}

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
    this.appxMetadata = const <Map<String, dynamic>>[],
    this.installDate,
    this.installLocation,
    this.sizeBytes,
    this.uninstall,
    this.wingetId,
  });

  final AppProvider provider;
  final String packageId;
  final String name;
  final String? version;
  final String? publisher;
  final Set<AppInstallScope> scopes;
  final String source;
  final bool reinstallable;
  final List<Map<String, dynamic>> appxMetadata;
  final DateTime? installDate;
  final String? installLocation;

  /// Null when not known yet; never 0 for "unknown".
  final int? sizeBytes;
  final UninstallEntry? uninstall;

  /// winget id matched to this program, used only to reinstall it.
  final String? wingetId;

  /// AppX framework or resource package: a dependency, not an app.
  bool get isFramework => appxMetadata.any(
    (row) => row['IsFramework'] == true || row['IsResourcePackage'] == true,
  );

  Set<AppLabel> get labels => <AppLabel>{
    if (provider == AppProvider.appx) AppLabel.storeApp,
    if (uninstall?.systemComponent == true) AppLabel.systemComponent,
    if (uninstall?.noRemove == true) AppLabel.protected,
    if (uninstall?.isUpdate == true) AppLabel.update,
    if (provider == AppProvider.win32 &&
        (uninstall == null ||
            uninstall!.uninstallString == null &&
                uninstall!.quietUninstallString == null &&
                uninstall!.msiProductCode == null))
      AppLabel.missingUninstaller,
  };

  AppPackage copyWith({int? sizeBytes, String? wingetId}) => AppPackage(
    provider: provider,
    packageId: packageId,
    name: name,
    version: version,
    publisher: publisher,
    scopes: scopes,
    source: source,
    reinstallable: reinstallable || wingetId != null,
    appxMetadata: appxMetadata,
    installDate: installDate,
    installLocation: installLocation,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    uninstall: uninstall,
    wingetId: wingetId ?? this.wingetId,
  );

  AppxCandidate? get appxCandidate =>
      provider == AppProvider.appx ? appxCandidatePolicy[packageId] : null;
  bool get canRemoveAppx {
    final mainPackages = appxMetadata.where(
      (row) => row['IsResourcePackage'] != true,
    );
    return appxCandidate?.removable == true &&
        mainPackages.isNotEmpty &&
        mainPackages.every(isRemovableAppxMetadata);
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'provider': provider.name,
    'packageId': packageId,
    'name': name,
    'version': version,
    'publisher': publisher,
    'scopes': scopes.map((scope) => scope.name).toList(growable: false),
    'source': source,
    'reinstallable': reinstallable,
    'appxMetadata': appxMetadata,
    'installDate': installDate?.toIso8601String(),
    'installLocation': installLocation,
    'sizeBytes': sizeBytes,
    'uninstall': uninstall?.toJson(),
    'wingetId': wingetId,
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
    appxMetadata: (json['appxMetadata'] as List? ?? const <dynamic>[])
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false),
    installDate: DateTime.tryParse(json['installDate'] as String? ?? ''),
    installLocation: json['installLocation'] as String?,
    sizeBytes: json['sizeBytes'] as int?,
    uninstall: json['uninstall'] == null
        ? null
        : UninstallEntry.fromJson(
            Map<String, dynamic>.from(json['uninstall'] as Map),
          ),
    wingetId: json['wingetId'] as String?,
  );
}

List<AppPackage> mergeAppPackages(Iterable<AppPackage> packages) {
  final merged = <String, AppPackage>{};
  for (final package in packages) {
    final key = '${package.provider.name}:${package.packageId}';
    final previous = merged[key];
    merged[key] = AppPackage(
      provider: package.provider,
      packageId: package.packageId,
      name: package.name,
      version: package.version ?? previous?.version,
      publisher: package.publisher ?? previous?.publisher,
      scopes: <AppInstallScope>{...?previous?.scopes, ...package.scopes},
      source: package.source,
      reinstallable: package.reinstallable || previous?.reinstallable == true,
      appxMetadata: <Map<String, dynamic>>[
        ...?previous?.appxMetadata,
        ...package.appxMetadata,
      ],
      installDate: package.installDate ?? previous?.installDate,
      installLocation: package.installLocation ?? previous?.installLocation,
      sizeBytes: package.sizeBytes ?? previous?.sizeBytes,
      uninstall: package.uninstall ?? previous?.uninstall,
      wingetId: package.wingetId ?? previous?.wingetId,
    );
  }
  return merged.values.toList(growable: false)
    ..sort((left, right) => left.name.compareTo(right.name));
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

  bool get canRemove =>
      affectedScopes.isNotEmpty &&
      (package.provider != AppProvider.appx || package.canRemoveAppx) &&
      sharedDependencies.isEmpty;
}
