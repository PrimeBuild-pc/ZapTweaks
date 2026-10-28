import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Real path of a Windows known folder (`FOLDERID_*`), following moves such
/// as Documents redirected to OneDrive; null when Windows has none.
String? knownFolderPath(String id) {
  final guid = GUIDFromString(id);
  final path = calloc<Pointer<Utf16>>();
  try {
    if (FAILED(SHGetKnownFolderPath(guid, KF_FLAG_DEFAULT, NULL, path))) {
      return null;
    }
    return path.value.toDartString();
  } finally {
    CoTaskMemFree(path.value);
    calloc.free(path);
    calloc.free(guid);
  }
}
