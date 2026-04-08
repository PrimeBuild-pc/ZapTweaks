import '../models/system_metrics_snapshot.dart';
import 'process_runner.dart';

class MetricsSamplingService {
  MetricsSamplingService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  Future<SystemMetricsSnapshot> sample() async {
    const script = r'''
$cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$os = Get-CimInstance Win32_OperatingSystem
$total = [double]$os.TotalVisibleMemorySize * 1024
$free = [double]$os.FreePhysicalMemory * 1024
$used = [Math]::Max(0, $total - $free)
$memPercent = if ($total -gt 0) { ($used / $total) * 100 } else { 0 }
[string]::Format('{0:N3}|{1:N3}|{2:0}|{3:0}', $cpu, $memPercent, $used, $total)
''';

    final result = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-Command',
      script,
    ], timeout: const Duration(seconds: 6));

    if (!result.success) {
      return SystemMetricsSnapshot.empty;
    }

    final output = result.stdout.trim();
    if (output.isEmpty) {
      return SystemMetricsSnapshot.empty;
    }

    final line = output
        .split(RegExp(r'\r?\n'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .last;

    final parts = line.split('|');
    if (parts.length != 4) {
      return SystemMetricsSnapshot.empty;
    }

    final cpu = double.tryParse(parts[0]) ?? 0;
    final memoryPercent = double.tryParse(parts[1]) ?? 0;
    final memoryUsed = int.tryParse(parts[2]) ?? 0;
    final memoryTotal = int.tryParse(parts[3]) ?? 0;

    return SystemMetricsSnapshot(
      timestamp: DateTime.now(),
      cpuUsagePercent: _clampPercent(cpu),
      memoryUsagePercent: _clampPercent(memoryPercent),
      memoryUsedBytes: memoryUsed,
      memoryTotalBytes: memoryTotal,
    );
  }

  double _clampPercent(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0;
    }

    if (value < 0) {
      return 0;
    }

    if (value > 100) {
      return 100;
    }

    return value;
  }
}
