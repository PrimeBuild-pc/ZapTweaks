import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:win32/win32.dart';

Size windowsPrimaryDisplaySize() => Size(
  GetSystemMetrics(SM_CXSCREEN).toDouble(),
  GetSystemMetrics(SM_CYSCREEN).toDouble(),
);

Offset primaryWindowPosition(Size display, Size window) => Offset(
  math.max(0, (display.width - window.width) / 2),
  math.max(0, (display.height - window.height) / 2),
);
