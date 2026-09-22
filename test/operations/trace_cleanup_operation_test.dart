import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/trace_cleanup_operation.dart';

void main() {
  const request = OperationRequest(
    operationId: 'diagnostics.trace.cleanup',
    desiredValue: true,
  );

  test(
    'trace cleanup snapshots the preview before verified deletion',
    () async {
      final directory = await Directory.systemTemp.createTemp('zap-cleanup-');
      addTearDown(() => directory.delete(recursive: true));
      await File('${directory.path}/trace.etl').writeAsBytes(<int>[1, 2]);
      await File('${directory.path}/trace.etl.report.json').writeAsString('{}');
      final operation = TraceCleanupOperation(directory: directory);

      final snapshot = await operation.captureSnapshot(request);
      expect(snapshot.data['before'], <String, Object>{
        'fileCount': 2,
        'totalBytes': 4,
      });

      await operation.apply(request);
      final state = await operation.verify(request);
      expect(state.kind, OperationStateKind.configured);
      expect(state.value, isTrue);
      expect(directory.listSync(), isEmpty);
    },
  );

  test('trace cleanup rejects caller-selected paths', () async {
    final support = await TraceCleanupOperation().supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      const OperationRequest(
        operationId: 'diagnostics.trace.cleanup',
        desiredValue: true,
        parameters: <String, Object?>{'path': r'C:\'},
      ),
    );
    expect(support.supported, isFalse);
  });
}
