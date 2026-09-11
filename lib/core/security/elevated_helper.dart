import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../models/tweak_descriptor.dart';
import '../services/restore_point_service.dart';
import '../services/tweak_catalog_service.dart';
import '../tweak_manager.dart';

Directory defaultElevatedHelperDirectory() => Directory(
  '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}'
  '${Platform.pathSeparator}ZapTweaks${Platform.pathSeparator}Helper',
);

typedef HelperLauncher =
    Future<int> Function(String executable, File request, String nonce);
typedef DirectorySecurity = Future<void> Function(Directory directory);

class ElevatedHelperResult {
  const ElevatedHelperResult({
    required this.success,
    this.observed,
    this.message,
  });

  final bool success;
  final bool? observed;
  final String? message;
}

class ElevatedHelperClient {
  ElevatedHelperClient({
    required Directory directory,
    HelperLauncher? launcher,
    DirectorySecurity? secureDirectory,
  }) : _directory = directory,
       _launcher = launcher ?? _launchElevated,
       _secureDirectory = secureDirectory ?? _applyWindowsAcl;

  final Directory _directory;
  final HelperLauncher _launcher;
  final DirectorySecurity _secureDirectory;

  Future<ElevatedHelperResult> applySystemTweak({
    required String operationId,
    required bool desiredValue,
    required bool createRestorePoint,
  }) async {
    await _directory.create(recursive: true);
    await _secureDirectory(_directory);
    final nonce = _nonce();
    final request = File(
      '${_directory.path}${Platform.pathSeparator}$nonce.json',
    );
    final response = File('${request.path}.response');
    await request.writeAsString(
      jsonEncode(<String, Object?>{
        'nonce': nonce,
        'operationId': operationId,
        'desiredValue': desiredValue,
        'createRestorePoint': createRestorePoint,
      }),
      flush: true,
    );
    try {
      final exitCode = await _launcher(
        Platform.resolvedExecutable,
        request,
        nonce,
      );
      if (!await response.exists()) {
        return ElevatedHelperResult(
          success: false,
          message: 'Elevated helper failed with exit code $exitCode.',
        );
      }
      final json =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      return ElevatedHelperResult(
        success: json['success'] == true,
        observed: json['observed'] as bool?,
        message: json['message'] as String?,
      );
    } finally {
      if (await request.exists()) await request.delete();
      if (await response.exists()) await response.delete();
    }
  }

  static Future<void> _applyWindowsAcl(Directory directory) async {
    if (!Platform.isWindows) return;
    final domain = Platform.environment['USERDOMAIN'];
    final user = Platform.environment['USERNAME'];
    if (domain == null || user == null) {
      throw StateError('Unable to identify the helper directory owner.');
    }
    final result = await Process.run('icacls.exe', <String>[
      directory.path,
      '/inheritance:r',
      '/grant:r',
      '$domain\\$user:(OI)(CI)F',
      '*S-1-5-18:(OI)(CI)F',
      '*S-1-5-32-544:(OI)(CI)F',
    ]);
    if (result.exitCode != 0) {
      throw StateError('Unable to secure the elevated helper directory.');
    }
  }

  static Future<int> _launchElevated(
    String executable,
    File request,
    String nonce,
  ) async {
    String quote(String value) => value.replaceAll("'", "''");
    final encodedPath = base64Url.encode(utf8.encode(request.path));
    final script =
        "\$p=Start-Process -FilePath '${quote(executable)}' "
        "-Verb RunAs -Wait -PassThru -ArgumentList @("
        "'--zaptweaks-helper','$encodedPath','$nonce'); "
        'exit \$p.ExitCode';
    final encoded = base64.encode(const Utf16Encoder().convert(script));
    final result = await Process.run('powershell.exe', <String>[
      '-NoProfile',
      '-NonInteractive',
      '-EncodedCommand',
      encoded,
    ]);
    return result.exitCode;
  }

  static String _nonce() {
    final random = Random.secure();
    return List<int>.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

class ElevatedHelperHost {
  ElevatedHelperHost({
    required Directory allowedDirectory,
    required TweakCatalogService catalogService,
    required TweakManager tweakManager,
    required RestorePointService restorePointService,
  }) : _allowedDirectory = allowedDirectory,
       _catalogService = catalogService,
       _tweakManager = tweakManager,
       _restorePointService = restorePointService;

  final Directory _allowedDirectory;
  final TweakCatalogService _catalogService;
  final TweakManager _tweakManager;
  final RestorePointService _restorePointService;

  Future<int> run(File requestFile, String expectedNonce) async {
    File? response;
    try {
      final noncePattern = RegExp(r'^[0-9a-f]{64}$');
      final expectedDirectory = _allowedDirectory.absolute.path.toLowerCase();
      final actualDirectory = requestFile.parent.absolute.path.toLowerCase();
      if (actualDirectory != expectedDirectory ||
          !noncePattern.hasMatch(expectedNonce) ||
          requestFile.uri.pathSegments.last != '$expectedNonce.json') {
        throw StateError('Invalid helper request identity.');
      }
      if (!await requestFile.exists() || await requestFile.length() > 4096) {
        throw StateError('Invalid helper request file.');
      }
      response = File('${requestFile.path}.response');
      final json =
          jsonDecode(await requestFile.readAsString()) as Map<String, dynamic>;
      if (json.length != 4 ||
          json['nonce'] != expectedNonce ||
          json['operationId'] is! String ||
          json['desiredValue'] is! bool ||
          json['createRestorePoint'] is! bool) {
        throw StateError('Invalid helper request payload.');
      }
      TweakDescriptor? descriptor;
      for (final candidate in _catalogService.buildCatalog()) {
        if (candidate.id == json['operationId']) {
          descriptor = candidate;
          break;
        }
      }
      if (descriptor == null || !descriptor.isSystemToggle) {
        throw StateError('Operation is not helper-allowlisted.');
      }

      String? restoreMessage;
      if (json['createRestorePoint'] == true) {
        final restore = await _restorePointService.createRestorePoint(
          description: 'ZapTweaks_PreChange',
        );
        if (!restore.success) restoreMessage = restore.message;
      }
      final desired = json['desiredValue'] as bool;
      final applied = await _tweakManager.applyTweak(
        descriptor.systemKey!,
        desired,
      );
      final observed = applied.success
          ? await _tweakManager.detectTweakState(descriptor.systemKey!)
          : null;
      final success = applied.success && observed == desired;
      await _writeAtomic(response, <String, Object?>{
        'success': success,
        'observed': observed,
        if (!success) 'message': applied.errors.join('\n'),
        if (restoreMessage != null) 'restorePointMessage': restoreMessage,
      });
      return success ? 0 : 1;
    } catch (error) {
      if (response != null) {
        await _writeAtomic(response, <String, Object?>{
          'success': false,
          'message': error.toString(),
        });
      }
      return 2;
    }
  }

  static Future<void> _writeAtomic(
    File file,
    Map<String, Object?> value,
  ) async {
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(value), flush: true);
    await temporary.rename(file.path);
  }
}

class Utf16Encoder {
  const Utf16Encoder();

  List<int> convert(String value) => value.codeUnits
      .expand((unit) => <int>[unit & 0xff, unit >> 8])
      .toList(growable: false);
}
