import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/battery_health_service.dart';

String _battery({
  String name = 'BAT0',
  Object? designed,
  Object? full,
  Object? cycles,
  Object? remaining,
  Object? online,
}) =>
    '{"name":"$name","designed":$designed,"full":$full,"cycles":$cycles,'
    '"remaining":$remaining,"online":$online}';

BatterySnapshot _parse(String source, List<String> batteries) =>
    WindowsBatteryHealthService.parse(
      '{"source":"$source","batteries":[${batteries.join(',')}]}',
    );

void main() {
  test('a battery at full design capacity is 100% healthy, 0% worn', () {
    final battery = _parse('wmi', [
      _battery(
        designed: 50000,
        full: 50000,
        cycles: 12,
        remaining: 25000,
        online: true,
      ),
    ]).batteries.single;

    expect(battery.healthPercent, 100);
    expect(battery.wearPercent, 0);
    expect(battery.band, BatteryHealthBand.good);
    expect(battery.chargePercent, 50);
    expect(battery.cycles, 12);
    expect(battery.onAcPower, isTrue);
  });

  test('a worn battery reports health, wear and its band', () {
    final fair = _parse('wmi', [
      _battery(designed: 50000, full: 35000),
    ]).batteries.single;
    expect(fair.healthPercent, 70);
    expect(fair.wearPercent, 30);
    expect(fair.band, BatteryHealthBand.fair);

    final poor = _parse('wmi', [
      _battery(designed: 50000, full: 29500),
    ]).batteries.single;
    expect(poor.healthPercent, 59);
    expect(poor.band, BatteryHealthBand.poor);

    final edge = _parse('wmi', [
      _battery(designed: 50000, full: 40000),
    ]).batteries.single;
    expect(edge.band, BatteryHealthBand.good, reason: '80% is good');
  });

  test('missing design capacity is unavailable, never 0%', () {
    final battery = _parse('report', [
      _battery(designed: null, full: 41000, cycles: null),
    ]).batteries.single;

    expect(battery.healthPercent, isNull);
    expect(battery.wearPercent, isNull);
    expect(battery.band, isNull);
    expect(battery.fullChargedMwh, 41000);
    expect(battery.cycles, isNull);
  });

  test('zero or negative readings are treated as not read', () {
    final battery = _parse('wmi', [
      _battery(designed: 0, full: -5, cycles: 0, remaining: 0),
    ]).batteries.single;

    expect(battery.designedMwh, isNull);
    expect(battery.fullChargedMwh, isNull);
    expect(battery.healthPercent, isNull);
    expect(battery.chargePercent, isNull);
    expect(battery.cycles, isNull, reason: 'firmware without a counter says 0');
  });

  test('more capacity than designed is capped at 100%', () {
    final battery = _parse('wmi', [
      _battery(designed: 50000, full: 52000),
    ]).batteries.single;
    expect(battery.healthPercent, 100);
    expect(battery.wearPercent, 0);
  });

  test('no battery means nothing to show; several give one row each', () {
    expect(_parse('none', []).batteries, isEmpty);
    expect(_parse('none', []).hasBattery, isFalse);

    final two = _parse('wmi', [
      _battery(name: 'BAT0', designed: 40000, full: 38000),
      _battery(name: 'BAT1', designed: 20000, full: 10000),
    ]);
    expect(two.batteries.map((b) => b.name), ['BAT0', 'BAT1']);
    expect(two.batteries.map((b) => b.healthPercent), [95, 50]);
  });

  test('malformed output is rejected', () {
    expect(
      () => WindowsBatteryHealthService.parse('{"batteries":"x"}'),
      throwsFormatException,
    );
  });
}
