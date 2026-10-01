import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../models/operation_result.dart';
import '../models/update_info.dart';
import '../security/elevated_helper.dart';
import 'logging_service.dart';
import 'process_runner.dart';

class SystemActionService {
  SystemActionService({
    required ProcessRunner processRunner,
    LoggingService? loggingService,
    http.Client? httpClient,
    Directory? updatesDirectory,
    DirectorySecurity? secureDirectory,
  }) : _processRunner = processRunner,
       _loggingService = loggingService ?? LoggingService.instance,
       _httpClient = httpClient ?? http.Client(),
       _updatesDirectory =
           updatesDirectory ??
           Directory(
             path.join(
               Platform.environment['LOCALAPPDATA'] ??
                   Directory.systemTemp.path,
               'ZapTweaks',
               'Updates',
             ),
           ),
       _secureDirectory =
           secureDirectory ?? ElevatedHelperClient.applyWindowsAcl;

  static const latestReleaseApiUrl =
      'https://api.github.com/repos/PrimeBuild-pc/ZapTweaks/releases/latest';
  static const releasesPageUrl =
      'https://github.com/PrimeBuild-pc/ZapTweaks/releases';
  static const _maxInstallerBytes = 512 * 1024 * 1024;
  static final _version = RegExp(r'^\d+\.\d+\.\d+$');
  static final _digest = RegExp(r'^[a-fA-F0-9]{64}$');
  final ProcessRunner _processRunner;
  final LoggingService _loggingService;
  final http.Client _httpClient;
  final Directory _updatesDirectory;
  final DirectorySecurity _secureDirectory;
  bool _installing = false;

  Future<OperationResult> restartSystem() async {
    final result = await _processRunner.run('shutdown', [
      '/r',
      '/t',
      '5',
      '/c',
      'ZapTweaks: Restarting to apply changes.',
    ]);
    return result.success
        ? const OperationResult(success: true)
        : OperationResult(success: false, message: result.details);
  }

  Future<UpdateCheckResult> checkUpdateAvailability({
    required String currentVersion,
    required String latestReleaseApiUrl,
    required String releasesPageUrl,
  }) async {
    try {
      if (latestReleaseApiUrl != SystemActionService.latestReleaseApiUrl ||
          releasesPageUrl != SystemActionService.releasesPageUrl) {
        throw StateError(
          'Updates must originate from the official ZapTweaks repository.',
        );
      }
      final response = await _httpClient
          .send(
            http.Request('GET', Uri.parse(latestReleaseApiUrl))
              ..followRedirects = false
              ..headers.addAll({
                'Accept': 'application/vnd.github+json',
                'User-Agent': 'ZapTweaks/$currentVersion',
              }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw StateError('GitHub API returned ${response.statusCode}.');
      }
      final bytes = <int>[];
      await (() async {
        await for (final chunk in response.stream) {
          if (bytes.length + chunk.length > 1024 * 1024) {
            throw const FormatException('Update response too large.');
          }
          bytes.addAll(chunk);
        }
      })().timeout(const Duration(seconds: 10));
      final payload = jsonDecode(utf8.decode(bytes));
      if (payload is! Map<String, dynamic> ||
          payload['draft'] == true ||
          payload['prerelease'] == true) {
        throw const FormatException('Invalid stable release response.');
      }
      final latest = (payload['tag_name'] ?? '').toString().replaceFirst(
        RegExp(r'^[vV]'),
        '',
      );
      if (!_version.hasMatch(latest)) {
        throw const FormatException('Invalid release version.');
      }
      if (!_isRemoteVersionNewer(latest, currentVersion)) {
        return UpdateCheckResult(
          success: true,
          message: 'You are running the latest version ($currentVersion).',
        );
      }
      String? installerUrl, digest;
      int? size;
      final assets = payload['assets'];
      if (assets is List) {
        for (final asset in assets.whereType<Map>()) {
          if (asset['name'] != 'ZapTweaks_Setup_v$latest.exe') continue;
          final candidate = asset['browser_download_url'];
          final hash = asset['digest'];
          if (candidate is String &&
              _validInstallerUrl(candidate, latest) &&
              hash is String &&
              hash.startsWith('sha256:') &&
              _digest.hasMatch(hash.substring(7)) &&
              asset['size'] is int &&
              (asset['size'] as int) > 0 &&
              (asset['size'] as int) <= _maxInstallerBytes) {
            installerUrl = candidate;
            digest = hash.substring(7).toLowerCase();
            size = asset['size'] as int;
          }
        }
      }
      return UpdateCheckResult(
        success: true,
        update: UpdateInfo(
          version: latest,
          releaseUrl: '$releasesPageUrl/tag/v$latest',
          installerUrl: installerUrl,
          installerSha256: digest,
          installerSize: size,
          releaseNotes: (payload['body'] ?? '').toString().trim(),
        ),
        message: 'Update $latest is available.',
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
    if (!_version.hasMatch(update.version) ||
        update.releaseUrl != '$releasesPageUrl/tag/v${update.version}') {
      return const OperationResult(
        success: false,
        message: 'Invalid official release URL.',
      );
    }
    final result = await _processRunner.launch('explorer', [update.releaseUrl]);
    return result.success
        ? const OperationResult(success: true)
        : OperationResult(success: false, message: result.details);
  }

  Future<OperationResult> installUpdate(
    UpdateInfo update, {
    void Function(int received, int? total)? onProgress,
  }) async {
    if (_installing) {
      return const OperationResult(
        success: false,
        message: 'An update is already downloading.',
      );
    }
    final assetUrl = update.installerUrl;
    final digest = update.installerSha256;
    if (assetUrl == null ||
        !_version.hasMatch(update.version) ||
        !_validInstallerUrl(assetUrl, update.version) ||
        digest == null ||
        !_digest.hasMatch(digest) ||
        update.installerSize == null ||
        update.installerSize! <= 0 ||
        update.installerSize! > _maxInstallerBytes) {
      return const OperationResult(
        success: false,
        message:
            'No verified installer is available. Open the official release page instead.',
      );
    }
    // Dry-run must not download or execute an actual installer.
    if (_processRunner.isDryRun) {
      return const OperationResult(
        success: true,
        message: '[dry-run] Verified update installation simulated.',
      );
    }
    _installing = true;
    Directory? downloadDirectory;
    var launched = false;
    try {
      await _updatesDirectory.create(recursive: true);
      await _secureDirectory(_updatesDirectory);
      downloadDirectory = await _updatesDirectory.createTemp(
        '${update.version}-',
      );
      await _secureDirectory(downloadDirectory);
      final installer = File(
        path.join(
          downloadDirectory.path,
          'ZapTweaks_Setup_v${update.version}.exe',
        ),
      );
      await _downloadInstaller(
        assetUrl,
        installer,
        update.installerSize!,
        onProgress,
      );
      if (await installer.length() != update.installerSize ||
          (await sha256.bind(installer.openRead()).first).toString() !=
              digest.toLowerCase()) {
        throw StateError('Installer SHA-256 or size verification failed.');
      }
      String quote(String value) => value.replaceAll("'", "''");
      final appPath = Platform.resolvedExecutable;
      final installDirectory = path.dirname(appPath);
      final helperScript =
          "\$ErrorActionPreference = 'Stop'; "
          "Wait-Process -Id $pid -ErrorAction SilentlyContinue; "
          "try { "
          "\$stream = [IO.File]::OpenRead('${quote(installer.path)}'); \$sha = [Security.Cryptography.SHA256]::Create(); "
          "try { \$hash = [BitConverter]::ToString(\$sha.ComputeHash(\$stream)).Replace('-', '').ToLowerInvariant() } finally { \$sha.Dispose(); \$stream.Dispose() }; "
          "if (\$hash -ne '${digest.toLowerCase()}') { throw 'Installer integrity check failed' }; "
          "\$installer = Start-Process -FilePath '${quote(installer.path)}' "
          "-ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/CLOSEAPPLICATIONS','/DIR=\"${quote(installDirectory)}\"') -PassThru -Wait; "
          "if (\$installer.ExitCode -eq 0 -and (Test-Path -LiteralPath '${quote(appPath)}')) { Start-Process -FilePath '${quote(appPath)}' } "
          "} finally { Remove-Item -LiteralPath '${quote(downloadDirectory.path)}' -Recurse -Force -ErrorAction SilentlyContinue }";
      final result = await _processRunner.launch('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-Command',
        helperScript,
      ]);
      if (!result.success) {
        throw StateError('Updater launch failed. ${result.details}');
      }
      launched = true;
      return OperationResult(
        success: true,
        message: 'Update ${update.version} verified. Installing now...',
        shouldExitApp: true,
      );
    } catch (error) {
      await _loggingService.logError(
        'Update installation preparation failed: $error',
        source: 'SystemActionService',
      );
      return OperationResult(success: false, message: 'Update failed: $error');
    } finally {
      _installing = false;
      if (!launched &&
          downloadDirectory != null &&
          await downloadDirectory.exists()) {
        try {
          await downloadDirectory.delete(recursive: true);
        } on FileSystemException catch (error) {
          await _loggingService.logWarning(
            'Unable to remove failed update download: $error',
            source: 'SystemActionService',
          );
        }
      }
    }
  }

  Future<void> _downloadInstaller(
    String assetUrl,
    File file,
    int expectedSize,
    void Function(int, int?)? onProgress,
  ) async {
    final abort = Completer<void>();
    final deadline = Timer(const Duration(minutes: 2), () => abort.complete());
    try {
      var uri = Uri.parse(assetUrl);
      late http.StreamedResponse response;
      for (var redirects = 0; ; redirects++) {
        response = await _httpClient.send(
          http.AbortableRequest('GET', uri, abortTrigger: abort.future)
            ..followRedirects = false
            ..headers['Accept'] = 'application/octet-stream',
        );
        if (![301, 302, 303, 307, 308].contains(response.statusCode)) break;
        final location = response.headers['location'];
        if (redirects >= 3 || location == null) {
          throw StateError('Invalid installer redirect.');
        }
        uri = uri.resolve(location);
        if (uri.scheme != 'https' ||
            uri.port != 443 ||
            uri.userInfo.isNotEmpty ||
            !{
              'release-assets.githubusercontent.com',
              'objects.githubusercontent.com',
            }.contains(uri.host)) {
          throw StateError(
            'Installer redirect left trusted GitHub asset hosts.',
          );
        }
        await response.stream.drain<void>();
      }
      if (response.statusCode != 200 ||
          (response.contentLength != null &&
              response.contentLength != expectedSize)) {
        throw StateError('Invalid installer download response.');
      }
      final output = await file.open(mode: FileMode.writeOnly);
      var received = 0;
      try {
        onProgress?.call(0, expectedSize);
        await for (final chunk in response.stream) {
          received += chunk.length;
          if (received > expectedSize) {
            throw StateError('Installer exceeds expected size.');
          }
          await output.writeFrom(chunk);
          onProgress?.call(received, expectedSize);
        }
        await output.flush();
      } finally {
        await output.close();
      }
    } finally {
      deadline.cancel();
      if (!abort.isCompleted) abort.complete();
    }
  }

  static bool _validInstallerUrl(String value, String version) =>
      value ==
      '$releasesPageUrl/download/v$version/ZapTweaks_Setup_v$version.exe';

  bool _isRemoteVersionNewer(String remoteVersion, String localVersion) {
    List<int> parts(String version) => version
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final remote = parts(remoteVersion), local = parts(localVersion);
    for (var i = 0; i < remote.length || i < local.length; i++) {
      final a = i < remote.length ? remote[i] : 0,
          b = i < local.length ? local[i] : 0;
      if (a != b) return a > b;
    }
    return false;
  }
}
