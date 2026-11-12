import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Windows "Select folder" dialog. Returns the chosen file-system folder, or
/// null when the user cancels. The Flutter window stays frozen while it is
/// open, like any modal system dialog.
String? pickFolder({String? title}) {
  final init = CoInitializeEx(
    nullptr,
    COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE,
  );
  final dialog = FileOpenDialog.createInstance();
  final options = calloc<Uint32>();
  final item = calloc<Pointer<COMObject>>();
  final name = calloc<Pointer<Utf16>>();
  final caption = title?.toNativeUtf16();
  try {
    if (FAILED(dialog.getOptions(options))) return null;
    dialog.setOptions(
      options.value |
          FOS_PICKFOLDERS |
          FOS_FORCEFILESYSTEM |
          FOS_PATHMUSTEXIST |
          FOS_NOCHANGEDIR,
    );
    if (caption != null) dialog.setTitle(caption);
    // Cancel returns HRESULT_FROM_WIN32(ERROR_CANCELLED).
    if (FAILED(dialog.show(GetForegroundWindow()))) return null;
    if (FAILED(dialog.getResult(item))) return null;
    final shellItem = IShellItem(item.value);
    try {
      if (FAILED(shellItem.getDisplayName(SIGDN_FILESYSPATH, name))) {
        return null;
      }
      final path = name.value.toDartString();
      CoTaskMemFree(name.value);
      return path;
    } finally {
      shellItem.release();
    }
  } finally {
    if (caption != null) calloc.free(caption);
    calloc.free(name);
    calloc.free(item);
    calloc.free(options);
    dialog.release();
    if (SUCCEEDED(init)) CoUninitialize();
  }
}
