import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Files the elevated helper writes in a directory the user controls (the request folder).
///
/// A same-user process could otherwise put a link where the helper writes and make it append to, or replace, any file
/// with administrator rights. So: the directory is pinned with an open handle that refuses renames and is never a
/// reparse point; each file is created with CREATE_NEW, which never opens an existing file or link; its real path is
/// checked against the pinned directory; and the handle stays open, undeletable, until [closeAll].
class HelperOutputFiles {
  HelperOutputFiles._();

  static int? _directory;
  static String? _directoryPath;
  static final Map<String, int> _files = <String, int>{};

  static void pin(Directory directory) {
    if (!Platform.isWindows) return;
    closeAll();
    final name = directory.absolute.path.toNativeUtf16();
    try {
      final handle = CreateFile(
        name,
        FILE_LIST_DIRECTORY | FILE_READ_ATTRIBUTES,
        FILE_SHARE_READ | FILE_SHARE_WRITE,
        nullptr,
        OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT,
        0,
      );
      if (handle == INVALID_HANDLE_VALUE) {
        throw FileSystemException(
          'Cannot pin the helper directory',
          directory.path,
        );
      }
      _directory = handle;
      final attributes = _attributes(handle);
      if (attributes & FILE_ATTRIBUTE_REPARSE_POINT != 0 ||
          attributes & FILE_ATTRIBUTE_DIRECTORY == 0) {
        closeAll();
        throw FileSystemException('Helper directory is a link', directory.path);
      }
      _directoryPath = _finalPath(handle).toLowerCase();
    } finally {
      calloc.free(name);
    }
  }

  static void append(String path, String text) =>
      _write(path, text, truncate: false);

  static void replace(String path, String text) =>
      _write(path, text, truncate: true);

  static void closeAll() {
    for (final handle in _files.values) {
      CloseHandle(handle);
    }
    _files.clear();
    if (_directory case final handle?) CloseHandle(handle);
    _directory = null;
    _directoryPath = null;
  }

  static void _write(String path, String text, {required bool truncate}) {
    if (!Platform.isWindows) {
      File(path).writeAsStringSync(
        text,
        mode: truncate ? FileMode.writeOnly : FileMode.append,
        flush: true,
      );
      return;
    }
    final handle = _files[path] ?? _create(path);
    if (truncate) {
      SetFilePointerEx(handle, 0, nullptr, FILE_BEGIN);
      SetEndOfFile(handle);
    }
    final bytes = utf8.encode(text);
    final buffer = calloc<Uint8>(bytes.length);
    final written = calloc<Uint32>();
    try {
      buffer.asTypedList(bytes.length).setAll(0, bytes);
      if (WriteFile(handle, buffer, bytes.length, written, nullptr) == 0 ||
          written.value != bytes.length) {
        throw FileSystemException('Helper output write failed', path);
      }
      FlushFileBuffers(handle);
    } finally {
      calloc.free(buffer);
      calloc.free(written);
    }
  }

  static int _create(String path) {
    final directory = _directoryPath;
    if (directory == null) {
      throw StateError('Helper output directory is not pinned.');
    }
    final name = path.toNativeUtf16();
    try {
      final handle = CreateFile(
        name,
        GENERIC_WRITE,
        FILE_SHARE_READ,
        nullptr,
        CREATE_NEW,
        FILE_ATTRIBUTE_NORMAL,
        0,
      );
      if (handle == INVALID_HANDLE_VALUE) {
        throw FileSystemException('Helper output name is already taken', path);
      }
      final resolved = _finalPath(handle).toLowerCase();
      final parent = resolved.substring(0, resolved.lastIndexOf(r'\'));
      if (parent != directory) {
        CloseHandle(handle);
        throw FileSystemException('Helper output escaped its directory', path);
      }
      _files[path] = handle;
      return handle;
    } finally {
      calloc.free(name);
    }
  }

  static int _attributes(int handle) {
    final info = calloc<BY_HANDLE_FILE_INFORMATION>();
    try {
      if (GetFileInformationByHandle(handle, info) == 0) return 0;
      return info.ref.dwFileAttributes;
    } finally {
      calloc.free(info);
    }
  }

  static String _finalPath(int handle) {
    final buffer = calloc<Uint16>(32768).cast<Utf16>();
    try {
      final length = GetFinalPathNameByHandle(handle, buffer, 32768, 0);
      if (length == 0 || length >= 32768) {
        throw const FileSystemException('Cannot resolve a helper output path');
      }
      return buffer.toDartString();
    } finally {
      calloc.free(buffer);
    }
  }
}
