import 'dart:convert';

import '../../core/services/process_runner.dart';

class GpuMemorySnapshot {
  const GpuMemorySnapshot({
    required this.dedicatedBytes,
    required this.samples,
  });

  final int dedicatedBytes;
  final int samples;
}

class WindowsGpuMemoryService {
  const WindowsGpuMemoryService({required this.processRunner});

  final ProcessRunner processRunner;

  Future<GpuMemorySnapshot> capture() async {
    final output = await processRunner.runPowerShellForOutput(r'''
$rows=@(Get-CimInstance -ClassName Win32_PerfFormattedData_GPUPerformanceCounters_GPUAdapterMemory -ErrorAction Stop)
$sum=($rows | Measure-Object -Property DedicatedUsage -Sum).Sum
if($null -eq $sum){$sum=0}
[ordered]@{dedicatedBytes=[UInt64]$sum;samples=[int]$rows.Count} | ConvertTo-Json -Compress
''');
    final json = Map<String, dynamic>.from(jsonDecode(output) as Map);
    final bytes = json['dedicatedBytes'];
    final samples = json['samples'];
    if (bytes is! num || samples is! int || bytes < 0 || samples < 0) {
      throw const FormatException('Invalid GPU memory counter response.');
    }
    return GpuMemorySnapshot(dedicatedBytes: bytes.toInt(), samples: samples);
  }
}
