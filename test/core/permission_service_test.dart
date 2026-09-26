import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/permission_service.dart';

void main() {
  test('reads elevation from the current Windows token', () async {
    final expected = Process.runSync('powershell', <String>[
      '-NoProfile',
      '-Command',
      r'''$id=[Security.Principal.WindowsIdentity]::GetCurrent();([Security.Principal.WindowsPrincipal]::new($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)''',
    ]).stdout.toString().trim().toLowerCase();

    expect(
      await const PermissionService().isRunningElevated(),
      expected == 'true',
    );
  }, skip: !Platform.isWindows);
}
