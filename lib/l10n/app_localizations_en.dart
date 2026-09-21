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
      'Aggressive tweak. A restore point is recommended.';

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
  String get powerPlans => 'Power plans';

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

  @override
  String get restorePointPromptTitle => 'Create a restore point?';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks can create a Windows restore point before changing system settings. This is optional: skip it and the change is applied anyway. You are asked only once per session.';

  @override
  String get skip => 'Skip';

  @override
  String get continueAction => 'Continue';

  @override
  String get tweaksSectionHeader => 'TWEAKS';

  @override
  String get startingUp => 'Starting ZapTweaks';

  @override
  String get expertMode => 'Expert mode';

  @override
  String get expertModeDescription =>
      'Show advanced operations and external tools. Safety restrictions still apply.';

  @override
  String get searchOperations => 'Search operations';

  @override
  String get searchResults => 'Search results';

  @override
  String get operationTaskbarEndTaskTitle => 'Taskbar End task';

  @override
  String get operationTaskbarEndTaskDescription =>
      'Show End task in taskbar app context menus.';

  @override
  String get appStore => 'App store';

  @override
  String get appManagement => 'Installed apps';

  @override
  String get windowsAppTools => 'Windows app tools';

  @override
  String get optionalFeatures => 'Optional features';

  @override
  String get searchOptionalFeatures => 'Search optional features';

  @override
  String get scanOptionalFeatures => 'Scan features (UAC)';

  @override
  String get optionalFeaturesUacNotice =>
      'Feature inventory and each change run through the allowlisted helper. No change occurs during scanning.';

  @override
  String get confirmOptionalFeatureChange => 'Confirm optional feature change';

  @override
  String confirmOptionalFeatureChangeMessage(Object name, Object action) {
    return 'Feature: $name\nAction: $action\n\nWindows may require a restart. The previous enabled state is captured before the change.';
  }

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get enablePending => 'Enable pending restart';

  @override
  String get disablePending => 'Disable pending restart';

  @override
  String get startupApps => 'Startup apps';

  @override
  String get searchStartupApps => 'Search startup apps';

  @override
  String get openStartupSettings => 'Open Startup Settings';

  @override
  String get openTaskManagerStartup => 'Open Task Manager Startup';

  @override
  String get startupInventoryNotice =>
      'Read-only startup inventory. Use Windows Settings or Task Manager to change an entry.';

  @override
  String get guidedSetup => 'Guided setup';

  @override
  String get wizardInventory => 'Inventory';

  @override
  String get wizardBaseline => 'Baseline';

  @override
  String get wizardWindowsUpdate => 'Windows Update';

  @override
  String get wizardDrivers => 'Driver check';

  @override
  String get wizardApplications => 'Applications';

  @override
  String get wizardDebloat => 'Selective debloat';

  @override
  String get wizardPrivacyInterface => 'Privacy and interface';

  @override
  String get wizardPreview => 'Plan preview';

  @override
  String get wizardApply => 'Apply';

  @override
  String get wizardReport => 'Final report';

  @override
  String get wizardInventoryDescription =>
      'Read hardware, installed winget packages, and present devices before making choices.';

  @override
  String get runInventory => 'Run inventory';

  @override
  String inventorySummary(Object apps, Object devices) {
    return 'Detected $apps winget packages and $devices present devices.';
  }

  @override
  String get wizardUpdateNotice =>
      'Review Windows Update before driver and app changes. ZapTweaks does not install updates automatically.';

  @override
  String get openWindowsUpdate => 'Open Windows Update';

  @override
  String get updatesReviewed => 'I reviewed Windows Update';

  @override
  String driverInventorySummary(Object devices, Object missing) {
    return 'Present devices: $devices\nDevices without a bound INF: $missing';
  }

  @override
  String get wizardDebloatNotice =>
      'No debloat choice is implicit. Only current-user AppX packages with a verified restore source can be selected here; other removals remain available from App → Installed apps with a separate preview.';

  @override
  String get wizardPrivacyNotice =>
      'Privacy and interface settings remain unchanged unless selected explicitly below.';

  @override
  String get noAppsSelected =>
      'No operations selected. The wizard will make no changes.';

  @override
  String planContains(Object count) {
    return 'The plan contains $count explicit operation(s):';
  }

  @override
  String readyToApply(Object count) {
    return 'Ready to apply $count app operation(s). Each package is verified after winget completes.';
  }

  @override
  String get noPlanReport => 'Finished without applying a plan.';

  @override
  String get planStatus => 'Plan status';

  @override
  String get applyPlan => 'Apply plan';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get recovery => 'Recovery';

  @override
  String get diagnosticTools => 'Diagnostic tools';

  @override
  String get repairComponentStore => 'Repair Windows component store';

  @override
  String get repairComponentStoreDescription =>
      'Runs DISM RestoreHealth, then a separate ScanHealth verification. This can take a long time.';

  @override
  String get repairSystemFiles => 'Repair protected system files';

  @override
  String get repairSystemFilesDescription =>
      'Runs SFC scan and repair, then a separate verification pass.';

  @override
  String get confirmSystemRepair => 'Confirm Windows repair';

  @override
  String get systemRepairWarning =>
      'The repair may replace corrupted Windows components and cannot be rolled back by ZapTweaks. Do not turn off the PC while it runs.';

  @override
  String get systemRepairVerified =>
      'Repair completed and the verification pass succeeded.';

  @override
  String get runRepair => 'Run repair';

  @override
  String get operationCompleted => 'Operation completed';

  @override
  String get captureEtwTrace => 'Capture performance trace';

  @override
  String get captureEtwTraceDescription =>
      'Records a bounded 15-second Windows Performance Recorder trace on demand. No monitor remains active.';

  @override
  String etwTraceSaved(Object path) {
    return 'Trace saved to $path';
  }

  @override
  String get hardwareMonitor => 'Hardware monitor';

  @override
  String get dedicatedVramUsage => 'Dedicated GPU memory in use';

  @override
  String get dedicatedVramUsageDescription =>
      'Takes one Windows GPU performance-counter snapshot. Nothing keeps running afterward.';

  @override
  String vramUsageValue(Object megabytes) {
    return '$megabytes MB';
  }

  @override
  String get captureNow => 'Capture now';

  @override
  String get tweaks => 'Tweaks';

  @override
  String get searchPowerPlans => 'Search power plans';

  @override
  String get activePowerPlan => 'Active';

  @override
  String get activate => 'Activate';

  @override
  String get details => 'Details';

  @override
  String get compare => 'Compare';

  @override
  String get noPowerDifferences => 'No AC/DC value differences were found.';

  @override
  String get importPowerPlan => 'Import .pow';

  @override
  String get importPowerPlanDescription =>
      'Imports one locally selected power plan after bounded, hash-verified staging.';

  @override
  String get exportActivePowerPlan => 'Export active plan';

  @override
  String get renamePowerPlan => 'Rename power plan';

  @override
  String get renamePowerPlanDescription =>
      'Changes only the selected plan\'s display name and preserves the original name for rollback.';

  @override
  String get rename => 'Rename';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get duplicatePowerPlan => 'Duplicate power plan';

  @override
  String get duplicatePowerPlanDescription =>
      'Creates and verifies a PowrProf copy. Rollback is best effort because Windows assigns its GUID during creation.';

  @override
  String get apply => 'Apply';

  @override
  String get edit => 'Edit';

  @override
  String powerValueRange(int maximum) {
    return 'Values must be between 0 and $maximum.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deletePowerPlan => 'Delete power plan';

  @override
  String get deletePowerPlanDescription =>
      'Exports the selected inactive plan before deleting it and preserves the backup for exact rollback.';

  @override
  String deletePowerPlanWarning(Object name) {
    return 'Delete $name? ZapTweaks will export a recovery copy first.';
  }

  @override
  String get firmwareTemperatures => 'Firmware thermal zones';

  @override
  String get firmwareTemperaturesDescription =>
      'Reads ACPI thermal zones once. Availability and sensor meaning depend on the PC firmware; values are not labeled as CPU or GPU temperatures.';

  @override
  String get noThermalSensors =>
      'No ACPI thermal zones were exposed by this PC.';

  @override
  String get driverInventory => 'Driver Store inventory';

  @override
  String get installLocalDriver => 'Install a local driver package';

  @override
  String get installLocalDriverDescription =>
      'Verify a local INF, its signed catalog, and hardware compatibility before installation.';

  @override
  String get selectDevice => 'Select a present device';

  @override
  String get localInfPath => 'Absolute path to the local .inf file';

  @override
  String get verifyDriverPackage => 'Verify package';

  @override
  String verifiedDriverPublisher(Object publisher, Object sha256) {
    return 'Verified publisher: $publisher\nINF SHA-256: $sha256';
  }

  @override
  String get confirmLocalDriverInstall => 'Confirm local driver installation';

  @override
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  ) {
    return 'Device: $device\nSigned publisher: $publisher\nINF SHA-256: $sha256\n\nWindows may change the active driver and require a restart. Rollback is best effort.';
  }

  @override
  String get driverTools => 'Assisted flows';

  @override
  String get temporaryDriverUpdatesPause =>
      'Temporarily exclude drivers from Windows quality updates';

  @override
  String get temporaryDriverUpdatesPauseDescription =>
      'Uses the documented Windows Update policy for 7 or 30 days. ZapTweaks records the exact previous value and shows a reminder when the pause expires; restoration requires your confirmation.';

  @override
  String get driverUpdatePauseActive => 'Driver update pause active';

  @override
  String get driverUpdatePauseExpired =>
      'Driver update pause expired — restore the previous policy';

  @override
  String driverUpdatePauseUntil(Object date) {
    return 'Scheduled expiration: $date';
  }

  @override
  String get pauseSevenDays => 'Pause for 7 days';

  @override
  String get pauseThirtyDays => 'Pause for 30 days';

  @override
  String get restoreDriverUpdates => 'Restore previous policy';

  @override
  String get assistedDriverFlows => 'Verified and assisted driver flows';

  @override
  String get assistedDriverFlowsDescription =>
      'ZapTweaks opens only vendor-owned sources and Windows surfaces. It does not run mutable remote scripts, flash firmware, or silently remove driver components.';

  @override
  String get amdDriverFlow => 'AMD drivers and software';

  @override
  String get amdDriverFlowDescription =>
      'Open AMD\'s official driver selector. Verify the detected product before downloading.';

  @override
  String get nvidiaDriverFlow => 'NVIDIA drivers';

  @override
  String get nvidiaDriverFlowDescription =>
      'Open NVIDIA\'s official manual driver search. Clean installation remains an explicit vendor-installer choice.';

  @override
  String get intelDriverFlow => 'Intel Driver & Support Assistant';

  @override
  String get intelDriverFlowDescription =>
      'Open Intel\'s official detection and support flow.';

  @override
  String get windowsOptionalDrivers => 'Windows optional driver updates';

  @override
  String get windowsOptionalDriversDescription =>
      'Review optional driver updates in Windows Settings; nothing is selected automatically.';

  @override
  String get deviceManager => 'Device Manager';

  @override
  String get deviceManagerDescription =>
      'Inspect devices, status codes, active drivers, and manual rollback options.';

  @override
  String get openOfficialSource => 'Open official source';

  @override
  String get searchDrivers => 'Search Driver Store';

  @override
  String get driverStoreSafetyNotice =>
      'Only signed, unbound third-party packages can be removed here. ZapTweaks exports and hashes the package first; restoration is best effort because Windows may assign a different published name.';

  @override
  String get signed => 'Signed';

  @override
  String get unsigned => 'Unsigned';

  @override
  String get driverInUse => 'In use';

  @override
  String get driverUnbound => 'Unbound';

  @override
  String get exportAndRemove => 'Export and remove';

  @override
  String get confirmDriverRemoval => 'Confirm Driver Store removal';

  @override
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  ) {
    return 'Published name: $published\nOriginal INF: $inf\nPublisher: $publisher\nVersion: $version\n\nZapTweaks will export and hash the package before removal. A restart may be required; restoration is best effort.';
  }

  @override
  String get searchInstalledApps => 'Search installed apps';

  @override
  String get scanAllUsers => 'Scan all users (UAC)';

  @override
  String get systemScopesComplete =>
      'All-user and provisioned AppX scopes are included.';

  @override
  String get systemScopesIncomplete =>
      'Current-user and winget inventory only. Scan all users to include system AppX scopes.';

  @override
  String get currentUser => 'Current user';

  @override
  String get allUsers => 'All users';

  @override
  String get provisioned => 'Provisioned';

  @override
  String get confirmAppxRemoval => 'Confirm AppX removal';

  @override
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  ) {
    return 'App: $name\nIdentity: $id\nScope: $scope\nRecovery: $recovery\n\nOnly the listed scope will be removed. This operation has no exact rollback.';
  }

  @override
  String get reinstallable => 'Verified restore source available';

  @override
  String get notReinstallable => 'No verified restore source';

  @override
  String get searchApps => 'Search apps';

  @override
  String get allCategories => 'All categories';

  @override
  String get installedOnly => 'Installed only';

  @override
  String get refreshInventory => 'Refresh inventory';

  @override
  String get install => 'Install';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get uninstallSelected => 'Uninstall selected';

  @override
  String get openOfficialPage => 'Open official page';

  @override
  String get installed => 'Installed';

  @override
  String get notInstalled => 'Not installed';

  @override
  String get appInventoryUnavailable =>
      'Installed-app detection is unavailable.';

  @override
  String get confirmBulkUninstall => 'Confirm bulk uninstall';

  @override
  String confirmBulkUninstallMessage(Object apps) {
    return 'The following apps will be uninstalled:\n\n$apps';
  }

  @override
  String get appCatalogSources =>
      'Catalog merged from pinned CTT WinUtil, clean-room Winhance candidates, TweakHub, and requested official sources.';
}
