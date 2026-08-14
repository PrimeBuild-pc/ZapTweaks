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
                  'networkAdapters': <String>[
                    'Intel Ethernet [NDIS; Intel v1.2.3; Up]',
                  ],
                  'audioDevices': <String>['USB Audio [Realtek v1.2.3]'],
                  'gpuDrivers': <String>['NVIDIA GeForce RTX [NVIDIA v1.2.3]'],
                  'chipsetDrivers': <String>['AMD SMBus [AMD v1.2.3]'],
                  'monitors': <String>['LG ULTRAGEAR'],
                  'mice': <String>['Logitech G Pro'],
                  'keyboards': <String>['Keychron K2'],
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
      expect(profile.networkAdapters.single, contains('Intel Ethernet'));
      expect(profile.audioDevices.single, contains('Realtek'));
      expect(profile.gpuDrivers.single, contains('NVIDIA'));
      expect(profile.chipsetDrivers.single, contains('SMBus'));
      expect(profile.monitors, <String>['LG ULTRAGEAR']);
      expect(profile.mice, <String>['Logitech G Pro']);
      expect(profile.keyboards, <String>['Keychron K2']);
    },
  );
}
