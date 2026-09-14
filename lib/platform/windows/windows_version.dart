import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

typedef _RtlGetVersionNative = Int32 Function(Pointer<OSVERSIONINFO>);
typedef _RtlGetVersionDart = int Function(Pointer<OSVERSIONINFO>);

int windowsBuildNumber() {
  final version = calloc<OSVERSIONINFO>();
  try {
    version.ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFO>();
    final rtlGetVersion = DynamicLibrary.open(
      'ntdll.dll',
    ).lookupFunction<_RtlGetVersionNative, _RtlGetVersionDart>('RtlGetVersion');
    if (rtlGetVersion(version) != 0) return 0;
    return version.ref.dwBuildNumber;
  } finally {
    calloc.free(version);
  }
}
