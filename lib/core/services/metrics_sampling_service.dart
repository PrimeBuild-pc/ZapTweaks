import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../models/system_metrics_snapshot.dart';
import 'process_runner.dart';

class MetricsSamplingService {
  MetricsSamplingService({
    required ProcessRunner processRunner,
    bool preferNative = true,
  }) : _processRunner = processRunner,
       _preferNative = preferNative;

  final ProcessRunner _processRunner;
  final bool _preferNative;
  _WindowsMetricsSampler? _nativeSampler;

  Future<SystemMetricsSnapshot> sample() async {
    if (_preferNative && Platform.isWindows) {
      try {
        _nativeSampler ??= _WindowsMetricsSampler();
        return await _nativeSampler!.sample();
      } catch (_) {
        _nativeSampler?.dispose();
        _nativeSampler = null;
      }
    }
    return _sampleWithPowerShell();
  }

  void dispose() => _nativeSampler?.dispose();

  Future<SystemMetricsSnapshot> _sampleWithPowerShell() async {
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

final class _PdhFormattedCounterValue extends Struct {
  @Uint32()
  external int status;

  @Uint32()
  external int reserved;

  @Double()
  external double value;
}

final class _PdhFormattedCounterValueItem extends Struct {
  external Pointer<Utf16> name;
  external _PdhFormattedCounterValue formattedValue;
}

typedef _PdhOpenQueryNative =
    Uint32 Function(Pointer<Utf16>, IntPtr, Pointer<IntPtr>);
typedef _PdhOpenQueryDart = int Function(Pointer<Utf16>, int, Pointer<IntPtr>);
typedef _PdhAddCounterNative =
    Uint32 Function(IntPtr, Pointer<Utf16>, IntPtr, Pointer<IntPtr>);
typedef _PdhAddCounterDart =
    int Function(int, Pointer<Utf16>, int, Pointer<IntPtr>);
typedef _PdhCollectNative = Uint32 Function(IntPtr);
typedef _PdhCollectDart = int Function(int);
typedef _PdhReadArrayNative =
    Uint32 Function(
      IntPtr,
      Uint32,
      Pointer<Uint32>,
      Pointer<Uint32>,
      Pointer<_PdhFormattedCounterValueItem>,
    );
typedef _PdhReadArrayDart =
    int Function(
      int,
      int,
      Pointer<Uint32>,
      Pointer<Uint32>,
      Pointer<_PdhFormattedCounterValueItem>,
    );
typedef _PdhCloseNative = Uint32 Function(IntPtr);
typedef _PdhCloseDart = int Function(int);

class _WindowsMetricsSampler {
  _WindowsMetricsSampler() {
    final library = DynamicLibrary.open('pdh.dll');
    _openQuery = library.lookupFunction<_PdhOpenQueryNative, _PdhOpenQueryDart>(
      'PdhOpenQueryW',
    );
    _addCounter = library
        .lookupFunction<_PdhAddCounterNative, _PdhAddCounterDart>(
          'PdhAddEnglishCounterW',
        );
    _collect = library.lookupFunction<_PdhCollectNative, _PdhCollectDart>(
      'PdhCollectQueryData',
    );
    _readArray = library.lookupFunction<_PdhReadArrayNative, _PdhReadArrayDart>(
      'PdhGetFormattedCounterArrayW',
    );
    _close = library.lookupFunction<_PdhCloseNative, _PdhCloseDart>(
      'PdhCloseQuery',
    );
    _open();
  }

  static const int _pdhMoreData = 0x800007D2;
  static const int _formatDouble = 0x00000200;
  static const int _formatNoCap100 = 0x00008000;

  late final _PdhOpenQueryDart _openQuery;
  late final _PdhAddCounterDart _addCounter;
  late final _PdhCollectDart _collect;
  late final _PdhReadArrayDart _readArray;
  late final _PdhCloseDart _close;

  int _query = 0;
  int _gpuCounter = 0;
  int _vramUsageCounter = 0;
  int _vramLimitCounter = 0;
  int _registryVramTotal = 0;
  int? _previousIdle;
  int? _previousTotal;
  bool _warmed = false;

  void _open() {
    final query = calloc<IntPtr>();
    try {
      if (_openQuery(nullptr.cast(), 0, query) != 0) {
        throw StateError('Unable to open the PDH metrics query.');
      }
      _query = query.value;
      _gpuCounter = _add(r'\GPU Engine(*)\Utilization Percentage');
      _vramUsageCounter = _add(r'\GPU Adapter Memory(*)\Dedicated Usage');
      _vramLimitCounter = _add(r'\GPU Adapter Memory(*)\Dedicated Limit');
      _registryVramTotal = _readRegistryVramTotal();
      _collect(_query);
    } finally {
      calloc.free(query);
    }
  }

  int _add(String path) {
    final nativePath = path.toNativeUtf16();
    final counter = calloc<IntPtr>();
    try {
      return _addCounter(_query, nativePath, 0, counter) == 0
          ? counter.value
          : 0;
    } finally {
      calloc.free(nativePath);
      calloc.free(counter);
    }
  }

  Future<SystemMetricsSnapshot> sample() async {
    if (!_warmed) {
      _readCpuUsage();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _warmed = true;
    }

    if (_query != 0) _collect(_query);
    final cpu = _readCpuUsage();
    final memory = _readMemory();
    final gpuSamples = _readCounter(_gpuCounter);
    final preferredGpu = gpuSamples.where(
      (sample) =>
          sample.name.toLowerCase().contains('engtype_3d') ||
          sample.name.toLowerCase().contains('engtype_compute'),
    );
    final gpuValues = preferredGpu.isEmpty ? gpuSamples : preferredGpu;
    final gpu = gpuValues.fold<double>(0, (sum, item) => sum + item.value);

    final usage = _byAdapter(_readCounter(_vramUsageCounter), sum: true);
    final limits = _byAdapter(_readCounter(_vramLimitCounter), sum: false);
    String? primaryAdapter;
    var vramTotal = 0.0;
    for (final entry in limits.entries) {
      if (entry.value > vramTotal) {
        primaryAdapter = entry.key;
        vramTotal = entry.value;
      }
    }
    var vramUsed = primaryAdapter == null ? 0.0 : usage[primaryAdapter] ?? 0;
    if (vramTotal <= 0 && _registryVramTotal > 0) {
      vramTotal = _registryVramTotal.toDouble();
      vramUsed = usage.values.fold<double>(0, math.max);
    }
    vramUsed = math.max(0, math.min(vramUsed, vramTotal));
    final vramPercent = vramTotal <= 0 ? 0.0 : vramUsed / vramTotal * 100;

    return SystemMetricsSnapshot(
      timestamp: DateTime.now(),
      cpuUsagePercent: _percent(cpu),
      gpuUsagePercent: _percent(gpu),
      memoryUsagePercent: _percent(memory.percent),
      memoryUsedBytes: memory.used,
      memoryTotalBytes: memory.total,
      vramUsagePercent: _percent(vramPercent),
      vramUsedBytes: vramUsed.round(),
      vramTotalBytes: vramTotal.round(),
    );
  }

  double _readCpuUsage() {
    final idle = calloc<FILETIME>();
    final kernel = calloc<FILETIME>();
    final user = calloc<FILETIME>();
    try {
      if (GetSystemTimes(idle, kernel, user) == 0) return 0;
      final idleValue = _fileTime(idle.ref);
      final total = _fileTime(kernel.ref) + _fileTime(user.ref);
      final previousIdle = _previousIdle;
      final previousTotal = _previousTotal;
      _previousIdle = idleValue;
      _previousTotal = total;
      if (previousIdle == null || previousTotal == null) return 0;
      final totalDelta = total - previousTotal;
      if (totalDelta <= 0) return 0;
      return (totalDelta - (idleValue - previousIdle)) / totalDelta * 100;
    } finally {
      calloc.free(idle);
      calloc.free(kernel);
      calloc.free(user);
    }
  }

  ({double percent, int used, int total}) _readMemory() {
    final status = calloc<MEMORYSTATUSEX>();
    try {
      status.ref.dwLength = sizeOf<MEMORYSTATUSEX>();
      if (GlobalMemoryStatusEx(status) == 0) {
        return (percent: 0, used: 0, total: 0);
      }
      final total = status.ref.ullTotalPhys;
      return (
        percent: status.ref.dwMemoryLoad.toDouble(),
        used: total - status.ref.ullAvailPhys,
        total: total,
      );
    } finally {
      calloc.free(status);
    }
  }

  List<({String name, double value})> _readCounter(int counter) {
    if (counter == 0) return const [];
    final bytes = calloc<Uint32>();
    final count = calloc<Uint32>();
    try {
      final first = _readArray(
        counter,
        _formatDouble | _formatNoCap100,
        bytes,
        count,
        nullptr.cast(),
      );
      if (first != _pdhMoreData || bytes.value == 0) return const [];
      final buffer = calloc<Uint8>(bytes.value);
      try {
        final items = buffer.cast<_PdhFormattedCounterValueItem>();
        if (_readArray(
              counter,
              _formatDouble | _formatNoCap100,
              bytes,
              count,
              items,
            ) !=
            0) {
          return const [];
        }
        return <({String name, double value})>[
          for (var index = 0; index < count.value; index++)
            if ((items + index).ref.formattedValue.status <= 1)
              (
                name: (items + index).ref.name.toDartString(),
                value: (items + index).ref.formattedValue.value,
              ),
        ];
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(bytes);
      calloc.free(count);
    }
  }

  Map<String, double> _byAdapter(
    List<({String name, double value})> samples, {
    required bool sum,
  }) {
    final values = <String, double>{};
    final luid = RegExp(r'luid_[^_]+_[^_]+', caseSensitive: false);
    for (final sample in samples) {
      final key =
          luid.firstMatch(sample.name)?.group(0)?.toLowerCase() ??
          sample.name.toLowerCase();
      values[key] = sum
          ? (values[key] ?? 0) + sample.value
          : math.max(values[key] ?? 0, sample.value);
    }
    return values;
  }

  int _readRegistryVramTotal() {
    const videoPath = r'SYSTEM\CurrentControlSet\Control\Video';
    final nativePath = videoPath.toNativeUtf16();
    final key = calloc<IntPtr>();
    try {
      if (RegOpenKeyEx(
            HKEY_LOCAL_MACHINE,
            nativePath,
            0,
            KEY_ENUMERATE_SUB_KEYS | KEY_WOW64_64KEY,
            key,
          ) !=
          ERROR_SUCCESS) {
        return 0;
      }
      var maximum = 0;
      final name = calloc<Uint16>(256).cast<Utf16>();
      final length = calloc<Uint32>();
      try {
        for (var index = 0; ; index++) {
          length.value = 256;
          final result = RegEnumKeyEx(
            key.value,
            index,
            name,
            length,
            nullptr,
            nullptr,
            nullptr,
            nullptr,
          );
          if (result == ERROR_NO_MORE_ITEMS) break;
          if (result != ERROR_SUCCESS) continue;
          final subKey =
              '$videoPath\\${name.toDartString(length: length.value)}\\0000';
          maximum = math.max(maximum, _readVramValue(subKey));
        }
      } finally {
        calloc.free(name);
        calloc.free(length);
      }
      return maximum;
    } finally {
      if (key.value != 0) RegCloseKey(key.value);
      calloc.free(nativePath);
      calloc.free(key);
    }
  }

  int _readVramValue(String subKey) {
    final nativeSubKey = subKey.toNativeUtf16();
    final qwordName = 'HardwareInformation.qwMemorySize'.toNativeUtf16();
    final dwordName = 'HardwareInformation.MemorySize'.toNativeUtf16();
    final size = calloc<Uint32>();
    final qword = calloc<Uint64>();
    final dword = calloc<Uint32>();
    try {
      size.value = sizeOf<Uint64>();
      if (RegGetValue(
            HKEY_LOCAL_MACHINE,
            nativeSubKey,
            qwordName,
            RRF_RT_REG_QWORD | RRF_SUBKEY_WOW6464KEY,
            nullptr,
            qword,
            size,
          ) ==
          ERROR_SUCCESS) {
        return qword.value;
      }
      size.value = sizeOf<Uint32>();
      return RegGetValue(
                HKEY_LOCAL_MACHINE,
                nativeSubKey,
                dwordName,
                RRF_RT_REG_DWORD | RRF_SUBKEY_WOW6464KEY,
                nullptr,
                dword,
                size,
              ) ==
              ERROR_SUCCESS
          ? dword.value
          : 0;
    } finally {
      calloc.free(nativeSubKey);
      calloc.free(qwordName);
      calloc.free(dwordName);
      calloc.free(size);
      calloc.free(qword);
      calloc.free(dword);
    }
  }

  static int _fileTime(FILETIME value) =>
      (value.dwHighDateTime << 32) | value.dwLowDateTime;

  static double _percent(double value) =>
      value.isFinite ? value.clamp(0, 100).toDouble() : 0;

  void dispose() {
    if (_query != 0) {
      _close(_query);
      _query = 0;
    }
  }
}
