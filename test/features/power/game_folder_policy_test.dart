import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/power/domain/game_folder_policy.dart';

void main() {
  final directories = <String, String>{
    r'C:\Games\Hollow Knight': r'C:\Games\Hollow Knight',
    r'D:\SteamLibrary\steamapps\common\Elden Ring':
        r'D:\SteamLibrary\steamapps\common\Elden Ring',
    r'D:\SteamLibrary\steamapps\common': r'D:\SteamLibrary\steamapps\common',
    r'C:\Program Files (x86)\Steam': r'C:\Program Files (x86)\Steam',
    r'C:\Program Files': r'C:\Program Files',
    r'C:\Users': r'C:\Users',
    r'C:\Users\me\Documents': r'C:\Users\me\Documents',
    r'C:\Users\me\Documents\My Games\Mod':
        r'C:\Users\me\Documents\My Games\Mod',
    r'C:\Users\me\Downloads\game': r'C:\Users\me\Downloads\game',
    r'C:\Windows\System32': r'C:\Windows\System32',
    r'C:\Users\me\AppData\Local\Temp\x': r'C:\Users\me\AppData\Local\Temp\x',
    r'C:\Link': r'E:\Elsewhere',
    r'C:\Library': r'C:\Library',
    r'E:\EPIC GAMES': r'E:\EPIC GAMES',
  };
  final facts = GameFolderFacts(
    protectedFolders: const <String>[
      r'C:\Program Files',
      r'C:\Program Files (x86)',
      r'C:\Users\me',
      r'C:\Users\me\Documents',
      r'C:\Users\me\AppData\Local',
    ],
    forbiddenTrees: const <String>[
      r'C:\Windows',
      r'C:\Users\me\Downloads',
      r'C:\Users\me\AppData\Local\Temp',
    ],
    resolve: (path) {
      if (path == r'C:\file.txt') return (path: path, directory: false);
      final key = directories.keys.where(
        (key) => key.toLowerCase() == path.toLowerCase(),
      );
      return key.isEmpty
          ? null
          : (path: directories[key.first]!, directory: true);
    },
    separateGameFolders: (path) => path == r'C:\Library' ? 3 : 0,
  );

  GameFolderCheck check(String path) => checkGameFolder(path, facts);

  test('the folder of one game is allowed without warnings', () {
    final result = check(r'C:\Games\Hollow Knight\');
    expect(result.allowed, isTrue);
    expect(result.warning, isNull);
    expect(result.path, r'C:\Games\Hollow Knight');
    expect(
      check(r'D:\SteamLibrary\steamapps\common\Elden Ring').warning,
      isNull,
    );
    // Inside Documents is fine, only Documents itself is protected.
    expect(check(r'C:\Users\me\Documents\My Games\Mod').allowed, isTrue);
  });

  test('refuses everything that is not one local game folder', () {
    final cases = <String, GameFolderRefusal>{
      r'Games\Hollow Knight': GameFolderRefusal.notLocal,
      r'\\server\share\game': GameFolderRefusal.notLocal,
      r'\\?\C:\Games': GameFolderRefusal.notLocal,
      r'C:\': GameFolderRefusal.driveRoot,
      'D:': GameFolderRefusal.notLocal,
      r'C:\Missing': GameFolderRefusal.missing,
      r'C:\file.txt': GameFolderRefusal.notDirectory,
      r'C:\Link': GameFolderRefusal.link,
      r'C:\Program Files': GameFolderRefusal.protectedFolder,
      r'c:\program files': GameFolderRefusal.protectedFolder,
      r'C:\Users': GameFolderRefusal.protectedFolder,
      r'C:\Users\me\Documents': GameFolderRefusal.protectedFolder,
      r'C:\Users\me\Downloads\game': GameFolderRefusal.protectedFolder,
      r'C:\Windows\System32': GameFolderRefusal.protectedFolder,
      r'C:\Users\me\AppData\Local\Temp\x': GameFolderRefusal.protectedFolder,
    };
    for (final entry in cases.entries) {
      expect(check(entry.key).refusal, entry.value, reason: entry.key);
    }
  });

  test('warns, without refusing, for launchers and libraries', () {
    for (final path in <String>[
      r'C:\Program Files (x86)\Steam',
      r'D:\SteamLibrary\steamapps\common',
      r'E:\EPIC GAMES',
    ]) {
      final result = check(path);
      expect(result.allowed, isTrue, reason: path);
      expect(result.warning, GameFolderWarning.launcherLibrary, reason: path);
    }
    expect(check(r'C:\Library').warning, GameFolderWarning.severalGames);
  });
}
