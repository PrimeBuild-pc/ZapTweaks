import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/app/window_placement.dart';

void main() {
  test('window is centered inside the primary display work area', () {
    expect(
      primaryWindowPosition(const Size(2560, 1400), const Size(1280, 820)),
      const Offset(640, 290),
    );
  });

  test('window stays visible when the display is smaller than its minimum', () {
    expect(
      primaryWindowPosition(const Size(1000, 700), const Size(1280, 820)),
      Offset.zero,
    );
  });
}
