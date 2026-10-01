import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/metrics_sampling_service.dart';
import 'package:script_utility/core/models/system_metrics_snapshot.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('missing metrics must not be presented as idle hardware', () {
    expect(SystemMetricsSnapshot.empty.cpuLabel, 'N/A');
    expect(SystemMetricsSnapshot.empty.gpuLabel, 'N/A');
    expect(SystemMetricsSnapshot.empty.vramPercentLabel, 'N/A');
  });

  test('process counters share engines, never add engines or GPUs', () {
    final gpus = gpuMetricsFromCounters(
      [
        (name: 'pid_1_luid_0x0_0x1_phys_0_eng_0_engtype_3D', value: 20),
        (name: 'pid_2_luid_0x0_0x1_phys_0_eng_0_engtype_3D', value: 30),
        (name: 'pid_1_luid_0x0_0x1_phys_0_eng_1_engtype_Compute', value: 40),
        (name: 'pid_3_luid_0x0_0x2_phys_0_eng_0_engtype_3D', value: 80),
        (name: 'pid_4_luid_0x0_0x3_phys_0_eng_0_engtype_3D', value: double.nan),
      ],
      [
        (name: 'luid_0x0_0x1_phys_0', value: 200),
        (name: 'luid_0x0_0x2_phys_0', value: 900),
      ],
      [
        (name: 'luid_0x0_0x1_phys_0', value: 1000),
        (name: 'luid_0x0_0x2_phys_0', value: 2000),
      ],
    );
    expect(gpus, hasLength(2));
    expect(gpus.map((g) => g.usagePercent), [50, 80]);
    expect(gpus.map((g) => g.vramPercent), [20, 45]);
    final absent = gpuMetricsFromCounters([], [], [
      (name: 'luid_0x0_0x1_phys_0', value: 1000),
    ]).single;
    expect(absent.usagePercent, isNull);
    expect(absent.vramPercent, isNull);
    expect(gpuMetricsFromCounters([], [], []), isEmpty);
    final matched = gpuMetricsFromCounters(
      [],
      [
        (name: 'luid_0x0_0x1_phys_0', value: 500),
        (name: 'luid_0x0_0x2_phys_0', value: 900),
      ],
      [],
      adapterMemory: {'luid_0x0_0x1_phys_0': (name: 'Test GPU', bytes: 1000)},
    );
    expect(matched.first.name, 'Test GPU');
    expect(matched.first.vramPercent, 50);
    expect(matched.last.vramPercent, isNull);
  });

  test(
    'PowerShell fallback shares adapter aggregation and ignores noisy output',
    () async {
      final data = {
        'cpu': 12.5,
        'memory': {'used': 123456789, 'total': 234567890},
        'gpu': [
          {'name': 'pid_1_luid_0x0_0x1_phys_0_eng_0_engtype_3D', 'value': 34.1},
          {'name': 'pid_1_luid_0x0_0x2_phys_0_eng_0_engtype_3D', 'value': 22.2},
        ],
        'usage': [
          {'name': 'luid_0x0_0x1_phys_0', 'value': 987654321},
        ],
        'limits': [
          {'name': 'luid_0x0_0x1_phys_0', 'value': 1987654321},
        ],
      };
      final service = MetricsSamplingService(
        preferNative: false,
        processRunner: ProcessRunner(
          processRunDelegate:
              (
                String executable,
                List<String> arguments, {
                bool runInShell = false,
              }) async => ProcessResult(
                1,
                0,
                'Warning\n${jsonEncode(data)}\nnoise',
                '',
              ),
        ),
      );
      final snapshot = await service.sample();
      expect(snapshot.cpuUsagePercent, 12.5);
      expect(snapshot.gpuUsagePercent, 34.1);
      expect(snapshot.memoryUsedBytes, 123456789);
      expect(snapshot.memoryTotalBytes, 234567890);
      expect(snapshot.vramUsedBytes, 987654321);
      expect(snapshot.vramTotalBytes, 1987654321);
      expect(snapshot.gpus, hasLength(2));
      expect(snapshot.primaryGpuId, 'luid_0x0_0x1_phys_0');
      expect(snapshot.vramAvailable, isTrue);
    },
  );

  test(
    'missing fallback counters are unavailable, not measured zero',
    () async {
      final service = MetricsSamplingService(
        preferNative: false,
        processRunner: ProcessRunner(
          processRunDelegate:
              (
                String executable,
                List<String> arguments, {
                bool runInShell = false,
              }) async => ProcessResult(
                1,
                0,
                '{"cpu":null,"memory":null,"gpu":[],"usage":[],"limits":[]}',
                '',
              ),
        ),
      );
      final snapshot = await service.sample();
      expect(snapshot.cpuAvailable, isFalse);
      expect(snapshot.gpuAvailable, isFalse);
      expect(snapshot.memoryAvailable, isFalse);
      expect(snapshot.vramAvailable, isFalse);
    },
  );

  test(
    'native sampler returns bounded metrics without starting PowerShell',
    () async {
      var processCalls = 0;
      final service = MetricsSamplingService(
        processRunner: ProcessRunner(
          processRunDelegate:
              (
                String executable,
                List<String> arguments, {
                bool runInShell = false,
              }) async {
                processCalls++;
                return ProcessResult(1, 1, '', 'unexpected process');
              },
        ),
      );
      addTearDown(service.dispose);
      final snapshot = await service.sample();
      expect(snapshot.timestamp, isNotNull);
      expect(snapshot.cpuAvailable, isTrue);
      expect(snapshot.cpuUsagePercent, inInclusiveRange(0, 100));
      expect(snapshot.memoryUsagePercent, inInclusiveRange(0, 100));
      expect(snapshot.memoryTotalBytes, greaterThan(0));
      expect(processCalls, 0);
    },
    skip: !Platform.isWindows,
  );
}
