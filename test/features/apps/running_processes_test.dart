import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/running_processes.dart';

void main() {
  const processes = <({String name, String path})>[
    (
      name: 'Discord',
      path: r'C:\Users\Me\AppData\Local\Discord\app-1\Discord.exe',
    ),
    (name: 'Update', path: r'C:\Users\Me\AppData\Local\Discord\Update.exe'),
    (
      name: 'Discord',
      path: r'C:\Users\Me\AppData\Local\Discord\app-1\Discord.exe',
    ),
    (
      name: 'DiscordPTB',
      path: r'C:\Users\Me\AppData\Local\DiscordPTB\Discord.exe',
    ),
    (name: 'explorer', path: r'C:\Windows\explorer.exe'),
  ];

  test('lists each process running from the folder once', () {
    expect(processesUnder(processes, r'C:\Users\Me\AppData\Local\Discord\'), [
      'Discord',
      'Update',
    ]);
  });

  test('a sibling folder with the same prefix does not match', () {
    expect(
      processesUnder(processes, r'C:\Users\Me\AppData\Local\Discord'),
      isNot(contains('DiscordPTB')),
    );
  });

  test('shared folders never flag anything', () {
    expect(processesUnder(processes, r'C:\Windows'), isEmpty);
    expect(processesUnder(processes, r'C:\'), isEmpty);
  });
}
