import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/services/hardware_detection_service.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'hardware detection collects the profile with one PowerShell process',
    () async {
      var calls = 0;
      final runner = ProcessRunner(
        processRunDelegate:
            (
              String executable,
              List<String> arguments, {
              bool runInShell = false,
            }) async {
              calls++;
              return ProcessResult(
                0,
                0,
                jsonEncode(<String, Object>{
                  'cpuName': 'AMD Ryzen 7',
                  'gpuNames': <String>['NVIDIA GeForce RTX', 'Intel Arc'],
                  'ramInstalledBytes': 17179869184,
                  'networkAdapters': <String>['Ethernet [NetAdapterCx]'],
                  'audioDevices': <String>['USB Audio'],
                }),
                '',
              );
            },
      );

      final profile = await HardwareDetectionService(
        processRunner: runner,
      ).detect();

      expect(calls, 1);
      expect(profile.cpuVendor, 'amd');
      expect(profile.gpuVendors, <String>{'nvidia', 'intel'});
      expect(profile.ramInstalledBytes, 17179869184);
      expect(profile.networkAdapters, hasLength(1));
      expect(profile.audioDevices, <String>['USB Audio']);
    },
  );
}
