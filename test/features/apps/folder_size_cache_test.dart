import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/folder_size_cache.dart';

void main() {
  late Directory root;
  setUp(() async => root = await Directory.systemTemp.createTemp('zt-size-'));
  tearDown(() => root.delete(recursive: true));

  test('sums files recursively and caches the result per path', () async {
    await File('${root.path}/a.bin').writeAsBytes(List.filled(1000, 1));
    await Directory('${root.path}/sub').create();
    await File('${root.path}/sub/b.bin').writeAsBytes(List.filled(24, 1));
    final cache = FolderSizeCache();

    expect(await cache.sizeOf(root.path), 1024);
    await File('${root.path}/c.bin').writeAsBytes(List.filled(5, 1));
    expect(await cache.sizeOf(root.path), 1024, reason: 'cached');
    expect(await cache.sizeOf('${root.path}\\'), 1024, reason: 'same folder');
  });

  test('missing, empty or relative paths are unknown, not 0', () async {
    final cache = FolderSizeCache();
    expect(await cache.sizeOf('${root.path}/missing'), isNull);
    expect(await cache.sizeOf(''), isNull);
    expect(await cache.sizeOf(r'relative\dir'), isNull);
    expect(await cache.sizeOf(root.path), isNull, reason: 'empty folder');
  });

  test('shared folders are never measured for one app', () {
    for (final path in [
      r'C:\',
      r'C:\Program Files (x86)\',
      r'C:\Program Files\Common Files\Vendor',
      r'C:\Windows\System32',
      r'C:\Users\Lorenzo',
    ]) {
      expect(isAppOwnedFolder(path), isFalse, reason: path);
    }
    expect(isAppOwnedFolder(r'D:\Games'), isFalse);
    expect(isAppOwnedFolder(r'D:\Call of Duty'), isTrue);
    expect(isAppOwnedFolder(r'C:\Program Files\Git\'), isTrue);
    expect(isAppOwnedFolder(r'C:\Users\Lorenzo\AppData\Local\Discord'), isTrue);
    expect(normalizeFolder('C:/Games/X/'), r'C:\Games\X');
  });

  test('does not follow links out of the folder', () async {
    final outside = await Directory.systemTemp.createTemp('zt-outside-');
    addTearDown(() => outside.delete(recursive: true));
    await File('${outside.path}/big.bin').writeAsBytes(List.filled(4096, 1));
    await File('${root.path}/own.bin').writeAsBytes(List.filled(10, 1));
    try {
      await Link('${root.path}/jump').create(outside.path);
    } on FileSystemException {
      markTestSkipped('creating links needs Developer Mode or elevation');
      return;
    }
    expect(await FolderSizeCache().sizeOf(root.path), 10);
  });
}
