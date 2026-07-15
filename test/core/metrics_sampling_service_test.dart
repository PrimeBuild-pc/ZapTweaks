import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/metrics_sampling_service.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses cpu, gpu and memory counters from script output', () async {
    final service = MetricsSamplingService(
      processRunner: ProcessRunner(
        mode: ProcessExecutionMode.production,
        processRunDelegate:
            (
              String executable,
              List<String> arguments, {
              bool runInShell = false,
            }) async {
              return ProcessResult(
                1,
                0,
                '12.500|34.100|56.700|123456789|234567890|45.600|987654321|1987654321',
                '',
              );
            },
      ),
    );

    final snapshot = await service.sample();

    expect(snapshot.cpuUsagePercent, closeTo(12.5, 0.001));
    expect(snapshot.gpuUsagePercent, closeTo(34.1, 0.001));
    expect(snapshot.memoryUsagePercent, closeTo(56.7, 0.001));
    expect(snapshot.memoryUsedBytes, 123456789);
    expect(snapshot.memoryTotalBytes, 234567890);
    expect(snapshot.vramUsagePercent, closeTo(45.6, 0.001));
    expect(snapshot.vramUsedBytes, 987654321);
    expect(snapshot.vramTotalBytes, 1987654321);
  });

  test('parses metrics from noisy output taking last valid line', () async {
    final service = MetricsSamplingService(
      processRunner: ProcessRunner(
        mode: ProcessExecutionMode.production,
        processRunDelegate:
            (
              String executable,
              List<String> arguments, {
              bool runInShell = false,
            }) async {
              return ProcessResult(
                1,
                0,
                'Some warning text\nAnother line\n11.100|22.200|33.300|444|555|66.700|777|888',
                '',
              );
            },
      ),
    );

    final snapshot = await service.sample();

    expect(snapshot.cpuUsagePercent, closeTo(11.1, 0.001));
    expect(snapshot.gpuUsagePercent, closeTo(22.2, 0.001));
    expect(snapshot.memoryUsagePercent, closeTo(33.3, 0.001));
    expect(snapshot.memoryUsedBytes, 444);
    expect(snapshot.memoryTotalBytes, 555);
    expect(snapshot.vramUsagePercent, closeTo(66.7, 0.001));
    expect(snapshot.vramUsedBytes, 777);
    expect(snapshot.vramTotalBytes, 888);
  });
}
