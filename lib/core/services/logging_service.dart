import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

class LogEntry {
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
  });

  final DateTime timestamp;
  final String level;
  final String source;
  final String message;

  String toLine() {
    final time = timestamp.toIso8601String();
    return '[$time] [$level] [$source] $message';
  }
}

class LoggingService {
  LoggingService._();

  static final LoggingService instance = LoggingService._();

  bool _initialized = false;
  IOSink? _sink;
  Timer? _flushTimer;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final logDirectoryPath = path.join(
      _resolveAppDataPath(),
      'ZapTweaks',
      'logs',
    );
    await Directory(logDirectoryPath).create(recursive: true);

    final sessionStamp = _formatForFileName(DateTime.now());
    final header =
        '--- ZapTweaks session started at ${DateTime.now().toIso8601String()} ---';
    _initialized = true;

    final file = File(path.join(logDirectoryPath, 'session_$sessionStamp.log'));
    await file.writeAsString('$header\n', mode: FileMode.append);
    _sink = file.openWrite(mode: FileMode.append);
  }

  Future<void> logInfo(String message, {String source = 'App'}) {
    return _log(
      LogEntry(
        timestamp: DateTime.now(),
        level: 'INFO',
        source: source,
        message: message,
      ),
    );
  }

  Future<void> logWarning(String message, {String source = 'App'}) {
    return _log(
      LogEntry(
        timestamp: DateTime.now(),
        level: 'WARN',
        source: source,
        message: message,
      ),
    );
  }

  Future<void> logError(String message, {String source = 'App'}) {
    return _log(
      LogEntry(
        timestamp: DateTime.now(),
        level: 'ERROR',
        source: source,
        message: message,
      ),
    );
  }

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
    final command = '$executable ${arguments.join(' ')}'.trim();
    final status = timedOut
        ? 'timeout'
        : (dryRun ? 'dry-run simulated' : 'completed');

    await logInfo(
      'Command $status (exitCode=$exitCode, duration=${duration.inMilliseconds}ms): $command',
      source: source,
    );

    final stdOutText = stdout.trim();
    if (stdOutText.isNotEmpty) {
      await logInfo('stdout: $stdOutText', source: source);
    }

    final stdErrText = stderr.trim();
    if (stdErrText.isNotEmpty) {
      await logWarning('stderr: $stdErrText', source: source);
    }
  }

  Future<void> _log(LogEntry entry) => _appendRawLine(entry.toLine());

  Future<void> _appendRawLine(String line) async {
    if (!_initialized) {
      await initialize();
    }

    _sink?.writeln(line);
    _flushTimer ??= Timer(const Duration(seconds: 1), () {
      _flushTimer = null;
      _sink?.flush();
    });
  }

  String _resolveAppDataPath() {
    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.trim().isNotEmpty) {
      return appData;
    }

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
