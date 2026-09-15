import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/etw_trace_collector.dart';

void main() {
  test('ETW collector always stops and verifies its trace', () async {
    final directory = await Directory.systemTemp.createTemp('zap-etw-');
    addTearDown(() => directory.delete(recursive: true));
    final calls = <List<String>>[];
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async {
        calls.add(<String>[executable, ...arguments]);
        if (arguments.first == '-stop') {
          await File(arguments.last).writeAsBytes(<int>[1, 2, 3]);
        }
        return ProcessResult(1, 0, '', '');
      },
    );
    final collector = EtwTraceCollector(
      processRunner: runner,
      delay: (_) async {},
    );

    final trace = await collector.capture(
      directory: directory,
      duration: const Duration(seconds: 5),
    );

    expect(await trace.length(), 3);
    expect(calls.map((call) => call[1]), <String>['-start', '-stop']);
  });

  test(
    'ETW collector rejects unbounded sessions before starting WPR',
    () async {
      final directory = await Directory.systemTemp.createTemp('zap-etw-');
      addTearDown(() => directory.delete(recursive: true));
      final collector = EtwTraceCollector(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
      );

      expect(
        collector.capture(
          directory: directory,
          duration: const Duration(minutes: 10),
        ),
        throwsArgumentError,
      );
    },
  );
}
