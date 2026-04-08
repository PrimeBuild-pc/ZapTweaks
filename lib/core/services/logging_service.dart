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

  final List<LogEntry> _sessionEntries = <LogEntry>[];

  String? _logDirectoryPath;
  String? _currentSessionLogPath;
  bool _initialized = false;
  Future<void> _writeQueue = Future<void>.value();

  List<LogEntry> get sessionEntries =>
      List<LogEntry>.unmodifiable(_sessionEntries);

  String? get logsDirectoryPath => _logDirectoryPath;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final appData = _resolveAppDataPath();
    _logDirectoryPath = path.join(appData, 'ZapTweaks', 'logs');

    final directory = Directory(_logDirectoryPath!);
    await directory.create(recursive: true);

    final sessionStamp = _formatForFileName(DateTime.now());
    _currentSessionLogPath = path.join(
      _logDirectoryPath!,
      'session_$sessionStamp.log',
    );

    final header =
        '--- ZapTweaks session started at ${DateTime.now().toIso8601String()} ---';
    _initialized = true;

    final file = File(_currentSessionLogPath!);
    await file.writeAsString('$header\n', mode: FileMode.append, flush: true);
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

  Future<String> readLastSessionLog() async {
    await initialize();

    final directory = Directory(_logDirectoryPath!);
    if (!directory.existsSync()) {
      return 'No logs directory found.';
    }

    final files =
        directory
            .listSync(followLinks: false)
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.log'))
            .toList()
          ..sort(
            (left, right) =>
                right.lastModifiedSync().compareTo(left.lastModifiedSync()),
          );

    if (files.isEmpty) {
      return 'No log sessions found.';
    }

    File selected = files.first;
    if (files.length > 1 && selected.path == _currentSessionLogPath) {
      selected = files[1];
    }

    try {
      return await selected.readAsString();
    } on FileSystemException catch (error) {
      return 'Unable to read logs: ${error.message}';
    }
  }

  Future<String> readCurrentSessionLog() async {
    await initialize();
    final currentPath = _currentSessionLogPath;
    if (currentPath == null) {
      return 'Current session log is unavailable.';
    }

    final file = File(currentPath);
    if (!file.existsSync()) {
      return 'Current session log file not found.';
    }

    try {
      return await file.readAsString();
    } on FileSystemException catch (error) {
      return 'Unable to read current session logs: ${error.message}';
    }
  }

  Future<void> _log(LogEntry entry) async {
    _sessionEntries.add(entry);
    await _appendRawLine(entry.toLine());
  }

  Future<void> _appendRawLine(String line) async {
    if (!_initialized) {
      await initialize();
    }

    final logPath = _currentSessionLogPath;
    if (logPath == null) {
      return;
    }

    _writeQueue = _writeQueue.then((_) async {
      final file = File(logPath);
      await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    });

    await _writeQueue;
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
