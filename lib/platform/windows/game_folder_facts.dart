import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

import '../../features/power/domain/game_folder_policy.dart';
import 'known_folder.dart';

/// [GameFolderFacts] read from this PC, for the account running the check.
GameFolderFacts windowsGameFolderFacts() {
  List<String> folders(Iterable<String?> paths) => <String>[
    for (final path in paths)
      if (path != null && path.isNotEmpty) resolveFinalPath(path)?.path ?? path,
  ];
  final programFiles = knownFolderPath(FOLDERID_ProgramFiles);
  final programFilesX86 = knownFolderPath(FOLDERID_ProgramFilesX86);
  final profile = knownFolderPath(FOLDERID_Profile);
  return GameFolderFacts(
    protectedFolders: folders(<String?>[programFiles, programFilesX86]),
    // User-writable places (profiles, AppData, Startup, ProgramData) and the
    // security software's own folders are never excluded, not even below.
    forbiddenTrees: folders(<String?>[
      knownFolderPath(FOLDERID_Windows),
      knownFolderPath(FOLDERID_ProgramData),
      if (profile != null) p.windows.dirname(profile),
      // Shell folders can be redirected outside the profile.
      knownFolderPath(FOLDERID_Desktop),
      knownFolderPath(FOLDERID_Documents),
      knownFolderPath(FOLDERID_Downloads),
      knownFolderPath(FOLDERID_RoamingAppData),
      knownFolderPath(FOLDERID_LocalAppData),
      knownFolderPath(FOLDERID_Public),
      Directory.systemTemp.path,
      for (final root in <String?>[programFiles, programFilesX86])
        if (root != null)
          for (final name in const <String>[
            'Windows Defender',
            'Windows Defender Advanced Threat Protection',
            'WindowsApps',
            'Common Files',
          ])
            p.windows.join(root, name),
    ]),
    resolve: resolveFinalPath,
    separateGameFolders: countSeparateGameFolders,
  );
}

/// Final path of [path] with links and junctions followed, or null.
({String path, bool directory})? resolveFinalPath(String path) {
  final name = path.toNativeUtf16();
  final info = calloc<BY_HANDLE_FILE_INFORMATION>();
  final buffer = calloc<Uint16>(32768).cast<Utf16>();
  final handle = CreateFile(
    name,
    FILE_READ_ATTRIBUTES,
    FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
    nullptr,
    OPEN_EXISTING,
    FILE_FLAG_BACKUP_SEMANTICS,
    0,
  );
  try {
    if (handle == INVALID_HANDLE_VALUE) return null;
    if (GetFileInformationByHandle(handle, info) == 0) return null;
    final length = GetFinalPathNameByHandle(handle, buffer, 32768, 0);
    if (length == 0 || length >= 32768) return null;
    var result = buffer.toDartString();
    if (result.startsWith(r'\\?\UNC\')) {
      result = r'\\' + result.substring(8);
    } else if (result.startsWith(r'\\?\')) {
      result = result.substring(4);
    }
    return (
      path: result,
      directory: info.ref.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY != 0,
    );
  } finally {
    if (handle != INVALID_HANDLE_VALUE) CloseHandle(handle);
    calloc.free(buffer);
    calloc.free(info);
    calloc.free(name);
  }
}

/// Subfolders that hold an .exe within three levels, when [path] itself has
/// none: a library of games rather than one game.
///
/// shortcut: stops after 4000 entries, so a huge library may be undercounted;
/// the launcher-name check covers the common libraries.
int countSeparateGameFolders(String path) {
  var budget = 4000;
  bool hasExe(Directory directory, int depth) {
    try {
      for (final entry in directory.listSync(followLinks: false)) {
        if (--budget < 0) return false;
        if (entry is File && p.extension(entry.path).toLowerCase() == '.exe') {
          return true;
        }
        if (depth > 0 && entry is Directory && hasExe(entry, depth - 1)) {
          return true;
        }
      }
    } on FileSystemException {
      /* An unreadable folder counts as having no game. */
    }
    return false;
  }

  final root = Directory(path);
  if (hasExe(root, 0)) return 0;
  var count = 0;
  try {
    for (final entry in root.listSync(followLinks: false)) {
      if (entry is Directory && hasExe(entry, 2)) count++;
      if (count >= 2 || budget < 0) break;
    }
  } on FileSystemException {
    return 0;
  }
  return count;
}
