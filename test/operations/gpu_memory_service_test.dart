import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/gpu_memory_service.dart';

void main() {
  test('GPU memory snapshot parses locale-independent CIM JSON', () async {
    final service = WindowsGpuMemoryService(
      processRunner: ProcessRunner(
        processRunDelegate:
            (executable, arguments, {runInShell = false}) async =>
                ProcessResult(
                  1,
                  0,
                  '{"dedicatedBytes":1048576,"samples":2}',
                  '',
                ),
      ),
    );

    final snapshot = await service.capture();

    expect(snapshot.dedicatedBytes, 1048576);
    expect(snapshot.samples, 2);
  });

  test('GPU memory snapshot rejects negative counter data', () async {
    final service = WindowsGpuMemoryService(
      processRunner: ProcessRunner(
        processRunDelegate:
            (executable, arguments, {runInShell = false}) async =>
                ProcessResult(1, 0, '{"dedicatedBytes":-1,"samples":1}', ''),
      ),
    );

    expect(service.capture(), throwsFormatException);
  });
}
