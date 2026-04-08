import 'dart:convert';
import 'dart:typed_data';

import '../core/registry_manager.dart';
import '../core/services/process_runner.dart';
import 'system_tweak.dart';

List<SystemTweak> createUiVisualsTweaks() {
  return <SystemTweak>[
    StartMenuTaskbarCleanTweak(),
    ContextMenuCleanTweak(),
    DarkThemeTweak(),
    PointerPrecisionOffTweak(),
    BackgroundAppsOffTweak(),
  ];
}

abstract class _UiVisualsTweak extends SystemTweak {
  _UiVisualsTweak({
    required super.id,
    required super.title,
    required super.description,
  }) : super(category: 'UI & Visuals');

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

class StartMenuTaskbarCleanTweak extends _UiVisualsTweak {
  StartMenuTaskbarCleanTweak()
    : super(
        id: 'ui_start_taskbar_clean',
        title: 'Start Menu and Taskbar Clean',
        description:
            'Hides widgets/search/task view/chat and applies left alignment + list view preferences.',
      );

  static const String _windowsFeedsPolicyKey =
      r'HKLM\Software\Policies\Microsoft\Windows\Windows Feeds';
  static const String _advancedKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced';
  static const String _searchKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Search';
  static const String _startKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Start';
  static const String _policiesExplorerKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_windowsFeedsPolicyKey, 'EnableFeeds', 0);
    await RegistryManager.writeDword(_advancedKey, 'TaskbarAl', 0);
    await RegistryManager.writeDword(_advancedKey, 'ShowTaskViewButton', 0);
    await RegistryManager.writeDword(_advancedKey, 'TaskbarMn', 0);
    await RegistryManager.writeDword(_advancedKey, 'ShowCopilotButton', 0);
    await RegistryManager.writeDword(_searchKey, 'SearchboxTaskbarMode', 0);
    await RegistryManager.writeDword(_policiesExplorerKey, 'HideSCAMeetNow', 1);
    await RegistryManager.writeDword(_startKey, 'AllAppsViewMode', 2);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
cmd /c "reg delete \"HKLM\Software\Policies\Microsoft\Windows\Windows Feeds\" /f >nul 2>&1"
cmd /c "reg delete \"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" /v \"TaskbarAl\" /f >nul 2>&1"
cmd /c "reg delete \"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" /v \"ShowTaskViewButton\" /f >nul 2>&1"
cmd /c "reg delete \"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" /v \"TaskbarMn\" /f >nul 2>&1"
cmd /c "reg delete \"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" /v \"ShowCopilotButton\" /f >nul 2>&1"
cmd /c "reg delete \"HKCU\Software\Microsoft\Windows\CurrentVersion\Search\" /v \"SearchboxTaskbarMode\" /f >nul 2>&1"
cmd /c "reg delete \"HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\" /v \"HideSCAMeetNow\" /f >nul 2>&1"
cmd /c "reg delete \"HKCU\Software\Microsoft\Windows\CurrentVersion\Start\" /v \"AllAppsViewMode\" /f >nul 2>&1"
''', elevated: true);
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final searchBox = await RegistryManager.readDword(
      _searchKey,
      'SearchboxTaskbarMode',
    );
    final taskbarMn = await RegistryManager.readDword(
      _advancedKey,
      'TaskbarMn',
    );
    final showTaskView = await RegistryManager.readDword(
      _advancedKey,
      'ShowTaskViewButton',
    );

    final applied = searchBox == 0 && taskbarMn == 0 && showTaskView == 0;
    isApplied = applied;
    return applied;
  }
}

class ContextMenuCleanTweak extends _UiVisualsTweak {
  ContextMenuCleanTweak()
    : super(
        id: 'ui_context_menu_clean',
        title: 'Context Menu Clean',
        description:
            'Enables classic context menu and removes selected shell clutter entries.',
      );

  @override
  Future<void> onApply() async {
    await runSilentPowerShell(r'''
cmd /c "reg add \"HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32\" /ve /t REG_SZ /d \"\" /f >nul 2>&1"
cmd /c "reg add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\" /v \"NoCustomizeThisFolder\" /t REG_DWORD /d \"1\" /f >nul 2>&1"
cmd /c "reg delete \"HKCR\Folder\shell\pintohome\" /f >nul 2>&1"
cmd /c "reg delete \"HKCR\*\shell\pintohomefile\" /f >nul 2>&1"
cmd /c "reg add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\" /v \"{9F156763-7844-4DC4-B2B1-901F640F5155}\" /t REG_SZ /d \"\" /f >nul 2>&1"
cmd /c "reg add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\" /v \"{09A47860-11B0-4DA5-AFA5-26D86198A780}\" /t REG_SZ /d \"\" /f >nul 2>&1"
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
cmd /c "reg delete \"HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\" /f >nul 2>&1"
cmd /c "reg delete \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\" /v \"NoCustomizeThisFolder\" /f >nul 2>&1"
cmd /c "reg delete \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\" /v \"{9F156763-7844-4DC4-B2B1-901F640F5155}\" /f >nul 2>&1"
cmd /c "reg delete \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\" /v \"{09A47860-11B0-4DA5-AFA5-26D86198A780}\" /f >nul 2>&1"
''', elevated: true);

    isApplied = await checkState();
  }

  @override
  Future<bool> checkState() async {
    final output = (await runPowerShellForOutput(
      r"if (Test-Path 'Registry::HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32') { 'true' } else { 'false' }",
    )).toLowerCase();

    final applied = output.contains('true');
    isApplied = applied;
    return applied;
  }
}

class DarkThemeTweak extends SystemTweak {
  DarkThemeTweak()
    : super(
        id: 'ui_dark_theme',
        title: 'Theme Black',
        description:
            'Applies a dark Windows UI profile and disables transparency effects.',
        category: 'UI & Visuals',
      );

  static const String _personalizeUserKey =
      r'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize';
  static const String _personalizeMachineKey =
      r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(
      _personalizeUserKey,
      'AppsUseLightTheme',
      0,
    );
    await RegistryManager.writeDword(
      _personalizeUserKey,
      'SystemUsesLightTheme',
      0,
    );
    await RegistryManager.writeDword(
      _personalizeUserKey,
      'EnableTransparency',
      0,
    );
    await RegistryManager.writeDword(
      _personalizeMachineKey,
      'AppsUseLightTheme',
      0,
    );
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeDword(
      _personalizeUserKey,
      'AppsUseLightTheme',
      1,
    );
    await RegistryManager.writeDword(
      _personalizeUserKey,
      'SystemUsesLightTheme',
      1,
    );
    await RegistryManager.writeDword(
      _personalizeUserKey,
      'EnableTransparency',
      1,
    );

    final machineTheme = await RegistryManager.readDword(
      _personalizeMachineKey,
      'AppsUseLightTheme',
    );
    if (machineTheme != null) {
      await RegistryManager.deleteValue(
        _personalizeMachineKey,
        'AppsUseLightTheme',
      );
    }

    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final appsLightTheme = await RegistryManager.readDword(
      _personalizeUserKey,
      'AppsUseLightTheme',
    );
    final systemLightTheme = await RegistryManager.readDword(
      _personalizeUserKey,
      'SystemUsesLightTheme',
    );
    final transparency = await RegistryManager.readDword(
      _personalizeUserKey,
      'EnableTransparency',
    );

    final applied =
        appsLightTheme == 0 && systemLightTheme == 0 && transparency == 0;
    isApplied = applied;
    return applied;
  }
}

class PointerPrecisionOffTweak extends SystemTweak {
  PointerPrecisionOffTweak()
    : super(
        id: 'ui_pointer_precision_off',
        title: 'Pointer Precision Off',
        description:
            'Disables pointer precision and sets 6/11 style mouse thresholds.',
        category: 'UI & Visuals',
      );

  static const String _mouseKey = r'HKCU\Control Panel\Mouse';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeString(_mouseKey, 'MouseSpeed', '0');
    await RegistryManager.writeString(_mouseKey, 'MouseThreshold1', '0');
    await RegistryManager.writeString(_mouseKey, 'MouseThreshold2', '0');
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeString(_mouseKey, 'MouseSpeed', '1');
    await RegistryManager.writeString(_mouseKey, 'MouseThreshold1', '6');
    await RegistryManager.writeString(_mouseKey, 'MouseThreshold2', '10');
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final mouseSpeed = await RegistryManager.readString(
      _mouseKey,
      'MouseSpeed',
    );
    final threshold1 = await RegistryManager.readString(
      _mouseKey,
      'MouseThreshold1',
    );
    final threshold2 = await RegistryManager.readString(
      _mouseKey,
      'MouseThreshold2',
    );

    final applied = mouseSpeed == '0' && threshold1 == '0' && threshold2 == '0';
    isApplied = applied;
    return applied;
  }
}

class BackgroundAppsOffTweak extends SystemTweak {
  BackgroundAppsOffTweak()
    : super(
        id: 'ui_background_apps_off',
        title: 'Background Apps Off',
        description:
            'Blocks background app execution through AppPrivacy policy.',
        category: 'UI & Visuals',
      );

  static const String _policyKey =
      r'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_policyKey, 'LetAppsRunInBackground', 2);
    isApplied = true;
  }

  @override
  Future<void> onRevert() async {
    final current = await RegistryManager.readDword(
      _policyKey,
      'LetAppsRunInBackground',
    );
    if (current != null) {
      await RegistryManager.deleteValue(_policyKey, 'LetAppsRunInBackground');
    }
    isApplied = false;
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _policyKey,
      'LetAppsRunInBackground',
    );
    final applied = current == 2;
    isApplied = applied;
    return applied;
  }
}
