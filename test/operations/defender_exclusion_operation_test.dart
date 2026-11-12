import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/defender_exclusion_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/features/power/domain/game_folder_policy.dart';
import 'package:script_utility/features/presets/domain/preset_catalog.dart';

/// Defender as seen through PowerShell: a list of path exclusions.
class _FakeDefender {
  _FakeDefender(this.exclusions);
  final List<String> exclusions;
  String mode = 'Normal';
  bool realTime = true;
  bool refuseWrites = false;
  final scripts = <String>[];

  Future<String> run(String script) async {
    scripts.add(script);
    if (script.contains('Get-MpComputerStatus')) {
      return jsonEncode({'Mode': mode, 'RealTime': realTime, 'Ignored': false});
    }
    if (script.contains('Get-MpPreference')) return jsonEncode(exclusions);
    final payload = RegExp(r"FromBase64String\('([^']*)'\)").firstMatch(script);
    final path = utf8.decode(base64Decode(payload!.group(1)!));
    if (refuseWrites) throw StateError('0x800106ba');
    if (script.contains('Add-MpPreference')) exclusions.add(path);
    if (script.contains('Remove-MpPreference')) exclusions.remove(path);
    return '';
  }
}

void main() {
  const game = r"D:\Games\Baldur's Gate 3";
  const context = OperationContext(windowsBuild: 26100, edition: 'Pro');
  late _FakeDefender defender;
  late DefenderGameFolderExclusionOperation operation;

  GameFolderFacts facts({int games = 0}) => GameFolderFacts(
    protectedFolders: const <String>[r'C:\Program Files'],
    forbiddenTrees: const <String>[r'C:\Windows'],
    resolve: (path) => (path: path, directory: true),
    separateGameFolders: (_) => games,
  );

  OperationRequest request(
    bool exclude, {
    String path = game,
    Map<String, Object?> parameters = const <String, Object?>{},
  }) => OperationRequest(
    operationId: DefenderGameFolderExclusionOperation.operationId,
    target: path,
    desiredValue: exclude,
    parameters: parameters,
  );

  setUp(() {
    defender = _FakeDefender(<String>[r'E:\UserOwn', r'F:\Work']);
    operation = DefenderGameFolderExclusionOperation(
      powerShell: defender.run,
      facts: facts,
    );
  });

  test('adds, verifies and rolls back only its own folder', () async {
    final add = request(true);
    expect((await operation.supports(context, add)).supported, isTrue);
    final snapshot = await operation.captureSnapshot(add);
    expect(snapshot.data, <String, Object?>{'path': game, 'present': false});
    // The user's own exclusions never reach the journal.
    expect(jsonEncode(snapshot.toJson()), isNot(contains('UserOwn')));

    await operation.apply(add);
    expect((await operation.verify(add)).value, isTrue);
    expect(defender.exclusions, <String>[r'E:\UserOwn', r'F:\Work', game]);

    await operation.rollback(add, snapshot);
    expect(defender.exclusions, <String>[r'E:\UserOwn', r'F:\Work']);
    expect(
      (await operation.inspect(add)).sameValue(snapshot.expectedAfterRollback),
      isTrue,
    );
  });

  test('the path travels as base64, never as PowerShell text', () async {
    await operation.apply(request(true));
    final write = defender.scripts.singleWhere(
      (script) => script.contains('Add-MpPreference'),
    );
    expect(write, isNot(contains("Baldur's")));
    expect(write, contains(r'-ExclusionPath $arg'));
  });

  test('removing restores a pre-existing exclusion on rollback', () async {
    defender.exclusions.add(game);
    final remove = request(false);
    final snapshot = await operation.captureSnapshot(remove);
    await operation.apply(remove);
    expect(defender.exclusions, isNot(contains(game)));
    await operation.rollback(remove, snapshot);
    expect(defender.exclusions, contains(game));
  });

  test('refuses protected folders and unacknowledged launchers', () async {
    expect(
      (await operation.supports(
        context,
        request(true, path: r'C:\Program Files'),
      )).supported,
      isFalse,
    );
    final library = DefenderGameFolderExclusionOperation(
      powerShell: defender.run,
      facts: () => facts(games: 3),
    );
    expect((await library.supports(context, request(true))).supported, isFalse);
    expect(
      (await library.supports(
        context,
        request(true, parameters: {'acknowledgedWarning': 'severalGames'}),
      )).supported,
      isTrue,
    );
  });

  test('a forged rollback cannot add an unchecked exclusion', () async {
    for (final path in <String>[r'C:\Program Files', r'C:\*', r'C:\Windows']) {
      final forged = OperationSnapshot(
        type: 'defenderExclusion',
        data: <String, Object?>{'path': path, 'present': true},
        expectedAfterRollback: const OperationState(
          OperationStateKind.configured,
          value: true,
        ),
      );
      await expectLater(
        operation.rollback(request(false, path: path), forged),
        throwsStateError,
        reason: path,
      );
    }
    expect(defender.exclusions, <String>[r'E:\UserOwn', r'F:\Work']);
    expect(
      (await operation.supports(
        context,
        request(false, path: r'C:\*'),
      )).supported,
      isFalse,
    );
  });

  test('refuses when Defender is not the active real-time antivirus', () async {
    defender.mode = 'Passive Mode';
    expect(
      (await operation.supports(context, request(true))).reason,
      contains('not the active antivirus'),
    );
    defender
      ..mode = 'Normal'
      ..realTime = false;
    expect(
      (await operation.supports(context, request(true))).supported,
      isFalse,
    );
    // Removing an exclusion stays possible.
    expect(
      (await operation.supports(context, request(false))).supported,
      isTrue,
    );
  });

  test('a refused write reports Tamper Protection or policy', () async {
    defender.refuseWrites = true;
    await expectLater(
      operation.apply(request(true)),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Tamper Protection'),
        ),
      ),
    );
  });

  test('without administrator rights the list is unknown, not empty', () async {
    defender.exclusions
      ..clear()
      ..add('N/A: Must be an administrator to view exclusions');
    expect(
      (await operation.inspect(request(true))).kind,
      OperationStateKind.error,
    );
  });

  test('no preset ever contains the Defender exclusion', () {
    for (final preset in builtInPresets) {
      expect(
        preset.items.whereType<TweakPresetItem>().map(
          (item) => item.operationId,
        ),
        isNot(contains(DefenderGameFolderExclusionOperation.operationId)),
        reason: preset.id,
      );
    }
    final sources = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.contains('presets') || file.path.contains('setup'),
        );
    for (final file in sources) {
      expect(
        file.readAsStringSync(),
        isNot(contains('defender.exclusion')),
        reason: file.path,
      );
    }
  });

  test('the fixed claim exists in all 7 languages and in 3 UI places', () {
    for (final lang in <String>['en', 'it', 'de', 'es', 'fr', 'ru', 'zh']) {
      final arb =
          jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map;
      expect(
        (arb['gameFolderExclusionClaim'] as String?)?.trim(),
        isNotEmpty,
        reason: lang,
      );
      expect(
        arb.keys.where(
          (key) =>
              key is String &&
              (key.startsWith('gameFolder') || key.startsWith('defender')),
        ),
        hasLength(28),
        reason: lang,
      );
    }
    final page = File(
      'lib/features/power/presentation/game_folder_exclusion_page.dart',
    ).readAsStringSync();
    expect(
      'gameFolderExclusionClaim'.allMatches(page).length,
      greaterThanOrEqualTo(3),
    );
  });
}
