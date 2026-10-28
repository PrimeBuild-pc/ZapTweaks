import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/app_inventory_parser.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';
import 'package:script_utility/features/apps/domain/app_safety_policy.dart';

import '../../operations/appx_test_fixtures.dart';

AppPackage _win32(
  String name, {
  String? publisher,
  bool system = false,
  bool noRemove = false,
  bool update = false,
  String? uninstall = 'u.exe',
}) => AppPackage(
  provider: AppProvider.win32,
  packageId: 'HKLM\\64\\$name',
  name: name,
  version: null,
  publisher: publisher,
  scopes: const {AppInstallScope.allUsers},
  source: 'Windows',
  reinstallable: false,
  uninstall: UninstallEntry(
    hive: 'HKLM',
    view: '64',
    key: name,
    uninstallString: uninstall,
    systemComponent: system,
    noRemove: noRemove,
    isUpdate: update,
  ),
);

AppPackage _appx(String id, {Map<String, dynamic> meta = const {}}) =>
    AppPackage(
      provider: AppProvider.appx,
      packageId: id,
      name: id,
      version: null,
      publisher: null,
      scopes: const {AppInstallScope.currentUser},
      source: 'Microsoft Store',
      reinstallable: false,
      appxMetadata: [meta],
    );

void main() {
  test('system components, protected entries and updates are kept', () {
    expect(classifyApp(_win32('Hidden', system: true)).safety, AppSafety.keep);
    expect(
      classifyApp(_win32('Hidden', system: true)).reason,
      AppSafetyReason.systemComponent,
    );
    expect(
      classifyApp(_win32('Locked', noRemove: true)).reason,
      AppSafetyReason.protected,
    );
    expect(
      classifyApp(_win32('KB1', update: true)).reason,
      AppSafetyReason.update,
    );
  });

  test('shared runtimes, drivers and vendor panels need a check first', () {
    for (final name in [
      'Microsoft Visual C++ 2015-2022 Redistributable (x64) - 14.40.33810',
      'Microsoft .NET Runtime - 8.0.10 (x64)',
      'Microsoft Windows Desktop Runtime - 8.0.10 (x64)',
      'Microsoft ASP.NET Core 8.0.10 - Shared Framework (x64)',
      'Microsoft Edge WebView2 Runtime',
      'DirectX End-User Runtime',
      'NVIDIA Graphics Driver 566.14',
      'AMD Chipset Software',
      'Realtek High Definition Audio Driver',
      'Intel(R) Graphics Command Center',
      'NVIDIA PhysX System Software 9.23.1019',
      'Windows Software Development Kit - Windows 10.0.26100.8249',
      'Windows Assessment and Deployment Kit',
    ]) {
      final verdict = classifyApp(_win32(name));
      expect(verdict.safety, AppSafety.checkFirst, reason: name);
      expect(verdict.reason, AppSafetyReason.sharedDependency, reason: name);
    }
  });

  test('an ordinary user-installed program can be removed', () {
    final verdict = classifyApp(
      _win32('Mozilla Firefox (x64 en-US)', publisher: 'Mozilla'),
    );
    expect(verdict.safety, AppSafety.removable);
    expect(verdict.reason, AppSafetyReason.userInstalled);
  });

  test('a program without uninstaller needs a check', () {
    expect(
      classifyApp(_win32('Leftover', uninstall: null)).reason,
      AppSafetyReason.missingUninstaller,
    );
  });

  test('Store apps follow the AppX candidate policy', () {
    final feedbackHub = const AppInventoryParser()
        .parseAppx(jsonEncode(appxInventory()))
        .firstWhere((app) => app.packageId == 'Microsoft.WindowsFeedbackHub');
    expect(classifyApp(feedbackHub).safety, AppSafety.removable);
    expect(
      classifyApp(_appx('Microsoft.WindowsFeedbackHub')).safety,
      AppSafety.keep,
      reason: 'policy candidate whose metadata fails the removal checks',
    );
    final spotify = AppPackage(
      provider: AppProvider.appx,
      packageId: 'SpotifyAB.SpotifyMusic',
      name: 'Spotify',
      version: null,
      publisher: 'CN=5B2A6C5D-0CD2-47DE-A8EB-2A2A2E1F2A3B',
      scopes: const {AppInstallScope.currentUser},
      source: 'Microsoft Store',
      reinstallable: false,
    );
    expect(classifyApp(spotify).safety, AppSafety.removable);
    expect(
      classifyApp(
        _appx('Microsoft.UI.Xaml.2.8', meta: {'IsFramework': true}),
      ).reason,
      AppSafetyReason.windowsPart,
    );
    expect(classifyApp(_appx('Microsoft.WindowsStore')).safety, AppSafety.keep);
  });
}
