import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/orphan_folders.dart';

void main() {
  const candidates = <String>[
    r'C:\Program Files\Contoso',
    r'C:\Program Files\Git',
    r'C:\Program Files\Common Files',
    r'C:\Program Files\WindowsApps',
    r'C:\Program Files\Microsoft Office',
    r'C:\Program Files (x86)\OldGame',
    r'C:\Program Files (x86)\Steam',
  ];

  test('folders nothing installed points to are orphans', () {
    final orphans = findOrphanFolders(candidates, <String>[
      r'C:\Program Files\Git\',
      r'"C:\Program Files (x86)\Steam\uninstall.exe"',
      r'C:\PROGRAM FILES\CONTOSO\Paint\paint.exe',
    ]);
    expect(orphans, [r'C:\Program Files (x86)\OldGame']);
  });

  test('Windows and Microsoft folders are never offered', () {
    expect(findOrphanFolders(candidates, const <String>[]), [
      r'C:\Program Files\Contoso',
      r'C:\Program Files\Git',
      r'C:\Program Files (x86)\OldGame',
      r'C:\Program Files (x86)\Steam',
    ]);
  });

  test(
    'a reference must be the folder or inside it, not a prefix of a name',
    () {
      expect(
        findOrphanFolders(
          <String>[r'C:\Program Files\Git'],
          <String>[r'C:\Program Files\GitHub CLI\gh.exe'],
        ),
        [r'C:\Program Files\Git'],
      );
    },
  );

  test('references with %VAR% are expanded before matching', () {
    expect(
      findOrphanFolders(
        <String>[r'C:\Program Files\Foo'],
        <String>[r'"%ProgramFiles%\Foo\uninstall.exe"'],
        environment: const <String, String>{
          'ProgramFiles': r'C:\Program Files',
        },
      ),
      isEmpty,
    );
  });
}
