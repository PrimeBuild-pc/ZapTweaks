import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:script_utility/core/models/update_info.dart';
import 'package:script_utility/core/services/hardware_detection_service.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/core/services/system_action_service.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/core/tweak_manager.dart';
import 'package:script_utility/models/recovered_script_tweaks.dart';

class _CapturingLaunchRunner extends ProcessRunner {
  String? executable;
  List<String>? arguments;
  bool? usedShell;

  @override
  Future<CommandResult> launch(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    this.executable = executable;
    this.arguments = arguments;
    usedShell = runInShell;
    return const CommandResult(exitCode: 0, stdout: '', stderr: '');
  }
}

void main() {
  test('safe audit preserves actions and PowerShell encoding', () async {
    final tweaks = createRecoveredScriptTweaks();
    expect(tweaks, hasLength(92));
    expect(tweaks.map((item) => item.id).toSet(), hasLength(92));

    late List<String> capturedArguments;
    final runner = ProcessRunner(
      processRunDelegate:
          (
            String executable,
            List<String> arguments, {
            bool runInShell = false,
          }) async {
            expect(executable, 'powershell');
            capturedArguments = arguments;
            return ProcessResult(0, 0, ' result ', '');
          },
    );

    const script = 'Write-Output "è"';
    expect(await runner.runPowerShellForOutput(script), 'result');

    final bytes = base64Decode(capturedArguments.last);
    final decoded = String.fromCharCodes(<int>[
      for (var index = 0; index < bytes.length; index += 2)
        bytes[index] | (bytes[index + 1] << 8),
    ]);
    expect(decoded, script);
  });

  test('elevated PowerShell propagates the child exit code', () async {
    late List<String> capturedArguments;
    final runner = ProcessRunner(
      processRunDelegate:
          (
            String executable,
            List<String> arguments, {
            bool runInShell = false,
          }) async {
            capturedArguments = arguments;
            return ProcessResult(0, 0, '', '');
          },
    );

    await runner.runPowerShellScript('Write-Output test', elevated: true);

    expect(capturedArguments.last, contains('-PassThru -Wait'));
    expect(capturedArguments.last, contains(r'exit $process.ExitCode'));
  });

  test(
    'production timeout terminates the Windows process tree',
    () async {
      final marker = File(
        '${Directory.systemTemp.path}\\zaptweaks-timeout-${DateTime.now().microsecondsSinceEpoch}.txt',
      );
      final runner = ProcessRunner();

      final result = await runner.run('cmd', <String>[
        '/c',
        'ping 127.0.0.1 -n 3 >nul & echo survived > "${marker.path}"',
      ], timeout: const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 2300));

      expect(result.success, isFalse);
      expect(
        result.stderr,
        startsWith('Command timed out and was terminated.'),
      );
      expect(marker.existsSync(), isFalse);
    },
    skip: !Platform.isWindows,
  );

  test('TweakManager serializes concurrent applications', () async {
    var active = 0;
    var maximum = 0;
    final runner = ProcessRunner(
      processRunDelegate:
          (
            String executable,
            List<String> arguments, {
            bool runInShell = false,
          }) async {
            active++;
            maximum = active > maximum ? active : maximum;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            active--;
            return ProcessResult(0, 0, '', '');
          },
    );
    final manager = TweakManager(processRunner: runner);

    final results = await Future.wait([
      manager.applyTweak('network_ecn_disabled', true),
      manager.applyTweak('network_timestamps_disabled', true),
    ]);

    expect(results.every((result) => result.success), isTrue);
    expect(maximum, 1);
  });

  test(
    'hardware detection uses one process and preserves vendor data',
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
    },
  );

  test('update checks report availability without installing', () async {
    final service = SystemActionService(
      processRunner: ProcessRunner(
        mode: ProcessExecutionMode.dryRun,
        dryRunDelay: Duration.zero,
      ),
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object>{
            'tag_name': 'v1.5.0',
            'html_url': 'https://example.test/release',
            'body': 'Release notes',
            'assets': <Object>[
              <String, String>{
                'name': 'ZapTweaks_Setup_v1.5.0.exe',
                'browser_download_url': 'https://example.test/setup.exe',
              },
            ],
          }),
          200,
        );
      }),
    );

    final result = await service.checkUpdateAvailability(
      currentVersion: '1.4.1',
      latestReleaseApiUrl: 'https://example.test/latest',
      releasesPageUrl: 'https://example.test/releases',
    );

    expect(result.success, isTrue);
    expect(result.hasUpdate, isTrue);
    expect(result.update?.version, '1.5.0');
    expect(result.update?.installerUrl, 'https://example.test/setup.exe');
  });

  test('video guide opens with the default Windows app', () async {
    final previousRunner = ProcessRunner.shared;
    final runner = _CapturingLaunchRunner();
    ProcessRunner.configureShared(runner);

    try {
      final video = TweakCatalogService()
          .buildCatalog()
          .firstWhere((item) => item.id == 'tool_star_ethernet_analyzer_video')
          .scriptTweak!;

      await video.runAction();

      expect(runner.executable, 'cmd');
      expect(runner.arguments, containsAllInOrder(<String>['/c', 'start']));
      expect(runner.arguments?.last, endsWith('0. How_to_use.mp4'));
      expect(runner.usedShell, isTrue);
    } finally {
      ProcessRunner.configureShared(previousRunner);
    }
  });

  test('automatic installer waits, updates, and reopens the app', () async {
    final runner = _CapturingLaunchRunner();
    final service = SystemActionService(
      processRunner: runner,
      httpClient: MockClient((request) async {
        return http.Response.bytes(<int>[1, 2, 3], 200);
      }),
    );
    const update = UpdateInfo(
      version: '9.9.9-test',
      releaseUrl: 'https://example.test/release',
      installerUrl: 'https://example.test/ZapTweaks_Setup.exe',
      releaseNotes: '',
    );

    final result = await service.installUpdate(update);
    final helper = runner.arguments?.last ?? '';

    expect(result.success, isTrue);
    expect(result.shouldExitApp, isTrue);
    expect(helper, contains('Wait-Process'));
    expect(helper, contains("'/VERYSILENT'"));
    expect(helper, contains('Start-Process -FilePath'));
    await Directory(
      '${Directory.systemTemp.path}\\ZapTweaks\\updates\\9.9.9-test',
    ).delete(recursive: true);
  });

  test('safe preset excludes security and irreversible actions', () {
    final byId = {
      for (final item in TweakCatalogService().buildCatalog()) item.id: item,
    };

    for (final id in <String>[
      'checks_uac_off',
      'checks_firewall_off',
      'checks_spectre_meltdown_off',
      'checks_dep_off',
      'checks_core_isolation_off',
      'network_ipv4_only',
      'privacy_safe_debloat',
    ]) {
      expect(byId[id]?.isAggressive, isTrue, reason: id);
    }
    expect(byId['privacy_safe_debloat']?.isScriptAction, isTrue);
    expect(byId, isNot(contains('power_min_processor_state')));
    expect(byId, isNot(contains('tool_process_explorer_folder')));
    expect(byId, isNot(contains('tool_process_monitor_folder')));
    expect(byId, isNot(contains('tool_tcpview_folder')));
    expect(byId, isNot(contains('tool_latencymon_folder')));
  });
}
