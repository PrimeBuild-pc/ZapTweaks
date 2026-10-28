/// The five built-in presets, from lightest to most aggressive. Every item
/// maps to a typed operation (preview, snapshot, rollback) except manual
/// third-party steps, which are only shown with their author and links.
library;

sealed class PresetItem {
  const PresetItem();

  /// Stable id, also used in exported user presets.
  String get key;
}

/// Store app removed for the current user (appxCandidatePolicy).
class AppPresetItem extends PresetItem {
  const AppPresetItem(this.packageName);
  final String packageName;
  @override
  String get key => 'app:$packageName';
}

/// Curated service set to Manual (3) or Disabled (4).
class ServicePresetItem extends PresetItem {
  const ServicePresetItem(this.name, this.startType);
  final String name;
  final int startType;
  @override
  String get key => 'service:$name';
}

/// Run-key entries turned off like Task Manager does.
class StartupPresetItem extends PresetItem {
  const StartupPresetItem(this.rule);
  final StartupRule rule;
  @override
  String get key => 'startup:${rule.id}';
}

/// Typed registry/power setting.
class TweakPresetItem extends PresetItem {
  const TweakPresetItem(this.operationId, this.desiredValue);
  final String operationId;
  final Object? desiredValue;
  @override
  String get key => 'tweak:$operationId';
}

/// Third-party step ZapTweaks does not run: shown with author and links.
class ManualPresetItem extends PresetItem {
  const ManualPresetItem(this.step);
  final ManualStep step;
  @override
  String get key => 'manual:${step.id}';
}

class StartupRule {
  const StartupRule(
    this.id,
    this.label, {
    this.exeNames = const <String>{},
    this.names = const <String>{},
  });

  final String id;
  final String label;

  /// Lowercase executable file names, e.g. `spotify.exe`.
  final Set<String> exeNames;

  /// Lowercase Run value names; a trailing `*` matches a prefix.
  final Set<String> names;

  bool matches(String name, String command) {
    final lower = name.toLowerCase();
    if (names.any(
      (n) => n.endsWith('*')
          ? lower.startsWith(n.substring(0, n.length - 1))
          : lower == n,
    )) {
      return true;
    }
    final exe = RegExp(
      r'([^\\/"]+\.exe)(?=["\s]|$)',
      caseSensitive: false,
    ).firstMatch(command.trim())?.group(1)?.toLowerCase();
    return exe != null && exeNames.contains(exe);
  }
}

class ManualStep {
  const ManualStep(this.id, {required this.author, required this.links});
  final String id;
  final String author;
  final List<String> links;
}

class Preset {
  const Preset(this.id, this.items, {this.attention = false, this.name});

  final String id;
  final List<PresetItem> items;

  /// Shown with a visible "Attention" risk and an explicit consent.
  final bool attention;

  /// Only for user presets; built-ins are named by [id].
  final String? name;

  bool get builtIn => name == null;
}

const startupRules = <String, StartupRule>{
  'edgeAutoLaunch': StartupRule(
    'edgeAutoLaunch',
    'Microsoft Edge',
    names: {'microsoftedgeautolaunch_*'},
  ),
  'spotify': StartupRule('spotify', 'Spotify', exeNames: {'spotify.exe'}),
  'teamsClassic': StartupRule(
    'teamsClassic',
    'Microsoft Teams (classic)',
    names: {'com.squirrel.teams.teams'},
  ),
  'skype': StartupRule('skype', 'Skype', exeNames: {'skype.exe'}),
  'adobeUpdaters': StartupRule(
    'adobeUpdaters',
    'Adobe updaters',
    names: {'adobeaamupdater-1.0', 'adobe gc invoker 1.0'},
    exeNames: {'agsservice.exe', 'adobegcclient.exe'},
  ),
  'itunesHelper': StartupRule(
    'itunesHelper',
    'iTunes Helper',
    exeNames: {'ituneshelper.exe'},
  ),
  'ccleaner': StartupRule(
    'ccleaner',
    'CCleaner',
    names: {'ccleaner smart cleaning', 'ccleaner monitoring'},
  ),
  'discord': StartupRule('discord', 'Discord', names: {'discord'}),
  'steam': StartupRule('steam', 'Steam', exeNames: {'steam.exe'}),
  'epic': StartupRule(
    'epic',
    'Epic Games Launcher',
    exeNames: {'epicgameslauncher.exe'},
  ),
  'eaApp': StartupRule('eaApp', 'EA app', exeNames: {'eadesktop.exe'}),
  'battleNet': StartupRule(
    'battleNet',
    'Battle.net',
    exeNames: {'battle.net.exe', 'battle.net launcher.exe'},
  ),
  'ubisoft': StartupRule(
    'ubisoft',
    'Ubisoft Connect',
    exeNames: {'upc.exe', 'ubisoftconnect.exe'},
  ),
  'oneDrive': StartupRule('oneDrive', 'OneDrive', exeNames: {'onedrive.exe'}),
};

const manualSteps = <String, ManualStep>{
  'driverClean': ManualStep(
    'driverClean',
    author: 'Fr33thy · Wagnardsoft (DDU)',
    links: <String>[
      'https://github.com/FR33THYFR33THY/Ultimate',
      'https://www.wagnardsoft.com/display-driver-uninstaller-ddu',
    ],
  ),
  'winsux': ManualStep(
    'winsux',
    author: 'Fr33thy',
    links: <String>['https://github.com/FR33THYFR33THY/WinSux'],
  ),
};

const _debloatApps = <String>[
  'Microsoft.WindowsFeedbackHub',
  'Microsoft.GetHelp',
  'Microsoft.Getstarted',
  'Microsoft.BingNews',
  'Microsoft.BingWeather',
  'Microsoft.MicrosoftSolitaireCollection',
  'Microsoft.ZuneVideo',
  'Clipchamp.Clipchamp',
  'Microsoft.MicrosoftOfficeHub',
  'Microsoft.PowerAutomateDesktop',
  'Microsoft.Windows.DevHome',
  'Microsoft.WindowsMaps',
  'MSTeams',
];

/// Competitive also removes apps many people use; Notepad, Paint and the
/// Snipping Tool always stay.
const _competitiveApps = <String>[
  'Microsoft.OutlookForWindows',
  'Microsoft.Todos',
  'Microsoft.MicrosoftStickyNotes',
  'Microsoft.WindowsAlarms',
  'Microsoft.WindowsSoundRecorder',
  'Microsoft.YourPhone',
  'MicrosoftWindows.CrossDevice',
  'MicrosoftCorporationII.QuickAssist',
  'Microsoft.Office.OneNote',
  'Microsoft.GamingApp',
  'Microsoft.XboxGamingOverlay',
];

const _cleanServices = <String>[
  'DiagTrack',
  'dmwappushservice',
  'WerSvc',
  'MapsBroker',
  'RetailDemo',
  'RemoteRegistry',
  'WMPNetworkSvc',
];

const _competitiveServices = <String>[
  'Fax',
  'Spooler',
  'PhoneSvc',
  'WpcMonSvc',
  'SEMgrSvc',
  'wisvc',
  'lfsvc',
  'icssvc',
  'TermService',
  'XblAuthManager',
  'XblGameSave',
  'XboxNetApiSvc',
  'SysMain',
  'PcaSvc',
];

const _cleanStartup = <String>[
  'edgeAutoLaunch',
  'spotify',
  'teamsClassic',
  'skype',
  'adobeUpdaters',
  'itunesHelper',
  'ccleaner',
];

const _competitiveStartup = <String>[
  'discord',
  'steam',
  'epic',
  'eaApp',
  'battleNet',
  'ubisoft',
  'oneDrive',
];

const _gamingTweaks = <TweakPresetItem>[
  TweakPresetItem('power_throttling_off', 1),
  TweakPresetItem('ui_taskbar_end_task', 1),
];

const _privacyTweaks = <TweakPresetItem>[
  TweakPresetItem('privacy.advertising_id_off', 0),
  TweakPresetItem('privacy.language_list_opt_out', 1),
  TweakPresetItem('privacy.app_launch_tracking_off', 0),
  TweakPresetItem('privacy.tailored_experiences_off', 1),
  TweakPresetItem('privacy.cloud_optimized_content_off', 1),
  TweakPresetItem('privacy.diagnostic_data_required', 1),
  TweakPresetItem('sparkle.privacy.overlay', 0),
  TweakPresetItem('sparkle.privacy.lock_screen', 0),
];

List<PresetItem> _apps(List<String> names) => <PresetItem>[
  for (final name in names) AppPresetItem(name),
];
List<PresetItem> _services(List<String> names) => <PresetItem>[
  for (final name in names) ServicePresetItem(name, 4),
];
List<PresetItem> _startup(List<String> ids) => <PresetItem>[
  for (final id in ids) StartupPresetItem(startupRules[id]!),
];

final List<PresetItem> _debloat = _apps(_debloatApps);
final List<PresetItem> _clean = <PresetItem>[
  ..._debloat,
  ..._services(_cleanServices),
  ..._startup(_cleanStartup),
];

final List<Preset> builtInPresets = <Preset>[
  Preset('debloat', _debloat),
  Preset('clean', _clean),
  Preset('gaming', <PresetItem>[..._clean, ..._gamingTweaks]),
  Preset('privacy', <PresetItem>[..._clean, ..._privacyTweaks]),
  Preset('competitive', <PresetItem>[
    ..._clean,
    ..._apps(_competitiveApps),
    ..._services(_competitiveServices),
    ..._startup(_competitiveStartup),
    ..._gamingTweaks,
    ..._privacyTweaks,
    const TweakPresetItem('gaming.game_dvr_off', 0),
    for (final step in manualSteps.values) ManualPresetItem(step),
  ], attention: true),
];
