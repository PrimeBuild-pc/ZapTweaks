import '../models/system_metrics_snapshot.dart';
import 'process_runner.dart';

class MetricsSamplingService {
  MetricsSamplingService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  Future<SystemMetricsSnapshot> sample() async {
    const script = r'''
$invariant = [System.Globalization.CultureInfo]::InvariantCulture

$cpu = 0.0
try {
  $counter = Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop
  $cpu = [double]$counter.CounterSamples[0].CookedValue
} catch {
  try {
    $sample = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'" -ErrorAction Stop
    $cpu = [double]$sample.PercentProcessorTime
  } catch {
    $cpu = 0.0
  }
}

$total = 0.0
$used = 0.0
$memPercent = 0.0
try {
  $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
  $total = [double]$os.TotalVisibleMemorySize * 1024
  $free = [double]$os.FreePhysicalMemory * 1024
  $used = [Math]::Max([double]0, $total - $free)
  if ($total -gt 0) {
    $memPercent = ($used / $total) * 100
  }
} catch {
  $total = 0.0
  $used = 0.0
  $memPercent = 0.0
}

$gpuPercent = 0.0
try {
  $gpuCounters = Get-Counter '\GPU Engine(*)\Utilization Percentage' -ErrorAction Stop
  $samples = $gpuCounters.CounterSamples |
    Where-Object { $_.InstanceName -match 'engtype_3D' -or $_.InstanceName -match 'engtype_Compute' }

  if (-not $samples -or $samples.Count -eq 0) {
    $samples = $gpuCounters.CounterSamples
  }

  if ($samples -and $samples.Count -gt 0) {
    $sum = ($samples | Measure-Object -Property CookedValue -Sum).Sum
    if ($sum -ne $null) {
      $gpuPercent = [double]$sum
    }
  }
} catch {
  $gpuPercent = 0.0
}

$vramUsed = 0.0
$vramTotal = 0.0
$vramPercent = 0.0
try {
  $usageCounters = Get-Counter '\GPU Adapter Memory(*)\Dedicated Usage' -ErrorAction SilentlyContinue
  $limitCounters = Get-Counter '\GPU Adapter Memory(*)\Dedicated Limit' -ErrorAction SilentlyContinue

  $limitByAdapter = @{}
  if ($limitCounters -and $limitCounters.CounterSamples) {
    foreach ($sample in $limitCounters.CounterSamples) {
      $instanceName = $sample.InstanceName.ToLower()
      $adapterKey = $instanceName
      if ($instanceName -match 'luid_[^_]+_[^_]+') {
        $adapterKey = $matches[0]
      }

      $value = [double]$sample.CookedValue
      if (-not $limitByAdapter.ContainsKey($adapterKey) -or $value -gt [double]$limitByAdapter[$adapterKey]) {
        $limitByAdapter[$adapterKey] = $value
      }
    }
  }

  $usageByAdapter = @{}
  $usageAll = 0.0
  if ($usageCounters -and $usageCounters.CounterSamples) {
    foreach ($sample in $usageCounters.CounterSamples) {
      $instanceName = $sample.InstanceName.ToLower()
      $adapterKey = $instanceName
      if ($instanceName -match 'luid_[^_]+_[^_]+') {
        $adapterKey = $matches[0]
      }

      $value = [double]$sample.CookedValue
      $usageAll += $value
      if ($usageByAdapter.ContainsKey($adapterKey)) {
        $usageByAdapter[$adapterKey] = [double]$usageByAdapter[$adapterKey] + $value
      } else {
        $usageByAdapter[$adapterKey] = $value
      }
    }
  }

  $primaryAdapter = $null
  $primaryLimit = 0.0
  foreach ($entry in $limitByAdapter.GetEnumerator()) {
    $entryValue = [double]$entry.Value
    if ($entryValue -gt $primaryLimit) {
      $primaryLimit = $entryValue
      $primaryAdapter = $entry.Key
    }
  }

  if ($primaryAdapter -ne $null -and $primaryLimit -gt 0) {
    $vramTotal = $primaryLimit
    if ($usageByAdapter.ContainsKey($primaryAdapter)) {
      $vramUsed = [double]$usageByAdapter[$primaryAdapter]
    } elseif ($usageAll -gt 0) {
      $vramUsed = $usageAll
    }
  }

  if ($vramUsed -le 0) {
    $processCounters = Get-Counter '\GPU Process Memory(*)\Dedicated Usage' -ErrorAction SilentlyContinue
    if ($processCounters -and $processCounters.CounterSamples -and $processCounters.CounterSamples.Count -gt 0) {
      $processSum = ($processCounters.CounterSamples | Measure-Object -Property CookedValue -Sum).Sum
      if ($processSum -ne $null -and [double]$processSum -gt 0) {
        $vramUsed = [double]$processSum
      }
    }
  }

  if ($vramTotal -le 0) {
    $registryVramTotal = 0.0
    try {
      $videoKeys = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\Video' -ErrorAction SilentlyContinue
      foreach ($videoKey in $videoKeys) {
        $adapterPath = Join-Path $videoKey.PSPath '0000'
        if (-not (Test-Path $adapterPath)) {
          continue
        }

        $props = Get-ItemProperty -Path $adapterPath -ErrorAction SilentlyContinue
        if (-not $props) {
          continue
        }

        foreach ($propName in @('HardwareInformation.qwMemorySize', 'HardwareInformation.MemorySize')) {
          $raw = $props.$propName
          if ($raw -eq $null) {
            continue
          }

          $rawValue = [double]$raw
          if ($rawValue -gt $registryVramTotal) {
            $registryVramTotal = $rawValue
          }
        }
      }
    } catch {}

    if ($registryVramTotal -gt 0) {
      $vramTotal = $registryVramTotal
    }
  }

  if ($vramTotal -le 0) {
    $gpuAdapters = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue |
      Where-Object { $_.AdapterRAM -gt 0 } |
      Sort-Object -Property AdapterRAM -Descending
    if ($gpuAdapters -and $gpuAdapters.Count -gt 0) {
      $vramTotal = [double]$gpuAdapters[0].AdapterRAM
    }
  }

if ($vramUsed -gt $vramTotal -and $vramTotal -gt 0) {
  $vramUsed = $vramTotal
}

if ($vramTotal -gt 0) {
  $vramPercent = ($vramUsed / $vramTotal) * 100
}
} catch {
  $vramUsed = 0.0
  $vramTotal = 0.0
  $vramPercent = 0.0
}

$cpu = [Math]::Min(100, [Math]::Max(0, $cpu))
$memPercent = [Math]::Min(100, [Math]::Max(0, $memPercent))
$gpuPercent = [Math]::Min(100, [Math]::Max(0, $gpuPercent))
$vramPercent = [Math]::Min(100, [Math]::Max(0, $vramPercent))

$usedInt = [int64][Math]::Round($used)
$totalInt = [int64][Math]::Round($total)
$vramUsedInt = [int64][Math]::Round($vramUsed)
$vramTotalInt = [int64][Math]::Round($vramTotal)

$cpuStr = ([double]$cpu).ToString('F3', $invariant)
$gpuStr = ([double]$gpuPercent).ToString('F3', $invariant)
$memStr = ([double]$memPercent).ToString('F3', $invariant)
$vramPercentStr = ([double]$vramPercent).ToString('F3', $invariant)

"$cpuStr|$gpuStr|$memStr|$usedInt|$totalInt|$vramPercentStr|$vramUsedInt|$vramTotalInt"
''';

    final result = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-Command',
      script,
    ], timeout: const Duration(seconds: 8));

    if (!result.success) {
      return SystemMetricsSnapshot.empty;
    }

    final lines = result.stdout
        .split(RegExp(r'\r?\n'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      return SystemMetricsSnapshot.empty;
    }

    final parts = _extractMetricParts(lines);
    if (parts == null) {
      return SystemMetricsSnapshot.empty;
    }

    final cpu = _parseDouble(parts[0]);
    final gpu = _parseDouble(parts[1]);
    final memoryPercent = _parseDouble(parts[2]);
    final memoryUsed = _parseInt(parts[3]);
    final memoryTotal = _parseInt(parts[4]);
    final vramPercent = _parseDouble(parts[5]);
    final vramUsed = _parseInt(parts[6]);
    final vramTotal = _parseInt(parts[7]);

    return SystemMetricsSnapshot(
      timestamp: DateTime.now(),
      cpuUsagePercent: _clampPercent(cpu),
      gpuUsagePercent: _clampPercent(gpu),
      memoryUsagePercent: _clampPercent(memoryPercent),
      memoryUsedBytes: memoryUsed,
      memoryTotalBytes: memoryTotal,
      vramUsagePercent: _clampPercent(vramPercent),
      vramUsedBytes: vramUsed,
      vramTotalBytes: vramTotal,
    );
  }

  double _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  int _parseInt(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^0-9-]'), '');
    return int.tryParse(sanitized) ?? 0;
  }

  List<String>? _extractMetricParts(List<String> lines) {
    for (var index = lines.length - 1; index >= 0; index--) {
      final line = lines[index];
      final parts = line.split('|');
      if (parts.length != 8) {
        continue;
      }

      final numericDoubleParts = <double?>[
        double.tryParse(parts[0].replaceAll(',', '.')),
        double.tryParse(parts[1].replaceAll(',', '.')),
        double.tryParse(parts[2].replaceAll(',', '.')),
        double.tryParse(parts[5].replaceAll(',', '.')),
      ];

      if (numericDoubleParts.any((value) => value == null)) {
        continue;
      }

      return parts;
    }

    return null;
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
