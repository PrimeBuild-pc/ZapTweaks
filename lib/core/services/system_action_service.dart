import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../models/operation_result.dart';
import 'logging_service.dart';
import 'process_runner.dart';

class SystemActionService {
  SystemActionService({
    required ProcessRunner processRunner,
    LoggingService? loggingService,
  }) : _processRunner = processRunner,
       _loggingService = loggingService ?? LoggingService.instance;

  final ProcessRunner _processRunner;
  final LoggingService _loggingService;

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

  Future<OperationResult> restartToBios() async {
    final result = await _processRunner.run('shutdown', <String>[
      '/r',
      '/fw',
      '/t',
      '5',
      '/c',
      'ZapTweaks: Rebooting directly to BIOS/UEFI setup.',
    ]);

    if (!result.success) {
      return OperationResult(success: false, message: result.details);
    }

    return const OperationResult(success: true);
  }

  Future<OperationResult> restartToSafeMode() async {
    final bcdResult = await _processRunner.run('cmd', <String>[
      '/c',
      'bcdedit /set {current} safeboot minimal',
    ]);

    if (!bcdResult.success) {
      return OperationResult(success: false, message: bcdResult.details);
    }

    final shutdown = await _processRunner.run('shutdown', <String>[
      '/r',
      '/t',
      '5',
      '/c',
      'ZapTweaks: Rebooting to Safe Mode.',
    ]);

    if (!shutdown.success) {
      return OperationResult(success: false, message: shutdown.details);
    }

    return const OperationResult(success: true);
  }

  Future<OperationResult> openExternalScriptCommand({
    required String title,
    required String command,
  }) async {
    final result = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      'Start-Process -FilePath powershell -Verb RunAs -ArgumentList @('
          "'-NoExit','-ExecutionPolicy','Bypass','-Command','"
          '${command.replaceAll("'", "''")}'
          "')",
    ]);

    if (!result.success) {
      return OperationResult(
        success: false,
        message: 'Failed to launch $title. ${result.details}',
      );
    }

    return OperationResult(success: true, message: '$title launched.');
  }

  Future<OperationResult> checkForUpdates({
    required String currentVersion,
    required String latestReleaseApiUrl,
    required String releasesPageUrl,
    bool autoInstall = true,
  }) async {
    try {
      await _loggingService.logInfo(
        'Checking for updates against GitHub API.',
        source: 'SystemActionService',
      );

      final response = await http.get(
        Uri.parse(latestReleaseApiUrl),
        headers: <String, String>{
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'ZapTweaks/$currentVersion',
        },
      );

      if (response.statusCode != 200) {
        return OperationResult(
          success: false,
          message: 'GitHub API returned ${response.statusCode}.',
        );
      }

      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        return const OperationResult(
          success: false,
          message: 'Invalid update response.',
        );
      }

      final tagName = (payload['tag_name'] ?? '').toString().trim();
      if (tagName.isEmpty) {
        return const OperationResult(
          success: false,
          message: 'Latest release version not found.',
        );
      }

      final latestVersion = _normalizeVersion(tagName);
      final hasUpdate = _isRemoteVersionNewer(latestVersion, currentVersion);
      if (!hasUpdate) {
        await _loggingService.logInfo(
          'No updates found. Current version: $currentVersion.',
          source: 'SystemActionService',
        );

        return OperationResult(
          success: true,
          message: 'You are running the latest version ($currentVersion).',
        );
      }

      await _loggingService.logInfo(
        'Update found. Latest version: $latestVersion.',
        source: 'SystemActionService',
      );

      if (!autoInstall) {
        final launched = await launchUrl(
          Uri.parse(releasesPageUrl),
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          return const OperationResult(
            success: false,
            message: 'Unable to open the releases page.',
          );
        }

        return OperationResult(
          success: true,
          message: 'Update detected: $latestVersion. Releases page opened.',
        );
      }

      final assetUrl = _extractInstallerAssetUrl(payload);
      if (assetUrl == null) {
        return OperationResult(
          success: false,
          message:
              'Update detected ($latestVersion) but no installer asset was found.',
        );
      }

      final downloadedInstaller = await _downloadInstaller(
        assetUrl: assetUrl,
        targetVersion: latestVersion,
      );
      if (downloadedInstaller == null) {
        return const OperationResult(
          success: false,
          message: 'Failed to download update installer.',
        );
      }

      final launchResult = await _processRunner.launch('cmd', <String>[
        '/c',
        'start',
        '""',
        downloadedInstaller,
        '/SILENT',
        '/VERYSILENT',
      ]);

      if (!launchResult.success) {
        return OperationResult(
          success: false,
          message: 'Installer launch failed. ${launchResult.details}',
        );
      }

      final terminateResult = await _processRunner.run('cmd', <String>[
        '/c',
        'timeout /t 2 >nul && taskkill /f /pid $pid',
      ]);

      if (!terminateResult.success && !terminateResult.wasDryRun) {
        await _loggingService.logWarning(
          'Installer launched but app self-termination command failed: ${terminateResult.details}',
          source: 'SystemActionService',
        );
      }

      return OperationResult(
        success: true,
        message: 'Update $latestVersion downloaded and installer launched.',
        shouldExitApp: true,
      );
    } catch (error) {
      await _loggingService.logError(
        'Update check failed: $error',
        source: 'SystemActionService',
      );
      return OperationResult(success: false, message: error.toString());
    }
  }

  String? _extractInstallerAssetUrl(Map<String, dynamic> payload) {
    final assets = payload['assets'];
    if (assets is! List<dynamic>) {
      return null;
    }

    for (final item in assets) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final downloadUrl = (item['browser_download_url'] ?? '')
          .toString()
          .trim();
      final name = (item['name'] ?? '').toString().toLowerCase();
      if (downloadUrl.isEmpty) {
        continue;
      }

      if (name.endsWith('.exe') ||
          name.endsWith('.msi') ||
          name.contains('setup')) {
        return downloadUrl;
      }
    }

    return null;
  }

  Future<String?> _downloadInstaller({
    required String assetUrl,
    required String targetVersion,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(assetUrl),
        headers: const <String, String>{'Accept': 'application/octet-stream'},
      );

      if (response.statusCode != 200) {
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
