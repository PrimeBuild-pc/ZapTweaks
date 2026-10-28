import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/cleanup_preview.dart';
import 'package:win32/win32.dart';

String _shortPath(String path) {
  final input = path.toNativeUtf16();
  final buffer = calloc<Uint16>(32768).cast<Utf16>();
  try {
    final length = GetShortPathName(input, buffer, 32768);
    return length == 0 ? path : buffer.toDartString();
  } finally {
    calloc.free(input);
    calloc.free(buffer);
  }
}

void main() {
  // %TEMP% is often an 8.3 path (C:\Users\RUNNER~1 on CI, long user names).
  test('a root given by its 8.3 short name is scanned', () async {
    final dir = await Directory.systemTemp.createTemp('zaptweaks long name ');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}${Platform.pathSeparator}a.etl').writeAsString('x');
    final short = _shortPath(dir.path);
    if (short == dir.path) {
      markTestSkipped('8.3 names are disabled on this volume');
      return;
    }
    final preview = await const CleanupScanner().scanDirectory(
      Directory(short),
      category: 'test',
      reason: 'test',
    );
    expect(preview.errors, isEmpty);
    expect(preview.candidates, hasLength(1));
  }, skip: !Platform.isWindows);
}
