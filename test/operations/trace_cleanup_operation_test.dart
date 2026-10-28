import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/trace_cleanup_operation.dart';
import 'package:script_utility/platform/windows/cleanup_preview.dart';
import 'package:win32/win32.dart';

// GitHub runners are elevated too; `net session` succeeds only when elevated.
final _elevated =
    Platform.isWindows &&
    Process.runSync('net', <String>['session']).exitCode == 0;

OperationRequest _request(Iterable<CleanupCandidate> candidates) =>
    OperationRequest(
      operationId: 'diagnostics.trace.cleanup',
      desiredValue: true,
      parameters: <String, Object?>{
        'preview': candidates.map((item) => item.toJson()).toList(),
      },
    );

Future<CleanupPreview> _preview(Directory directory) =>
    const CleanupScanner().scanDirectory(
      directory,
      category: 'ZapTweaks traces',
      reason: 'User-requested diagnostic trace cleanup',
    );

class _RaceScanner extends CleanupScanner {
  _RaceScanner(this.beforeDelete);
  final void Function(CleanupCandidate) beforeDelete;

  @override
  void checkCandidate(
    Directory directory,
    CleanupCandidate candidate, {
    bool delete = false,
  }) {
    if (delete) beforeDelete(candidate);
    super.checkCandidate(directory, candidate, delete: delete);
  }
}

void main() {
  group(
    'native cleanup in synthetic directories only',
    () {
      late Directory sandbox;
      late Directory directory;
      late TraceCleanupOperation operation;
      late File trace;

      setUp(() async {
        // Long form: %TEMP% can be an 8.3 path (RUNNER~1 on CI).
        sandbox = Directory(
          cleanupRootPath(
            await Directory.systemTemp.createTemp('zap-cleanup-test-'),
          ),
        );
        directory = await Directory('${sandbox.path}/traces').create();
        trace = await File(
          '${directory.path}/trace.etl',
        ).writeAsString('before');
        operation = TraceCleanupOperation(directory: directory);
      });
      tearDown(() async {
        await sandbox.delete(recursive: true);
      });

      test(
        'snapshot round trip retains identities and deletes only approved files',
        () async {
          final report = await File(
            '${directory.path}/trace.etl.report.json',
          ).writeAsString('{}');
          final preview = await _preview(directory);
          expect(preview.complete, isTrue, reason: preview.errors.join('\n'));
          final request = _request(preview.candidates);
          // New files before support/inspect/capture must not widen the approval.
          final later = await File(
            '${directory.path}/new.etl',
          ).writeAsString('later');
          expect(
            (await operation.supports(
              const OperationContext(windowsBuild: 26100, edition: 'Pro'),
              request,
            )).supported,
            isTrue,
          );
          expect((await operation.inspect(request)).value, {
            'fileCount': 2,
            'totalBytes': 8,
          });
          final snapshot = OperationSnapshot.fromJson(
            (await operation.captureSnapshot(request)).toJson(),
          );
          expect(snapshot.data['candidates'], hasLength(2));
          await operation.applySnapshot(request, snapshot);
          final verified = await operation.verify(request);
          expect(
            verified.kind,
            OperationStateKind.configured,
            reason: verified.message,
          );
          expect(await trace.exists(), isFalse);
          expect(await report.exists(), isFalse);
          expect(await later.exists(), isTrue);
          expect(operation.rollbackCapability, RollbackCapability.none);
          expect(
            () => operation.rollback(request, snapshot),
            throwsUnsupportedError,
          );
          expect(() => operation.apply(request), throwsUnsupportedError);
        },
      );

      test(
        'empty approval never deletes files already present or newly created',
        () async {
          final request = _request([]);
          final snapshot = await operation.captureSnapshot(request);
          final later = await File(
            '${directory.path}/later.etl',
          ).writeAsString('later');
          await operation.applySnapshot(request, snapshot);
          expect(await trace.exists(), isTrue);
          expect(await later.exists(), isTrue);
        },
      );

      test(
        'missing roots are empty, while a non-directory root is an error',
        () async {
          final missing = await _preview(Directory('${sandbox.path}/missing'));
          expect(missing.complete, isTrue);
          expect(missing.candidates, isEmpty);
          final invalid = await _preview(Directory(trace.path));
          expect(invalid.complete, isFalse);
          expect(invalid.errors, isNotEmpty);
        },
      );

      test(
        'same-size content change is rejected before any deletion',
        () async {
          final request = _request((await _preview(directory)).candidates);
          final snapshot = await operation.captureSnapshot(request);
          await trace.writeAsString('edited');
          await trace.setLastModified(
            DateTime.now().add(const Duration(seconds: 2)),
          );
          await expectLater(
            operation.applySnapshot(request, snapshot),
            throwsStateError,
          );
          expect(await trace.exists(), isTrue);
        },
      );

      test(
        'same-size replacement with restored timestamp is a different identity',
        () async {
          final request = _request((await _preview(directory)).candidates);
          final snapshot = await operation.captureSnapshot(request);
          final modified = await trace.lastModified();
          await trace.rename('${sandbox.path}/old.etl');
          await trace.writeAsString('before');
          await trace.setLastModified(modified);
          await expectLater(
            operation.applySnapshot(request, snapshot),
            throwsStateError,
          );
          expect(await trace.readAsString(), 'before');
        },
      );

      test(
        'root replacement is rejected even if approved file metadata matches',
        () async {
          final request = _request((await _preview(directory)).candidates);
          final snapshot = await operation.captureSnapshot(request);
          await directory.rename('${sandbox.path}/old-root');
          await directory.create();
          await trace.writeAsString('before');
          await expectLater(
            operation.applySnapshot(request, snapshot),
            throwsStateError,
          );
          expect(await trace.exists(), isTrue);
        },
      );

      test('snapshot cannot widen or replace approved identities', () async {
        final request = _request((await _preview(directory)).candidates);
        final snapshot = await operation.captureSnapshot(request);
        await File('${directory.path}/new.etl').writeAsString('later');
        final tampered = OperationSnapshot(
          type: snapshot.type,
          data: {
            'candidates': (await _preview(
              directory,
            )).candidates.map((item) => item.toJson()).toList(),
          },
          expectedAfterRollback: snapshot.expectedAfterRollback,
        );
        await expectLater(
          operation.applySnapshot(request, tampered),
          throwsStateError,
        );
        expect(await trace.exists(), isTrue);
      });

      test(
        'duplicate, traversal, sibling root and legacy size-only previews fail closed',
        () async {
          final row = (await _preview(directory)).candidates.single.toJson();
          final invalidRows = <List<Map<String, Object?>>>[
            [row, row],
            [
              {...row, 'path': '${directory.path}\\..\\outside.etl'},
            ],
            [
              {...row, 'path': '${directory.path}-other\\outside.etl'},
            ],
            [
              {'path': trace.path, 'size': 6},
            ],
          ];
          for (final rows in invalidRows) {
            final request = OperationRequest(
              operationId: operation.id,
              desiredValue: true,
              parameters: {'preview': rows},
            );
            expect(
              (await operation.supports(
                const OperationContext(windowsBuild: 26100, edition: 'Pro'),
                request,
              )).supported,
              isFalse,
            );
          }
          expect(await trace.exists(), isTrue);
        },
      );

      test('junctions are excluded including a reparse root', () async {
        final outside = await Directory('${sandbox.path}/outside').create();
        final outsideFile = await File(
          '${outside.path}/keep.etl',
        ).writeAsString('keep');
        final junction = Directory('${directory.path}/junction');
        final result = await Process.run('cmd.exe', [
          '/c',
          'mklink',
          '/J',
          p.normalize(junction.path),
          p.normalize(outside.path),
        ]);
        expect(
          result.exitCode,
          0,
          reason: '${result.stdout}\n${result.stderr}',
        );
        try {
          final preview = await _preview(directory);
          expect(preview.complete, isTrue, reason: preview.errors.join('\n'));
          expect(preview.candidates.map((item) => item.path), [
            p.normalize(trace.path),
          ]);
          expect((await _preview(junction)).complete, isFalse);
          final request = _request(preview.candidates);
          await operation.applySnapshot(
            request,
            await operation.captureSnapshot(request),
          );
          expect(await outsideFile.readAsString(), 'keep');
        } finally {
          await junction.delete();
        }
      });

      test(
        'changed second file is checked again immediately before its deletion',
        () async {
          final second = await File(
            '${directory.path}/z-second.etl',
          ).writeAsString('before');
          final request = _request((await _preview(directory)).candidates);
          final snapshot = await operation.captureSnapshot(request);
          final racing = TraceCleanupOperation(
            directory: directory,
            scanner: _RaceScanner((item) {
              if (p.equals(item.path, second.path)) {
                second.renameSync('${sandbox.path}/old-second.etl');
                second.writeAsStringSync('before');
              }
            }),
          );
          await expectLater(
            racing.applySnapshot(request, snapshot),
            throwsStateError,
          );
          expect(await trace.exists(), isFalse);
          expect(await second.exists(), isTrue);
          expect((await racing.verify(request)).kind, OperationStateKind.error);
        },
      );

      test('locked file is an honest error, never force-unlocked', () async {
        final request = _request((await _preview(directory)).candidates);
        final snapshot = await operation.captureSnapshot(request);
        final name = trace.path.toNativeUtf16();
        final handle = CreateFile(
          name,
          GENERIC_READ,
          FILE_SHARE_READ,
          nullptr,
          OPEN_EXISTING,
          0,
          0,
        );
        calloc.free(name);
        expect(handle, isNot(INVALID_HANDLE_VALUE));
        try {
          await expectLater(
            operation.applySnapshot(request, snapshot),
            throwsA(isA<FileSystemException>()),
          );
          expect(await trace.exists(), isTrue);
        } finally {
          CloseHandle(handle);
        }
      });

      test(
        'unreadable preview reports incomplete rather than empty success',
        () async {
          final name = trace.path.toNativeUtf16();
          final handle = CreateFile(
            name,
            GENERIC_READ,
            0,
            nullptr,
            OPEN_EXISTING,
            0,
            0,
          );
          calloc.free(name);
          expect(handle, isNot(INVALID_HANDLE_VALUE));
          try {
            final preview = await _preview(directory);
            expect(preview.complete, isFalse);
            expect(preview.errors, isNotEmpty);
            expect(preview.candidates, isEmpty);
          } finally {
            CloseHandle(handle);
          }
        },
        skip: _elevated
            ? 'an elevated token opens a locked file with backup semantics'
            : false,
      );

      test(
        'read-only file remains intact and deletion fails without ACL changes',
        () async {
          final request = _request((await _preview(directory)).candidates);
          final snapshot = await operation.captureSnapshot(request);
          final name = trace.path.toNativeUtf16();
          final attributes = GetFileAttributes(name);
          expect(
            SetFileAttributes(name, attributes | FILE_ATTRIBUTE_READONLY),
            isNonZero,
          );
          try {
            await expectLater(
              operation.applySnapshot(request, snapshot),
              throwsA(anyOf(isA<StateError>(), isA<FileSystemException>())),
            );
            expect(await trace.exists(), isTrue);
            expect(
              GetFileAttributes(name) & FILE_ATTRIBUTE_READONLY,
              isNonZero,
            );
          } finally {
            SetFileAttributes(name, attributes);
            calloc.free(name);
          }
        },
      );

      test(
        'UserTemp preview stays separate and immutable; recycle is explicitly unavailable',
        () async {
          final userTemp = await Directory(
            '${sandbox.path}/user-temp',
          ).create();
          final tempFile = await File(
            '${userTemp.path}/temporary.tmp',
          ).writeAsString('temp');
          final preview = await const CleanupScanner().scanDirectory(
            userTemp,
            category: 'UserTemp',
            reason: 'Preview only',
          );
          expect(preview.candidates.single.category, 'UserTemp');
          expect(() => preview.candidates.clear(), throwsUnsupportedError);
          expect(
            (await _preview(directory)).candidates.single.path,
            p.normalize(trace.path),
          );
          await expectLater(
            operation.captureSnapshot(_request(preview.candidates)),
            throwsStateError,
          );
          expect(await tempFile.exists(), isTrue);
          expect(recycleCleanupUnavailable, contains('No empty-all'));
        },
      );
    },
    skip: !Platform.isWindows
        ? 'Native Windows handle identity/deletion requires Windows.'
        : false,
  );
}
