import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/cpu_frequency_service.dart';

String _row(String name, int performance, {bool parked = false}) =>
    '{"name":"$name","performance":$performance,"utility":5,"parked":$parked}';

void main() {
  test(
    'effective clock uses the Task Manager formula and sorts numerically',
    () {
      final snapshot = WindowsCpuFrequencyService.parse(
        '{"nominalMhz":3400,"rows":[${_row('0,10', 50)},${_row('_Total', 117)},'
        '${_row('0,2', 125, parked: true)},${_row('0,0', 100)}]}',
      );

      expect(snapshot.total.effectiveMhz, 3978);
      expect(snapshot.processors.map((cpu) => cpu.name), [
        '0,0',
        '0,2',
        '0,10',
      ]);
      expect(snapshot.processors.map((cpu) => cpu.effectiveMhz), [
        3400,
        4250,
        1700,
      ]);
      expect(snapshot.parkedCount, 1);
    },
  );

  test('missing or implausible counters are errors, never zeros', () {
    for (final output in <String>[
      'not json',
      '{"nominalMhz":3400,"rows":[${_row('_Total', 100)}]}',
      '{"nominalMhz":3400,"rows":[${_row('0,0', 100)}]}',
      '{"nominalMhz":0,"rows":[${_row('_Total', 100)},${_row('0,0', 100)}]}',
      '{"nominalMhz":3400,"rows":[${_row('_Total', -1)},${_row('0,0', 100)}]}',
      '{"nominalMhz":3400,"rows":[{"name":"0,0"}]}',
      '{"nominalMhz":3400,"rows":[${_row('_Total', 0)},${_row('0,0', 0)}]}',
    ]) {
      expect(
        () => WindowsCpuFrequencyService.parse(output),
        throwsFormatException,
        reason: output,
      );
    }
  });
}
