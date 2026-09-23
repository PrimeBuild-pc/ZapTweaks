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
  String get appearance => 'Appearance';

  @override
  String get appearanceDescription =>
      'Follow Windows or use a fixed light or dark app theme.';

  @override
  String get themeSystem => 'Windows default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

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
  String get powerPlans => 'Power Settings Explorer';

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
  String get searchSections => 'Sections and integrated tools';

  @override
  String get searchApps => 'Search apps';

  @override
  String get searchCatalog => 'Operations and external tools';

  @override
  String get searchOpenResult => 'Open';

  @override
  String get searchExpertRequired => 'Enable Expert mode to open';

  @override
  String get noSearchResults =>
      'No matching sections, apps, operations, or tools.';

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
      'Records a bounded Windows Performance Recorder trace and produces a DPC/ISR diagnostic report on demand. No monitor remains active.';

  @override
  String get dpcLatencyAnalyzer => 'DPC / ISR latency analyzer';

  @override
  String get dpcLatencyAnalyzerDescription =>
      'Captures ETW on demand and reports DPC, ISR, hard-fault and context-switch activity, per-processor distribution, observed kernel-module names and ETW providers.';

  @override
  String get diagnosticNotCausality =>
      'Diagnostic signal, not a latency verdict';

  @override
  String get diagnosticNotCausalityDescription =>
      'Counts and observed module names help narrow an investigation but do not prove that a driver caused latency. Confirm with repeatable A/B/A traces and WPA or vendor tooling.';

  @override
  String get startDpcCapture => 'Start capture';

  @override
  String get openTraceFolder => 'Open trace folder';

  @override
  String captureInProgress(int seconds) {
    return 'Capturing for $seconds seconds… keep the workload running.';
  }

  @override
  String get traceDuration => 'Observed duration';

  @override
  String get hardFaults => 'Hard faults';

  @override
  String get contextSwitches => 'Context switches';

  @override
  String get totalEvents => 'Total ETW events';

  @override
  String get kernelModulesObserved =>
      'Kernel modules observed in DPC/ISR events';

  @override
  String get noKernelModulesObserved =>
      'The exported events did not expose kernel module names. Open the ETL in WPA for symbol-aware analysis.';

  @override
  String get dpcIsrByProcessor => 'DPC/ISR events by logical processor';

  @override
  String get noProcessorDistribution =>
      'Processor IDs were not present in the exported events.';

  @override
  String get topEtwProviders => 'Top ETW providers';

  @override
  String get noProviderData => 'No provider data was available.';

  @override
  String etwTraceSaved(Object path) {
    return 'Trace saved to $path';
  }

  @override
  String get cleanupDiagnosticTraces => 'Delete diagnostic traces';

  @override
  String get cleanupDiagnosticTracesDescription =>
      'Scans only ZapTweaks trace files, shows the exact file count and byte total, then deletes them after confirmation.';

  @override
  String cleanupTracePreview(int count, int bytes) {
    return 'Delete $count ZapTweaks trace files ($bytes bytes)? This cannot be undone.';
  }

  @override
  String get cleanupTracesCompleted =>
      'The previewed diagnostic traces were deleted and verified absent.';

  @override
  String get noDiagnosticTraces => 'No ZapTweaks diagnostic traces were found.';

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
  String get restoreDefaultPowerSchemes => 'Restore Windows defaults';

  @override
  String get restoreDefaultPowerSchemesDescription =>
      'Exports and hashes every current scheme before asking Windows to restore its defaults.';

  @override
  String get restoreDefaultPowerSchemesWarning =>
      'Replace all current power schemes with Windows defaults? ZapTweaks will first export every scheme for exact rollback.';

  @override
  String get interruptConfiguration => 'MSI Utility v3 & Interrupt Affinity';

  @override
  String get interruptConfigurationDescription =>
      'Advanced, capability-gated MSI and group-0 interrupt-affinity controls for present display, network, media, USB host, and HD audio devices. No value is recommended automatically.';

  @override
  String get configureMsi => 'Configure MSI';

  @override
  String get enableMsi => 'Enable message-signaled interrupts';

  @override
  String get configureInterruptAffinity => 'Configure affinity';

  @override
  String get interruptChangeWarning =>
      'An invalid interrupt policy can make the device unavailable until rollback or reboot. ZapTweaks validates hardware limits and snapshots the exact current values.';

  @override
  String get affinityMaskHint => 'Group-0 hexadecimal mask, for example 3';

  @override
  String get invalidAffinityMask =>
      'Enter a non-zero canonical hexadecimal mask of at most 64 bits.';

  @override
  String msiRange(int maximum) {
    return 'Message count must be between 1 and $maximum.';
  }

  @override
  String get noCompatibleInterruptDevices =>
      'No present display, network, media, USB host, or HD audio PCI device exposes compatible interrupt capabilities.';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return 'Hardware: Line $line · MSI $msi · MSI-X $msix · maximum messages $maximum';
  }

  @override
  String get messageNumberLimit => 'Message number limit';

  @override
  String get interruptPriority => 'Interrupt priority policy';

  @override
  String get interruptPriorityDefault => 'Undefined / driver default';

  @override
  String get interruptPriorityLow => 'Low';

  @override
  String get interruptPriorityNormal => 'Normal';

  @override
  String get interruptPriorityHigh => 'High';

  @override
  String get interruptPolicy => 'Processor affinity policy';

  @override
  String get interruptPolicyDefault => 'Machine default';

  @override
  String get interruptPolicyAllClose => 'All close processors';

  @override
  String get interruptPolicyOneClose => 'One close processor';

  @override
  String get interruptPolicyAllProcessors => 'All processors';

  @override
  String get interruptPolicySpecified => 'Specified processors (group 0)';

  @override
  String get interruptPolicySpread => 'Spread messages across processors';

  @override
  String get selectLogicalProcessors =>
      'Select logical processors in processor group 0';

  @override
  String get compatibleDevices => 'Compatible devices';

  @override
  String get msiEnabledDevices => 'MSI currently enabled';

  @override
  String get logicalProcessors => 'Logical processors';

  @override
  String get searchDevices => 'Search devices, instance IDs, or driver INF';

  @override
  String get driverUnknown => 'Driver INF unavailable';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return 'Current: $mode · messages $messages · priority $priority · policy $policy · mask $mask';
  }

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
  String get powerSettingConfigure => 'Configure any bounded power setting';

  @override
  String get powerSettingConfigureDescription =>
      'Edits a setting exposed by PowrProf only when Windows provides live minimum, maximum, and increment metadata.';

  @override
  String get searchPowerSettings =>
      'Search settings, descriptions, subgroups, or GUIDs';

  @override
  String get allPowerSubgroups => 'All power-setting groups';

  @override
  String powerSettingCount(int count) {
    return '$count settings';
  }

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Range $minimum–$maximum, step $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows did not expose safe edit bounds for this setting.';

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
  String get driverUpdatePolicy => 'Windows Update driver policy';

  @override
  String get driverUpdatePolicyDescription =>
      'Exclude device drivers from Windows quality updates for 7 days, 30 days, or until you explicitly restore the exact previous policy.';

  @override
  String get disableUntilRestored => 'Disable until restored';

  @override
  String get driverUpdatePausePermanent =>
      'Driver updates remain excluded until you restore the previous policy.';

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
  String get openWindowsPanel => 'Open Windows panel';

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
