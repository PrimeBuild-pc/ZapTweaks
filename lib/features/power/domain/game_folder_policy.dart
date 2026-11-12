import 'package:path/path.dart' as p;

/// Why a folder cannot become a Defender exclusion.
enum GameFolderRefusal {
  notLocal,
  missing,
  notDirectory,
  link,
  driveRoot,
  protectedFolder,
}

/// Allowed, but only after a strong warning and a second confirmation.
enum GameFolderWarning { launcherLibrary, severalGames }

/// What the policy needs to know about the file system. Injected so the
/// rules stay a pure function in tests.
class GameFolderFacts {
  const GameFolderFacts({
    required this.protectedFolders,
    required this.forbiddenTrees,
    required this.resolve,
    required this.separateGameFolders,
  });

  /// Folders that may not be excluded, nor any folder that contains them
  /// (Program Files, the user profile, Desktop, Documents, AppData…).
  final List<String> protectedFolders;

  /// Folders refused together with everything inside them (Windows, Temp,
  /// Downloads).
  final List<String> forbiddenTrees;

  /// Final path of an existing entry, following links; null when missing.
  final ({String path, bool directory})? Function(String path) resolve;

  /// Number of subfolders that look like separate games.
  final int Function(String path) separateGameFolders;
}

class GameFolderCheck {
  const GameFolderCheck(this.path, {this.refusal, this.warning});

  final String path;
  final GameFolderRefusal? refusal;
  final GameFolderWarning? warning;

  bool get allowed => refusal == null;
}

const _launcherFolders = <String>{
  'steam',
  'steamapps',
  'steamlibrary',
  'epic games',
  'epicgames',
  'ea games',
  'ea app',
  'origin games',
  'ubisoft',
  'ubisoft game launcher',
  'battle.net',
  'gog galaxy',
  'gog games',
  'riot games',
  'rockstar games',
  'xboxgames',
  'xbox games',
};

final _drivePath = RegExp(r'^[A-Za-z]:\\');
final _driveRoot = RegExp(r'^[A-Za-z]:\\?$');

/// Rules for the folder of one game excluded from Defender scanning.
GameFolderCheck checkGameFolder(String input, GameFolderFacts facts) {
  final raw = input.trim();
  if (raw.startsWith(r'\\') || !_drivePath.hasMatch(raw)) {
    return GameFolderCheck(raw, refusal: GameFolderRefusal.notLocal);
  }
  var path = p.windows.normalize(raw);
  if (_driveRoot.hasMatch(path)) {
    return GameFolderCheck(path, refusal: GameFolderRefusal.driveRoot);
  }
  if (path.endsWith(r'\')) path = path.substring(0, path.length - 1);
  final resolved = facts.resolve(path);
  if (resolved == null) {
    return GameFolderCheck(path, refusal: GameFolderRefusal.missing);
  }
  if (!resolved.directory) {
    return GameFolderCheck(path, refusal: GameFolderRefusal.notDirectory);
  }
  if (!p.windows.equals(resolved.path, path)) {
    return GameFolderCheck(path, refusal: GameFolderRefusal.link);
  }
  bool coversOrIs(String folder) =>
      p.windows.equals(folder, path) || p.windows.isWithin(path, folder);
  if (facts.forbiddenTrees.any(
        (tree) => coversOrIs(tree) || p.windows.isWithin(tree, path),
      ) ||
      facts.protectedFolders.any(coversOrIs)) {
    return GameFolderCheck(path, refusal: GameFolderRefusal.protectedFolder);
  }
  final name = p.windows.basename(path).toLowerCase();
  final parent = p.windows.basename(p.windows.dirname(path)).toLowerCase();
  if (_launcherFolders.contains(name) ||
      (name == 'common' && parent == 'steamapps')) {
    return GameFolderCheck(path, warning: GameFolderWarning.launcherLibrary);
  }
  if (facts.separateGameFolders(path) >= 2) {
    return GameFolderCheck(path, warning: GameFolderWarning.severalGames);
  }
  return GameFolderCheck(path);
}
