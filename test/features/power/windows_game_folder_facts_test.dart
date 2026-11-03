import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/power/domain/game_folder_policy.dart';
import 'package:script_utility/platform/windows/game_folder_facts.dart';

void main() {
  test(
    'user-writable and security folders are refused on this PC',
    () {
      final env = Platform.environment;
      final facts = windowsGameFolderFacts();
      final checked = <String>[];
      for (final path in <String>[
        '${env['APPDATA']}\\Microsoft\\Windows\\Start Menu\\Programs\\Startup',
        '${env['LOCALAPPDATA']}\\Microsoft\\WindowsApps',
        '${env['USERPROFILE']}\\Documents',
        r'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp',
        r'C:\Users\Public\Desktop',
        '${env['ProgramFiles']}\\Windows Defender',
        '${env['ProgramFiles']}\\Common Files',
      ]) {
        if (!Directory(path).existsSync()) continue;
        checked.add(path);
        expect(
          checkGameFolder(path, facts).refusal,
          GameFolderRefusal.protectedFolder,
          reason: path,
        );
      }
      expect(checked, isNotEmpty);
      // A game below a launcher in Program Files stays possible.
      final steam = '${env['ProgramFiles(x86)']}\\Steam\\steamapps\\common';
      final game = Directory(steam).existsSync()
          ? Directory(steam).listSync().whereType<Directory>().firstOrNull
          : null;
      if (game != null) {
        expect(checkGameFolder(game.path, facts).allowed, isTrue);
      }
    },
    skip: !Platform.isWindows,
  );
}
