import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

Directory defaultUserTempDirectory() {
  final local = Platform.environment['LOCALAPPDATA'];
  if (!Platform.isWindows || local == null || local.isEmpty) {
    throw UnsupportedError('UserTemp is unavailable: no Windows user profile.');
  }
  return Directory(p.join(local, 'Temp'));
}

const _invalidFileAttributes = 0xffffffff;

const recycleCleanupUnavailable =
    'Recycle Bin cleanup is unavailable: exact item identities cannot be '
    'previewed and deleted safely. No empty-all action is performed.';

class CleanupCandidate {
  const CleanupCandidate({
    required this.path,
    required this.category,
    required this.size,
    required this.reason,
    required this.identity,
    required this.rootCanonical,
    required this.rootIdentity,
  });

  final String path;
  final String category;
  final int size;
  final String reason;
  final String identity;
  final String rootCanonical;
  final String rootIdentity;

  Map<String, Object?> toJson() => <String, Object?>{
    'path': path,
    'size': size,
    'identity': identity,
    'rootCanonical': rootCanonical,
    'rootIdentity': rootIdentity,
  };

  factory CleanupCandidate.fromJson(Object? row) {
    if (row is! Map ||
        row.length != 5 ||
        row['path'] is! String ||
        row['size'] is! int ||
        (row['size'] as int) < 0 ||
        row['identity'] is! String ||
        row['rootCanonical'] is! String ||
        row['rootIdentity'] is! String ||
        (row['identity'] as String).isEmpty ||
        (row['rootIdentity'] as String).isEmpty) {
      throw StateError(
        'Invalid cleanup file identity. Review the preview again.',
      );
    }
    return CleanupCandidate(
      path: row['path'] as String,
      size: row['size'] as int,
      identity: row['identity'] as String,
      rootCanonical: row['rootCanonical'] as String,
      rootIdentity: row['rootIdentity'] as String,
      category: 'ZapTweaks traces',
      reason: 'User-requested diagnostic trace cleanup',
    );
  }
}

class CleanupPreview {
  CleanupPreview(
    Iterable<CleanupCandidate> candidates, {
    Iterable<String> errors = const <String>[],
  }) : candidates = List.unmodifiable(candidates),
       errors = List.unmodifiable(errors);

  final List<CleanupCandidate> candidates;
  final List<String> errors;
  bool get complete => errors.isEmpty;
  int get totalBytes => candidates.fold(0, (sum, item) => sum + item.size);
}

class CleanupScanner {
  const CleanupScanner();

  Future<CleanupPreview> scanDirectory(
    Directory directory, {
    required String category,
    required String reason,
  }) async {
    final candidates = <CleanupCandidate>[];
    final errors = <String>[];
    final root = p.normalize(directory.absolute.path);
    if (!Platform.isWindows) {
      return CleanupPreview(
        [],
        errors: ['Native Windows file identities are unavailable.'],
      );
    }
    // Resolve the lazy FFI binding before any fallible calls can set last-error.
    GetLastError();
    // Missing roots are empty; access failures must not masquerade as empty.
    final attributes = root.toNativeUtf16();
    try {
      if (GetFileAttributes(attributes) == _invalidFileAttributes) {
        final error = GetLastError();
        if (error == ERROR_FILE_NOT_FOUND || error == ERROR_PATH_NOT_FOUND) {
          return CleanupPreview([]);
        }
        throw FileSystemException(
          'Cannot inspect cleanup root (Win32 $error)',
          root,
        );
      }
    } finally {
      calloc.free(attributes);
    }
    _PinnedCleanupPath? pinnedRoot;
    try {
      pinnedRoot = _PinnedCleanupPath(root, directory: true);
      final rootIdentity = pinnedRoot.objectIdentity;
      final rootCanonical = pinnedRoot.canonical;
      Future<void> walk(String path) async {
        _PinnedCleanupPath? pinned;
        try {
          pinned = _PinnedCleanupPath(path, directory: true);
          await for (final entity in Directory(path).list(followLinks: false)) {
            if (entity is Link) continue;
            if (entity is Directory) {
              await walk(entity.path);
            } else if (entity is File) {
              _PinnedCleanupPath? file;
              try {
                file = _PinnedCleanupPath(entity.path, directory: false);
                candidates.add(
                  CleanupCandidate(
                    path: file.canonical,
                    category: category,
                    size: file.size,
                    reason: reason,
                    identity: file.identity,
                    rootCanonical: rootCanonical,
                    rootIdentity: rootIdentity,
                  ),
                );
              } on _CleanupReparsePoint {
                // Reparse points are intentionally outside the cleanup scope.
              } catch (error) {
                errors.add('${entity.path}: $error');
              } finally {
                file?.close();
              }
            }
          }
        } on _CleanupReparsePoint {
          // Never enter junctions, symlinks or other reparse directories.
        } catch (error) {
          errors.add('$path: $error');
        } finally {
          pinned?.close();
        }
      }

      await walk(root);
    } catch (error) {
      errors.add('$root: $error');
    } finally {
      pinnedRoot?.close();
    }
    candidates.sort((left, right) => left.path.compareTo(right.path));
    return CleanupPreview(candidates, errors: errors);
  }

  void validatePath(Directory directory, CleanupCandidate candidate) {
    final root = p.normalize(directory.absolute.path);
    final path = candidate.path;
    if (!p.isAbsolute(path) ||
        path != p.normalize(path) ||
        !p.isWithin(root, path) ||
        !p.equals(root, candidate.rootCanonical) ||
        path.contains('\u0000') ||
        path.substring(p.rootPrefix(path).length).contains(':')) {
      throw StateError(
        'Cleanup preview escapes its fixed canonical directory.',
      );
    }
  }

  bool isAbsent(Directory directory, CleanupCandidate candidate) {
    validatePath(directory, candidate);
    final root = _PinnedCleanupPath(directory.absolute.path, directory: true);
    _PinnedCleanupPath? parent;
    final name = candidate.path.toNativeUtf16();
    try {
      if (root.objectIdentity != candidate.rootIdentity ||
          !p.equals(root.canonical, candidate.rootCanonical)) {
        throw StateError('Cleanup root changed during verification.');
      }
      parent = _PinnedCleanupPath(p.dirname(candidate.path), directory: true);
      if (GetFileAttributes(name) != _invalidFileAttributes) return false;
      final error = GetLastError();
      if (error == ERROR_FILE_NOT_FOUND) return true;
      throw FileSystemException(
        'Cannot verify cleanup (Win32 $error)',
        candidate.path,
      );
    } finally {
      calloc.free(name);
      parent?.close();
      root.close();
    }
  }

  void checkCandidate(
    Directory directory,
    CleanupCandidate candidate, {
    bool delete = false,
  }) {
    validatePath(directory, candidate);
    final root = _PinnedCleanupPath(directory.absolute.path, directory: true);
    try {
      if (!p.equals(root.canonical, candidate.rootCanonical) ||
          root.objectIdentity != candidate.rootIdentity) {
        throw StateError('Cleanup root changed. Review the preview again.');
      }
      final file = _PinnedCleanupPath(
        candidate.path,
        directory: false,
        delete: delete,
      );
      try {
        if (!p.equals(file.canonical, candidate.path) ||
            file.identity != candidate.identity ||
            file.size != candidate.size) {
          throw StateError(
            'A previewed file changed before deletion: ${candidate.path}',
          );
        }
        if (delete) file.delete();
      } finally {
        file.close();
      }
    } finally {
      root.close();
    }
  }
}

class _CleanupReparsePoint implements Exception {
  @override
  String toString() =>
      'Cleanup excludes links, junctions and all reparse points.';
}

// Hold every ancestor against rename/reparse writes, and delete by the checked
// file handle rather than reopening its path after the identity check.
class _PinnedCleanupPath {
  _PinnedCleanupPath(
    String path, {
    required bool directory,
    bool delete = false,
  }) {
    if (!Platform.isWindows) {
      throw UnsupportedError('Native Windows file identities are unavailable.');
    }
    GetLastError();
    try {
      final absolute = p.normalize(p.absolute(path));
      final parents = <String>[];
      var parent = p.dirname(absolute);
      while (true) {
        parents.add(parent);
        final next = p.dirname(parent);
        if (next == parent) break;
        parent = next;
      }
      for (final parent in parents.reversed) {
        _open(parent, directory: true);
      }
      _open(absolute, directory: directory, delete: delete);
      final info = calloc<BY_HANDLE_FILE_INFORMATION>();
      final name = calloc<Uint16>(32768).cast<Utf16>();
      try {
        if (GetFileInformationByHandle(_handles.last, info) == 0) {
          _fail(absolute);
        }
        final value = info.ref;
        objectIdentity =
            '${value.dwVolumeSerialNumber}:${value.nFileIndexHigh}:'
            '${value.nFileIndexLow}:${value.ftCreationTime.dwHighDateTime}:'
            '${value.ftCreationTime.dwLowDateTime}';
        size = (value.nFileSizeHigh << 32) | value.nFileSizeLow;
        identity =
            '$objectIdentity:${value.ftLastWriteTime.dwHighDateTime}:'
            '${value.ftLastWriteTime.dwLowDateTime}:$size:'
            '${value.dwFileAttributes}:${value.nNumberOfLinks}';
        final length = GetFinalPathNameByHandle(_handles.last, name, 32768, 0);
        if (length == 0 || length >= 32768) _fail(absolute);
        var resolved = name.toDartString();
        if (resolved.startsWith(r'\\?\UNC\')) {
          resolved = r'\\' + resolved.substring(8);
        } else if (resolved.startsWith(r'\\?\')) {
          resolved = resolved.substring(4);
        }
        canonical = p.normalize(resolved);
        if (!p.equals(canonical, absolute)) {
          throw StateError('Non-canonical cleanup path: $absolute');
        }
      } finally {
        calloc.free(info);
        calloc.free(name);
      }
    } catch (_) {
      close();
      rethrow;
    }
  }

  final List<int> _handles = <int>[];
  late final String canonical;
  late final String objectIdentity;
  late final String identity;
  late final int size;

  Never _fail(String path) => throw FileSystemException(
    'Cleanup access failed (Win32 ${GetLastError()}); no permissions or locks are forced',
    path,
  );

  void _open(String path, {required bool directory, bool delete = false}) {
    final name = path.toNativeUtf16();
    final info = calloc<BY_HANDLE_FILE_INFORMATION>();
    try {
      final handle = CreateFile(
        name,
        FILE_READ_ATTRIBUTES |
            (directory ? FILE_LIST_DIRECTORY : GENERIC_READ) |
            (delete ? DELETE : 0),
        FILE_SHARE_READ,
        nullptr,
        OPEN_EXISTING,
        FILE_FLAG_OPEN_REPARSE_POINT | FILE_FLAG_BACKUP_SEMANTICS,
        0,
      );
      if (handle == INVALID_HANDLE_VALUE) _fail(path);
      _handles.add(handle);
      if (GetFileInformationByHandle(handle, info) == 0) _fail(path);
      if (info.ref.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT != 0) {
        throw _CleanupReparsePoint();
      }
      if ((info.ref.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY != 0) !=
          directory) {
        throw StateError('Cleanup object type changed: $path');
      }
    } finally {
      calloc.free(name);
      calloc.free(info);
    }
  }

  void delete() {
    final disposition = calloc<Uint8>()..value = 1;
    try {
      if (SetFileInformationByHandle(
            _handles.last,
            FileDispositionInfo,
            disposition.cast(),
            sizeOf<Uint8>(),
          ) ==
          0) {
        _fail(canonical);
      }
    } finally {
      calloc.free(disposition);
    }
  }

  void close() {
    for (final handle in _handles.reversed) {
      CloseHandle(handle);
    }
    _handles.clear();
  }
}
