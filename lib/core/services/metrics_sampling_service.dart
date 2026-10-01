import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../models/system_metrics_snapshot.dart';
import '../../platform/windows/dxgi_adapter_memory.dart';
import 'process_runner.dart';

typedef MetricCounter = ({String name, double value});

/// Sum processes sharing a physical engine; report the busiest engine, never
/// add concurrent engines or different GPUs. Memory uses the same adapter ID.
List<GpuMetrics> gpuMetricsFromCounters(
  List<MetricCounter> engines,
  List<MetricCounter> usage,
  List<MetricCounter> limits, {
  Map<String, ({String name, int bytes})> adapterMemory = const {},
}) {
  final adapter = RegExp(
    r'luid_[^_]+_[^_]+(?:_phys_\d+)?',
    caseSensitive: false,
  );
  final engine = RegExp(r'_(eng_\d+)(?:_|$)', caseSensitive: false);
  final loads = <String, Map<String, double>>{};
  final used = <String, double>{}, total = <String, double>{};
  for (final sample in engines) {
    final id = adapter.firstMatch(sample.name)?.group(0)?.toLowerCase();
    final unit = engine.firstMatch(sample.name)?.group(1)?.toLowerCase();
    if (id == null ||
        unit == null ||
        !sample.value.isFinite ||
        sample.value < 0) {
      continue;
    }
    final units = loads[id] ??= {};
    units[unit] = (units[unit] ?? 0) + sample.value;
  }
  void memory(List<MetricCounter> samples, Map<String, double> values) {
    for (final sample in samples) {
      final id = adapter.firstMatch(sample.name)?.group(0)?.toLowerCase();
      if (id == null || !sample.value.isFinite || sample.value < 0) continue;
      values[id] = math.max(values[id] ?? 0, sample.value);
    }
  }

  memory(usage, used);
  memory(limits, total);
  for (final entry in adapterMemory.entries) {
    if (loads.containsKey(entry.key) || used.containsKey(entry.key)) {
      total.putIfAbsent(entry.key, () => entry.value.bytes.toDouble());
    }
  }
  final ids = {...loads.keys, ...used.keys, ...total.keys}.toList()..sort();
  return List.unmodifiable(
    ids.map(
      (id) => GpuMetrics(
        adapterId: id,
        name: adapterMemory[id]?.name,
        usagePercent: loads[id]?.values
            .reduce(math.max)
            .clamp(0, 100)
            .toDouble(),
        vramTotalBytes: (total[id] ?? 0) > 0 ? total[id]!.round() : null,
        vramUsedBytes: used[id] == null
            ? null
            : math.min(used[id]!, total[id] ?? used[id]!).round(),
      ),
    ),
  );
}

SystemMetricsSnapshot _snapshot(
  double? cpu,
  ({int used, int total})? memory,
  List<GpuMetrics> gpus,
) {
  GpuMetrics? primary;
  for (final gpu in gpus) {
    if (primary == null ||
        (gpu.usagePercent ?? -1) > (primary.usagePercent ?? -1)) {
      primary = gpu;
    }
  }
  return SystemMetricsSnapshot(
    timestamp: DateTime.now(),
    cpuUsagePercent: cpu?.clamp(0, 100).toDouble() ?? 0,
    cpuAvailable: cpu != null && cpu.isFinite,
    gpuUsagePercent: primary?.usagePercent ?? 0,
    gpuAvailable: primary?.usagePercent != null,
    memoryUsagePercent: memory == null || memory.total <= 0
        ? 0
        : memory.used / memory.total * 100,
    memoryUsedBytes: memory?.used ?? 0,
    memoryTotalBytes: memory?.total ?? 0,
    memoryAvailable: memory != null && memory.total > 0,
    vramUsagePercent: primary?.vramPercent ?? 0,
    vramAvailable: primary?.vramPercent != null,
    vramUsedBytes: primary?.vramUsedBytes ?? 0,
    vramTotalBytes: primary?.vramTotalBytes ?? 0,
    gpus: gpus,
    primaryGpuId: primary?.adapterId,
  );
}

class MetricsSamplingService {
  MetricsSamplingService({
    required ProcessRunner processRunner,
    bool preferNative = true,
  }) : _processRunner = processRunner,
       _preferNative = preferNative;
  final ProcessRunner _processRunner;
  final bool _preferNative;
  _WindowsMetricsSampler? _nativeSampler;
  // ponytail: DXGI metadata is per-session; re-enumerate on hot-plug if needed.
  Map<String, ({String name, int bytes})>? _adapterMemory;

  Future<SystemMetricsSnapshot> sample() async {
    if (_preferNative && Platform.isWindows) {
      try {
        _nativeSampler ??= _WindowsMetricsSampler();
        return await _nativeSampler!.sample(
          _adapterMemory ??= readDxgiAdapterMemory(),
        );
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
$cpu = $null
$memory = $null
try {
  $cpu = [double](Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'" -ErrorAction Stop).PercentProcessorTime
} catch {}
try {
  $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
  $total = [int64]$os.TotalVisibleMemorySize * 1024
  $memory = @{ used = [Math]::Max([int64]0, $total - [int64]$os.FreePhysicalMemory * 1024); total = $total }
} catch {}
function Read-Counters([string]$counter) {
  try {
    @( (Get-Counter $counter -ErrorAction Stop).CounterSamples | Where-Object Status -EQ 0 | ForEach-Object {
      @{ name = $_.InstanceName; value = [double]$_.CookedValue }
    })
  } catch { @() }
}
$gpu = @(Read-Counters '\GPU Engine(*)\Utilization Percentage')
$usage = @(Read-Counters '\GPU Adapter Memory(*)\Dedicated Usage')
$limits = @(Read-Counters '\GPU Adapter Memory(*)\Dedicated Limit')
@{ cpu = $cpu; memory = $memory; gpu = $gpu; usage = $usage; limits = $limits } | ConvertTo-Json -Compress -Depth 5
''';
    final result = await _processRunner.run('powershell', [
      '-NoProfile',
      '-Command',
      script,
    ], timeout: const Duration(seconds: 8));
    if (!result.success) return SystemMetricsSnapshot.empty;
    for (final line in result.stdout.split(RegExp(r'\r?\n')).reversed) {
      try {
        final data = jsonDecode(line.trim()) as Map<String, dynamic>;
        final cpu = (data['cpu'] as num?)?.toDouble();
        final mem = data['memory'] as Map?;
        final memory = mem == null
            ? null
            : (
                used: (mem['used'] as num).toInt(),
                total: (mem['total'] as num).toInt(),
              );
        if (cpu != null && (!cpu.isFinite || cpu < 0 || cpu > 100) ||
            memory != null &&
                (memory.total <= 0 ||
                    memory.used < 0 ||
                    memory.used > memory.total)) {
          continue;
        }
        List<MetricCounter> counters(String key) => (data[key] as List)
            .map(
              (row) => (
                name: row['name'] as String,
                value: (row['value'] as num).toDouble(),
              ),
            )
            .toList();
        return _snapshot(
          cpu,
          memory,
          gpuMetricsFromCounters(
            counters('gpu'),
            counters('usage'),
            counters('limits'),
            adapterMemory: _adapterMemory ??= readDxgiAdapterMemory(),
          ),
        );
      } catch (_) {
        /* Ignore noise or invalid output; try the preceding line. */
      }
    }
    return SystemMetricsSnapshot.empty;
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
    final query = calloc<IntPtr>();
    try {
      if (_openQuery(nullptr.cast(), 0, query) != 0) {
        throw StateError('Unable to open PDH query.');
      }
      _query = query.value;
      _gpuCounter = _add(r'\GPU Engine(*)\Utilization Percentage');
      _vramUsageCounter = _add(r'\GPU Adapter Memory(*)\Dedicated Usage');
      _vramLimitCounter = _add(r'\GPU Adapter Memory(*)\Dedicated Limit');
      _collect(_query);
    } catch (_) {
      dispose();
      rethrow;
    } finally {
      calloc.free(query);
    }
  }
  late final _PdhOpenQueryDart _openQuery;
  late final _PdhAddCounterDart _addCounter;
  late final _PdhCollectDart _collect;
  late final _PdhReadArrayDart _readArray;
  late final _PdhCloseDart _close;
  int _query = 0, _gpuCounter = 0, _vramUsageCounter = 0, _vramLimitCounter = 0;
  int? _previousIdle, _previousTotal;
  bool _warmed = false;

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

  Future<SystemMetricsSnapshot> sample(
    Map<String, ({String name, int bytes})> adapterMemory,
  ) async {
    if (!_warmed) {
      _readCpuUsage();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _warmed = true;
    }
    final countersAvailable = _query != 0 && _collect(_query) == 0;
    return _snapshot(
      _readCpuUsage(),
      _readMemory(),
      countersAvailable
          ? gpuMetricsFromCounters(
              _readCounter(_gpuCounter),
              _readCounter(_vramUsageCounter),
              _readCounter(_vramLimitCounter),
              adapterMemory: adapterMemory,
            )
          : const [],
    );
  }

  double? _readCpuUsage() {
    final idle = calloc<FILETIME>(),
        kernel = calloc<FILETIME>(),
        user = calloc<FILETIME>();
    try {
      if (GetSystemTimes(idle, kernel, user) == 0) return null;
      final idleValue = _fileTime(idle.ref),
          total = _fileTime(kernel.ref) + _fileTime(user.ref);
      final previousIdle = _previousIdle, previousTotal = _previousTotal;
      _previousIdle = idleValue;
      _previousTotal = total;
      if (previousIdle == null || previousTotal == null) return null;
      final delta = total - previousTotal;
      return delta <= 0
          ? null
          : (delta - (idleValue - previousIdle)) / delta * 100;
    } finally {
      calloc.free(idle);
      calloc.free(kernel);
      calloc.free(user);
    }
  }

  ({int used, int total})? _readMemory() {
    final status = calloc<MEMORYSTATUSEX>();
    try {
      status.ref.dwLength = sizeOf<MEMORYSTATUSEX>();
      if (GlobalMemoryStatusEx(status) == 0) return null;
      return (
        used: status.ref.ullTotalPhys - status.ref.ullAvailPhys,
        total: status.ref.ullTotalPhys,
      );
    } finally {
      calloc.free(status);
    }
  }

  List<MetricCounter> _readCounter(int counter) {
    if (counter == 0) return const [];
    final bytes = calloc<Uint32>(), count = calloc<Uint32>();
    try {
      final first = _readArray(
        counter,
        0x00000200 | 0x00008000,
        bytes,
        count,
        nullptr.cast(),
      );
      if (first != 0x800007D2 || bytes.value == 0) return const [];
      final buffer = calloc<Uint8>(bytes.value);
      try {
        final items = buffer.cast<_PdhFormattedCounterValueItem>();
        if (_readArray(counter, 0x00000200 | 0x00008000, bytes, count, items) !=
            0) {
          return const [];
        }
        return [
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

  static int _fileTime(FILETIME value) =>
      (value.dwHighDateTime << 32) | value.dwLowDateTime;
  void dispose() {
    if (_query != 0) _close(_query);
    _query = 0;
  }
}
