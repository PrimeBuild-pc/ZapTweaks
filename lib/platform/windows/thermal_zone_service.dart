import 'dart:convert';

import '../../core/services/process_runner.dart';

/// One ACPI thermal zone: a sensor the firmware chose (board, chassis or CPU package), not necessarily the CPU die.
class ThermalZoneReading {
  const ThermalZoneReading({
    required this.name,
    required this.celsius,
    this.passiveLimit,
  });

  final String name;
  final double celsius;

  /// Percent of full speed the firmware allows (100 = no limit); null when the source does not report it.
  final int? passiveLimit;

  bool get limited => passiveLimit != null && passiveLimit! < 100;
}

enum ThermalZoneSource { counters, acpi, none }

class ThermalZoneSnapshot {
  const ThermalZoneSnapshot({required this.source, required this.zones});

  final ThermalZoneSource source;
  final List<ThermalZoneReading> zones;
}

/// Read-only. The "Thermal Zone Information" counter set needs no administrator rights and also reports the passive
/// (firmware) throttling limit; MSAcpi_ThermalZoneTemperature is the fallback and usually needs elevation.
/// A zone that reports no value is left out: it is never shown as 0 °C.
class WindowsThermalSensorService {
  const WindowsThermalSensorService({required this.processRunner});

  final ProcessRunner processRunner;

  static const script = r'''
$zones=@(Get-CimInstance -ClassName Win32_PerfFormattedData_Counters_ThermalZoneInformation -ErrorAction SilentlyContinue | ForEach-Object {
  [ordered]@{name=[string]$_.Name;tenthsKelvin=[int]$_.HighPrecisionTemperature;kelvin=[int]$_.Temperature;passive=[int]$_.PercentPassiveLimit} })
$source='counters'
if($zones.Count -eq 0){
  $source='acpi'
  try { $zones=@(Get-CimInstance -Namespace root/wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop | ForEach-Object {
    [ordered]@{name=[string]$_.InstanceName;tenthsKelvin=[int]$_.CurrentTemperature;kelvin=0;passive=-1} }) } catch { $zones=@() }
  if($zones.Count -eq 0){$source='none'}
}
[ordered]@{source=$source;zones=$zones} | ConvertTo-Json -Compress -Depth 4
''';

  Future<ThermalZoneSnapshot> capture() async =>
      parse(await processRunner.runPowerShellForOutput(script));

  static ThermalZoneSnapshot parse(String output) {
    final json = jsonDecode(output);
    if (json is! Map || json['zones'] is! List) {
      throw const FormatException('Invalid thermal zone response.');
    }
    final source = ThermalZoneSource.values.firstWhere(
      (value) => value.name == json['source'],
      orElse: () => throw const FormatException('Unknown thermal zone source.'),
    );
    final zones = <ThermalZoneReading>[];
    for (final row in json['zones'] as List) {
      if (row is! Map ||
          row['name'] is! String ||
          row['tenthsKelvin'] is! int ||
          row['kelvin'] is! int ||
          row['passive'] is! int) {
        throw const FormatException('Invalid thermal zone row.');
      }
      // Older builds fill only the whole-Kelvin counter.
      final tenths = row['tenthsKelvin'] as int > 0
          ? row['tenthsKelvin'] as int
          : (row['kelvin'] as int) * 10;
      // Kelvin tenths minus 2731.5 always ends in .5: round in tenths so the result never depends on float error.
      final celsius = (tenths - 2731.5).round() / 10;
      // 0 K means "no reading"; anything outside a physical range is a firmware placeholder, not a temperature.
      if (tenths <= 0 || celsius < -40 || celsius > 150) continue;
      final passive = row['passive'] as int;
      zones.add(
        ThermalZoneReading(
          name: displayName(row['name'] as String),
          celsius: celsius,
          passiveLimit: passive >= 0 && passive <= 100 ? passive : null,
        ),
      );
    }
    return ThermalZoneSnapshot(
      source: zones.isEmpty ? ThermalZoneSource.none : source,
      zones: List.unmodifiable(zones),
    );
  }

  /// `\_TZ.TZ00` (counters) or `ACPI\ThermalZone\TZ00_0` (WMI) → `TZ00`.
  static String displayName(String name) {
    final last = name
        .split(RegExp(r'[\\.]'))
        .lastWhere((part) => part.isNotEmpty, orElse: () => name);
    return last.replaceFirst(RegExp(r'_\d+$'), '');
  }
}
