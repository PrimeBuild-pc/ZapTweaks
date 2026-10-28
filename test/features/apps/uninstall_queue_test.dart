import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/uninstall_queue.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';

AppPackage _app(
  String name,
  String? uninstall, {
  String? quiet,
  String hive = 'HKLM',
}) => AppPackage(
  provider: AppProvider.win32,
  packageId: '$hive\\64\\$name',
  name: name,
  version: null,
  publisher: null,
  scopes: const {AppInstallScope.allUsers},
  source: 'Windows',
  reinstallable: false,
  uninstall: UninstallEntry(
    hive: hive,
    view: '64',
    key: name,
    uninstallString: uninstall,
    quietUninstallString: quiet,
  ),
);

UninstallQueue _queue(List<AppPackage> apps) => UninstallQueue.build(
  apps,
  environment: const {'SystemRoot': r'C:\Windows'},
  fileExists: (_) => true,
);

void main() {
  final silent = _app('Silent', r'"C:\P\S\unins000.exe"');
  final windowed = _app('Windowed', r'"C:\P\W\setup.exe" /remove');
  final manual = _app('Manual', 'cmd /c del x');

  test(
    'windowed first, then silent; manual ones are skipped with a reason',
    () {
      final queue = _queue([silent, manual, windowed]);

      expect(queue.items.map((i) => i.app.name), [
        'Windowed',
        'Silent',
        'Manual',
      ]);
      expect(queue.items.map((i) => i.status), [
        QueueStatus.waiting,
        QueueStatus.waiting,
        QueueStatus.skipped,
      ]);
      expect(queue.items.last.manualCommandLine, 'cmd /c del x');
    },
  );

  test('runs one at a time and records each outcome', () async {
    final queue = _queue([silent, windowed]);
    final order = <String>[];
    var running = 0;

    await queue.run((item) async {
      expect(++running, 1, reason: 'never two at once');
      order.add(item.app.name);
      await Future<void>.delayed(Duration.zero);
      running--;
      return item.app.name == 'Silent' ? 'exit 1603' : null;
    });

    expect(order, ['Windowed', 'Silent']);
    expect(queue.items.map((i) => i.status), [
      QueueStatus.done,
      QueueStatus.failed,
    ]);
    expect(queue.items.last.message, 'exit 1603');
  });

  test('a waiting item can be skipped and the queue stopped', () async {
    final third = _app('Third', r'"C:\P\T\unins001.exe"');
    final queue = _queue([silent, windowed, third]);
    final started = Completer<void>();
    final release = Completer<String?>();

    final run = queue.run((item) {
      if (!started.isCompleted) started.complete();
      return release.future;
    });
    await started.future;
    queue.skip(queue.items.indexWhere((i) => i.app.name == 'Third'));
    queue.stop();
    release.complete(null);
    await run;

    expect(
      {for (final i in queue.items) i.app.name: i.status},
      {
        'Windowed': QueueStatus.done,
        'Silent': QueueStatus.skipped,
        'Third': QueueStatus.skipped,
      },
    );
  });

  test('an exception counts as a failure, not a crash', () async {
    final queue = _queue([silent]);
    await queue.run((_) async => throw StateError('helper died'));
    expect(queue.items.single.status, QueueStatus.failed);
    expect(queue.items.single.message, contains('helper died'));
  });

  test('requests use the elevated op for HKLM and the user op for HKCU', () {
    final queue = _queue([
      silent,
      _app('Mine', r'"C:\U\unins000.exe"', hive: 'HKCU'),
    ]);
    expect(queue.items.map((i) => i.request.operationId).toSet(), {
      'app.win32.uninstall',
      'app.win32.uninstall_user',
    });
    expect(queue.items.first.request.parameters['silent'], isTrue);
  });
}
