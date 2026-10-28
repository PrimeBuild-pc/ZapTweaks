// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get externalDownload => 'External download';

  @override
  String get appRequirements => 'Requirements';

  @override
  String get appWarnings => 'Warnings';

  @override
  String get metricUnavailable => 'N/A';

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
      'Show advanced operations and external tools only after explicit manual consent. It is off by default; safety restrictions still apply.';

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
  String get affinitySelectAll => 'All logical processors';

  @override
  String get affinityClear => 'Clear';

  @override
  String get affinityPhysicalCores => 'One thread per physical core';

  @override
  String get affinityPerformanceCores => 'Performance cores';

  @override
  String get affinityEfficiencyCores => 'Efficiency cores';

  @override
  String get affinityParked => 'parked';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'NUMA node $index';
  }

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
  String powerSettingOptions(int count) {
    return '$count Windows-defined options';
  }

  @override
  String get backToPowerPlans => 'Back to power plans';

  @override
  String get powerPlanEditorHint =>
      'Duplicate a plan to create your custom profile, then open Details and edit its hidden AC/DC settings one by one.';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Range $minimum–$maximum, step $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows did not expose safe values or bounds for this setting.';

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
  String get cpuFrequency => 'CPU clock and core parking';

  @override
  String get cpuFrequencyDescription =>
      'Takes one sample of the Windows processor performance counters. The effective clock is the base clock × % Processor Performance, the same formula as Task Manager. Use it to check power plan, boost and core parking changes. Read-only.';

  @override
  String cpuEffectiveClock(Object mhz, Object nominal) {
    return '$mhz MHz effective · base $nominal MHz';
  }

  @override
  String cpuParkedCount(Object parked, Object total) {
    return '$parked of $total logical processors parked';
  }

  @override
  String get cpuParked => 'parked';

  @override
  String get cpuFrequencySource =>
      'Source: Processor Information performance counters (Win32_PerfFormattedData_Counters_ProcessorInformation), one sample averaged over the last counter interval. Not a peak clock. Per-core values use one nominal clock, so efficiency cores of hybrid CPUs read high.';

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

  @override
  String get tcpOptimizer => 'TCP Optimizer';

  @override
  String get tcpOptimizerDescription =>
      'Inspect and configure Windows TCP templates, global offloads, per-application QoS, and repeatable network diagnostics.';

  @override
  String get tcpNoRecommendation =>
      'No value is recommended automatically. A read-back or one network test does not prove a performance benefit.';

  @override
  String get tcpLiveState => 'Live TCP state';

  @override
  String get tcpTemplates => 'TCP templates';

  @override
  String get tcpGlobal => 'Global TCP offloads';

  @override
  String get tcpAutotuning => 'Receive-window autotuning';

  @override
  String get tcpHeuristics => 'Window-scaling heuristics';

  @override
  String get tcpEcn => 'ECN capability';

  @override
  String get tcpCongestion => 'Congestion control';

  @override
  String get tcpRsc => 'Receive segment coalescing (RSC)';

  @override
  String get tcpRss => 'Global receive-side scaling (RSS)';

  @override
  String get tcpConfigure => 'Configure';

  @override
  String get tcpChangePreview => 'TCP change preview';

  @override
  String get tcpCurrentValue => 'Current value';

  @override
  String get tcpNewValue => 'New value';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks will snapshot the exact current value, apply with one UAC request, read it back, journal it, and preserve exact rollback.';

  @override
  String get tcpUnsupported => 'Not exposed by this Windows build';

  @override
  String get tcpAdapterRss => 'Open per-adapter RSS controls';

  @override
  String get rssAdapterState => 'Per-adapter RSS state';

  @override
  String get rssEnabled => 'RSS enabled';

  @override
  String get rssProfile => 'RSS profile';

  @override
  String get rssQueuesProcessors => 'Queues/processors';

  @override
  String get tcpSettingOperationTitle => 'Configure TCP setting';

  @override
  String get tcpSettingOperationDescription =>
      'Changes one capability-gated Windows TCP template or global offload value with exact rollback.';

  @override
  String get qosPolicies => 'Application QoS policies';

  @override
  String get qosDescription =>
      'Create explicit persistent QoS policies for one executable. Existing non-ZapTweaks policies remain read-only.';

  @override
  String get qosCreate => 'Create policy';

  @override
  String get qosEdit => 'Edit';

  @override
  String get qosDelete => 'Delete';

  @override
  String get qosName => 'Policy name';

  @override
  String get qosAppPath => 'Executable path';

  @override
  String get qosProtocol => 'Protocol';

  @override
  String get qosSourcePort => 'Source port (optional)';

  @override
  String get qosDestinationPort => 'Destination port (optional)';

  @override
  String get qosDscp => 'DSCP 0–63 (optional)';

  @override
  String get qosThrottleMbps => 'Throttle Mbit/s (optional)';

  @override
  String get qosOwnedOnly =>
      'Names must start with “ZapTweaks - ”. Only the selected policy is changed; unrelated QoS policies are never cleared.';

  @override
  String get qosDeleteConfirm =>
      'Delete the selected QoS policy? Its exact state is stored in the ZapTweaks journal for rollback.';

  @override
  String get qosReadOnly => 'Read-only';

  @override
  String get qosPolicyOperationTitle => 'Configure application QoS';

  @override
  String get qosPolicyOperationDescription =>
      'Creates, edits, or removes one validated persistent per-application QoS policy with exact rollback.';

  @override
  String get networkDiagnostics => 'Before/after diagnostics';

  @override
  String get networkDiagnosticsDescription =>
      'Measure bounded TCP connection latency, jitter, loss, and HTTPS download throughput. Results are diagnostic evidence, not a recommendation.';

  @override
  String get diagnosticEndpoint => 'Direct HTTPS test-file URL';

  @override
  String get diagnosticNetworkCost =>
      'The test downloads at most 10 MiB from the endpoint you enter. No third-party endpoint is built in.';

  @override
  String get diagnosticBaseline => 'Run baseline';

  @override
  String get diagnosticComparison => 'Run comparison';

  @override
  String get diagnosticCancel => 'Cancel measurement';

  @override
  String get diagnosticLatency => 'Latency';

  @override
  String get diagnosticJitter => 'Jitter';

  @override
  String get diagnosticPacketLoss => 'Packet loss';

  @override
  String get diagnosticThroughput => 'Throughput';

  @override
  String get diagnosticRawSamples => 'Raw latency samples';

  @override
  String get diagnosticDownloadedBytes => 'Downloaded bytes';

  @override
  String get diagnosticDifference => 'Difference B − A';

  @override
  String get tcpAttribution =>
      'Inspired by WINSPAR — powplowdevs (frozen revision)';

  @override
  String get openRecoveryHistory => 'Open recovery and journal';

  @override
  String get manualRestoreTitle => 'Restore original manual settings';

  @override
  String get manualRestoreWarning =>
      'Restore the recorded originals, not defaults. Changed settings are not overwritten. High-risk settings require Expert mode and UAC. Review the journal after restoration; restart or sign-out requirements still apply.';

  @override
  String get cleanupUserTemp => 'UserTemp cleanup';

  @override
  String get cleanupUserTempDescription =>
      'Review and select exact files in the current user\'s Temp directory. No automatic selection, forced deletion or directory removal.';

  @override
  String get cleanupSelectFiles => 'Preview and select files';

  @override
  String get cleanupShaderCache => 'GPU shader cache cleanup';

  @override
  String get cleanupShaderCacheDescription =>
      'Previews the DirectX, AMD, NVIDIA and Intel shader caches of the current user, folder by folder, and deletes exactly the files found by that preview. The driver rebuilds them, so the first launch of each game can stutter. Close games first. Not reversible.';

  @override
  String get cleanupShaderCacheNone => 'No GPU shader cache files were found.';

  @override
  String get cleanupShaderCacheCompleted =>
      'The previewed shader cache files were deleted and verified absent.';

  @override
  String get cleanupPreview => 'Preview';

  @override
  String get cleanupUserTempNone => 'No UserTemp files found.';

  @override
  String get cleanupPermanentWarning =>
      'Permanent deletion. No rollback or permission/lock override. Close applications first. If deletion fails, earlier files may already have been removed.';

  @override
  String get cleanupUserTempSelectionHint =>
      'Nothing is selected. Select only files you recognize; files created after this preview are excluded.';

  @override
  String cleanupPreviewCount(int count, int bytes) {
    return '$count files, $bytes bytes';
  }

  @override
  String get cleanupRecycleUnavailable =>
      'Recycle Bin cleanup is unavailable: exact item identities cannot be previewed and deleted safely. No empty-all action is performed.';

  @override
  String get cleanupCrashReports => 'Crash dumps and error reports';

  @override
  String get cleanupCrashReportsDescription =>
      'Deletes the crash dumps of your programs (%LOCALAPPDATA%\\CrashDumps) and your Windows Error Reporting archive and queue. Useful after a game or app crashed many times. System minidumps (blue screens) are not touched.';

  @override
  String get cleanupCrashReportsNone =>
      'No crash dumps or error reports to delete.';

  @override
  String get cleanupCrashReportsCompleted =>
      'Crash dumps and error reports deleted.';

  @override
  String get cleanupBrowserCache => 'Browser caches';

  @override
  String get cleanupBrowserCacheDescription =>
      'Deletes the disk caches of Chrome, Edge, Brave (every profile) and Firefox. Cookies, history, passwords and extensions are not touched; pages load a little slower the first time.';

  @override
  String get cleanupBrowserCacheNone => 'No browser cache files to delete.';

  @override
  String get cleanupBrowserCacheCompleted => 'Browser caches deleted.';

  @override
  String cleanupBrowserRunning(String browsers) {
    return 'Close $browsers first (also from the system tray: Edge and Chrome can keep running in the background).';
  }

  @override
  String thermalZoneLimited(String percent) {
    return 'firmware limits the CPU to $percent%';
  }

  @override
  String get thermalSourceCounters =>
      'Source: Windows \"Thermal Zone Information\" counters (ACPI zones defined by the firmware, no administrator rights needed). A zone is a sensor the manufacturer chose; it is often not the CPU die.';

  @override
  String get thermalSourceAcpi =>
      'Source: MSAcpi_ThermalZoneTemperature (ACPI zones defined by the firmware). A zone is a sensor the manufacturer chose; it is often not the CPU die.';

  @override
  String get thermalSourceNone =>
      'The firmware of this PC exposes no ACPI thermal zone (common on desktop boards). Nothing is shown rather than a value that was not measured.';

  @override
  String get srumTab => 'App history';

  @override
  String get srumTitle => 'App history (SRUM)';

  @override
  String get srumDescription =>
      'Network, CPU and disk use of every program in the last 30 days, as recorded by Windows (System Resource Usage Monitor). Read-only: ZapTweaks reads a shadow copy of the database and deletes it afterwards. Needs administrator rights.';

  @override
  String get srumRead => 'Read history';

  @override
  String get srumNotCollectingTitle => 'Windows is not recording app history';

  @override
  String srumNotCollecting(String status, String startType, String date) {
    return 'The Diagnostic Policy Service, which records this history, is $status ($startType). The data ends on $date.';
  }

  @override
  String get srumNoData => 'No usage recorded in the last 30 days.';

  @override
  String get srumNetwork => 'Network (sent / received)';

  @override
  String get srumCpu =>
      'CPU time (share of all programs; part used in the background)';

  @override
  String srumCpuShare(String share, String background) {
    return '$share% · $background% background';
  }

  @override
  String get srumUnattributed => 'Not attributed to a program';

  @override
  String srumSource(String first, String last) {
    return 'Source: C:\\Windows\\System32\\sru\\SRUDB.dat, records from $first to $last. Windows writes them about once an hour.';
  }

  @override
  String get manualControls => 'Manual controls';

  @override
  String upToDate(String version) {
    return 'You are running the latest version ($version).';
  }

  @override
  String get startCapture => 'Start capture';

  @override
  String get batteryHealth => 'Battery health';

  @override
  String get batteryHealthDescription =>
      'Capacity the battery still holds compared with its design. Read-only.';

  @override
  String get batteryGood => 'Good';

  @override
  String get batteryFair => 'Worn';

  @override
  String get batteryPoor => 'Replace soon';

  @override
  String get notAvailable => 'Not available';

  @override
  String get batteryDesigned => 'Design capacity';

  @override
  String get batteryFullCharge => 'Full charge capacity';

  @override
  String get batteryWear => 'Wear';

  @override
  String get batteryCycles => 'Charge cycles';

  @override
  String get batteryCharge => 'Current charge';

  @override
  String get batteryOnAc => 'Plugged in';

  @override
  String get batteryOnBattery => 'On battery';

  @override
  String get batterySourceWmi =>
      'Source: root\\wmi BatteryStaticData, BatteryFullChargedCapacity, BatteryCycleCount and BatteryStatus, as reported by the battery firmware.';

  @override
  String get batterySourceReport =>
      'Source: powercfg /batteryreport (temporary XML, deleted after reading), as reported by the battery firmware.';

  @override
  String get appTypeSystem => 'System';

  @override
  String get appTypeUser => 'User';

  @override
  String get appTypeStore => 'Store';

  @override
  String get appSafetyRemovable => 'Can remove';

  @override
  String get appSafetyCheckFirst => 'Check first';

  @override
  String get appSafetyKeep => 'Keep it';

  @override
  String get appReasonSystemComponent => 'Hidden Windows or vendor component.';

  @override
  String get appReasonProtected => 'Its installer forbids removal.';

  @override
  String get appReasonUpdate =>
      'Update of another program: remove that program instead.';

  @override
  String get appReasonWindowsPart =>
      'Part of Windows or a framework other apps need.';

  @override
  String get appReasonSharedDependency =>
      'Used by other apps (runtime, driver or vendor panel).';

  @override
  String get appReasonOptionalFeature =>
      'Optional Windows feature: read what stops working.';

  @override
  String get appReasonMissingUninstaller => 'No uninstaller registered.';

  @override
  String get appReasonUserInstalled =>
      'Installed by you or the PC maker; nothing else depends on it.';

  @override
  String get appLabelMissingUninstaller => 'No uninstaller';

  @override
  String get appLabelProtected => 'Protected';

  @override
  String get appLabelSystemComponent => 'System component';

  @override
  String get appLabelUpdate => 'Update';

  @override
  String get filterAll => 'All';

  @override
  String get filterType => 'Type';

  @override
  String get filterSafety => 'Safety';

  @override
  String get filterSource => 'Source';

  @override
  String get sourceWholePc => 'Whole PC';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortSize => 'Size';

  @override
  String get sortName => 'Name';

  @override
  String get sortDate => 'Install date';

  @override
  String appsShown(int count) {
    return '$count apps';
  }

  @override
  String selectionSummary(int count, String size) {
    return '$count selected · $size';
  }

  @override
  String selectionUnknownSizes(int count) {
    return '$count with unknown size';
  }

  @override
  String get appsSource =>
      'Source: Uninstall registry keys (HKLM 64/32-bit, HKCU), Get-AppxPackage, winget export for reinstall ids. Size: EstimatedSize, otherwise the install folder.';

  @override
  String get noAppsMatch => 'No app matches these filters.';

  @override
  String reinstallableVia(String id) {
    return 'Reinstall: winget $id';
  }

  @override
  String get uninstallQueueTitle => 'Uninstall queue';

  @override
  String get uninstallModeSilent => 'Silent';

  @override
  String get uninstallModeWindowed => 'Opens its window';

  @override
  String get uninstallManualNoUninstaller =>
      'Manual: no uninstaller registered.';

  @override
  String get uninstallManualUnsafe =>
      'Manual: the registered command runs a shell or script, so ZapTweaks does not start it.';

  @override
  String get uninstallManualNotFound =>
      'Manual: the uninstaller file is missing.';

  @override
  String uninstallRunningWarning(String processes) {
    return 'Still running from its folder: $processes. Close it first.';
  }

  @override
  String get uninstallSimulate =>
      'Simulation: plan and show the queue, uninstall nothing';

  @override
  String get uninstallRestorePointNote =>
      'A restore point is created first. Programs that open a window run first, one at a time; silent ones follow.';

  @override
  String get uninstallStart => 'Start uninstalling';

  @override
  String get restorePointCreating => 'Creating restore point…';

  @override
  String get restorePointFailed =>
      'The restore point was not created. System Protection may be off. Nothing has been changed.';

  @override
  String get restorePointEnableAndRetry =>
      'Turn on System Protection and retry';

  @override
  String get queueWaiting => 'Waiting';

  @override
  String get queueRunning => 'Running';

  @override
  String get queueDone => 'Done';

  @override
  String get queueFailed => 'Failed';

  @override
  String get queueSkipped => 'Skipped';

  @override
  String get queueSkip => 'Skip';

  @override
  String get queueStop => 'Stop after the current one';

  @override
  String get queueSimulated => 'Simulation: nothing was uninstalled.';

  @override
  String get uninstallStoreAppsHint =>
      'Store apps in the selection use the Uninstall menu on their row.';

  @override
  String get leftoverSearch => 'Look for leftovers';

  @override
  String get leftoverTitle => 'Leftovers';

  @override
  String get leftoverGood => 'Sure';

  @override
  String get leftoverMedium => 'Likely';

  @override
  String get leftoverLow => 'Uncertain';

  @override
  String get leftoverKindFolder => 'Folder';

  @override
  String get leftoverKindShortcut => 'Shortcut';

  @override
  String get leftoverKindRegistry => 'Registry key';

  @override
  String get leftoverKindRun => 'Startup entry';

  @override
  String get leftoverKindTask => 'Scheduled task';

  @override
  String get leftoverKindFirewall => 'Firewall rule';

  @override
  String get leftoverNone => 'No leftovers found.';

  @override
  String leftoverRemoveSelected(int count) {
    return 'Remove selected ($count)';
  }

  @override
  String get leftoverBackupNote =>
      'Only items marked Sure start selected. Before removal, registry keys are exported to .reg, tasks to XML and firewall rules to JSON; files and folders go to the Recycle Bin.';

  @override
  String leftoverRemoved(String path) {
    return 'Leftovers removed. Backups: $path';
  }

  @override
  String get leftoverRefusedInvalid =>
      'Not removed: malformed or unsafe entry.';

  @override
  String get leftoverRefusedOutside =>
      'Not removed: outside what ZapTweaks may clean here.';

  @override
  String get leftoverRefusedShared =>
      'Not removed: shared with Windows or other programs.';

  @override
  String get orphanFolders => 'Orphan folders';

  @override
  String get orphanFoldersNote =>
      'Program Files folders that no installed program points to. A portable tool or a driver kit can look the same, so nothing is selected: check each one first.';

  @override
  String get openLocation => 'Open location';

  @override
  String get processesTab => 'Processes';

  @override
  String get searchProcesses => 'Search processes';

  @override
  String get sortMemory => 'Memory';

  @override
  String get sortCpu => 'CPU';

  @override
  String get processKindWindows => 'Windows';

  @override
  String get processKindMicrosoft => 'Microsoft app';

  @override
  String get processKindThirdParty => 'Third party';

  @override
  String get processCanClose => 'Can close';

  @override
  String get processLeaveRunning => 'Leave running';

  @override
  String get processReasonCritical =>
      'Windows needs it: closing it can sign you out or crash the system.';

  @override
  String get processReasonWindowsFolder =>
      'Runs from the Windows folder or is protected.';

  @override
  String get processReasonService =>
      'Runs a service: manage it from the Services tab.';

  @override
  String get processReasonSelf => 'This is ZapTweaks.';

  @override
  String get processReasonUserApp =>
      'An app you started: closing it loses unsaved work.';

  @override
  String get processEnd => 'End process';

  @override
  String processEndConfirm(String name) {
    return 'End $name? Anything unsaved in it is lost.';
  }

  @override
  String get processEndChanged =>
      'It had already closed, or its ID now belongs to another process: nothing was ended.';

  @override
  String get processEndFailed =>
      'Windows refused to end it. It may run as administrator.';

  @override
  String get searchOnline => 'Search online';

  @override
  String get processOnlyClosable => 'Only ones you can close';

  @override
  String get processNote =>
      'A snapshot: CPU is a single sample, refresh to read it again. Signatures are checked after the list appears. System processes are never offered for closing.';

  @override
  String get noProcessesMatch => 'No process matches these filters.';

  @override
  String signedBy(String signer) {
    return 'Signed by $signer';
  }

  @override
  String get servicesTab => 'Services';

  @override
  String get searchServices => 'Search services';

  @override
  String get filterOrigin => 'Origin';

  @override
  String get originMicrosoft => 'Microsoft';

  @override
  String get serviceCanDisable => 'Can disable';

  @override
  String get serviceDependsOnUse => 'Depends on use';

  @override
  String get serviceKeep => 'Keep it';

  @override
  String get serviceStartAutomatic => 'Automatic';

  @override
  String get serviceStartDelayed => 'Automatic (delayed)';

  @override
  String get serviceStartManual => 'Manual';

  @override
  String get serviceStartDisabled => 'Disabled';

  @override
  String get serviceStartBoot => 'Boot';

  @override
  String get serviceRunning => 'Running';

  @override
  String get serviceStopped => 'Stopped';

  @override
  String get serviceSetDisabled => 'Disable';

  @override
  String get serviceSetManual => 'Set to manual';

  @override
  String get serviceSetAutomatic => 'Set to automatic';

  @override
  String serviceChangeTitle(String service) {
    return 'Change $service';
  }

  @override
  String serviceChangeConfirm(String from, String to, String reason) {
    return 'Start type: $from → $to.\n$reason\nIt applies the next time the service or Windows starts. You can undo it right after.';
  }

  @override
  String serviceChanged(String service, String to) {
    return '$service is now $to.';
  }

  @override
  String get serviceUndo => 'Undo';

  @override
  String get serviceNote =>
      'Changes ask for administrator rights and take effect at the next start of the service or of Windows. Services Windows needs are never offered; disabling a service that others depend on is refused.';

  @override
  String get noServicesMatch => 'No service matches these filters.';

  @override
  String get svcReasonTelemetry =>
      'Sends usage and diagnostic data to Microsoft. Nothing you use stops working.';

  @override
  String get svcReasonDeviceManagement =>
      'Telemetry and work or school device management: only needed if an organization manages this PC.';

  @override
  String get svcReasonCrashReports =>
      'Sends crash reports to Microsoft. Crashes are still logged on this PC.';

  @override
  String get svcReasonRemoteRegistry =>
      'Lets other computers edit this PC\'s registry over the network. Off by default.';

  @override
  String get svcReasonOfflineMaps =>
      'Keeps offline maps up to date for the Maps app.';

  @override
  String get svcReasonMediaSharing =>
      'Shares the Windows Media Player library on the network.';

  @override
  String get svcReasonRetailDemo => 'Shop demo mode. Never needed at home.';

  @override
  String get svcReasonXbox =>
      'Without it: Xbox app, Game Pass, cloud saves and Xbox accessories stop working.';

  @override
  String get svcReasonPrinting =>
      'Without it: printing stops working, Print to PDF included.';

  @override
  String get svcReasonBluetooth =>
      'Without it: Bluetooth devices stop connecting.';

  @override
  String get svcReasonSearch =>
      'Without it: search in Start, Settings and File Explorer gets slow and incomplete.';

  @override
  String get svcReasonSysMain =>
      'Preloads apps you use often. Without it launches can be slower, mostly on hard disks.';

  @override
  String get svcReasonTouchKeyboard =>
      'Without it: touch keyboard, handwriting, the emoji panel and some input methods stop working.';

  @override
  String get svcReasonLocation =>
      'Without it: apps and Find my device can no longer get your location.';

  @override
  String get svcReasonBiometrics =>
      'Without it: Windows Hello face and fingerprint sign-in stop working.';

  @override
  String get svcReasonPhone =>
      'Without it: calls through Phone Link stop working.';

  @override
  String get svcReasonRemoteDesktop =>
      'Without it: Remote Desktop into this PC stops working.';

  @override
  String get svcReasonSmartCard =>
      'Without it: smart cards and some security keys stop working.';

  @override
  String get svcReasonParental =>
      'Without it: Microsoft Family Safety limits are no longer enforced.';

  @override
  String get svcReasonNfc => 'Without it: NFC and tap-to-pay stop working.';

  @override
  String get svcReasonHotspot => 'Without it: Mobile hotspot stops working.';

  @override
  String get svcReasonScanner =>
      'Without it: scanners and some cameras stop working.';

  @override
  String get svcReasonCompatibility =>
      'Without it: Windows no longer offers fixes when an old program fails to run.';

  @override
  String get svcReasonFax => 'Without it: fax stops working.';

  @override
  String get svcReasonInsider =>
      'Without it: Windows Insider preview builds stop arriving.';

  @override
  String get svcReasonUpdates =>
      'Windows Update needs it: without it security fixes stop arriving.';

  @override
  String get svcReasonSecurity =>
      'Protects this PC (antivirus, firewall, security status).';

  @override
  String get svcReasonWindowsCore =>
      'Windows needs it for sound, network, logs or basic system functions.';

  @override
  String get svcReasonNotReviewed =>
      'Part of Windows and not reviewed: leave it as it is.';

  @override
  String get svcReasonDriverService =>
      'Installed with a driver: leave it unless you know what it does.';

  @override
  String get svcReasonMicrosoftApp =>
      'Belongs to a Microsoft app: without it that app may stop working or updating.';

  @override
  String get svcReasonThirdParty =>
      'Installed with another program: without it that program may stop working or updating.';

  @override
  String get serviceStartTypeAction => 'Change startup';

  @override
  String get presetsTab => 'Presets';

  @override
  String get presetDebloatName => 'Debloat only';

  @override
  String get presetDebloatSummary =>
      'Removes preinstalled Microsoft apps few people use. Nothing else changes.';

  @override
  String get presetCleanName => 'Clean';

  @override
  String get presetCleanSummary =>
      'Debloat, plus telemetry and unused services off and apps that start with Windows for no reason.';

  @override
  String get presetGamingName => 'Gaming';

  @override
  String get presetGamingSummary =>
      'Clean, plus settings for playing: no power throttling of running apps, End task in the taskbar. Xbox stays.';

  @override
  String get presetPrivacyName => 'Privacy';

  @override
  String get presetPrivacySummary =>
      'Clean, plus the privacy settings from Microsoft\'s own guide: advertising ID, tracking, suggestions, diagnostic data to the minimum.';

  @override
  String get presetCompetitiveName => 'Competitive';

  @override
  String get presetCompetitiveSummary =>
      'Removes everything the other presets remove and more: apps many people use, Xbox, printing, launchers at startup, game recording. Plus a clean driver install and WinSux, done by hand.';

  @override
  String get presetAttention => 'Attention';

  @override
  String get presetAttentionNote =>
      'It removes a lot, including things many people use. No FPS, latency or other gain is promised: it is a set of changes, not a measured improvement.';

  @override
  String get presetGroupApps => 'Apps it removes (current user)';

  @override
  String get presetGroupServices => 'Services it turns off';

  @override
  String get presetGroupStartup => 'Startup entries it turns off';

  @override
  String get presetGroupTweaks => 'Settings';

  @override
  String get presetGroupThirdParty => 'Third-party scripts and tools';

  @override
  String get presetGroupRestart => 'Restart';

  @override
  String get presetGroupReversible => 'What can be undone';

  @override
  String get presetRestartNeeded =>
      'Restart afterwards: services and startup entries change at the next start.';

  @override
  String get presetRestartNone => 'No restart needed.';

  @override
  String get presetReversibleApps =>
      'Apps: reinstall them from the Microsoft Store.';

  @override
  String get presetReversibleSettings =>
      'Services, startup entries and settings: undo them right after with Undo preset, or later with the restore point created first.';

  @override
  String get presetReversibleManual =>
      'Third-party steps are not run by ZapTweaks: follow the author\'s own instructions to undo them.';

  @override
  String get presetManualWhy =>
      'Done by hand: the script downloads and runs other files that cannot be pinned to a hash, so ZapTweaks does not run it.';

  @override
  String get presetManualDriverClean =>
      'Clean graphics driver install: DDU in Safe Mode, then the latest driver from the vendor.';

  @override
  String get presetManualWinsux =>
      'WinSux: Windows debloat and settings in one script.';

  @override
  String get presetPreview => 'Preview on this PC';

  @override
  String get presetPreviewLoading =>
      'Reading apps, services, startup entries and settings…';

  @override
  String get presetStatusApply => 'To do';

  @override
  String get presetStatusDone => 'Already set';

  @override
  String get presetStatusSkipped => 'Skipped';

  @override
  String get presetStatusManual => 'By hand';

  @override
  String get presetSkipNotInstalled => 'not installed';

  @override
  String get presetSkipNotFound => 'not on this PC';

  @override
  String get presetSkipUnsupported => 'not supported here';

  @override
  String get presetSkipDuplicate =>
      'same name twice: only the first is changed';

  @override
  String presetCounts(int apply, int done, int skipped) {
    return '$apply to do · $done already set · $skipped skipped';
  }

  @override
  String get presetConsent => 'I have read the full list and accept the risk.';

  @override
  String get presetApply => 'Apply preset';

  @override
  String get presetApplyNote =>
      'A restore point is created first; if it fails nothing changes. Administrator changes ask for UAC once.';

  @override
  String get presetApplying => 'Applying…';

  @override
  String presetReport(int ok, int failed) {
    return 'Done: $ok changed, $failed not changed.';
  }

  @override
  String get presetUndo => 'Undo preset';

  @override
  String get presetUndone =>
      'Preset undone. Removed apps stay removed: reinstall them from the Store.';

  @override
  String get presetNothingToDo => 'Nothing to do: everything is already set.';

  @override
  String get presetSaveAs => 'Save as my preset';

  @override
  String get presetSaveNote =>
      'Saves the items still ticked. Share the file to export it; put a file in the folder to import it.';

  @override
  String get presetName => 'Name';

  @override
  String presetSaved(String path) {
    return 'Saved: $path';
  }

  @override
  String get presetOpenFolder => 'Open presets folder';

  @override
  String get presetUserTitle => 'My presets';

  @override
  String presetInvalidFile(String file, String error) {
    return '$file not loaded: $error';
  }

  @override
  String get presetItemPowerThrottling =>
      'Power throttling of running apps off';

  @override
  String get presetItemEndTask => 'End task in the taskbar menu';

  @override
  String get presetItemAdvertisingId => 'Advertising ID off';

  @override
  String get presetItemLanguageList =>
      'Websites can\'t read your language list';

  @override
  String get presetItemAppLaunchTracking =>
      'Windows doesn\'t track the apps you start';

  @override
  String get presetItemTailoredExperiences =>
      'No tailored experiences from diagnostic data';

  @override
  String get presetItemCloudContent =>
      'No cloud-optimized content (suggestions)';

  @override
  String get presetItemDiagnosticData => 'Diagnostic data: required only';

  @override
  String get presetItemLockScreenOverlay => 'No tips over the lock screen';

  @override
  String get presetItemLockScreenFacts => 'No fun facts on the lock screen';

  @override
  String get presetItemGameDvr => 'Game Bar game recording off';

  @override
  String get presetSkipHasDependents =>
      'Other services depend on it, so Windows does not allow disabling it.';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsModes => 'Modes';

  @override
  String get settingsMaintenance => 'Maintenance';

  @override
  String get settingsAbout => 'About';

  @override
  String get openLogFolderDescription =>
      'Session logs with every command ZapTweaks ran.';

  @override
  String get redetectSystemStateDescription =>
      'Read the hardware and the state of every tweak again.';

  @override
  String get profileTitle => 'Settings profile';

  @override
  String get profileDescription =>
      'Save ZapTweaks preferences to a file or load them from one.';

  @override
  String get resetAppSettingsDescription =>
      'Back to default ZapTweaks preferences. Windows is not changed.';

  @override
  String get expertModeOn => 'On';

  @override
  String get expertModeOff => 'Off';
}
