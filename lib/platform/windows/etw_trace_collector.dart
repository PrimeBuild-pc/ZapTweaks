import 'dart:io';

import '../../core/services/process_runner.dart';
import 'etw_dpc_analyzer.dart';

class EtwTraceCollector {
  EtwTraceCollector({
    required this.processRunner,
    this.analyzer,
    Future<void> Function(Duration)? delay,
  }) : delay = delay ?? Future<void>.delayed;

  final ProcessRunner processRunner;
  final EtwDpcAnalyzer? analyzer;
  final Future<void> Function(Duration) delay;

  Future<File> capture({
    required Directory directory,
    Duration duration = const Duration(seconds: 15),
  }) async {
    if (duration < const Duration(seconds: 5) ||
        duration > const Duration(minutes: 2)) {
      throw ArgumentError('ETW duration must be between 5 and 120 seconds.');
    }
    await directory.create(recursive: true);
    final output = File(
      '${directory.path}${Platform.pathSeparator}zaptweaks-${DateTime.now().toUtc().millisecondsSinceEpoch}.etl',
    );
    final start = await processRunner.run('wpr.exe', const <String>[
      '-start',
      'GeneralProfile',
      '-filemode',
    ]);
    if (!start.success) throw StateError('WPR start failed: ${start.details}');
    Object? collectionError;
    try {
      await delay(duration);
    } catch (error) {
      collectionError = error;
    } finally {
      final stop = await processRunner.run('wpr.exe', <String>[
        '-stop',
        output.path,
      ]);
      if (!stop.success) throw StateError('WPR stop failed: ${stop.details}');
    }
    if (collectionError != null) throw collectionError;
    if (!await output.exists() || await output.length() == 0) {
      throw StateError('WPR completed without a trace file.');
    }
    await analyzer?.analyze(output);
    return output;
  }
}
