import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/etw_trace_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/etw_trace_collector.dart';

class _Collector extends EtwTraceCollector {
  _Collector()
    : super(processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun));

  @override
  Future<File> capture({
    required Directory directory,
    Duration duration = const Duration(seconds: 15),
  }) async {
    await directory.create(recursive: true);
    return File(
      '${directory.path}${Platform.pathSeparator}trace.etl',
    ).writeAsBytes(<int>[1]);
  }
}

void main() {
  test('ETW operation returns only a verified non-empty local trace', () async {
    final directory = await Directory.systemTemp.createTemp('zap-etw-op-');
    addTearDown(() => directory.delete(recursive: true));
    final operation = EtwTraceOperation(
      collector: _Collector(),
      outputDirectory: directory,
    );
    const request = OperationRequest(
      operationId: 'diagnostics.etw.capture',
      desiredValue: true,
      parameters: <String, Object?>{'durationSeconds': 15},
    );

    await operation.apply(request);
    final state = await operation.verify(request);

    expect(state.kind, OperationStateKind.configured);
    expect(state.value, endsWith('trace.etl'));
  });

  test('ETW operation rejects captures longer than two minutes', () async {
    final operation = EtwTraceOperation(collector: _Collector());
    const request = OperationRequest(
      operationId: 'diagnostics.etw.capture',
      desiredValue: true,
      parameters: <String, Object?>{'durationSeconds': 121},
    );
    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      request,
    );
    expect(support.supported, isFalse);
  });
}
