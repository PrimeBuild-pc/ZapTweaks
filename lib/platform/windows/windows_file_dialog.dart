import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsFileDialog {
  const WindowsFileDialog();

  String? openPowerPlan() => _show(save: false);
  String? savePowerPlan() => _show(save: true);

  String? _show({required bool save}) => using((arena) {
    final file = arena<Uint16>(32768).cast<Utf16>();
    final dialog = arena<OPENFILENAME>();
    final filter = 'Power plans (*.pow)\u0000*.pow\u0000\u0000'.toNativeUtf16(
      allocator: arena,
    );
    final extension = 'pow'.toNativeUtf16(allocator: arena);
    dialog.ref
      ..lStructSize = sizeOf<OPENFILENAME>()
      ..hwndOwner = GetActiveWindow()
      ..hInstance = 0
      ..lpstrFilter = filter
      ..lpstrCustomFilter = nullptr
      ..nMaxCustFilter = 0
      ..nFilterIndex = 1
      ..lpstrFile = file
      ..nMaxFile = 32768
      ..lpstrFileTitle = nullptr
      ..nMaxFileTitle = 0
      ..lpstrInitialDir = nullptr
      ..lpstrTitle = nullptr
      ..Flags =
          OFN_NOCHANGEDIR |
          OFN_PATHMUSTEXIST |
          (save ? OFN_OVERWRITEPROMPT : OFN_FILEMUSTEXIST)
      ..nFileOffset = 0
      ..nFileExtension = 0
      ..lpstrDefExt = extension
      ..lCustData = 0
      ..lpfnHook = nullptr
      ..lpTemplateName = nullptr
      ..pvReserved = nullptr
      ..dwReserved = 0
      ..FlagsEx = 0;
    final accepted = save ? GetSaveFileName(dialog) : GetOpenFileName(dialog);
    return accepted == TRUE ? file.toDartString() : null;
  });
}
