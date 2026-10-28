import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/security/helper_output_files.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  group(
    'elevated helper output files',
    () {
      late Directory sandbox;
      late Directory helper;
      setUp(() async {
        sandbox = await Directory.systemTemp.createTemp('zap-helper-out-');
        helper = await Directory('${sandbox.path}/Helper').create();
      });
      tearDown(() async {
        HelperOutputFiles.closeAll();
        await sandbox.delete(recursive: true);
      });

      test('writes, appends and replaces through one pinned handle', () {
        HelperOutputFiles.pin(helper);
        final events = '${helper.path}${Platform.pathSeparator}n.json.events';
        final response =
            '${helper.path}${Platform.pathSeparator}n.json.response';
        HelperOutputFiles.append(events, 'a\n');
        HelperOutputFiles.append(events, 'b\n');
        HelperOutputFiles.replace(
          response,
          '{"success":false,"long":"xxxxxxxx"}',
        );
        HelperOutputFiles.replace(response, '{"success":true}');
        HelperOutputFiles.closeAll();
        expect(File(events).readAsStringSync(), 'a\nb\n');
        expect(File(response).readAsStringSync(), '{"success":true}');
      });

      test(
        'a name prepared in advance (a planted file or link) is refused',
        () {
          final victim = File('${sandbox.path}/victim.txt')
            ..writeAsStringSync('keep');
          final planted = File('${helper.path}/n.json.events')
            ..writeAsStringSync('');
          HelperOutputFiles.pin(helper);
          expect(
            () => HelperOutputFiles.append(planted.path, 'x'),
            throwsA(isA<FileSystemException>()),
          );
          expect(victim.readAsStringSync(), 'keep');
          expect(planted.readAsStringSync(), isEmpty);
        },
      );

      test('a helper directory that is a junction is refused', () async {
        final elsewhere = await Directory('${sandbox.path}/Elsewhere').create();
        final junction = '${sandbox.path}/Junction';
        final result = await Process.run('cmd.exe', <String>[
          '/c',
          'mklink',
          '/J',
          junction.replaceAll('/', r'\'),
          elsewhere.path.replaceAll('/', r'\'),
        ]);
        expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
        expect(
          () => HelperOutputFiles.pin(Directory(junction)),
          throwsA(isA<FileSystemException>()),
        );
        await Directory(junction).delete();
      });

      test('writing before the directory is pinned is refused', () {
        expect(
          () => HelperOutputFiles.append('${helper.path}/n.json.events', 'x'),
          throwsStateError,
        );
      });
    },
    skip: Platform.isWindows ? false : 'Windows handles only',
  );

  test('Windows tools resolve to their real folder, other names stay', () {
    bool exists(String path) =>
        path == r'C:\Windows\System32\reg.exe' ||
        path == r'C:\Windows\explorer.exe';
    String resolve(String name) => ProcessRunner.resolveSystemExecutable(
      name,
      windowsDirectory: r'C:\Windows',
      exists: exists,
    );
    expect(
      resolve('powershell'),
      r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    );
    expect(resolve('reg'), r'C:\Windows\System32\reg.exe');
    expect(resolve('explorer.exe'), r'C:\Windows\explorer.exe');
    expect(resolve('winget'), 'winget');
    expect(resolve(r'C:\Tools\x.exe'), r'C:\Tools\x.exe');
  });
}
