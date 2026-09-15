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

class ThermalZoneSnapshot {
  const ThermalZoneSnapshot({required this.celsius});

  final List<double> celsius;
}

class WindowsThermalSensorService {
  const WindowsThermalSensorService({required this.processRunner});

  final ProcessRunner processRunner;

  Future<ThermalZoneSnapshot> capture() async {
    final output = await processRunner.runPowerShellForOutput(r'''
$rows=@(Get-CimInstance -Namespace root/wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop)
$values=@($rows | ForEach-Object {[Math]::Round(($_.CurrentTemperature / 10.0) - 273.15, 1)})
[ordered]@{celsius=$values} | ConvertTo-Json -Compress
''');
    final json = Map<String, dynamic>.from(jsonDecode(output) as Map);
    final values = json['celsius'];
    if (values is! List || values.any((value) => value is! num)) {
      throw const FormatException('Invalid firmware thermal sensor response.');
    }
    final temperatures = values
        .cast<num>()
        .map((value) => value.toDouble())
        .toList(growable: false);
    if (temperatures.any((value) => value < -50 || value > 200)) {
      throw const FormatException(
        'Firmware thermal sensor is outside its physical range.',
      );
    }
    return ThermalZoneSnapshot(celsius: temperatures);
  }
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
