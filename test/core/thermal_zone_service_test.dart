import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/thermal_zone_service.dart';

String _zone(String name, int tenths, {int kelvin = 0, int passive = 100}) =>
    '{"name":"${name.replaceAll(r'\', r'\\')}","tenthsKelvin":$tenths,"kelvin":$kelvin,"passive":$passive}';

void main() {
  test('counters give named zones with the firmware throttling limit', () {
    final snapshot = WindowsThermalSensorService.parse(
      '{"source":"counters","zones":[${_zone(r'\_TZ.TZ00', 3184)},${_zone(r'\_TZ.CPUZ', 3532, passive: 80)}]}',
    );
    expect(snapshot.source, ThermalZoneSource.counters);
    expect(snapshot.zones.map((zone) => zone.name), ['TZ00', 'CPUZ']);
    expect(snapshot.zones.map((zone) => zone.celsius), [45.3, 80.1]);
    expect(snapshot.zones.map((zone) => zone.limited), [false, true]);
  });

  test('missing or impossible readings are left out, never shown as 0 °C', () {
    final snapshot = WindowsThermalSensorService.parse(
      '{"source":"counters","zones":[${_zone('A', 0)},${_zone('B', 0, kelvin: 318)},${_zone('C', 9999)},${_zone('D', 1000)}]}',
    );
    expect(snapshot.zones.map((zone) => zone.name), [
      'B',
    ], reason: 'whole-Kelvin fallback');
    expect(snapshot.zones.single.celsius, 44.9);

    final none = WindowsThermalSensorService.parse(
      '{"source":"counters","zones":[${_zone('A', 0)}]}',
    );
    expect(none.source, ThermalZoneSource.none);
    expect(none.zones, isEmpty);
  });

  test('ACPI fallback names and unknown passive limit', () {
    final snapshot = WindowsThermalSensorService.parse(
      '{"source":"acpi","zones":[${_zone(r'ACPI\ThermalZone\TZ01_0', 3000, passive: -1)}]}',
    );
    expect(snapshot.zones.single.name, 'TZ01');
    expect(snapshot.zones.single.passiveLimit, isNull);
    expect(snapshot.zones.single.limited, isFalse);
  });

  test('malformed output is an error', () {
    for (final output in <String>[
      'not json',
      '{"zones":[]}',
      '{"source":"other","zones":[]}',
      '{"source":"counters","zones":[{"name":"A"}]}',
    ]) {
      expect(
        () => WindowsThermalSensorService.parse(output),
        throwsFormatException,
        reason: output,
      );
    }
  });
}
