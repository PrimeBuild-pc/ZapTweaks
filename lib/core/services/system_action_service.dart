import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../models/operation_result.dart';
import '../models/update_info.dart';
import 'logging_service.dart';
import 'process_runner.dart';

class SystemActionService {
  SystemActionService({
    required ProcessRunner processRunner,
    LoggingService? loggingService,
    http.Client? httpClient,
  }) : _processRunner = processRunner,
       _loggingService = loggingService ?? LoggingService.instance,
       _httpClient = httpClient ?? http.Client();

  final ProcessRunner _processRunner;
  final LoggingService _loggingService;
  final http.Client _httpClient;

  Future<OperationResult> restartSystem() async {
    final result = await _processRunner.run('shutdown', <String>[
      '/r',
      '/t',
      '5',
      '/c',
      'ZapTweaks: Restarting to apply changes.',
    ]);

    if (!result.success) {
      return OperationResult(success: false, message: result.details);
    }

    return const OperationResult(success: true);
  }

  Future<UpdateCheckResult> checkUpdateAvailability({
    required String currentVersion,
    required String latestReleaseApiUrl,
    required String releasesPageUrl,
  }) async {
    try {
      await _loggingService.logInfo(
        'Checking for updates against GitHub API.',
        source: 'SystemActionService',
      );
      final response = await _httpClient
          .get(
            Uri.parse(latestReleaseApiUrl),
            headers: <String, String>{
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'ZapTweaks/$currentVersion',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return UpdateCheckResult(
          success: false,
          message: 'GitHub API returned ${response.statusCode}.',
        );
      }

      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        return const UpdateCheckResult(
          success: false,
          message: 'Invalid update response.',
        );
      }

      final latestVersion = _normalizeVersion(
        (payload['tag_name'] ?? '').toString(),
      );
      if (latestVersion.isEmpty) {
        return const UpdateCheckResult(
          success: false,
          message: 'Latest release version not found.',
        );
      }
      if (!_isRemoteVersionNewer(latestVersion, currentVersion)) {
        return UpdateCheckResult(
          success: true,
          message: 'You are running the latest version ($currentVersion).',
        );
      }

      final releaseUrl = (payload['html_url'] ?? releasesPageUrl)
          .toString()
          .trim();
      final update = UpdateInfo(
        version: latestVersion,
        releaseUrl: releaseUrl.isEmpty ? releasesPageUrl : releaseUrl,
        installerUrl: _extractInstallerAssetUrl(payload),
        releaseNotes: (payload['body'] ?? '').toString().trim(),
      );
      await _loggingService.logInfo(
        'Update found. Latest version: $latestVersion.',
        source: 'SystemActionService',
      );
      return UpdateCheckResult(
        success: true,
        update: update,
        message: 'Update $latestVersion is available.',
      );
    } catch (error) {
      await _loggingService.logError(
        'Update check failed: $error',
        source: 'SystemActionService',
      );
      return UpdateCheckResult(success: false, message: error.toString());
    }
  }

  Future<OperationResult> openRelease(UpdateInfo update) async {
    final result = await _processRunner.launch('explorer', <String>[
      update.releaseUrl,
    ]);
    return result.success
        ? const OperationResult(success: true)
        : OperationResult(success: false, message: result.details);
  }

  Future<OperationResult> installUpdate(UpdateInfo update) async {
    final assetUrl = update.installerUrl;
    if (assetUrl == null) {
      return const OperationResult(
        success: false,
        message: 'No installer is attached to this release.',
      );
    }

    final installer = await _downloadInstaller(
      assetUrl: assetUrl,
      targetVersion: update.version,
    );
    if (installer == null) {
      return const OperationResult(
        success: false,
        message: 'Failed to download update installer.',
      );
    }

    String quote(String value) => value.replaceAll("'", "''");
    final appPath = Platform.resolvedExecutable;
    final installDirectory = path.dirname(appPath);
    final helperScript =
        "Wait-Process -Id $pid -ErrorAction SilentlyContinue; "
        "\$installer = Start-Process -FilePath '${quote(installer)}' "
        "-ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/CLOSEAPPLICATIONS','/DIR=\"${quote(installDirectory)}\"') "
        "-PassThru -Wait; "
        "if (\$installer.ExitCode -eq 0 -and (Test-Path -LiteralPath '${quote(appPath)}')) { "
        "Start-Process -FilePath '${quote(appPath)}' -Verb RunAs }";
    final launchResult = await _processRunner.launch('powershell', <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-WindowStyle',
      'Hidden',
      '-Command',
      helperScript,
    ]);
    if (!launchResult.success) {
      return OperationResult(
        success: false,
        message: 'Updater launch failed. ${launchResult.details}',
      );
    }

    return OperationResult(
      success: true,
      message: 'Update ${update.version} downloaded. Installing now...',
      shouldExitApp: true,
    );
  }

  String? _extractInstallerAssetUrl(Map<String, dynamic> payload) {
    final assets = payload['assets'];
    if (assets is! List<dynamic>) {
      return null;
    }

    String? firstExecutable;
    for (final item in assets) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final downloadUrl = (item['browser_download_url'] ?? '')
          .toString()
          .trim();
      final name = (item['name'] ?? '').toString().toLowerCase();
      if (downloadUrl.isEmpty || !name.endsWith('.exe')) {
        continue;
      }

      if (name.contains('setup')) {
        return downloadUrl;
      }
      firstExecutable ??= downloadUrl;
    }

    return firstExecutable;
  }

  Future<String?> _downloadInstaller({
    required String assetUrl,
    required String targetVersion,
  }) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse(assetUrl),
            headers: const <String, String>{
              'Accept': 'application/octet-stream',
            },
          )
          .timeout(const Duration(minutes: 2));

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }

      final uri = Uri.parse(assetUrl);
      final fileName = path.basename(uri.path);
      final updatesDirectory = Directory(
        path.join(
          Directory.systemTemp.path,
          'ZapTweaks',
          'updates',
          targetVersion,
        ),
      );
      if (!updatesDirectory.existsSync()) {
        updatesDirectory.createSync(recursive: true);
      }

      final filePath = path.join(updatesDirectory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  String _normalizeVersion(String rawVersion) {
    return rawVersion.trim().replaceFirst(RegExp(r'^[vV]'), '');
  }

  bool _isRemoteVersionNewer(String remoteVersion, String localVersion) {
    final remoteParts = _parseVersionParts(remoteVersion);
    final localParts = _parseVersionParts(localVersion);

    final maxLength = remoteParts.length > localParts.length
        ? remoteParts.length
        : localParts.length;

    for (var index = 0; index < maxLength; index++) {
      final remote = index < remoteParts.length ? remoteParts[index] : 0;
      final local = index < localParts.length ? localParts[index] : 0;

      if (remote > local) {
        return true;
      }
      if (remote < local) {
        return false;
      }
    }

    return false;
  }

  List<int> _parseVersionParts(String version) {
    final cleanVersion = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return cleanVersion
        .split('.')
        .map(
          (part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        )
        .toList();
  }
}
