import 'dart:io';
import 'dart:isolate';

/// Size of an install folder, computed off the UI thread and kept until the
/// next refresh. Links are not followed (the folder itself included), so a
/// junction cannot pull in another folder. Unknown (missing, unreadable,
/// empty, a link) stays null, never 0.
class FolderSizeCache {
  final Map<String, Future<int?>> _sizes = <String, Future<int?>>{};

  Future<int?> sizeOf(String path) {
    final key = normalizeFolder(path);
    if (key.isEmpty || !File(key).isAbsolute) return Future.value(null);
    return _sizes[key.toLowerCase()] ??= Isolate.run(() => _measure(key));
  }

  static Future<int?> _measure(String path) async {
    if (FileSystemEntity.isLinkSync(path)) return null;
    final directory = Directory(path);
    if (!directory.existsSync()) return null;
    var total = 0;
    try {
      // Streamed, so a game folder with a million files never sits in memory.
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) total += entity.lengthSync();
      }
    } on FileSystemException {
      // shortcut: a folder with one unreadable child reads as unknown; a
      // partial total would look exact. Upgrade to a per-child walk if needed.
      return null;
    }
    return total > 0 ? total : null;
  }
}

/// `C:/Foo/` and `C:\Foo` are the same folder.
String normalizeFolder(String path) =>
    path.trim().replaceAll('/', r'\').replaceFirst(RegExp(r'\\+$'), '');

/// False for folders shared by many programs: a drive root, the first level
/// under it (Program Files, ProgramData, Users…), Common Files and Windows.
/// Measuring them would credit one app with everything installed there.
bool isAppOwnedFolder(String path) {
  final parts = normalizeFolder(
    path,
  ).toLowerCase().split(r'\').where((part) => part.isNotEmpty).toList();
  if (parts.length < 2 || parts.contains('common files')) return false;
  const shared = <String>{
    'program files',
    'program files (x86)',
    'program files (arm)',
    'programdata',
    'users',
    'windows',
    'games',
    'steamlibrary',
  };
  if (parts[1] == 'windows') return false;
  if (parts[1] == 'users') return parts.length >= 4;
  // `D:\Call of Duty` is the game's own folder; `D:\Games` is not.
  return parts.length >= 3 || !shared.contains(parts[1]);
}
