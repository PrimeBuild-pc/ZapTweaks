import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'logging_service.dart';

enum ProcessExecutionMode { production, dryRun }

typedef ProcessRunDelegate =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      bool runInShell,
    });

typedef ProcessStartDelegate =
    Future<Process> Function(
      String executable,
      List<String> arguments, {
      bool runInShell,
    });

class CommandResult {
  const CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    this.wasDryRun = false,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final bool wasDryRun;

  bool get success => exitCode == 0;

  String get details {
    if (stderr.trim().isNotEmpty) {
      return stderr.trim();
    }
    return stdout.trim();
  }
}

class ProcessRunner {
  ProcessRunner({
    LoggingService? loggingService,
    ProcessExecutionMode mode = ProcessExecutionMode.production,
    Duration dryRunDelay = const Duration(seconds: 2),
    ProcessRunDelegate? processRunDelegate,
    ProcessStartDelegate? processStartDelegate,
    List<String>? trustedPathRoots,
    Set<String>? allowedSystemExecutables,
  }) : _loggingService = loggingService ?? LoggingService.instance,
       _mode = mode,
       _dryRunDelay = dryRunDelay,
       _processRunDelegate = processRunDelegate ?? Process.run,
       _processStartDelegate = processStartDelegate ?? Process.start,
       _trustedPathRoots = _normalizeRoots(
         trustedPathRoots ?? _defaultTrustedRoots(),
       ),
       _allowedSystemExecutables =
           (allowedSystemExecutables ?? _defaultAllowedSystemExecutables)
               .map((value) => value.trim().toLowerCase())
               .where((value) => value.isNotEmpty)
               .toSet();

  static ProcessRunner _shared = ProcessRunner();

  static ProcessRunner get shared => _shared;

  static void configureShared(ProcessRunner runner) {
    _shared = runner;
  }

  final LoggingService _loggingService;
  final Duration _dryRunDelay;
  final ProcessRunDelegate _processRunDelegate;
  final ProcessStartDelegate _processStartDelegate;
  final List<String> _trustedPathRoots;
  final Set<String> _allowedSystemExecutables;

  ProcessExecutionMode _mode;

  static const Set<String> _defaultAllowedSystemExecutables = <String>{
    'powershell',
    'powershell.exe',
    'pwsh',
    'pwsh.exe',
    'cmd',
    'cmd.exe',
    'reg',
    'reg.exe',
    'net',
    'net.exe',
    'shutdown',
    'shutdown.exe',
    'powercfg',
    'powercfg.exe',
    'sc',
    'sc.exe',
    'fsutil',
    'fsutil.exe',
    'explorer',
    'explorer.exe',
    'bcdedit',
    'bcdedit.exe',
  };

  ProcessExecutionMode get mode => _mode;

  bool get isDryRun => _mode == ProcessExecutionMode.dryRun;

  void setMode(ProcessExecutionMode nextMode) {
    _mode = nextMode;
  }

  Future<CommandResult> launch(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final startedAt = DateTime.now();
    final requestError = _validateExecutionRequest(executable, arguments);
    if (requestError != null) {
      await _loggingService.logWarning(requestError, source: 'ProcessRunner');
      return CommandResult(exitCode: -1, stdout: '', stderr: requestError);
    }

    final displayCommand = '$executable ${arguments.join(' ')}'.trim();
    await _loggingService.logInfo(
      'Launching command: $displayCommand',
      source: 'ProcessRunner',
    );

    if (isDryRun) {
      final elapsed = await _simulateDryRunDelay(timeout);
      final response = const CommandResult(
        exitCode: 0,
        stdout: '[dry-run] launch simulated',
        stderr: '',
        wasDryRun: true,
      );

      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: response.exitCode,
        stdout: response.stdout,
        stderr: response.stderr,
        duration: elapsed,
        timedOut: false,
        dryRun: true,
      );

      return response;
    }

    try {
      await _processStartDelegate(
        executable,
        arguments,
        runInShell: runInShell,
      ).timeout(timeout);

      final elapsed = DateTime.now().difference(startedAt);
      final response = const CommandResult(exitCode: 0, stdout: '', stderr: '');
      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: response.exitCode,
        stdout: response.stdout,
        stderr: response.stderr,
        duration: elapsed,
        timedOut: false,
      );
      return response;
    } on TimeoutException {
      final elapsed = DateTime.now().difference(startedAt);
      const timeoutResult = CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Command launch timed out.',
      );
      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: timeoutResult.exitCode,
        stdout: timeoutResult.stdout,
        stderr: timeoutResult.stderr,
        duration: elapsed,
        timedOut: true,
      );
      return timeoutResult;
    } on ProcessException catch (error) {
      final elapsed = DateTime.now().difference(startedAt);
      final exceptionResult = CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: error.message,
      );
      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: exceptionResult.exitCode,
        stdout: exceptionResult.stdout,
        stderr: exceptionResult.stderr,
        duration: elapsed,
        timedOut: false,
      );
      return exceptionResult;
    }
  }

  Future<CommandResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final startedAt = DateTime.now();
    final requestError = _validateExecutionRequest(executable, arguments);
    if (requestError != null) {
      await _loggingService.logWarning(requestError, source: 'ProcessRunner');
      return CommandResult(exitCode: -1, stdout: '', stderr: requestError);
    }

    await _loggingService.logInfo(
      'Running command: $executable ${arguments.join(' ')}',
      source: 'ProcessRunner',
    );

    if (isDryRun) {
      final elapsed = await _simulateDryRunDelay(timeout);
      const response = CommandResult(
        exitCode: 0,
        stdout: '[dry-run] execution simulated',
        stderr: '',
        wasDryRun: true,
      );

      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: response.exitCode,
        stdout: response.stdout,
        stderr: response.stderr,
        duration: elapsed,
        timedOut: false,
        dryRun: true,
      );

      return response;
    }

    try {
      final result = await _processRunDelegate(
        executable,
        arguments,
        runInShell: runInShell,
      ).timeout(timeout);

      final elapsed = DateTime.now().difference(startedAt);

      final response = CommandResult(
        exitCode: result.exitCode,
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
      );

      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: response.exitCode,
        stdout: response.stdout,
        stderr: response.stderr,
        duration: elapsed,
        timedOut: false,
      );

      return response;
    } on TimeoutException {
      final elapsed = DateTime.now().difference(startedAt);
      final timeoutResult = const CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Command timed out.',
      );

      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: timeoutResult.exitCode,
        stdout: timeoutResult.stdout,
        stderr: timeoutResult.stderr,
        duration: elapsed,
        timedOut: true,
      );

      return timeoutResult;
    } on ProcessException catch (error) {
      final elapsed = DateTime.now().difference(startedAt);
      final exceptionResult = CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: error.message,
      );

      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: exceptionResult.exitCode,
        stdout: exceptionResult.stdout,
        stderr: exceptionResult.stderr,
        duration: elapsed,
        timedOut: false,
      );

      return exceptionResult;
    } catch (error) {
      final elapsed = DateTime.now().difference(startedAt);
      final unexpectedResult = CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: error.toString(),
      );

      await _loggingService.logCommandExecution(
        executable: executable,
        arguments: arguments,
        exitCode: unexpectedResult.exitCode,
        stdout: unexpectedResult.stdout,
        stderr: unexpectedResult.stderr,
        duration: elapsed,
        timedOut: false,
      );

      return unexpectedResult;
    }
  }

  String? _validateExecutionRequest(String executable, List<String> arguments) {
    final normalizedExecutable = executable.trim();
    if (normalizedExecutable.isEmpty) {
      return 'Executable cannot be empty.';
    }

    if (_hasDisallowedControlCharacters(normalizedExecutable)) {
      return 'Executable contains invalid control characters.';
    }

    for (final argument in arguments) {
      if (_hasDisallowedControlCharacters(argument)) {
        return 'One or more command arguments contain invalid control characters.';
      }
    }

    if (_isAllowedSystemExecutable(normalizedExecutable)) {
      return null;
    }

    final absoluteExecutablePath = path.normalize(
      path.absolute(normalizedExecutable),
    );
    if (!_isUnderTrustedRoot(absoluteExecutablePath)) {
      return 'Execution blocked: path is outside trusted roots ($absoluteExecutablePath).';
    }

    final extension = path.extension(absoluteExecutablePath).toLowerCase();
    const allowedExtensions = <String>{'.exe', '.cmd', '.bat', '.ps1'};
    if (!allowedExtensions.contains(extension)) {
      return 'Execution blocked: unsupported executable type ($extension).';
    }

    if (!File(absoluteExecutablePath).existsSync()) {
      return 'Executable not found: $absoluteExecutablePath';
    }

    return null;
  }

  bool _isAllowedSystemExecutable(String executable) {
    if (_looksLikePath(executable)) {
      return false;
    }

    return _allowedSystemExecutables.contains(executable.trim().toLowerCase());
  }

  bool _isUnderTrustedRoot(String candidatePath) {
    final normalizedCandidate = _normalizePath(candidatePath);

    for (final trustedRoot in _trustedPathRoots) {
      if (normalizedCandidate == trustedRoot) {
        return true;
      }

      if (normalizedCandidate.startsWith('$trustedRoot\\') ||
          normalizedCandidate.startsWith('$trustedRoot/')) {
        return true;
      }
    }

    return false;
  }

  bool _looksLikePath(String executable) {
    return executable.contains('\\') ||
        executable.contains('/') ||
        executable.contains(':');
  }

  bool _hasDisallowedControlCharacters(String value) {
    return value.runes.any(
      (codePoint) =>
          codePoint == 0 ||
          (codePoint >= 0x00 && codePoint <= 0x1F && codePoint != 0x09),
    );
  }

  Future<Duration> _simulateDryRunDelay(Duration timeout) async {
    final startedAt = DateTime.now();
    final safeDelay = timeout < _dryRunDelay ? timeout : _dryRunDelay;
    if (safeDelay > Duration.zero) {
      await Future<void>.delayed(safeDelay);
    }
    return DateTime.now().difference(startedAt);
  }

  static List<String> _normalizeRoots(List<String> roots) {
    final normalized = roots
        .map(_normalizePath)
        .where((root) => root.isNotEmpty)
        .toSet()
        .toList();
    normalized.sort();
    return normalized;
  }

  static String _normalizePath(String inputPath) {
    return path.normalize(path.absolute(inputPath)).toLowerCase();
  }

  static List<String> _defaultTrustedRoots() {
    final roots = <String>[];
    final executableDirectory = path.dirname(Platform.resolvedExecutable);

    roots.add(
      path.join(executableDirectory, 'data', 'flutter_assets', 'resources'),
    );
    roots.add(path.join(executableDirectory, 'resources'));
    roots.add(path.join(Directory.current.path, 'resources'));

    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.trim().isNotEmpty) {
      roots.add(path.join(appData, 'ZapTweaks', 'Tools'));
    }

    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null && userProfile.trim().isNotEmpty) {
      roots.add(
        path.join(userProfile, 'AppData', 'Roaming', 'ZapTweaks', 'Tools'),
      );
    }

    return roots;
  }
}
