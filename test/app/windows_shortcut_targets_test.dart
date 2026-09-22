import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/models/reference_tweaks.dart';

void main() {
  test(
    'every Windows quick-access command resolves to a native target',
    () async {
      if (!Platform.isWindows) return;
      final shortcuts = createReferenceTweaks()
          .whereType<WindowsSettingsLauncherTweak>();
      final system32 = '${Platform.environment['SystemRoot']}\\System32';

      for (final shortcut in shortcuts) {
        final command = shortcut.command;
        if (command.startsWith('start "" ms-settings:')) {
          expect(command, isNot(contains('\n')), reason: shortcut.id);
          continue;
        }
        final executable = command.split(' ').first;
        if (executable.endsWith('.msc') || executable.endsWith('.cpl')) {
          expect(
            File('$system32\\$executable').existsSync(),
            isTrue,
            reason: '${shortcut.id}: $command',
          );
          continue;
        }
        final result = await Process.run('where.exe', <String>[executable]);
        expect(result.exitCode, 0, reason: '${shortcut.id}: $command');
      }
    },
  );
}
