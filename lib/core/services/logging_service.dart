import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

class LoggingService {
  LoggingService._();

  static final LoggingService instance = LoggingService._();

  bool _initialized = false;
  File? _file;
  Future<void>? _initialization;
  Future<void> _writeQueue = Future<void>.value();

  String get logDirectoryPath =>
      path.join(_resolveAppDataPath(), 'ZapTweaks', 'logs');

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    final logDirectoryPath = this.logDirectoryPath;
    await Directory(logDirectoryPath).create(recursive: true);

    final sessionStamp = _formatForFileName(DateTime.now());
    final header =
        '--- ZapTweaks session started at ${DateTime.now().toIso8601String()} ---';
    final file = File(
      path.join(logDirectoryPath, 'session_${sessionStamp}_$pid.log'),
    );
    await file.writeAsString('$header\n', mode: FileMode.append);
    _file = file;
    _initialized = true;
  }

  Future<void> logInfo(String message, {String source = 'App'}) =>
      _log('INFO', source, message);

  Future<void> logWarning(String message, {String source = 'App'}) =>
      _log('WARN', source, message);

  Future<void> logError(String message, {String source = 'App'}) =>
      _log('ERROR', source, message);

  Future<void> logCommandExecution({
    required String executable,
    required List<String> arguments,
    required int exitCode,
    required String stdout,
    required String stderr,
    required Duration duration,
    required bool timedOut,
    bool dryRun = false,
    String source = 'ProcessRunner',
  }) async {
    final status = timedOut
        ? 'timeout'
        : (dryRun ? 'dry-run simulated' : 'completed');

    await logInfo(
      'Command $status (exitCode=$exitCode, duration=${duration.inMilliseconds}ms): '
      '${_formatCommand(executable, arguments)}',
      source: source,
    );

    if (stdout.trim().isNotEmpty) {
      await logInfo('stdout: $stdout', source: source);
    }
    if (stderr.trim().isNotEmpty) {
      await logWarning('stderr: $stderr', source: source);
    }
  }

  Future<void> _log(String level, String source, String message) {
    final line =
        '[${DateTime.now().toIso8601String()}] [$level] [$source] '
        '${_bounded(message)}';
    _writeQueue = _writeQueue.then((_) async {
      try {
        await _appendRawLine(line);
      } on FileSystemException {
        // Logging must never block a system tweak when storage is unavailable.
      }
    });
    return _writeQueue;
  }

  Future<void> _appendRawLine(String line) async {
    if (!_initialized) await initialize();
    await _file?.writeAsString('$line\n', mode: FileMode.append);
  }

  String _formatCommand(String executable, List<String> arguments) {
    final safe = <String>[];
    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      if (index > 0 &&
          const <String>{
            '-command',
            '-encodedcommand',
          }.contains(arguments[index - 1].toLowerCase())) {
        safe.add('<script:${argument.length} chars>');
      } else {
        safe.add(
          argument.length <= 256 ? argument : '${argument.substring(0, 256)}…',
        );
      }
    }
    return '$executable ${safe.join(' ')}'.trim();
  }

  String _bounded(String value, [int limit = 4096]) {
    final singleLine = value
        .trim()
        .replaceAll('\r', r'\r')
        .replaceAll('\n', r'\n');
    return singleLine.length <= limit
        ? singleLine
        : '${singleLine.substring(0, limit)}…';
  }

  String _resolveAppDataPath() {
    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.trim().isNotEmpty) return appData;

    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null && userProfile.trim().isNotEmpty) {
      return path.join(userProfile, 'AppData', 'Roaming');
    }

    return Directory.current.path;
  }

  String _formatForFileName(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${dateTime.year}${twoDigits(dateTime.month)}${twoDigits(dateTime.day)}_'
        '${twoDigits(dateTime.hour)}${twoDigits(dateTime.minute)}${twoDigits(dateTime.second)}';
  }
}
