import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/trace_cleanup_operation.dart';
import 'package:script_utility/platform/windows/cleanup_preview.dart';

OperationRequest _request(Iterable<CleanupCandidate> candidates) =>
    OperationRequest(
      operationId: 'cleanup.shader_cache',
      desiredValue: true,
      parameters: <String, Object?>{
        'preview': candidates.map((item) => item.toJson()).toList(),
      },
    );

Future<List<CleanupCandidate>> _scan(Directory directory) async {
  final preview = await const CleanupScanner().scanDirectory(
    directory,
    category: 'GPU shader cache',
    reason: 'test',
  );
  expect(preview.complete, isTrue, reason: preview.errors.join('\n'));
  return preview.candidates;
}

void main() {
  group(
    'shader cache cleanup in synthetic directories only',
    () {
      late Directory sandbox;
      late Directory amd;
      late Directory d3d;
      late Directory outside;
      late ShaderCacheCleanupOperation operation;

      setUp(() async {
        sandbox = await Directory.systemTemp.createTemp('zap-shader-test-');
        amd = await Directory(
          p.join(sandbox.path, 'AMD', 'DxcCache'),
        ).create(recursive: true);
        d3d = await Directory(
          p.join(sandbox.path, 'D3DSCache', 'abc'),
        ).create(recursive: true);
        outside = await Directory(p.join(sandbox.path, 'Documents')).create();
        await File(p.join(amd.path, 'cache.bin')).writeAsString('amd');
        await File(p.join(d3d.path, 'shader.idx')).writeAsString('d3d');
        await File(p.join(outside.path, 'keep.txt')).writeAsString('mine');
        operation = ShaderCacheCleanupOperation(
          directories: <Directory>[amd, Directory(p.dirname(d3d.path))],
        );
      });
      tearDown(() => sandbox.delete(recursive: true));

      test(
        'deletes exactly the previewed files across allowlisted roots',
        () async {
          final candidates = <CleanupCandidate>[
            ...await _scan(amd),
            ...await _scan(Directory(p.dirname(d3d.path))),
          ];
          expect(candidates, hasLength(2));
          final request = _request(candidates);
          final snapshot = await operation.captureSnapshot(request);
          await operation.applySnapshot(request, snapshot);

          expect(
            (await operation.verify(request)).kind,
            OperationStateKind.configured,
          );
          expect(File(p.join(amd.path, 'cache.bin')).existsSync(), isFalse);
          expect(File(p.join(d3d.path, 'shader.idx')).existsSync(), isFalse);
          expect(File(p.join(outside.path, 'keep.txt')).existsSync(), isTrue);
        },
      );

      test('a file outside the allowlisted roots is rejected', () async {
        final request = _request(await _scan(outside));
        final support = await operation.supports(
          const OperationContext(windowsBuild: 26100, edition: 'Pro'),
          request,
        );
        expect(support.supported, isFalse);
        await expectLater(operation.captureSnapshot(request), throwsStateError);
        expect(File(p.join(outside.path, 'keep.txt')).existsSync(), isTrue);
      });
    },
    skip: Platform.isWindows ? false : 'Windows file identities only',
  );

  test('default roots are GPU shader caches of the current user only', () {
    if (!Platform.isWindows) return;
    final roots = defaultShaderCacheDirectories().map((d) => d.path).toList();
    final local = Platform.environment['LOCALAPPDATA']!;
    final low = p.join(
      Platform.environment['USERPROFILE']!,
      'AppData',
      'LocalLow',
    );
    expect(roots, contains(p.join(local, 'D3DSCache')));
    for (final root in roots) {
      expect(
        p.isWithin(local, root) || p.isWithin(low, root),
        isTrue,
        reason: root,
      );
      expect(
        root,
        matches(RegExp(r'Cache$', caseSensitive: false)),
        reason: root,
      );
    }
  });
}
