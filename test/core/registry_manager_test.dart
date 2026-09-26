import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/registry_manager.dart';

void main() {
  test(
    'native registry reader handles DWORD and UTF-16 strings',
    () async {
      expect(
        await RegistryManager.readDword(
          r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
          'EnableLUA',
        ),
        isNotNull,
      );
      expect(
        await RegistryManager.readString(
          r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion',
          'ProgramFilesDir',
        ),
        isNotEmpty,
      );
    },
    skip: !Platform.isWindows,
  );
}
