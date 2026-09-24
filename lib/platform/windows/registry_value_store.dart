import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

enum RegistryView { registry64, registry32 }

class RawRegistryValue {
  const RawRegistryValue({required this.type, required this.bytes});

  final int type;
  final Uint8List bytes;
}

abstract class RegistryValueStore {
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  });

  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  });

  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  });
}

class WindowsRegistryValueStore implements RegistryValueStore {
  const WindowsRegistryValueStore();

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {
    _requireWindows();
    final keyPath = _split(path);
    final subKey = keyPath.subKey.toNativeUtf16();
    final valueName = name.toNativeUtf16();
    final handle = calloc<IntPtr>();
    try {
      final opened = RegOpenKeyEx(
        keyPath.root,
        subKey,
        0,
        KEY_QUERY_VALUE | _viewFlag(view),
        handle,
      );
      if (opened == ERROR_FILE_NOT_FOUND) return null;
      _check(opened, 'open $path');
      try {
        final type = calloc<Uint32>();
        final size = calloc<Uint32>();
        try {
          var result = RegQueryValueEx(
            handle.value,
            valueName,
            nullptr,
            type,
            nullptr,
            size,
          );
          if (result == ERROR_FILE_NOT_FOUND) return null;
          _check(result, 'query $path/$name');
          final data = calloc<Uint8>(size.value == 0 ? 1 : size.value);
          try {
            result = RegQueryValueEx(
              handle.value,
              valueName,
              nullptr,
              type,
              data,
              size,
            );
            _check(result, 'read $path/$name');
            return RawRegistryValue(
              type: type.value,
              bytes: Uint8List.fromList(data.asTypedList(size.value)),
            );
          } finally {
            calloc.free(data);
          }
        } finally {
          calloc.free(type);
          calloc.free(size);
        }
      } finally {
        RegCloseKey(handle.value);
      }
    } finally {
      calloc.free(subKey);
      calloc.free(valueName);
      calloc.free(handle);
    }
  }

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) async {
    _requireWindows();
    final keyPath = _split(path);
    final subKey = keyPath.subKey.toNativeUtf16();
    final valueName = name.toNativeUtf16();
    final handle = calloc<IntPtr>();
    final disposition = calloc<Uint32>();
    try {
      _check(
        RegCreateKeyEx(
          keyPath.root,
          subKey,
          0,
          nullptr,
          REG_OPTION_NON_VOLATILE,
          KEY_SET_VALUE | _viewFlag(view),
          nullptr,
          handle,
          disposition,
        ),
        'create $path',
      );
      try {
        final data = calloc<Uint8>(
          value.bytes.isEmpty ? 1 : value.bytes.length,
        );
        try {
          data.asTypedList(value.bytes.length).setAll(0, value.bytes);
          _check(
            RegSetValueEx(
              handle.value,
              valueName,
              0,
              value.type,
              data,
              value.bytes.length,
            ),
            'write $path/$name',
          );
        } finally {
          calloc.free(data);
        }
      } finally {
        RegCloseKey(handle.value);
      }
    } finally {
      calloc.free(subKey);
      calloc.free(valueName);
      calloc.free(handle);
      calloc.free(disposition);
    }
  }

  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {
    _requireWindows();
    final keyPath = _split(path);
    final subKey = keyPath.subKey.toNativeUtf16();
    final valueName = name.toNativeUtf16();
    final handle = calloc<IntPtr>();
    try {
      final opened = RegOpenKeyEx(
        keyPath.root,
        subKey,
        0,
        KEY_SET_VALUE | _viewFlag(view),
        handle,
      );
      if (opened == ERROR_FILE_NOT_FOUND) return;
      _check(opened, 'open $path');
      try {
        final deleted = RegDeleteValue(handle.value, valueName);
        if (deleted != ERROR_FILE_NOT_FOUND) {
          _check(deleted, 'delete $path/$name');
        }
      } finally {
        RegCloseKey(handle.value);
      }
    } finally {
      calloc.free(subKey);
      calloc.free(valueName);
      calloc.free(handle);
    }
  }

  static void _requireWindows() {
    if (!Platform.isWindows) throw UnsupportedError('Windows is required.');
  }

  static int _viewFlag(RegistryView view) =>
      view == RegistryView.registry64 ? KEY_WOW64_64KEY : KEY_WOW64_32KEY;

  static ({int root, String subKey}) _split(String path) {
    final separator = path.indexOf(r'\');
    if (separator < 1 || separator == path.length - 1) {
      throw ArgumentError.value(path, 'path', 'Invalid Registry path.');
    }
    final root = switch (path.substring(0, separator).toUpperCase()) {
      'HKCU' || 'HKEY_CURRENT_USER' => HKEY_CURRENT_USER,
      'HKLM' || 'HKEY_LOCAL_MACHINE' => HKEY_LOCAL_MACHINE,
      _ => throw ArgumentError.value(
        path,
        'path',
        'Unsupported Registry root.',
      ),
    };
    return (root: root, subKey: path.substring(separator + 1));
  }

  static void _check(int result, String operation) {
    if (result != ERROR_SUCCESS) {
      throw WindowsException(HRESULT_FROM_WIN32(result), message: operation);
    }
  }
}
