import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application code contains no mutable download-and-execute command', () {
    final source = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');
    expect(
      RegExp(
        r'(?:irm|iwr|Invoke-WebRequest|Invoke-RestMethod)[^\r\n]*(?:\|\s*iex|Invoke-Expression)',
        caseSensitive: false,
      ).hasMatch(source),
      isFalse,
    );
  });
}
