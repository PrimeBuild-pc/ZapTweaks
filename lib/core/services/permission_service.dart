import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class PermissionService {
  const PermissionService();

  Future<bool> isRunningElevated() async {
    final token = calloc<IntPtr>();
    final elevation = calloc<Uint32>();
    final returnedLength = calloc<Uint32>();
    try {
      if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, token) == 0) {
        return false;
      }
      return GetTokenInformation(
                token.value,
                TokenElevation,
                elevation.cast(),
                sizeOf<Uint32>(),
                returnedLength,
              ) !=
              0 &&
          elevation.value != 0;
    } finally {
      if (token.value != 0) CloseHandle(token.value);
      calloc.free(token);
      calloc.free(elevation);
      calloc.free(returnedLength);
    }
  }
}
