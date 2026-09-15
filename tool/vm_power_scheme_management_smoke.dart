import 'dart:io';

import 'package:script_utility/platform/windows/power_scheme_service.dart';

void main() {
  final service = WindowsPowerSchemeService();
  final original = service.activeSchemeId;
  String? duplicate;
  try {
    duplicate = service.duplicateScheme(original, 'ZapTweaks VM Smoke');
    final created = service.enumerate().singleWhere(
      (item) => item.id == duplicate,
    );
    if (created.name != 'ZapTweaks VM Smoke') {
      throw StateError('Rename failed.');
    }
    service.setActiveScheme(duplicate);
    if (service.activeSchemeId != duplicate) {
      throw StateError('Activation failed.');
    }
    stdout.writeln('DUPLICATED=$duplicate');
    stdout.writeln('ACTIVATED=true');
  } finally {
    service.setActiveScheme(original);
    if (duplicate != null) service.deleteScheme(duplicate);
  }
  if (service.activeSchemeId != original ||
      service.enumerate().any((item) => item.id == duplicate)) {
    throw StateError('Power scheme cleanup failed.');
  }
  stdout.writeln('RESTORED=$original');
  stdout.writeln('CLEAN=true');
}
