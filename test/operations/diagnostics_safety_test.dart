import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/platform/windows/cleanup_preview.dart';
import 'package:script_utility/platform/windows/diagnostic_session.dart';

void main() {
  test('diagnostic sessions close after collection errors', () async {
    var started = false;
    var stopped = false;
    final session = DiagnosticSession(
      start: () async => started = true,
      stop: () async => stopped = true,
    );

    await expectLater(
      session.run<void>(() => throw StateError('failed')),
      throwsStateError,
    );

    expect(started, isTrue);
    expect(stopped, isTrue);
  });

  test('cleanup always produces an explicit preview first', () async {
    final directory = await Directory.systemTemp.createTemp('zap-cleanup-');
    addTearDown(() => directory.delete(recursive: true));
    await File('${directory.path}/cache.tmp').writeAsBytes(<int>[1, 2, 3]);

    final preview = await const CleanupScanner().scanDirectory(
      directory,
      category: 'Temporary files',
      reason: 'User cache',
    );

    expect(preview.candidates, hasLength(1));
    expect(preview.totalBytes, 3);
    expect(await File(preview.candidates.single.path).exists(), isTrue);
  });
}
