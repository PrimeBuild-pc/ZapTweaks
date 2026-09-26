class DriverPackage {
  const DriverPackage({
    required this.publishedName,
    required this.infName,
    required this.version,
    required this.publisher,
    required this.hardwareIds,
    required this.signed,
    this.exportPath,
  });

  final String publishedName;
  final String infName;
  final String version;
  final String publisher;
  final Set<String> hardwareIds;
  final bool signed;
  final String? exportPath;

  bool supportsAny(Set<String> deviceHardwareIds) =>
      hardwareIds.any(deviceHardwareIds.contains);

  bool get exactRollbackAvailable => exportPath != null;

  Map<String, Object?> toJson() => <String, Object?>{
    'publishedName': publishedName,
    'infName': infName,
    'version': version,
    'publisher': publisher,
    'hardwareIds': hardwareIds.toList(growable: false),
    'signed': signed,
    'exportPath': exportPath,
  };

  factory DriverPackage.fromJson(Map<String, dynamic> json) => DriverPackage(
    publishedName: json['publishedName']! as String,
    infName: json['infName']! as String,
    version: json['version']! as String,
    publisher: json['publisher']! as String,
    hardwareIds: Set<String>.from(json['hardwareIds']! as List),
    signed: json['signed']! as bool,
    exportPath: json['exportPath'] as String?,
  );
}

class DriverExport {
  const DriverExport({
    required this.package,
    required this.directory,
    required this.infPath,
    required this.sha256,
    required this.manifestPath,
    required this.manifestSha256,
  });

  final DriverPackage package;
  final String directory;
  final String infPath;
  final Map<String, String> sha256;
  final String manifestPath;
  final String manifestSha256;

  Map<String, Object?> toJson() => <String, Object?>{
    'package': package.toJson(),
    'directory': directory,
    'infPath': infPath,
    'sha256': sha256,
    'manifestPath': manifestPath,
    'manifestSha256': manifestSha256,
  };

  factory DriverExport.fromJson(Map<String, dynamic> json) => DriverExport(
    package: DriverPackage.fromJson(
      Map<String, dynamic>.from(json['package']! as Map),
    ),
    directory: json['directory']! as String,
    infPath: json['infPath']! as String,
    sha256: Map<String, String>.from(json['sha256']! as Map),
    manifestPath: json['manifestPath']! as String,
    manifestSha256: json['manifestSha256']! as String,
  );

  Map<String, Object?> toReferenceJson() => <String, Object?>{
    'publishedName': package.publishedName,
    'manifestPath': manifestPath,
    'manifestSha256': manifestSha256,
  };
}
