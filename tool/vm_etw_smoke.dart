import 'dart:io';

import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/etw_dpc_analyzer.dart';
import 'package:script_utility/platform/windows/etw_trace_collector.dart';

Future<void> main() async {
  final directory = Directory(
    '${Platform.environment['TEMP']}${Platform.pathSeparator}ZapTweaksEtwSmoke',
  );
  final runner = ProcessRunner.shared;
  final trace = await EtwTraceCollector(
    processRunner: runner,
    analyzer: EtwDpcAnalyzer(processRunner: runner),
  ).capture(directory: directory, duration: const Duration(seconds: 5));
  final report = File('${trace.path}.report.json');
  stdout.writeln('TRACE=${trace.path}');
  stdout.writeln('BYTES=${await trace.length()}');
  stdout.writeln('REPORT=${await report.readAsString()}');
  await trace.delete();
  await report.delete();
  await directory.delete(recursive: true);
  stdout.writeln('CLEAN=true');
}
