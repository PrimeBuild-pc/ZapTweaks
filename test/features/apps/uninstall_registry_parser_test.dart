import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/app_inventory_parser.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';

Map<String, Object?> _row(
  String key, {
  String hive = 'HKLM',
  String view = '64',
  Map<String, Object?> values = const {},
}) => {'Hive': hive, 'View': view, 'Key': key, ...values};

List<AppPackage> _parse(List<Map<String, Object?>> rows) =>
    const AppInventoryParser().parseUninstallEntries(jsonEncode(rows));

void main() {
  test('reads the Uninstall fields of a normal program', () {
    final app = _parse([
      _row(
        'Git_is1',
        values: {
          'DisplayName': 'Git',
          'Publisher': 'The Git Development Community',
          'DisplayVersion': '2.47.0',
          'InstallDate': '20260915',
          'InstallLocation': r'C:\Program Files\Git\',
          'EstimatedSize': 345000,
          'UninstallString': r'"C:\Program Files\Git\unins000.exe"',
          'QuietUninstallString':
              r'"C:\Program Files\Git\unins000.exe" /VERYSILENT',
        },
      ),
    ]).single;

    expect(app.provider, AppProvider.win32);
    expect(app.packageId, r'HKLM\64\Git_is1');
    expect(app.name, 'Git');
    expect(app.publisher, 'The Git Development Community');
    expect(app.version, '2.47.0');
    expect(app.installDate, DateTime(2026, 9, 15));
    expect(app.installLocation, r'C:\Program Files\Git\');
    expect(app.sizeBytes, 345000 * 1024);
    expect(
      app.uninstall!.uninstallString,
      r'"C:\Program Files\Git\unins000.exe"',
    );
    expect(app.uninstall!.quietUninstallString, contains('/VERYSILENT'));
    expect(app.labels, isEmpty);
  });

  test(
    'MSI product code comes from the key name only for Windows Installer',
    () {
      final apps = _parse([
        _row(
          '{26A24AE4-039D-4CA4-87B4-2F64180101F0}',
          values: {
            'DisplayName': 'Java 8 Update 401',
            'WindowsInstaller': 1,
            'UninstallString':
                'MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F64180101F0}',
          },
        ),
        _row(
          '{NOT-A-GUID}',
          values: {'DisplayName': 'Odd', 'WindowsInstaller': 1},
        ),
        _row(
          '{11111111-2222-3333-4444-555555555555}',
          values: {
            'DisplayName': 'Exe with GUID key',
            'UninstallString': 'x.exe',
          },
        ),
      ]);

      expect(
        apps
            .firstWhere((a) => a.name.startsWith('Java'))
            .uninstall!
            .msiProductCode,
        '{26A24AE4-039D-4CA4-87B4-2F64180101F0}',
      );
      expect(
        apps.firstWhere((a) => a.name == 'Odd').uninstall!.msiProductCode,
        isNull,
      );
      expect(
        apps
            .firstWhere((a) => a.name.startsWith('Exe'))
            .uninstall!
            .msiProductCode,
        isNull,
      );
    },
  );

  test('labels: system component, protected, update, missing uninstaller', () {
    final apps = {
      for (final app in _parse([
        _row(
          'Hidden',
          values: {
            'DisplayName': 'Hidden runtime',
            'SystemComponent': 1,
            'UninstallString': 'u.exe',
          },
        ),
        _row(
          'Locked',
          values: {
            'DisplayName': 'Locked',
            'NoRemove': 1,
            'UninstallString': 'u.exe',
          },
        ),
        _row(
          'KB5001',
          values: {
            'DisplayName': 'Security Update for Office',
            'ParentKeyName': 'Office16',
            'UninstallString': 'u.exe',
          },
        ),
        _row(
          'Hotfix',
          values: {
            'DisplayName': 'Some hotfix',
            'ReleaseType': 'Hotfix',
            'UninstallString': 'u.exe',
          },
        ),
        _row('Orphan', values: {'DisplayName': 'No uninstaller'}),
      ]))
        app.name: app.labels,
    };

    expect(apps['Hidden runtime'], {AppLabel.systemComponent});
    expect(apps['Locked'], {AppLabel.protected});
    expect(apps['Security Update for Office'], {AppLabel.update});
    expect(apps['Some hotfix'], {AppLabel.update});
    expect(apps['No uninstaller'], {AppLabel.missingUninstaller});
  });

  test(
    'skips nameless keys, bad dates and sizes; keeps 64-bit over 32-bit twin',
    () {
      final apps = _parse([
        _row('NoName', values: {'UninstallString': 'u.exe'}),
        _row(
          'App',
          values: {
            'DisplayName': 'Twin',
            'DisplayVersion': '1.0',
            'InstallDate': '2026-13-45',
            'EstimatedSize': -3,
            'UninstallString': 'a.exe',
          },
        ),
        _row(
          'App',
          view: '32',
          values: {
            'DisplayName': 'Twin',
            'DisplayVersion': '1.0',
            'UninstallString': 'b.exe',
          },
        ),
        _row(
          'Mine',
          hive: 'HKCU',
          view: '64',
          values: {'DisplayName': 'Per-user', 'UninstallString': 'c.exe'},
        ),
      ]);

      expect(apps.map((a) => a.name), ['Twin', 'Per-user']);
      expect(apps.first.packageId, r'HKLM\64\App');
      expect(apps.first.installDate, isNull);
      expect(apps.first.sizeBytes, isNull);
      expect(apps.last.packageId, r'HKCU\64\Mine');
    },
  );

  test('of two twins the visible one with an uninstaller is kept', () {
    final apps = _parse([
      _row(
        '{11111111-2222-3333-4444-555555555555}',
        values: {
          'DisplayName': 'Bundle',
          'DisplayVersion': '2.0',
          'SystemComponent': 1,
          'WindowsInstaller': 1,
        },
      ),
      _row(
        '{AAAAAAAA-2222-3333-4444-555555555555}',
        view: '32',
        values: {
          'DisplayName': 'Bundle',
          'DisplayVersion': '2.0',
          'UninstallString': r'"C:\ProgramData\Package Cache\b.exe" /uninstall',
        },
      ),
      _row(
        'Same',
        hive: 'HKCU',
        values: {
          'DisplayName': 'Bundle',
          'DisplayVersion': '2.0',
          'UninstallString': 'u.exe',
        },
      ),
    ]);

    expect(apps, hasLength(2), reason: 'HKCU install is a separate entry');
    expect(
      apps.first.packageId,
      r'HKLM\32\{AAAAAAAA-2222-3333-4444-555555555555}',
    );
    expect(apps.first.labels, isEmpty);
  });

  test('winget ids attach to the one matching program and add no rows', () {
    const parser = AppInventoryParser();
    final apps = parser.parseUninstallEntries(
      jsonEncode([
        _row(
          'Git_is1',
          values: {
            'DisplayName': 'Git',
            'Publisher': 'The Git Development Community',
            'UninstallString': 'u',
          },
        ),
        _row(
          'Mozilla Firefox',
          values: {
            'DisplayName': 'Mozilla Firefox (x64 en-US)',
            'Publisher': 'Mozilla',
            'UninstallString': 'u',
          },
        ),
        _row(
          '7-Zip',
          values: {
            'DisplayName': '7-Zip 23.01 (x64)',
            'Publisher': 'Igor Pavlov',
            'UninstallString': 'u',
          },
        ),
        _row(
          'VSCode',
          hive: 'HKCU',
          values: {
            'DisplayName': 'Microsoft Visual Studio Code (User)',
            'Publisher': 'Microsoft Corporation',
            'UninstallString': 'u',
          },
        ),
      ]),
    );
    final winget = parser.parseWinget(
      jsonEncode({
        'Sources': [
          {
            'Packages': [
              {'PackageIdentifier': 'Git.Git'},
              {'PackageIdentifier': 'Mozilla.Firefox'},
              {'PackageIdentifier': '7zip.7zip'},
              {'PackageIdentifier': 'Microsoft.VisualStudioCode'},
              {'PackageIdentifier': 'Valve.Steam'},
            ],
            'SourceDetails': {'Name': 'winget'},
          },
        ],
      }),
    );

    final merged = attachWingetIds(apps, winget);

    expect(merged, hasLength(4), reason: 'Steam is not installed here');
    expect(
      {for (final a in merged) a.name: a.wingetId},
      {
        'Git': 'Git.Git',
        'Mozilla Firefox (x64 en-US)': 'Mozilla.Firefox',
        '7-Zip 23.01 (x64)': '7zip.7zip',
        'Microsoft Visual Studio Code (User)': 'Microsoft.VisualStudioCode',
      },
    );
    expect(merged.every((a) => a.reinstallable), isTrue);
  });

  test('an ambiguous winget id attaches to nothing', () {
    const parser = AppInventoryParser();
    final apps = parser.parseUninstallEntries(
      jsonEncode([
        _row(
          'A',
          values: {
            'DisplayName': 'Contoso Tool',
            'Publisher': 'Contoso',
            'UninstallString': 'u',
          },
        ),
        _row(
          'B',
          values: {
            'DisplayName': 'Contoso Tool Beta',
            'Publisher': 'Contoso',
            'UninstallString': 'u',
          },
        ),
      ]),
    );
    final winget = parser.parseWinget(
      jsonEncode([
        {'PackageIdentifier': 'Contoso.Tool'},
      ]),
    );
    expect(attachWingetIds(apps, winget).map((a) => a.wingetId), [null, null]);
  });
}
