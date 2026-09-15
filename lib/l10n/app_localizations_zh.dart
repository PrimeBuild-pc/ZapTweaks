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
