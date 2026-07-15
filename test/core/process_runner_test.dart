import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:script_utility/core/services/logging_service.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProcessRunner dry-run', () {
    test('simulates run without invoking process delegate', () async {
      var runCalls = 0;

      final runner = ProcessRunner(
        loggingService: LoggingService.instance,
        mode: ProcessExecutionMode.dryRun,
        dryRunDelay: const Duration(milliseconds: 20),
        processRunDelegate:
            (
              String executable,
              List<String> arguments, {
              bool runInShell = false,
            }) async {
              runCalls++;
              throw StateError('should not execute in dry-run');
            },
      );

      final result = await runner.run('cmd', <String>['/c', 'ver']);

      expect(result.success, isTrue);
      expect(result.wasDryRun, isTrue);
      expect(runCalls, 0);
    });

    test('simulates launch without invoking process delegate', () async {
      var startCalls = 0;

      final runner = ProcessRunner(
        loggingService: LoggingService.instance,
        mode: ProcessExecutionMode.dryRun,
        dryRunDelay: const Duration(milliseconds: 20),
        processStartDelegate:
            (
              String executable,
              List<String> arguments, {
              bool runInShell = false,
            }) async {
              startCalls++;
              throw StateError('should not execute in dry-run');
            },
      );

      final result = await runner.launch('powershell', <String>['-NoProfile']);

      expect(result.success, isTrue);
      expect(result.wasDryRun, isTrue);
      expect(startCalls, 0);
    });
  });

  test('PowerShell helpers preserve UTF-16 scripts and output', () async {
    late List<String> capturedArguments;
    final runner = ProcessRunner(
      loggingService: LoggingService.instance,
      processRunDelegate:
          (
            String executable,
            List<String> arguments, {
            bool runInShell = false,
          }) async {
            expect(executable, 'powershell');
            capturedArguments = arguments;
            return ProcessResult(0, 0, ' result ', '');
          },
    );

    const script = 'Write-Output "è"';
    expect(await runner.runPowerShellForOutput(script), 'result');

    final bytes = base64Decode(capturedArguments.last);
    final decoded = String.fromCharCodes(<int>[
      for (var index = 0; index < bytes.length; index += 2)
        bytes[index] | (bytes[index + 1] << 8),
    ]);
    expect(decoded, script);
  });

  group('ProcessRunner security hardening', () {
    test('blocks execution outside trusted roots for absolute paths', () async {
      final root = path.join(Directory.systemTemp.path, 'trusted-root');
      final blockedExecutable = path.join(
        Directory.systemTemp.path,
        'blocked.exe',
      );

      final runner = ProcessRunner(
        loggingService: LoggingService.instance,
        mode: ProcessExecutionMode.production,
        trustedPathRoots: <String>[root],
      );

      final result = await runner.run(blockedExecutable, const <String>[]);

      expect(result.success, isFalse);
      expect(result.stderr.toLowerCase(), contains('outside trusted roots'));
    });

    test('allows trusted absolute executable paths', () async {
      final trustedRoot = await Directory(
        path.join(Directory.systemTemp.path, 'trusted-runner-test'),
      ).create(recursive: true);
      final executablePath = path.join(trustedRoot.path, 'dummy.exe');
      await File(executablePath).writeAsString('placeholder');

      var runCalls = 0;
      final runner = ProcessRunner(
        loggingService: LoggingService.instance,
        mode: ProcessExecutionMode.production,
        trustedPathRoots: <String>[trustedRoot.path],
        processRunDelegate:
            (
              String executable,
              List<String> arguments, {
              bool runInShell = false,
            }) async {
              runCalls++;
              return ProcessResult(0, 0, '', '');
            },
      );

      final result = await runner.run(executablePath, const <String>[]);

      expect(result.success, isTrue);
      expect(runCalls, 1);
    });

    test('blocks path traversal in path-like executable argument', () async {
      final trustedRoot = path.join(Directory.systemTemp.path, 'safe-root');
      final runner = ProcessRunner(
        loggingService: LoggingService.instance,
        mode: ProcessExecutionMode.production,
        trustedPathRoots: <String>[trustedRoot],
      );

      final result = await runner.run(
        path.join(trustedRoot, '..', 'evil.exe'),
        const <String>[],
      );

      expect(result.success, isFalse);
      expect(result.stderr.toLowerCase(), contains('outside trusted roots'));
    });

    test('blocks invalid control characters in arguments', () async {
      final runner = ProcessRunner(
        loggingService: LoggingService.instance,
        mode: ProcessExecutionMode.production,
      );

      final invalidArg = '/c${String.fromCharCode(0)}ver';
      final result = await runner.run('cmd', <String>[invalidArg]);

      expect(result.success, isFalse);
      expect(
        result.stderr.toLowerCase(),
        contains('invalid control characters'),
      );
    });

    test('blocks absolute path outside trusted roots on launch', () async {
      final trustedRoot = path.join(
        Directory.systemTemp.path,
        'trusted-launch-root',
      );

      final runner = ProcessRunner(
        loggingService: LoggingService.instance,
        mode: ProcessExecutionMode.production,
        trustedPathRoots: <String>[trustedRoot],
      );

      final result = await runner.launch(
        path.join(Directory.systemTemp.path, 'outside-tool.exe'),
        const <String>[],
      );

      expect(result.success, isFalse);
      expect(result.stderr.toLowerCase(), contains('outside trusted roots'));
    });
  });
}
