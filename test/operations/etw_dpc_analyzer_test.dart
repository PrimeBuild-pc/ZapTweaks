import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/etw_dpc_analyzer.dart';

void main() {
  const fixture = '''
<Events>
  <Event><System><Provider Name="Microsoft-Windows-Kernel"/><Task>DPC</Task></System></Event>
  <Event><System><Provider Name="Microsoft-Windows-Kernel"/><Opcode>ISR</Opcode></System></Event>
  <Event><System><Provider Name="Memory"/></System><EventData><Data>HardFault</Data></EventData></Event>
  <Event><System><Provider Name="Scheduler"/><Task>CSwitch</Task></System></Event>
  <Event><System><Provider Name="Scheduler"/><Task>ReadyThread</Task></System></Event>
</Events>
''';

  test('ETW XML report counts diagnostic event classes without claims', () {
    final report = EtwDpcAnalyzer.parseXml(fixture);

    expect(report.analysisAvailable, isTrue);
    expect(report.totalEvents, 5);
    expect(report.dpcEvents, 1);
    expect(report.isrEvents, 1);
    expect(report.hardFaultEvents, 1);
    expect(report.contextSwitchEvents, 1);
    expect(report.topProviders['Scheduler'], 2);
    expect(report.toJson()['interpretation'], contains('do not prove latency'));
  });

  test(
    'analyzer writes a bounded sidecar and removes intermediate XML',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'zap-etw-report-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final trace = await File(
        '${directory.path}/trace.etl',
      ).writeAsBytes(<int>[1]);
      final analyzer = EtwDpcAnalyzer(
        processRunner: ProcessRunner(
          processRunDelegate:
              (executable, arguments, {runInShell = false}) async {
                await File(arguments[4]).writeAsString(fixture);
                return ProcessResult(1, 0, '', '');
              },
        ),
      );

      final output = await analyzer.analyze(trace);
      final json =
          jsonDecode(await output.readAsString()) as Map<String, dynamic>;

      expect(
        json['analysisAvailable'],
        isTrue,
        reason: json['message'] as String?,
      );
      expect(json['dpcEvents'], 1);
      expect(File('${trace.path}.events.xml').existsSync(), isFalse);
    },
  );
}
