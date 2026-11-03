// VM only: adds and removes a real Defender exclusion. Run elevated.
import 'dart:convert';
import 'dart:io';

import 'package:script_utility/core/operations/defender_exclusion_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/platform/windows/game_folder_facts.dart';

Future<String> _powerShell(String script) async {
  final result = await Process.run(
    r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    <String>[
      '-NoProfile',
      '-NonInteractive',
      '-EncodedCommand',
      base64Encode(
        script.codeUnits
            .expand((unit) => <int>[unit & 0xff, unit >> 8])
            .toList(),
      ),
    ],
  );
  if (result.exitCode != 0) throw StateError('${result.stderr}');
  return '${result.stdout}'.trim();
}

Future<List<String>> _exclusions() async =>
    (jsonDecode(
              await _powerShell(
                r'ConvertTo-Json -Compress -InputObject @((Get-MpPreference).ExclusionPath | Where-Object { $_ })',
              ),
            )
            as List)
        .cast<String>();

Future<void> main() async {
  var ok = true;
  void check(String label, bool passed) {
    ok &= passed;
    stdout.writeln('${passed ? 'OK  ' : 'FAIL'} $label');
  }

  const userOwn = r'C:\UserOwnExclusion';
  const game = r"C:\VmGames\Baldur's Gate 3";
  const library = r'C:\VmGames';
  Directory(userOwn).createSync(recursive: true);
  Directory(game).createSync(recursive: true);
  File('$game\\bg3.exe').writeAsStringSync('stub');
  Directory(r'C:\VmGames\Other Game').createSync();
  File(r'C:\VmGames\Other Game\other.exe').writeAsStringSync('stub');
  await _powerShell("Add-MpPreference -ExclusionPath '$userOwn'");

  stdout.writeln(
    'Status: ${await _powerShell(DefenderStatus.script)} '
    'Tamper: ${await _powerShell(r'[bool](Get-MpComputerStatus).IsTamperProtected')}',
  );
  final operation = DefenderGameFolderExclusionOperation(
    powerShell: _powerShell,
    facts: windowsGameFolderFacts,
  );
  const context = OperationContext(windowsBuild: 26100, edition: 'Pro');
  OperationRequest request(
    String path,
    bool exclude, [
    Map<String, Object?> parameters = const <String, Object?>{},
  ]) => OperationRequest(
    operationId: operation.id,
    target: path,
    desiredValue: exclude,
    parameters: parameters,
  );

  final add = request(game, true);
  check(
    'supports game folder',
    (await operation.supports(context, add)).supported,
  );
  final snapshot = await operation.captureSnapshot(add);
  check('snapshot absent', snapshot.data['present'] == false);
  await operation.apply(add);
  check('verify present', (await operation.verify(add)).value == true);
  check('Get-MpPreference lists it', (await _exclusions()).contains(game));
  await operation.rollback(add, snapshot);
  final after = await _exclusions();
  check('rollback removed it', !after.contains(game));
  check('user exclusion untouched', after.contains(userOwn));

  final remove = request(game, false);
  await operation.apply(add);
  final removeSnapshot = await operation.captureSnapshot(remove);
  await operation.apply(remove);
  check('remove works', !(await _exclusions()).contains(game));
  await operation.rollback(remove, removeSnapshot);
  check('remove rollback re-adds', (await _exclusions()).contains(game));
  await operation.apply(remove);

  for (final refused in <String>[
    r'C:\Windows',
    r'C:\Program Files',
    r'C:\',
    Platform.environment['USERPROFILE']!,
    Directory.systemTemp.path,
  ]) {
    check(
      'refuses $refused',
      !(await operation.supports(context, request(refused, true))).supported,
    );
  }
  check(
    'library needs a second consent',
    !(await operation.supports(context, request(library, true))).supported &&
        (await operation.supports(
          context,
          request(library, true, {'acknowledgedWarning': 'severalGames'}),
        )).supported,
  );

  await _powerShell("Remove-MpPreference -ExclusionPath '$userOwn'");
  stdout.writeln('CLEAN=$ok');
  exit(ok ? 0 : 1);
}
