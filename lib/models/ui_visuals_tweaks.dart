import '../core/registry_manager.dart';
import 'system_tweak.dart';

List<SystemTweak> createUiVisualsTweaks() {
  return <SystemTweak>[
    StartMenuTaskbarCleanTweak(),
    FolderDiscoveryOffTweak(),
    TaskbarEndTaskTweak(),
    HideExplorerGalleryTweak(),
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
  }

  @override
  Future<bool> checkState() async {
    final values = await Future.wait<int?>(<Future<int?>>[
      RegistryManager.readDword(_windowsFeedsPolicyKey, 'EnableFeeds'),
      RegistryManager.readDword(_advancedKey, 'TaskbarAl'),
      RegistryManager.readDword(_advancedKey, 'ShowTaskViewButton'),
      RegistryManager.readDword(_advancedKey, 'TaskbarMn'),
      RegistryManager.readDword(_advancedKey, 'ShowCopilotButton'),
      RegistryManager.readDword(_searchKey, 'SearchboxTaskbarMode'),
      RegistryManager.readDword(_policiesExplorerKey, 'HideSCAMeetNow'),
      RegistryManager.readDword(_startKey, 'AllAppsViewMode'),
    ]);
    final applied =
        values.length == 8 &&
        values[0] == 0 &&
        values[1] == 0 &&
        values[2] == 0 &&
        values[3] == 0 &&
        values[4] == 0 &&
        values[5] == 0 &&
        values[6] == 1 &&
        values[7] == 2;
    return applied;
  }
}

class FolderDiscoveryOffTweak extends _UiVisualsTweak {
  FolderDiscoveryOffTweak()
    : super(
        id: 'ui_folder_discovery_off',
        title: 'Folder Type Discovery Off',
        description:
            'Prevents Explorer from auto-detecting folder templates, which can speed up large media folders.',
      );

  static const String _shellBagsKey =
      r'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell';

  @override
  Future<void> onApply() =>
      RegistryManager.writeString(_shellBagsKey, 'FolderType', 'NotSpecified');

  @override
  Future<void> onRevert() =>
      RegistryManager.deleteValue(_shellBagsKey, 'FolderType');

  @override
  Future<bool> checkState() async =>
      await RegistryManager.readString(_shellBagsKey, 'FolderType') ==
      'NotSpecified';
}

class TaskbarEndTaskTweak extends SystemTweak {
  TaskbarEndTaskTweak()
    : super(
        id: 'ui_taskbar_end_task',
        title: 'Taskbar End Task',
        description:
            'Adds End task to taskbar app context menus on supported Windows 11 builds.',
        category: 'UI & Visuals',
        minimumWindowsBuild: 22631,
      );

  static const String _developerSettingsKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings';

  @override
  Future<void> onApply() =>
      RegistryManager.writeDword(_developerSettingsKey, 'TaskbarEndTask', 1);

  @override
  Future<void> onRevert() =>
      RegistryManager.deleteValue(_developerSettingsKey, 'TaskbarEndTask');

  @override
  Future<bool> checkState() async =>
      await RegistryManager.readDword(
        _developerSettingsKey,
        'TaskbarEndTask',
      ) ==
      1;
}

class HideExplorerGalleryTweak extends SystemTweak {
  HideExplorerGalleryTweak()
    : super(
        id: 'ui_hide_explorer_gallery',
        title: 'Hide File Explorer Gallery',
        description: 'Hides the Gallery navigation item from File Explorer.',
        category: 'UI & Visuals',
        minimumWindowsBuild: 22631,
      );

  static const String _galleryKey =
      r'HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}';

  @override
  Future<void> onApply() => RegistryManager.writeDword(
    _galleryKey,
    'System.IsPinnedToNameSpaceTree',
    0,
  );

  @override
  Future<void> onRevert() => RegistryManager.deleteValue(
    _galleryKey,
    'System.IsPinnedToNameSpaceTree',
  );

  @override
  Future<bool> checkState() async =>
      await RegistryManager.readDword(
        _galleryKey,
        'System.IsPinnedToNameSpaceTree',
      ) ==
      0;
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
  }

  @override
  Future<void> onRevert() async {
    await runSilentPowerShell(r'''
cmd /c "reg delete \"HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\" /f >nul 2>&1"
cmd /c "reg delete \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\" /v \"NoCustomizeThisFolder\" /f >nul 2>&1"
cmd /c "reg delete \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\" /v \"{9F156763-7844-4DC4-B2B1-901F640F5155}\" /f >nul 2>&1"
cmd /c "reg delete \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\" /v \"{09A47860-11B0-4DA5-AFA5-26D86198A780}\" /f >nul 2>&1"
''', elevated: true);
  }

  @override
  Future<bool> checkState() async {
    final output = (await runPowerShellForOutput(r'''
$classic = Test-Path -LiteralPath 'Registry::HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
$policy = (Get-ItemProperty -LiteralPath 'Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -ErrorAction SilentlyContinue).NoCustomizeThisFolder -eq 1
$pinFolderRemoved = -not (Test-Path -LiteralPath 'Registry::HKEY_CLASSES_ROOT\Folder\shell\pintohome')
$pinFileRemoved = -not (Test-Path -LiteralPath 'Registry::HKEY_CLASSES_ROOT\*\shell\pintohomefile')
$blocked = Get-ItemProperty 'Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' -ErrorAction SilentlyContinue
$blockedOne = $null -ne $blocked.'{9F156763-7844-4DC4-B2B1-901F640F5155}'
$blockedTwo = $null -ne $blocked.'{09A47860-11B0-4DA5-AFA5-26D86198A780}'
$classic -and $policy -and $pinFolderRemoved -and $pinFileRemoved -and $blockedOne -and $blockedTwo
''')).toLowerCase();

    final applied = output.trim() == 'true';
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
  }

  @override
  Future<void> onRevert() async {
    await RegistryManager.writeString(_mouseKey, 'MouseSpeed', '1');
    await RegistryManager.writeString(_mouseKey, 'MouseThreshold1', '6');
    await RegistryManager.writeString(_mouseKey, 'MouseThreshold2', '10');
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
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(
      _policyKey,
      'LetAppsRunInBackground',
    );
    final applied = current == 2;
    return applied;
  }
}
