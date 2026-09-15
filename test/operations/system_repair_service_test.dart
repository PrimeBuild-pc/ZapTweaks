import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/system_repair_service.dart';

void main() {
  test(
    'DISM repair requires a separate successful health verification',
    () async {
      final calls = <List<String>>[];
      final service = WindowsRepairService(
        processRunner: ProcessRunner(
          processRunDelegate:
              (executable, arguments, {runInShell = false}) async {
                calls.add(<String>[executable, ...arguments]);
                return ProcessResult(1, calls.length == 1 ? 0 : 2, '', '');
              },
        ),
      );

      final report = await service.repairComponentStore();

      expect(report.repairExitCode, 0);
      expect(report.verificationExitCode, 2);
      expect(report.verified, isFalse);
      expect(calls, hasLength(2));
      expect(calls.last, contains('/ScanHealth'));
    },
  );

  test(
    'failed SFC repair does not claim success or run verification',
    () async {
      var calls = 0;
      final service = WindowsRepairService(
        processRunner: ProcessRunner(
          processRunDelegate:
              (executable, arguments, {runInShell = false}) async {
                calls++;
                return ProcessResult(1, 1, '', 'failed');
              },
        ),
      );

      final report = await service.repairSystemFiles();

      expect(report.verified, isFalse);
      expect(report.verificationExitCode, -1);
      expect(calls, 1);
    },
  );
}
