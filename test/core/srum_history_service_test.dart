import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/srum_history_service.dart';

Map<String, Object?> _app(
  String name, {
  int sent = 0,
  int received = 0,
  int foreground = 0,
  int background = 0,
}) => <String, Object?>{
  'Name': name,
  'BytesSent': sent,
  'BytesReceived': received,
  'ForegroundCycles': foreground,
  'BackgroundCycles': background,
  'BytesRead': 0,
  'BytesWritten': 0,
};

Map<String, Object?> _history(
  List<Object?> apps, {
  String status = 'Running',
}) => <String, Object?>{
  'serviceStatus': status,
  'serviceStartType': 'Automatic',
  'databaseWrite': '2026-01-19T23:40:06.6290000Z',
  'firstRecord': '2025-12-21T10:00:00.0000000Z',
  'lastRecord': '2026-01-19T23:40:00.0000000Z',
  'apps': apps,
};

void main() {
  test('rows of the same program are merged and names shortened', () {
    final history = SrumHistory.fromJson(
      _history([
        _app(
          r'\Device\HarddiskVolume3\Program Files\Google\Chrome\Application\chrome.exe',
          sent: 10,
          foreground: 100,
        ),
        _app(
          r'\device\harddiskvolume3\program files\google\chrome\application\chrome.exe',
          received: 5,
          background: 50,
        ),
        _app(
          r'\Device\HarddiskVolume3\Windows\System32\svchost.exe [GraphicsPerfSvcGroup]',
          foreground: 7,
        ),
        _app('#1', sent: 1000),
        _app('#7', received: 1),
        _app('System', foreground: 3),
      ]),
    );
    final chrome = history.apps.singleWhere((app) => app.name == 'chrome.exe');
    expect(
      (chrome.bytesSent, chrome.bytesReceived, chrome.cycles),
      (10, 5, 150),
    );
    expect(
      history.apps.map((app) => app.name),
      containsAll(['svchost.exe [GraphicsPerfSvcGroup]', 'System']),
    );
    final unattributed = history.apps.singleWhere((app) => !app.attributed);
    expect(
      unattributed.networkBytes,
      1001,
      reason: 'every unnamed id is one row',
    );
    expect(history.totalCycles, 160);
    expect(history.collecting, isTrue);
    expect(history.lastRecord, DateTime.utc(2026, 1, 19, 23, 40));
  });

  test('a stopped service and an empty period are reported, not errors', () {
    final history = SrumHistory.fromJson(<String, Object?>{
      ..._history(const [], status: 'Stopped'),
      'firstRecord': '',
    });
    expect(history.collecting, isFalse);
    expect(history.apps, isEmpty);
    expect(history.firstRecord, isNull);
  });

  test('malformed helper output is rejected', () {
    for (final json in <Map<String, Object?>>[
      <String, Object?>{'apps': []},
      _history([
        <String, Object?>{'Name': 'x'},
      ]),
      _history([_app('x', sent: -1)]),
      <String, Object?>{..._history(const []), 'lastRecord': 5},
    ]) {
      expect(
        () => SrumHistory.fromJson(json),
        throwsFormatException,
        reason: '$json',
      );
    }
  });

  test('the script fits in a PowerShell -EncodedCommand argument', () {
    final encoded = base64Encode(
      WindowsSrumHistoryService.script.codeUnits
          .expand((unit) => <int>[unit & 0xff, unit >> 8])
          .toList(),
    );
    // Windows limits a command line to 32767 characters.
    expect(encoded.length, lessThan(30000));
    expect(WindowsSrumHistoryService.script, contains('/vss'));
    expect(
      WindowsSrumHistoryService.script,
      contains('Remove-Item -LiteralPath \$work'),
    );
  });
}
