// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the language used by ZapTweaks.';

  @override
  String get settings => 'Settings';

  @override
  String get startWithWindows => 'Start with Windows';

  @override
  String get startWithWindowsDescription =>
      'Launch ZapTweaks after you sign in to Windows.';

  @override
  String get openLogFolder => 'Open log folder';

  @override
  String get redetectSystemState => 'Re-detect system state';

  @override
  String get exportProfile => 'Export profile';

  @override
  String get importProfile => 'Import profile';

  @override
  String get resetAppSettings => 'Reset app settings';

  @override
  String get updates => 'Updates';

  @override
  String get automaticUpdateNotifications => 'Automatic update notifications';

  @override
  String get automaticUpdateDescription =>
      'Check at startup and show a notification dot. Updates are never installed automatically.';

  @override
  String get checking => 'Checking...';

  @override
  String get checkNow => 'Check now';

  @override
  String get viewRelease => 'View release';

  @override
  String get updateNow => 'Update now';

  @override
  String get applicationVersion => 'Application version';

  @override
  String get dryRunMode => 'Dry-run mode';

  @override
  String get dryRunDescription => 'Simulate commands without changing Windows.';

  @override
  String get done => 'Done';

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get updateAvailable => 'An update is available';

  @override
  String get updateAvailableDescription =>
      'You can review the release notes or install it directly.';

  @override
  String get updateAvailableShort => 'Update available';

  @override
  String get checkingForUpdates => 'Checking for updates';

  @override
  String get contactingReleaseServer => 'Contacting the release server...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version is available';
  }

  @override
  String installedVersion(Object version) {
    return 'Installed version: $version';
  }

  @override
  String get releaseNotesOnGitHub => 'Release notes are available on GitHub.';

  @override
  String get later => 'Later';

  @override
  String get failed => 'Failed';

  @override
  String get downloadingUpdate => 'Downloading update';

  @override
  String get downloadingUpdateDescription =>
      'Downloading and preparing the installer...';

  @override
  String get adminPrivilegesRequired => 'Administrator privileges are required';

  @override
  String get adminRequiredBanner =>
      'Close the app and launch ZapTweaks with \"Run as administrator\". Without elevation, system tweaks cannot be applied safely.';

  @override
  String get cancel => 'Cancel';

  @override
  String get createRestorePoint => 'Create restore point';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks needs administrator permissions to apply system settings.\n\nClose the app, right-click the executable, and select \"Run as administrator\".';

  @override
  String get understood => 'Understood';

  @override
  String aboutVersion(Object version) {
    return 'Version: v$version';
  }

  @override
  String get author => 'Author: PrimeBuild';

  @override
  String get aboutDescription =>
      'Advanced optimization companion for deeper Windows gaming, hardware, and diagnostics workflows.';

  @override
  String year(Object year) {
    return 'Year: $year';
  }

  @override
  String get close => 'Close';

  @override
  String get github => 'GitHub';

  @override
  String get discord => 'Discord';

  @override
  String get homeAndStats => 'Home & Stats';

  @override
  String get cpuUsage => 'CPU Usage';

  @override
  String get cpuUsageDescription =>
      'Realtime utilization from Windows counters';

  @override
  String get gpuUsage => 'GPU Usage';

  @override
  String get gpuUsageDescription => 'Realtime engine utilization';

  @override
  String get vramUsage => 'VRAM Usage';

  @override
  String get memoryUsage => 'Memory Usage';

  @override
  String get unknown => 'Unknown';

  @override
  String get installedRam => 'Installed RAM';

  @override
  String get networkAdapters => 'Network Adapters';

  @override
  String get noConnectedAdapters => 'No connected adapters detected';

  @override
  String get audioDevices => 'Audio Devices';

  @override
  String get noAudioDevices => 'No audio devices detected';

  @override
  String get noTweaksAvailable =>
      'No tweaks are available for your hardware configuration.';

  @override
  String get detectedHardware => 'Detected hardware';

  @override
  String get gpuUnknown => 'GPU: Unknown';

  @override
  String cpuValue(Object value) {
    return 'CPU: $value';
  }

  @override
  String gpuValue(Object value) {
    return 'GPU: $value';
  }

  @override
  String ramValue(Object value) {
    return 'RAM: $value';
  }

  @override
  String get enableAllVisible => 'Enable all visible';

  @override
  String get disableAllVisible => 'Disable all visible';

  @override
  String get restartNow => 'Restart now';

  @override
  String get restartRequired => 'Restart required';

  @override
  String get restartRequiredDescription =>
      'A system restart is required to fully apply one or more changes.';

  @override
  String get advancedActionsIncluded => 'Advanced actions included';

  @override
  String get advancedActionsDescription =>
      'External tools, launcher actions, and script-driven utilities are grouped here for quick diagnostics and maintenance workflows.';

  @override
  String get aggressiveTweakWarning =>
      'Aggressive tweak. A restore point is mandatory.';

  @override
  String get networkReconnectWarning =>
      'Network adapter reconnect or system restart may be required.';

  @override
  String get actionWarning => 'Action warning';

  @override
  String get unknownError => 'Unknown error.';

  @override
  String get presets => 'Presets';

  @override
  String get presetFailed => 'Preset failed';

  @override
  String get safetyWarning => 'Safety warning';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get powerPlans => 'Bundled Power Plans';

  @override
  String get powerPlansDescription =>
      'Import and activate a bundled plan. ZapTweaks remembers the previous active plan for restore.';

  @override
  String get noPowerPlans => 'No bundled power plans were found.';

  @override
  String get working => 'Working...';

  @override
  String get importAndActivate => 'Import and activate';

  @override
  String get restorePreviousPlan => 'Restore previous plan';

  @override
  String get ran => 'Ran';

  @override
  String get gpuDrivers => 'GPU Drivers';

  @override
  String get noGpuDrivers => 'No GPU drivers detected';

  @override
  String get chipsetDrivers => 'Chipset Drivers';

  @override
  String get noChipsetDrivers => 'No chipset drivers detected';

  @override
  String get monitors => 'Monitors';

  @override
  String get noMonitors => 'No monitors detected';

  @override
  String get mice => 'Mice';

  @override
  String get noMice => 'No mice detected';

  @override
  String get keyboards => 'Keyboards';

  @override
  String get noKeyboards => 'No keyboards detected';
}
