import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/leftover_removal_operation.dart';

const _user = LeftoverRoots(
  folders: <String>[
    r'C:\Users\Me\AppData\Roaming',
    r'C:\Users\Me\AppData\Local',
    r'C:\Users\Me\Desktop',
    r'C:\Users\Me\AppData\Roaming\Microsoft\Windows\Start Menu\Programs',
  ],
);
const _machine = LeftoverRoots(
  folders: <String>[
    r'C:\ProgramData',
    r'C:\Program Files',
    r'C:\Program Files (x86)',
    r'C:\ProgramData\Microsoft\Windows\Start Menu\Programs',
    r'C:\Users\Public\Desktop',
  ],
);

LeftoverRefusal? _check(String kind, String path, {bool machine = false}) =>
    validateLeftoverItem(
      <String, Object?>{'kind': kind, 'path': path},
      machine: machine,
      roots: machine ? _machine : _user,
    );

void main() {
  group('accepted', () {
    for (final (kind, path, machine) in [
      ('folder', r'C:\Users\Me\AppData\Local\Contoso Paint', false),
      ('folder', r'C:\Users\Me\AppData\Roaming\Contoso\Paint', false),
      (
        'folder',
        r'C:\Users\Me\AppData\Local\Programs\Microsoft VS Code',
        false,
      ),
      ('folder', r'C:\Program Files\Contoso\Paint', true),
      ('folder', r'C:\ProgramData\Contoso', true),
      ('shortcut', r'C:\Users\Me\Desktop\Contoso Paint.lnk', false),
      (
        'shortcut',
        r'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Contoso\Paint.lnk',
        true,
      ),
      ('registryKey', r'HKCU\Software\Contoso\Paint', false),
      ('registryKey', r'HKLM\Software\WOW6432Node\Contoso', true),
      (
        'registryKey',
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ContosoPaint',
        true,
      ),
      (
        'registryKey',
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Mine',
        false,
      ),
      (
        'runValue',
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run|PaintTray',
        false,
      ),
      (
        'runValue',
        r'HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run|PaintTray',
        true,
      ),
      ('task', r'\Contoso\PaintUpdate', true),
      ('firewallRule', '{0A1B2C3D-0000-0000-0000-000000000000}', true),
    ]) {
      test('$kind $path', () {
        expect(_check(kind, path, machine: machine), isNull);
      });
    }
  });

  group('refused', () {
    for (final (kind, path, machine) in [
      // Roots themselves and system folders.
      ('folder', r'C:\Users\Me\AppData\Local', false),
      ('folder', r'C:\Program Files', true),
      ('folder', r'C:\Program Files\Common Files', true),
      ('folder', r'C:\Program Files\WindowsApps', true),
      ('folder', r'C:\ProgramData\Microsoft', true),
      ('folder', r'C:\Users\Me\AppData\Local\Microsoft\Windows', false),
      ('folder', r'C:\Users\Me\AppData\Local\Programs', false),
      ('folder', r'C:\Users\Me\AppData\Local\Programs\Common', false),
      ('folder', r'C:\Windows\System32', true),
      // Escapes and other contexts.
      ('folder', r'C:\Users\Me\AppData\Local\..\..\Documents', false),
      ('folder', r'C:\ProgramData\Contoso', false),
      ('folder', r'C:\Users\Me\AppData\Local\Contoso', true),
      ('folder', r'\\server\share\x', true),
      ('folder', 'relative\\x', false),
      ('shortcut', r'C:\Users\Me\Desktop\notes.txt', false),
      // Registry outside Software\<vendor>, or the wrong hive.
      ('registryKey', r'HKCU\Software', false),
      ('registryKey', r'HKCU\Software\Microsoft', false),
      ('registryKey', r'HKCU\Software\Microsoft\Windows', false),
      ('registryKey', r'HKCU\Software\Classes\.txt', false),
      ('registryKey', r'HKCU\Software\Policies\Contoso', false),
      ('registryKey', r'HKLM\Software\Contoso\Paint\Deep', true),
      ('registryKey', r'HKLM\SYSTEM\CurrentControlSet\Services\x', true),
      ('registryKey', r'HKLM\Software\Contoso', false),
      ('registryKey', r'HKCU\Software\Contoso', true),
      ('registryKey', 'HKCU\\Software\\Con"toso', false),
      (
        'runValue',
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run',
        false,
      ),
      ('runValue', r'HKCU\Software\Contoso|x', false),
      // Machine-only kinds from the user operation, Windows tasks.
      ('task', r'\Contoso\PaintUpdate', false),
      ('task', r'\Microsoft\Windows\Defrag\ScheduledDefrag', true),
      ('task', r'Contoso" /F & del', true),
      ('firewallRule', 'x', false),
      ('firewallRule', 'bad\nname', true),
      ('unknown', r'C:\x', true),
    ]) {
      test('$kind $path (machine: $machine)', () {
        expect(_check(kind, path, machine: machine), isNotNull);
      });
    }
  });

  test('state matches desiredValue false only when nothing is left', () async {
    final root = await Directory.systemTemp.createTemp('zt-left-');
    addTearDown(() => root.delete(recursive: true));
    final leftover = await Directory('${root.path}\\Contoso Paint').create();
    final op = LeftoverRemovalOperation(
      machine: false,
      roots: LeftoverRoots(folders: <String>[root.path]),
    );
    final request = OperationRequest(
      operationId: op.id,
      desiredValue: false,
      parameters: <String, Object?>{
        'items': [
          {'kind': 'folder', 'path': leftover.path},
        ],
      },
    );

    final before = await op.inspect(request);
    expect(before.value, isTrue);
    expect(before.message, contains('Contoso Paint'));

    await leftover.delete();
    final after = await op.inspect(request);
    expect(
      after.sameValue(
        const OperationState(OperationStateKind.configured, value: false),
      ),
      isTrue,
    );
  });
}
