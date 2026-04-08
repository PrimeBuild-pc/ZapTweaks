import 'dart:convert';
import 'dart:typed_data';

import '../core/registry_manager.dart';
import '../core/services/process_runner.dart';
import 'system_tweak.dart';

List<SystemTweak> createPrivacyBloatwareTweaks() {
  return <SystemTweak>[
    ConsumerContentPrivacyTweak(),
    WidgetsTweak(),
    CopilotTweak(),
    GameBarTweak(),
    SafeDebloatPresetTweak(),
  ];
}

abstract class _PrivacyBloatwareSystemTweak extends SystemTweak {
  _PrivacyBloatwareSystemTweak({
    required super.id,
    required super.title,
    required super.description,
  }) : super(category: 'Privacy & Bloatware');

  Future<void> runSilentPowerShell(
    String script, {
    bool elevated = false,
  }) async {
    final encodedScript = _encodePowerShellScript(script);

    final List<String> arguments;
    if (elevated) {
      final elevateCommand =
          "Start-Process -FilePath 'powershell.exe' -Verb RunAs -WindowStyle Hidden -Wait -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-EncodedCommand','${encodedScript.replaceAll("'", "''")}')";

      arguments = <String>[
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-Command',
        elevateCommand,
      ];
    } else {
      arguments = <String>[
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-EncodedCommand',
        encodedScript,
      ];
    }

    final result = await ProcessRunner.shared.run('powershell', arguments);

    if (result.exitCode != 0) {
      final stderr = result.stderr.trim();
      final stdout = result.stdout.trim();
      final details = stderr.isNotEmpty
          ? stderr
          : (stdout.isNotEmpty ? stdout : 'Unknown PowerShell error');
      throw Exception(details);
    }
  }

  Future<String> runPowerShellForOutput(String script) async {
    final encodedScript = _encodePowerShellScript(script);
    final result = await ProcessRunner.shared.run('powershell', <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-WindowStyle',
      'Hidden',
      '-EncodedCommand',
      encodedScript,
    ]);

    if (result.exitCode != 0) {
      final stderr = result.stderr.trim();
      final stdout = result.stdout.trim();
      final details = stderr.isNotEmpty
          ? stderr
          : (stdout.isNotEmpty ? stdout : 'Unknown PowerShell error');
      throw Exception(details);
    }

    return result.stdout.trim();
  }

  String _encodePowerShellScript(String script) {
    final units = script.codeUnits;
    final bytes = Uint8List(units.length * 2);
    for (var i = 0; i < units.length; i++) {
      final unit = units[i];
      bytes[i * 2] = unit & 0xFF;
      bytes[i * 2 + 1] = (unit >> 8) & 0xFF;
    }
    return base64Encode(bytes);
  }
}

class ConsumerContentPrivacyTweak extends SystemTweak {
  ConsumerContentPrivacyTweak()
    : super(
        id: 'privacy_consumer_content',
        title: 'Consumer Content and Auto-App Suggestions',
        description:
            'Disables Windows consumer content suggestions and silent preinstalled app pushes.',
        category: 'Privacy & Bloatware',
      );

  static const String _cloudContentKey =
      r'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent';
  static const String _contentDeliveryKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _cloudContentKey,
      'DisableWindowsConsumerFeatures',
      1,
    );
    await RegistryManager.writeDword(
      _contentDeliveryKey,
      'SilentInstalledAppsEnabled',
      0,
    );
    await RegistryManager.writeDword(
      _contentDeliveryKey,
      'PreInstalledAppsEnabled',
      0,
    );
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(
      _cloudContentKey,
      'DisableWindowsConsumerFeatures',
      0,
    );
    await RegistryManager.writeDword(
      _contentDeliveryKey,
      'SilentInstalledAppsEnabled',
      1,
    );
    await RegistryManager.writeDword(
      _contentDeliveryKey,
      'PreInstalledAppsEnabled',
      1,
    );
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final disableConsumer = await RegistryManager.readDword(
      _cloudContentKey,
      'DisableWindowsConsumerFeatures',
    );
    final silentInstall = await RegistryManager.readDword(
      _contentDeliveryKey,
      'SilentInstalledAppsEnabled',
    );
    final preInstalled = await RegistryManager.readDword(
      _contentDeliveryKey,
      'PreInstalledAppsEnabled',
    );

    final applied =
        disableConsumer == 1 && silentInstall == 0 && preInstalled == 0;
    isApplied = applied;
    return applied;
  }
}

class WidgetsTweak extends _PrivacyBloatwareSystemTweak {
  WidgetsTweak()
    : super(
        id: 'privacy_widgets',
        title: 'Widgets and News Feed',
        description:
            'Disables Widgets policy flags and stops running widget processes.',
      );

  static const String _policyManagerKey =
      r'HKLM\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests';
  static const String _dshKey = r'HKLM\SOFTWARE\Policies\Microsoft\Dsh';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_policyManagerKey, 'value', 0);
    await RegistryManager.writeDword(_dshKey, 'AllowNewsAndInterests', 0);

    await runSilentPowerShell(r'''
Get-Process -Name Widgets -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name WidgetService -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
''');

    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_policyManagerKey, 'value', 1);

    final current = await RegistryManager.readDword(
      _dshKey,
      'AllowNewsAndInterests',
    );
    if (current != null) {
      await RegistryManager.deleteValue(_dshKey, 'AllowNewsAndInterests');
    }

    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final policyManagerValue = await RegistryManager.readDword(
      _policyManagerKey,
      'value',
    );
    final dshValue = await RegistryManager.readDword(
      _dshKey,
      'AllowNewsAndInterests',
    );

    final applied = policyManagerValue == 0 && dshValue == 0;
    isApplied = applied;
    return applied;
  }
}

class CopilotTweak extends _PrivacyBloatwareSystemTweak {
  CopilotTweak()
    : super(
        id: 'privacy_copilot',
        title: 'Copilot Disable',
        description:
            'Disables Copilot policies and removes current Copilot app package registration.',
      );

  static const String _copilotKeyUser =
      r'HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot';
  static const String _copilotKeyMachine =
      r'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _copilotKeyUser,
      'TurnOffWindowsCopilot',
      1,
    );
    await RegistryManager.writeDword(
      _copilotKeyMachine,
      'TurnOffWindowsCopilot',
      1,
    );

    await runSilentPowerShell(r'''
$stop = @('backgroundTaskHost','Copilot','CrossDeviceResume','RuntimeBroker','Search','SearchHost','WidgetService','Widgets')
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
Get-Process | Where-Object { $_.ProcessName -like '*edge*' } | Stop-Process -Force -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers | Where-Object { $_.Name -like '*Copilot*' } | Remove-AppxPackage -ErrorAction SilentlyContinue
''', elevated: true);

    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    final userValue = await RegistryManager.readDword(
      _copilotKeyUser,
      'TurnOffWindowsCopilot',
    );
    if (userValue != null) {
      await RegistryManager.deleteValue(
        _copilotKeyUser,
        'TurnOffWindowsCopilot',
      );
    }

    final machineValue = await RegistryManager.readDword(
      _copilotKeyMachine,
      'TurnOffWindowsCopilot',
    );
    if (machineValue != null) {
      await RegistryManager.deleteValue(
        _copilotKeyMachine,
        'TurnOffWindowsCopilot',
      );
    }

    await runSilentPowerShell(r'''
Get-AppxPackage -AllUsers | Where-Object { $_.Name -like '*Copilot*' } | ForEach-Object {
  if ($_.InstallLocation -and (Test-Path (Join-Path $_.InstallLocation 'AppXManifest.xml'))) {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
  }
}
''', elevated: true);

    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final userValue = await RegistryManager.readDword(
      _copilotKeyUser,
      'TurnOffWindowsCopilot',
    );
    final machineValue = await RegistryManager.readDword(
      _copilotKeyMachine,
      'TurnOffWindowsCopilot',
    );

    final applied = userValue == 1 && machineValue == 1;
    isApplied = applied;
    return applied;
  }
}

class GameBarTweak extends _PrivacyBloatwareSystemTweak {
  GameBarTweak()
    : super(
        id: 'privacy_gamebar',
        title: 'Game Bar and Capture Overlay',
        description:
            'Disables Game Bar capture and overlay related policy values.',
      );

  static const String _gameConfigStore = r'HKCU\System\GameConfigStore';
  static const String _gameDvrKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR';
  static const String _gameBarKey = r'HKCU\Software\Microsoft\GameBar';
  static const String _presenceWriter =
      r'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_gameConfigStore, 'GameDVR_Enabled', 0);
    await RegistryManager.writeDword(_gameDvrKey, 'AppCaptureEnabled', 0);
    await RegistryManager.writeDword(
      _gameBarKey,
      'UseNexusForGameBarEnabled',
      0,
    );
    await RegistryManager.writeDword(
      _gameBarKey,
      'GamepadNexusChordEnabled',
      0,
    );
    await RegistryManager.writeDword(_presenceWriter, 'ActivationType', 0);

    await runSilentPowerShell(r'''
Get-Process -Name GameBar -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
''');

    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(_gameConfigStore, 'GameDVR_Enabled', 1);

    final appCapture = await RegistryManager.readDword(
      _gameDvrKey,
      'AppCaptureEnabled',
    );
    if (appCapture != null) {
      await RegistryManager.deleteValue(_gameDvrKey, 'AppCaptureEnabled');
    }

    final useNexus = await RegistryManager.readDword(
      _gameBarKey,
      'UseNexusForGameBarEnabled',
    );
    if (useNexus != null) {
      await RegistryManager.deleteValue(
        _gameBarKey,
        'UseNexusForGameBarEnabled',
      );
    }

    final nexusChord = await RegistryManager.readDword(
      _gameBarKey,
      'GamepadNexusChordEnabled',
    );
    if (nexusChord != null) {
      await RegistryManager.deleteValue(
        _gameBarKey,
        'GamepadNexusChordEnabled',
      );
    }

    await RegistryManager.writeDword(_presenceWriter, 'ActivationType', 1);

    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final gameDvrEnabled = await RegistryManager.readDword(
      _gameConfigStore,
      'GameDVR_Enabled',
    );
    final appCaptureEnabled = await RegistryManager.readDword(
      _gameDvrKey,
      'AppCaptureEnabled',
    );
    final useNexus = await RegistryManager.readDword(
      _gameBarKey,
      'UseNexusForGameBarEnabled',
    );
    final gamepadChord = await RegistryManager.readDword(
      _gameBarKey,
      'GamepadNexusChordEnabled',
    );
    final activationType = await RegistryManager.readDword(
      _presenceWriter,
      'ActivationType',
    );

    final applied =
        gameDvrEnabled == 0 &&
        appCaptureEnabled == 0 &&
        useNexus == 0 &&
        gamepadChord == 0 &&
        activationType == 0;
    isApplied = applied;
    return applied;
  }
}

class SafeDebloatPresetTweak extends _PrivacyBloatwareSystemTweak {
  SafeDebloatPresetTweak()
    : super(
        id: 'privacy_safe_debloat',
        title: 'Safe Debloat Preset',
        description:
            'Removes only selected UWP bloat apps while preserving Store and Xbox base components.',
      );

  static const List<String> _targets = <String>[
    'Clipchamp.Clipchamp',
    'Microsoft.3DBuilder',
    'Microsoft.BingFinance',
    'Microsoft.BingNews',
    'Microsoft.BingSports',
    'Microsoft.BingWeather',
    'Microsoft.GetHelp',
    'Microsoft.Getstarted',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.MixedReality.Portal',
    'Microsoft.Office.OneNote',
    'Microsoft.People',
    'Microsoft.SkypeApp',
    'Microsoft.Todos',
    'Microsoft.WindowsFeedbackHub',
    'Microsoft.YourPhone',
    'Microsoft.ZuneMusic',
    'Microsoft.ZuneVideo',
    'MicrosoftTeams',
  ];

  @override
  Future<void> onApply() async {
    final targetList = _targets.map((entry) => "'$entry'").join(', ');

    final script =
        r'''
$ErrorActionPreference = 'SilentlyContinue'
$targets = @(__TARGETS__)
$protected = @('Microsoft.WindowsStore','Microsoft.StorePurchaseApp','Microsoft.DesktopAppInstaller','Microsoft.VCLibs','Microsoft.UI.Xaml','Microsoft.XboxIdentityProvider','Microsoft.Xbox.TCUI','Microsoft.GamingServices','Microsoft.XboxGamingOverlay','Microsoft.XboxGameOverlay','Microsoft.XboxSpeechToTextOverlay','Microsoft.GamingApp')

function IsProtected([string]$name) {
  foreach ($p in $protected) {
    if ($name -like ($p + '*')) { return $true }
  }
  return $false
}

foreach ($target in $targets) {
  $packages = Get-AppxPackage -AllUsers -Name ($target + '*')
  foreach ($pkg in $packages) {
    if (-not (IsProtected $pkg.Name)) {
      Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
    }
  }

  $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like ($target + '*') }
  foreach ($prov in $provisioned) {
    if (-not (IsProtected $prov.DisplayName)) {
      Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName | Out-Null
    }
  }
}
'''
            .replaceAll('__TARGETS__', targetList);

    await runSilentPowerShell(script, elevated: true);
    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
Get-AppxPackage -AllUsers | ForEach-Object {
  if ($_.InstallLocation -and (Test-Path (Join-Path $_.InstallLocation 'AppXManifest.xml'))) {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
  }
}
''', elevated: true);

    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final targetList = _targets.map((entry) => "'$entry'").join(', ');

    final script =
        r'''
$targets = @(__TARGETS__)
$remaining = 0
foreach ($target in $targets) {
  $remaining += (Get-AppxPackage -AllUsers -Name ($target + '*') | Measure-Object).Count
}
Write-Output $remaining
'''
            .replaceAll('__TARGETS__', targetList);

    final output = await runPowerShellForOutput(script);
    final remaining = int.tryParse(output.trim()) ?? 0;
    final applied = remaining == 0;
    isApplied = applied;
    return applied;
  }
}
