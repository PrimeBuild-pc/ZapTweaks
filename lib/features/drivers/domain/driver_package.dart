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
}

class TemporaryDriverUpdatePolicy {
  const TemporaryDriverUpdatePolicy({
    required this.expiresAt,
    required this.previousValue,
  });

  final DateTime expiresAt;
  final Object? previousValue;

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);
}
