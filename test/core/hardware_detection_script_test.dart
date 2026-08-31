import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/hardware_detection_service.dart';

/// Windows caps a process command line at 32767 characters. The detection
/// script is handed to PowerShell as a base64 -EncodedCommand, so an oversized
/// script makes CreateProcess fail instantly and every device reads as "not
/// detected" with no error anywhere obvious. This test is the early warning.
const int _windowsCommandLineLimit = 32767;
const int _safeBudget = 28000;

int _encodedLength(String script) {
  // ProcessRunner encodes UTF-16LE, then base64.
  final bytes = script.codeUnits.length * 2;
  return base64Encode(List<int>.filled(bytes, 0)).length;
}

String _readDetectionScript() {
  final source = File(
    'lib/core/services/hardware_detection_service.dart',
  ).readAsStringSync();
  const opener = "static const String _detectionScript = r'''";
  final start = source.indexOf(opener) + opener.length;
  final end = source.indexOf("''';", start);
  expect(start, greaterThan(opener.length - 1));
  expect(end, greaterThan(start));
  return source.substring(start, end);
}

void main() {
  test('detection script fits well inside the command-line limit', () {
    final encoded = _encodedLength(_readDetectionScript());

    expect(
      encoded,
      lessThan(_windowsCommandLineLimit),
      reason:
          'the script would fail to launch at all; move payload into Dart '
          'rather than growing the PowerShell',
    );
    expect(
      encoded,
      lessThan(_safeBudget),
      reason:
          'less than 15% headroom left against the $_windowsCommandLineLimit '
          'character limit; move payload into Dart before adding more',
    );
  });

  test('detection script carries no comments', () {
    // Comments inside the script are shipped over the command line.
    final commentLines = _readDetectionScript()
        .split('\n')
        .where((line) => line.trimLeft().startsWith('#'))
        .toList();

    expect(
      commentLines,
      isEmpty,
      reason: 'explain the script in Dart comments, not in the payload',
    );
  });

  group('formatInputDevice', () {
    test('prefixes a known vendor', () {
      expect(
        HardwareDetectionService.formatInputDevice('G Pro Wireless|046D|C088'),
        'Logitech G Pro Wireless',
      );
    });

    test('does not repeat a vendor already in the name', () {
      expect(
        HardwareDetectionService.formatInputDevice(
          'Razer Viper V3 Pro|1532|00A6',
        ),
        'Razer Viper V3 Pro',
      );
    });

    test('appends hardware ids for an unknown vendor', () {
      expect(
        HardwareDetectionService.formatInputDevice(
          'Wireless mouse 8k dongle-L|373B|11D9',
        ),
        'Wireless mouse 8k dongle-L [VID_373B/PID_11D9]',
      );
    });

    test('falls back when the product string is empty', () {
      expect(
        HardwareDetectionService.formatInputDevice('|373B|11D9'),
        'Unknown device [VID_373B/PID_11D9]',
      );
      expect(
        HardwareDetectionService.formatInputDevice('|046D|C088'),
        'Logitech',
      );
    });

    test('passes through a plain CIM fallback row', () {
      expect(
        HardwareDetectionService.formatInputDevice('HID-compliant mouse||'),
        'HID-compliant mouse',
      );
    });
  });
}
