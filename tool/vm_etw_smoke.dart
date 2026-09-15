import 'dart:io';

import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/etw_trace_collector.dart';

Future<void> main() async {
  final directory = Directory(
    '${Platform.environment['TEMP']}${Platform.pathSeparator}ZapTweaksEtwSmoke',
  );
  final trace = await EtwTraceCollector(
    processRunner: ProcessRunner.shared,
  ).capture(directory: directory, duration: const Duration(seconds: 5));
  stdout.writeln('TRACE=${trace.path}');
  stdout.writeln('BYTES=${await trace.length()}');
  await trace.delete();
  await directory.delete(recursive: true);
  stdout.writeln('CLEAN=true');
}
