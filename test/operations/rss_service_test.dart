import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/processor_topology.dart';
import 'package:script_utility/platform/windows/rss_service.dart';

void main() {
  test('RSS adapter inventory is structured and locale independent', () async {
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async =>
          ProcessResult(1, 0, '{"names":["Ethernet","Wi-Fi"]}', ''),
    );

    expect(
      await WindowsRssService(processRunner: runner).adapterNames(),
      <String>['Ethernet', 'Wi-Fi'],
    );
  });

  test(
    'restoring enabled RSS re-enables provider before validating live limits',
    () async {
      var call = 0;
      final runner = ProcessRunner(
        processRunDelegate: (executable, arguments, {runInShell = false}) async {
          call++;
          final output = switch (call) {
            1 =>
              '{"name":"Ethernet","enabled":false,"profile":"NUMAStatic","baseGroup":0,"baseNumber":0,"maxGroup":0,"maxNumber":0,"processorCount":1,"queueCount":0,"processorArray":[{"group":0,"number":0}],"maximumQueues":0,"maximumProcessors":1}',
            2 || 4 => 'OK',
            3 =>
              '{"name":"Ethernet","enabled":true,"profile":"NUMAStatic","baseGroup":0,"baseNumber":0,"maxGroup":0,"maxNumber":0,"processorCount":1,"queueCount":1,"processorArray":[{"group":0,"number":0}],"maximumQueues":1,"maximumProcessors":1}',
            _ => throw StateError('Unexpected process call.'),
          };
          return ProcessResult(1, 0, output, '');
        },
      );
      final service = WindowsRssService(
        processRunner: runner,
        topology: () =>
            const ProcessorTopology(processorsPerGroup: <int, int>{0: 1}),
      );
      const desired = RssConfiguration(
        enabled: true,
        profile: 'NUMAStatic',
        baseProcessor: ProcessorAddress(0, 0),
        maximumProcessor: ProcessorAddress(0, 0),
        processorCount: 1,
        queueCount: 1,
        processorArray: <ProcessorAddress>[ProcessorAddress(0, 0)],
      );

      await service.write('Ethernet', desired);

      expect(call, 4);
    },
  );
}
