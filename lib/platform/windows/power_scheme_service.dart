import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class PowerSchemeInfo {
  const PowerSchemeInfo({
    required this.id,
    required this.name,
    required this.active,
  });

  final String id;
  final String name;
  final bool active;
}

typedef _PowerGetActiveSchemeNative =
    Uint32 Function(IntPtr, Pointer<Pointer<GUID>>);
typedef _PowerGetActiveSchemeDart = int Function(int, Pointer<Pointer<GUID>>);
typedef _PowerEnumerateNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Uint32,
      Uint32,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerEnumerateDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      int,
      int,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadFriendlyNameNative =
    Uint32 Function(
      IntPtr,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );
typedef _PowerReadFriendlyNameDart =
    int Function(
      int,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<GUID>,
      Pointer<Uint8>,
      Pointer<Uint32>,
    );

class WindowsPowerSchemeService {
  WindowsPowerSchemeService({DynamicLibrary? library})
    : _library = library ?? DynamicLibrary.open('powrprof.dll') {
    _getActiveScheme = _library
        .lookupFunction<_PowerGetActiveSchemeNative, _PowerGetActiveSchemeDart>(
          'PowerGetActiveScheme',
        );
    _enumerate = _library
        .lookupFunction<_PowerEnumerateNative, _PowerEnumerateDart>(
          'PowerEnumerate',
        );
    _readFriendlyName = _library
        .lookupFunction<
          _PowerReadFriendlyNameNative,
          _PowerReadFriendlyNameDart
        >('PowerReadFriendlyName');
  }

  static const int _accessScheme = 16;
  final DynamicLibrary _library;
  late final _PowerGetActiveSchemeDart _getActiveScheme;
  late final _PowerEnumerateDart _enumerate;
  late final _PowerReadFriendlyNameDart _readFriendlyName;

  List<PowerSchemeInfo> enumerate() {
    final active = _activeSchemeId();
    final schemes = <PowerSchemeInfo>[];
    for (var index = 0; ; index++) {
      final guid = calloc<GUID>();
      final size = calloc<Uint32>()..value = sizeOf<GUID>();
      try {
        final result = _enumerate(
          0,
          nullptr,
          nullptr,
          _accessScheme,
          index,
          guid.cast<Uint8>(),
          size,
        );
        if (result == ERROR_NO_MORE_ITEMS) break;
        _check(result, 'PowerEnumerate');
        final id = guid.ref.toString().toLowerCase();
        schemes.add(
          PowerSchemeInfo(
            id: id,
            name: _friendlyName(guid),
            active: id == active,
          ),
        );
      } finally {
        calloc.free(guid);
        calloc.free(size);
      }
    }
    return schemes;
  }

  String _activeSchemeId() {
    final pointer = calloc<Pointer<GUID>>();
    try {
      _check(_getActiveScheme(0, pointer), 'PowerGetActiveScheme');
      try {
        return pointer.value.ref.toString().toLowerCase();
      } finally {
        LocalFree(pointer.value.cast());
      }
    } finally {
      calloc.free(pointer);
    }
  }

  String _friendlyName(Pointer<GUID> scheme) {
    final size = calloc<Uint32>();
    try {
      final first = _readFriendlyName(
        0,
        scheme,
        nullptr,
        nullptr,
        nullptr,
        size,
      );
      if (first != ERROR_MORE_DATA) _check(first, 'PowerReadFriendlyName size');
      final buffer = calloc<Uint8>(size.value);
      try {
        _check(
          _readFriendlyName(0, scheme, nullptr, nullptr, buffer, size),
          'PowerReadFriendlyName',
        );
        return buffer.cast<Utf16>().toDartString();
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(size);
    }
  }

  static void _check(int result, String operation) {
    if (result != ERROR_SUCCESS) {
      throw WindowsException(HRESULT_FROM_WIN32(result), message: operation);
    }
  }
}
