import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = File(
    'lib/platform/windows/tcp_optimizer_service.dart',
  ).readAsStringSync();
  final diagnostics = File(
    'lib/platform/windows/network_diagnostics_service.dart',
  ).readAsStringSync();

  test('QoS never deletes a parent branch or executes caller commands', () {
    expect(service, isNot(contains('Remove-Item')));
    expect(service, isNot(contains('gpupdate')));
    expect(service, isNot(contains('Invoke-Expression')));
    expect(service, isNot(contains(r'system(')));
    expect(service, contains('Remove-NetQosPolicy -Name'));
  });

  test('diagnostics contain no hard-coded test endpoint', () {
    expect(diagnostics, isNot(contains('https://')));
    expect(diagnostics.toLowerCase(), isNot(contains('speedtest')));
  });

  test('TCP Optimizer is a fourth searchable Gaming tab', () {
    final tabs = File(
      'lib/features/power/presentation/gaming_hub_page.dart',
    ).readAsStringSync();
    final search = File('lib/app/search_results_page.dart').readAsStringSync();
    final page = File(
      'lib/features/power/presentation/tcp_optimizer_page.dart',
    ).readAsStringSync();
    expect(tabs, contains('TcpOptimizerPage'));
    expect(tabs, contains('clamp(0, 3)'));
    expect(search, contains('strings.tcpOptimizer'));
    expect(search, contains("'Gaming & Performance',\n                3,"));
    expect(page, contains('WindowsRssService'));
    expect(page, contains("operationId: 'network.rss.configure'"));
  });

  test('no WINSPAR payload is bundled', () {
    final files = <String>[
      for (final root in <String>['assets', 'resources'])
        if (Directory(root).existsSync())
          ...Directory(root)
              .listSync(recursive: true)
              .whereType<File>()
              .map((file) => file.path.toLowerCase()),
    ];
    expect(
      files.where(
        (path) =>
            path.endsWith('tcp optimizer.exe') ||
            path.endsWith('speedtest.py') ||
            path.endsWith('testfile40mb'),
      ),
      isEmpty,
    );
  });
}
