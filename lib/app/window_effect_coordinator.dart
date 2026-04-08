import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class WindowEffectCoordinator with WidgetsBindingObserver {
  WindowEffectCoordinator._();

  static final WindowEffectCoordinator instance = WindowEffectCoordinator._();

  Timer? _resizeDebounce;
  bool _attached = false;

  void attach() {
    if (_attached) {
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _attached = true;
  }

  Future<void> applyNow() async {
    if (!Platform.isWindows) {
      return;
    }

    try {
      await Window.setEffect(effect: WindowEffect.mica);
    } catch (_) {
      await Window.setEffect(effect: WindowEffect.acrylic);
    }
  }

  @override
  void didChangeMetrics() {
    if (!Platform.isWindows) {
      return;
    }

    _resizeDebounce?.cancel();
    _resizeDebounce = Timer(const Duration(milliseconds: 120), () async {
      await applyNow();
    });
  }
}
