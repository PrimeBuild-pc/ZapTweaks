class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.releaseUrl,
    required this.installerUrl,
    required this.releaseNotes,
  });

  final String version;
  final String releaseUrl;
  final String? installerUrl;
  final String releaseNotes;
}

class UpdateCheckResult {
  const UpdateCheckResult({required this.success, this.update, this.message});

  final bool success;
  final UpdateInfo? update;
  final String? message;

  bool get hasUpdate => update != null;
}
