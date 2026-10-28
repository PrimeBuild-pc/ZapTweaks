import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/trace_cleanup_operation.dart';
import 'package:script_utility/platform/windows/cleanup_preview.dart';

OperationRequest _request(String id, Iterable<CleanupCandidate> candidates) =>
    OperationRequest(
      operationId: id,
      desiredValue: true,
      parameters: <String, Object?>{
        'preview': candidates.map((item) => item.toJson()).toList(),
      },
    );

Future<List<CleanupCandidate>> _scan(Directory directory) async {
  final preview = await const CleanupScanner().scanDirectory(
    directory,
    category: 'test',
    reason: 'test',
  );
  expect(preview.complete, isTrue, reason: preview.errors.join('\n'));
  return preview.candidates;
}

void main() {
  test('Chromium profiles are Default, Guest and numbered profiles only', () {
    expect(isChromiumProfile('Default'), isTrue);
    expect(isChromiumProfile('Profile 3'), isTrue);
    expect(isChromiumProfile('Guest Profile'), isTrue);
    expect(isChromiumProfile('System Profile'), isFalse);
    expect(isChromiumProfile('Crashpad'), isFalse);
    expect(isChromiumProfile('Profile x'), isFalse);
  });

  test('running browsers are read from tasklist CSV, case-insensitively', () {
    const csv =
        '"System Idle Process","0","Services","0","8 K"\r\n'
        '"msedge.exe","1200","Console","1","120.000 K"\r\n'
        '"MSEDGE.EXE","1300","Console","1","80.000 K"\r\n'
        '"firefox.exe","1400","Console","1","300.000 K"\r\n'
        '"chromedriver.exe","1500","Console","1","10.000 K"\r\n'
        'INFO: garbage line\r\n';
    expect(parseRunningBrowsers(csv), <String>['Edge', 'Firefox']);
    expect(parseRunningBrowsers(''), isEmpty);
  });

  group(
    'crash report and browser cache cleanups in synthetic directories only',
    () {
      late Directory sandbox;
      late Directory dumps;
      late Directory cache;
      late Directory profile;

      setUp(() async {
        // Long form: %TEMP% can be an 8.3 path (RUNNER~1 on CI).
        sandbox = Directory(
          cleanupRootPath(
            await Directory.systemTemp.createTemp('zap-roots-test-'),
          ),
        );
        dumps = await Directory(
          p.join(sandbox.path, 'CrashDumps'),
        ).create(recursive: true);
        profile = await Directory(
          p.join(sandbox.path, 'Chrome', 'Default'),
        ).create(recursive: true);
        cache = await Directory(
          p.join(profile.path, 'Cache', 'Cache_Data'),
        ).create(recursive: true);
        await File(
          p.join(dumps.path, 'game.exe.123.dmp'),
        ).writeAsString('dump');
        await File(p.join(cache.path, 'data_1')).writeAsString('cache');
        await File(p.join(profile.path, 'Cookies')).writeAsString('keep');
      });
      tearDown(() => sandbox.delete(recursive: true));

      test(
        'deletes only the previewed files of each allowlisted root',
        () async {
          final crash = CrashReportCleanupOperation(directories: [dumps]);
          final browser = BrowserCacheCleanupOperation(directories: [cache]);
          for (final (operation, root) in [(crash, dumps), (browser, cache)]) {
            final request = _request(operation.id, await _scan(root));
            await operation.applySnapshot(
              request,
              await operation.captureSnapshot(request),
            );
            expect(
              (await operation.verify(request)).kind,
              OperationStateKind.configured,
            );
          }
          expect(Directory(dumps.path).listSync(), isEmpty);
          expect(Directory(cache.path).listSync(), isEmpty);
          expect(
            File(p.join(profile.path, 'Cookies')).existsSync(),
            isTrue,
            reason: 'cookies live outside the cache folder',
          );
        },
      );

      test('a preview from another root is refused', () async {
        final browser = BrowserCacheCleanupOperation(directories: [cache]);
        final request = _request(browser.id, await _scan(dumps));
        expect(
          (await browser.supports(
            const OperationContext(windowsBuild: 26100, edition: 'Pro'),
            request,
          )).supported,
          isFalse,
        );
        await expectLater(browser.captureSnapshot(request), throwsStateError);
        expect(Directory(dumps.path).listSync(), isNotEmpty);
      });

      test(
        'a root created after start-up is accepted after a re-read',
        () async {
          final roots = <Directory>[dumps];
          final browser = _Lazy(() => List.of(roots));
          expect(browser.rootFor((await _scan(dumps)).single).path, dumps.path);
          roots.add(cache);
          expect(browser.rootFor((await _scan(cache)).single).path, cache.path);
        },
      );
    },
    skip: Platform.isWindows ? false : 'Windows file identities only',
  );

  test('default crash and browser roots stay inside the user profile', () {
    if (!Platform.isWindows) return;
    final local = Platform.environment['LOCALAPPDATA']!;
    for (final root in [
      ...defaultCrashReportDirectories(),
      ...defaultBrowserCacheDirectories(),
    ]) {
      expect(p.isWithin(local, root.path), isTrue, reason: root.path);
    }
    for (final root in defaultBrowserCacheDirectories()) {
      expect(
        root.path,
        matches(RegExp(r'(Cache_Data|Code Cache|GPUCache|cache2)$')),
      );
    }
  });
}

class _Lazy extends FixedRootsCleanupOperation {
  _Lazy(super.roots);

  @override
  String get id => 'test.lazy';
}
