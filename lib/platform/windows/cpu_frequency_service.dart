import 'dart:convert';

import '../../core/services/process_runner.dart';

/// One logical processor (or the `_Total` row) from the Processor Information counters.
class CpuFrequencySample {
  const CpuFrequencySample({
    required this.name,
    required this.effectiveMhz,
    required this.utility,
    required this.parked,
  });

  /// `group,index` as Windows names the counter instance, or `_Total`.
  final String name;
  final int effectiveMhz;
  final int utility;
  final bool parked;
}

class CpuFrequencySnapshot {
  const CpuFrequencySnapshot({
    required this.nominalMhz,
    required this.total,
    required this.processors,
  });

  final int nominalMhz;
  final CpuFrequencySample total;
  final List<CpuFrequencySample> processors;

  int get parkedCount => processors.where((cpu) => cpu.parked).length;
}

/// Read-only CPU clock sample. Effective clock = nominal clock × `% Processor Performance`, the formula Task Manager
/// uses; the CIM perf class is locale independent, unlike `Get-Counter` paths.
class WindowsCpuFrequencyService {
  const WindowsCpuFrequencyService({required this.processRunner});

  final ProcessRunner processRunner;

  static const script = r'''
$nominal=[int](@(Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop)[0].MaxClockSpeed)
$rows=@(Get-CimInstance -ClassName Win32_PerfFormattedData_Counters_ProcessorInformation -ErrorAction Stop |
  Where-Object { $_.Name -eq '_Total' -or $_.Name -match '^\d+,\d+$' } |
  ForEach-Object { [ordered]@{name=[string]$_.Name;performance=[int]$_.PercentProcessorPerformance;utility=[int]$_.PercentProcessorUtility;parked=([int]$_.ParkingStatus -eq 1)} })
[ordered]@{nominalMhz=$nominal;rows=$rows} | ConvertTo-Json -Compress -Depth 4
''';

  Future<CpuFrequencySnapshot> capture() async =>
      parse(await processRunner.runPowerShellForOutput(script));

  static CpuFrequencySnapshot parse(String output) {
    final json = jsonDecode(output);
    if (json is! Map || json['nominalMhz'] is! int || json['rows'] is! List) {
      throw const FormatException('Invalid processor counter response.');
    }
    final nominal = json['nominalMhz'] as int;
    // A sanity range, not a calibration: anything outside means the counters are not real clocks.
    if (nominal < 100 || nominal > 20000) {
      throw const FormatException('Processor nominal clock is out of range.');
    }
    CpuFrequencySample? total;
    final processors = <CpuFrequencySample>[];
    for (final row in json['rows'] as List) {
      if (row is! Map ||
          row['name'] is! String ||
          row['performance'] is! int ||
          row['utility'] is! int ||
          row['parked'] is! bool) {
        throw const FormatException('Invalid processor counter row.');
      }
      final performance = row['performance'] as int;
      if (performance < 0 || performance > 1000) {
        throw const FormatException('Processor performance is out of range.');
      }
      final sample = CpuFrequencySample(
        name: row['name'] as String,
        effectiveMhz: (nominal * performance / 100).round(),
        utility: row['utility'] as int,
        parked: row['parked'] as bool,
      );
      if (sample.name == '_Total') {
        total = sample;
      } else {
        processors.add(sample);
      }
    }
    // A cold WMI provider returns 0 for rate counters on its first query: that is no sample, not a 0 MHz clock.
    if (total == null || total.effectiveMhz == 0 || processors.isEmpty) {
      throw const FormatException(
        'Windows exposed no per-processor performance counters.',
      );
    }
    processors.sort((a, b) => _order(a.name).compareTo(_order(b.name)));
    return CpuFrequencySnapshot(
      nominalMhz: nominal,
      total: total,
      processors: List.unmodifiable(processors),
    );
  }

  // "group,index" sorts numerically: 0,2 before 0,10.
  static int _order(String name) {
    final parts = name.split(',');
    return int.parse(parts[0]) * 4096 + int.parse(parts[1]);
  }
}
