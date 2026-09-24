// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择 ZapTweaks 使用的语言。';

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
  String get settings => '设置';

  @override
  String get startWithWindows => '随 Windows 启动';

  @override
  String get startWithWindowsDescription => '登录 Windows 后启动 ZapTweaks。';

  @override
  String get openLogFolder => '打开日志文件夹';

  @override
  String get redetectSystemState => '重新检测系统状态';

  @override
  String get exportProfile => '导出配置';

  @override
  String get importProfile => '导入配置';

  @override
  String get resetAppSettings => '重置应用设置';

  @override
  String get updates => '更新';

  @override
  String get automaticUpdateNotifications => '自动更新通知';

  @override
  String get automaticUpdateDescription => '启动时检查并显示提示点。绝不会自动安装更新。';

  @override
  String get checking => '正在检查...';

  @override
  String get checkNow => '立即检查';

  @override
  String get viewRelease => '查看版本';

  @override
  String get updateNow => '立即更新';

  @override
  String get applicationVersion => '应用版本';

  @override
  String get dryRunMode => '模拟运行模式';

  @override
  String get dryRunDescription => '模拟命令而不更改 Windows。';

  @override
  String get done => '完成';

  @override
  String get operationFailed => '操作失败';

  @override
  String get updateAvailable => '有可用更新';

  @override
  String get updateAvailableDescription => '您可以查看发行说明或直接安装。';

  @override
  String get updateAvailableShort => '可用更新';

  @override
  String get checkingForUpdates => '检查更新';

  @override
  String get contactingReleaseServer => '正在联系发布服务器...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version 可用';
  }

  @override
  String installedVersion(Object version) {
    return '安装版本：$version';
  }

  @override
  String get releaseNotesOnGitHub => '发行说明可在 GitHub 上获取。';

  @override
  String get later => '后来';

  @override
  String get failed => '失败';

  @override
  String get downloadingUpdate => '正在下载更新';

  @override
  String get downloadingUpdateDescription => '下载并准备安装程序...';

  @override
  String get adminPrivilegesRequired => '需要管理员权限';

  @override
  String get adminRequiredBanner =>
      '关闭应用程序并使用“以管理员身份运行”启动 ZapTweaks。如果没有提升，系统调整就无法安全地应用。';

  @override
  String get cancel => '取消';

  @override
  String get createRestorePoint => '创建还原点';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks 需要管理员权限才能应用系统设置。\n\n关闭应用程序，右键单击可执行文件，然后选择“以管理员身份运行”。';

  @override
  String get understood => '明白了';

  @override
  String aboutVersion(Object version) {
    return '版本：v$version';
  }

  @override
  String get author => '作者：PrimeBuild';

  @override
  String get aboutDescription => '用于更深入的 Windows 游戏、硬件和诊断工作流程的高级优化伴侣。';

  @override
  String year(Object year) {
    return '年份：$year';
  }

  @override
  String get close => '关闭';

  @override
  String get github => 'GitHub';

  @override
  String get discord => '不和谐';

  @override
  String get homeAndStats => '主页与统计';

  @override
  String get cpuUsage => '中央处理器使用率';

  @override
  String get cpuUsageDescription => 'Windows 计数器的实时利用率';

  @override
  String get gpuUsage => 'GPU 使用情况';

  @override
  String get gpuUsageDescription => '实时引擎利用率';

  @override
  String get vramUsage => '显存使用情况';

  @override
  String get memoryUsage => '内存使用情况';

  @override
  String get unknown => '未知';

  @override
  String get installedRam => '已安装内存';

  @override
  String get networkAdapters => '网络适配器';

  @override
  String get noConnectedAdapters => '未检测到连接的适配器';

  @override
  String get audioDevices => '音频设备';

  @override
  String get noAudioDevices => '未检测到音频设备';

  @override
  String get noTweaksAvailable => '您的硬件配置无法进行任何调整。';

  @override
  String get detectedHardware => '检测到的硬件';

  @override
  String get gpuUnknown => '显卡：未知';

  @override
  String cpuValue(Object value) {
    return '中央处理器：$value';
  }

  @override
  String gpuValue(Object value) {
    return 'GPU：$value';
  }

  @override
  String ramValue(Object value) {
    return '内存：$value';
  }

  @override
  String get enableAllVisible => '启用所有可见';

  @override
  String get disableAllVisible => '禁用所有可见的';

  @override
  String get restartNow => '立即重新启动';

  @override
  String get restartRequired => '需要重新启动';

  @override
  String get restartRequiredDescription => '需要重新启动系统才能完全应用一项或多项更改。';

  @override
  String get advancedActionsIncluded => '包括高级操作';

  @override
  String get advancedActionsDescription =>
      '外部工具、启动器操作和脚本驱动的实用程序都集中在此处，以实现快速诊断和维护工作流程。';

  @override
  String get aggressiveTweakWarning => '激进的调整。建议创建还原点。';

  @override
  String get networkReconnectWarning => '可能需要重新连接网络适配器或重新启动系统。';

  @override
  String get actionWarning => '动作警告';

  @override
  String get unknownError => '未知错误。';

  @override
  String get presets => '预设';

  @override
  String get presetFailed => '预设失败';

  @override
  String get safetyWarning => '安全警示';

  @override
  String get unavailable => '不可用';

  @override
  String get powerPlans => '捆绑电源计划';

  @override
  String get powerPlansDescription => '导入并激活捆绑计划。 ZapTweaks 会记住之前的活动恢复计划。';

  @override
  String get noPowerPlans => '未找到捆绑的电源计划。';

  @override
  String get working => '工作...';

  @override
  String get importAndActivate => '导入并激活';

  @override
  String get restorePreviousPlan => '恢复之前的计划';

  @override
  String get ran => '然';

  @override
  String get gpuDrivers => '显卡驱动程序';

  @override
  String get noGpuDrivers => '未检测到 GPU 驱动程序';

  @override
  String get chipsetDrivers => '芯片组驱动程序';

  @override
  String get noChipsetDrivers => '未检测到芯片组驱动程序';

  @override
  String get monitors => '显示器';

  @override
  String get noMonitors => '未检测到监视器';

  @override
  String get mice => '小鼠';

  @override
  String get noMice => '未检测到老鼠';

  @override
  String get keyboards => '键盘';

  @override
  String get noKeyboards => '未检测到键盘';

  @override
  String get restorePointPromptTitle => '创建还原点？';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks 可以在更改系统设置前创建 Windows 还原点。这是可选的：跳过后仍会应用更改。每次运行只询问一次。';

  @override
  String get skip => '跳过';

  @override
  String get continueAction => '继续';

  @override
  String get tweaksSectionHeader => '优化项';

  @override
  String get startingUp => '正在启动 ZapTweaks';

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
}
