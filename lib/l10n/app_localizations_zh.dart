// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get externalDownload => '外部下载';

  @override
  String get appRequirements => '系统要求';

  @override
  String get appWarnings => '警告';

  @override
  String get metricUnavailable => '暂无数据';

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择 ZapTweaks 使用的语言。';

  @override
  String get appearance => '外观';

  @override
  String get appearanceDescription => '跟随 Windows，或为应用固定使用浅色或深色主题。';

  @override
  String get themeSystem => 'Windows 默认';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

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
  String get expertMode => '专家模式';

  @override
  String get expertModeDescription => '仅在明确手动同意后才显示高级操作和外部工具。默认关闭；安全限制始终有效。';

  @override
  String get searchOperations => '搜索操作';

  @override
  String get searchResults => '搜索结果';

  @override
  String get searchSections => '分区和内置工具';

  @override
  String get searchApps => '搜索应用';

  @override
  String get searchCatalog => '操作和外部工具';

  @override
  String get searchOpenResult => '打开';

  @override
  String get searchExpertRequired => '启用专家模式后才能打开';

  @override
  String get noSearchResults => '没有匹配的分区、应用、操作或工具。';

  @override
  String get operationTaskbarEndTaskTitle => '任务栏“结束任务”';

  @override
  String get operationTaskbarEndTaskDescription => '在任务栏应用的右键菜单中显示“结束任务”。';

  @override
  String get appStore => '应用商店';

  @override
  String get appManagement => '已安装的应用';

  @override
  String get windowsAppTools => 'Windows 应用工具';

  @override
  String get optionalFeatures => '可选功能';

  @override
  String get searchOptionalFeatures => '搜索可选功能';

  @override
  String get scanOptionalFeatures => '扫描功能（UAC）';

  @override
  String get optionalFeaturesUacNotice =>
      '功能清单和每项更改都通过允许列表中的辅助程序执行。扫描期间不会做任何更改。';

  @override
  String get confirmOptionalFeatureChange => '确认更改可选功能';

  @override
  String confirmOptionalFeatureChangeMessage(Object name, Object action) {
    return '功能：$name\n操作：$action\n\nWindows 可能需要重启。更改前会记录之前的启用状态。';
  }

  @override
  String get enable => '启用';

  @override
  String get disable => '禁用';

  @override
  String get enabled => '已启用';

  @override
  String get disabled => '已禁用';

  @override
  String get enablePending => '重启后启用';

  @override
  String get disablePending => '重启后禁用';

  @override
  String get startupApps => '启动应用';

  @override
  String get searchStartupApps => '搜索启动应用';

  @override
  String get openStartupSettings => '打开启动设置';

  @override
  String get openTaskManagerStartup => '打开任务管理器中的启动';

  @override
  String get startupInventoryNotice => '启动项清单为只读。请在 Windows 设置或任务管理器中更改条目。';

  @override
  String get guidedSetup => '引导式设置';

  @override
  String get wizardInventory => '清单';

  @override
  String get wizardBaseline => '基线';

  @override
  String get wizardWindowsUpdate => 'Windows 更新';

  @override
  String get wizardDrivers => '驱动检查';

  @override
  String get wizardApplications => '应用程序';

  @override
  String get wizardDebloat => '选择性精简';

  @override
  String get wizardPrivacyInterface => '隐私和界面';

  @override
  String get wizardPreview => '计划预览';

  @override
  String get wizardApply => '应用';

  @override
  String get wizardReport => '最终报告';

  @override
  String get wizardInventoryDescription => '在做出选择前读取硬件、已安装的 winget 包和当前设备。';

  @override
  String get runInventory => '生成清单';

  @override
  String inventorySummary(Object apps, Object devices) {
    return '检测到 $apps 个 winget 包和 $devices 个当前设备。';
  }

  @override
  String get wizardUpdateNotice =>
      '更改驱动和应用前请先检查 Windows 更新。ZapTweaks 不会自动安装更新。';

  @override
  String get openWindowsUpdate => '打开 Windows 更新';

  @override
  String get updatesReviewed => '我已检查 Windows 更新';

  @override
  String driverInventorySummary(Object devices, Object missing) {
    return '当前设备：$devices\n未绑定 INF 的设备：$missing';
  }

  @override
  String get wizardDebloatNotice =>
      '不会隐式进行任何精简。此处只能选择当前用户、且有已验证恢复来源的 AppX 包；其他移除操作仍在“应用 → 已安装的应用”中，并有单独的预览。';

  @override
  String get wizardPrivacyNotice => '除非在下方明确选择，否则隐私和界面设置保持不变。';

  @override
  String get noAppsSelected => '未选择任何操作。向导不会做任何更改。';

  @override
  String planContains(Object count) {
    return '计划包含 $count 项明确操作：';
  }

  @override
  String readyToApply(Object count) {
    return '已准备应用 $count 项应用操作。winget 完成后会逐个验证每个包。';
  }

  @override
  String get noPlanReport => '已结束，未应用任何计划。';

  @override
  String get planStatus => '计划状态';

  @override
  String get applyPlan => '应用计划';

  @override
  String get back => '返回';

  @override
  String get finish => '完成';

  @override
  String get recovery => '恢复';

  @override
  String get diagnosticTools => '诊断工具';

  @override
  String get repairComponentStore => '修复 Windows 组件存储';

  @override
  String get repairComponentStoreDescription =>
      '运行 DISM RestoreHealth，然后单独运行 ScanHealth 验证。可能需要很长时间。';

  @override
  String get repairSystemFiles => '修复受保护的系统文件';

  @override
  String get repairSystemFilesDescription => '运行 SFC 扫描并修复，然后单独进行一次验证。';

  @override
  String get confirmSystemRepair => '确认修复 Windows';

  @override
  String get systemRepairWarning =>
      '修复可能会替换损坏的 Windows 组件，ZapTweaks 无法回滚。运行期间请勿关闭电脑。';

  @override
  String get systemRepairVerified => '修复完成，验证通过。';

  @override
  String get runRepair => '开始修复';

  @override
  String get operationCompleted => '操作已完成';

  @override
  String get captureEtwTrace => '捕获性能跟踪';

  @override
  String get captureEtwTraceDescription =>
      '录制有时长限制的 Windows Performance Recorder 跟踪，并按需生成 DPC/ISR 诊断报告。不会留下任何持续运行的监视。';

  @override
  String get dpcLatencyAnalyzer => 'DPC / ISR 延迟分析';

  @override
  String get dpcLatencyAnalyzerDescription =>
      '按需捕获 ETW，报告 DPC、ISR、硬错误和上下文切换活动、各处理器分布、观察到的内核模块名称和 ETW 提供程序。';

  @override
  String get diagnosticNotCausality => '诊断信号，并非延迟结论';

  @override
  String get diagnosticNotCausalityDescription =>
      '计数和观察到的模块名称有助于缩小排查范围，但不能证明是某个驱动导致了延迟。请用可重复的 A/B/A 跟踪以及 WPA 或厂商工具确认。';

  @override
  String get startDpcCapture => '开始捕获';

  @override
  String get openTraceFolder => '打开跟踪文件夹';

  @override
  String captureInProgress(int seconds) {
    return '正在捕获 $seconds 秒…请保持负载运行。';
  }

  @override
  String get traceDuration => '观察时长';

  @override
  String get hardFaults => '硬错误';

  @override
  String get contextSwitches => '上下文切换';

  @override
  String get totalEvents => 'ETW 事件总数';

  @override
  String get kernelModulesObserved => 'DPC/ISR 事件中观察到的内核模块';

  @override
  String get noKernelModulesObserved =>
      '导出的事件不包含内核模块名称。请在 WPA 中打开 ETL 进行带符号的分析。';

  @override
  String get dpcIsrByProcessor => '各逻辑处理器的 DPC/ISR 事件';

  @override
  String get noProcessorDistribution => '导出的事件中没有处理器 ID。';

  @override
  String get topEtwProviders => '主要 ETW 提供程序';

  @override
  String get noProviderData => '没有可用的提供程序数据。';

  @override
  String etwTraceSaved(Object path) {
    return '跟踪已保存到 $path';
  }

  @override
  String get cleanupDiagnosticTraces => '删除诊断跟踪';

  @override
  String get cleanupDiagnosticTracesDescription =>
      '只扫描 ZapTweaks 的跟踪文件，显示确切的文件数和总字节数，确认后删除。';

  @override
  String cleanupTracePreview(int count, int bytes) {
    return '删除 $count 个 ZapTweaks 跟踪文件（$bytes 字节）？此操作无法撤销。';
  }

  @override
  String get cleanupTracesCompleted => '预览中的诊断跟踪已删除，并已确认不再存在。';

  @override
  String get noDiagnosticTraces => '未找到 ZapTweaks 诊断跟踪。';

  @override
  String get hardwareMonitor => '硬件监视';

  @override
  String get dedicatedVramUsage => '已用专用 GPU 内存';

  @override
  String get dedicatedVramUsageDescription =>
      '读取一次 Windows GPU 性能计数器快照。之后不会有任何程序继续运行。';

  @override
  String vramUsageValue(Object megabytes) {
    return '$megabytes MB';
  }

  @override
  String get captureNow => '立即读取';

  @override
  String get tweaks => '优化';

  @override
  String get searchPowerPlans => '搜索电源计划';

  @override
  String get activePowerPlan => '活动';

  @override
  String get activate => '启用';

  @override
  String get details => '详细信息';

  @override
  String get compare => '比较';

  @override
  String get noPowerDifferences => '未发现交流/直流值的差异。';

  @override
  String get importPowerPlan => '导入 .pow';

  @override
  String get importPowerPlanDescription => '经过有限制且经哈希验证的暂存后，导入一个本地选择的电源计划。';

  @override
  String get exportActivePowerPlan => '导出活动计划';

  @override
  String get restoreDefaultPowerSchemes => '恢复 Windows 默认值';

  @override
  String get restoreDefaultPowerSchemesDescription =>
      '在请求 Windows 恢复默认值前，先导出每个当前方案并计算哈希。';

  @override
  String get restoreDefaultPowerSchemesWarning =>
      '用 Windows 默认方案替换所有当前电源方案？ZapTweaks 会先导出每个方案，以便精确回滚。';

  @override
  String get interruptConfiguration => 'MSI Utility v3 与中断亲和性';

  @override
  String get interruptConfigurationDescription =>
      '针对当前显示、网络、媒体、USB 主机和 HD 音频设备的高级 MSI 和第 0 组中断亲和性控制，按硬件能力启用。不会自动推荐任何值。';

  @override
  String get configureMsi => '配置 MSI';

  @override
  String get enableMsi => '启用消息信号中断';

  @override
  String get configureInterruptAffinity => '配置亲和性';

  @override
  String get interruptChangeWarning =>
      '无效的中断策略可能导致设备在回滚或重启前无法使用。ZapTweaks 会验证硬件限制并保存确切的当前值。';

  @override
  String get affinityMaskHint => '第 0 组十六进制掩码，例如 3';

  @override
  String get invalidAffinityMask => '请输入非零、规范、最多 64 位的十六进制掩码。';

  @override
  String msiRange(int maximum) {
    return '消息数必须在 1 到 $maximum 之间。';
  }

  @override
  String get noCompatibleInterruptDevices =>
      '没有任何当前的显示、网络、媒体、USB 主机或 HD 音频 PCI 设备提供兼容的中断能力。';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return '硬件：Line $line · MSI $msi · MSI-X $msix · 最大消息数 $maximum';
  }

  @override
  String get messageNumberLimit => '消息数上限';

  @override
  String get interruptPriority => '中断优先级策略';

  @override
  String get interruptPriorityDefault => '未定义 / 驱动默认';

  @override
  String get interruptPriorityLow => '低';

  @override
  String get interruptPriorityNormal => '普通';

  @override
  String get interruptPriorityHigh => '高';

  @override
  String get interruptPolicy => '处理器亲和性策略';

  @override
  String get interruptPolicyDefault => '系统默认';

  @override
  String get interruptPolicyAllClose => '所有邻近处理器';

  @override
  String get interruptPolicyOneClose => '一个邻近处理器';

  @override
  String get interruptPolicyAllProcessors => '所有处理器';

  @override
  String get interruptPolicySpecified => '指定的处理器（第 0 组）';

  @override
  String get interruptPolicySpread => '将消息分散到各处理器';

  @override
  String get selectLogicalProcessors => '选择处理器组 0 中的逻辑处理器';

  @override
  String get affinitySelectAll => '所有逻辑处理器';

  @override
  String get affinityClear => '清除';

  @override
  String get affinityPhysicalCores => '每个物理核心一个线程';

  @override
  String get affinityPerformanceCores => '性能核';

  @override
  String get affinityEfficiencyCores => '能效核';

  @override
  String get affinityParked => '已停放';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'NUMA 节点 $index';
  }

  @override
  String get compatibleDevices => '兼容设备';

  @override
  String get msiEnabledDevices => '当前已启用 MSI';

  @override
  String get logicalProcessors => '逻辑处理器';

  @override
  String get searchDevices => '搜索设备、实例 ID 或驱动 INF';

  @override
  String get driverUnknown => '驱动 INF 不可用';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return '当前：$mode · 消息 $messages · 优先级 $priority · 策略 $policy · 掩码 $mask';
  }

  @override
  String get renamePowerPlan => '重命名电源计划';

  @override
  String get renamePowerPlanDescription => '只更改所选计划的显示名称，并保留原名称以便回滚。';

  @override
  String get rename => '重命名';

  @override
  String get duplicate => '复制';

  @override
  String get duplicatePowerPlan => '复制电源计划';

  @override
  String get duplicatePowerPlanDescription =>
      '通过 PowrProf 创建并验证副本。回滚只能尽力而为，因为 GUID 由 Windows 在创建时分配。';

  @override
  String get apply => '应用';

  @override
  String get edit => '编辑';

  @override
  String powerValueRange(int maximum) {
    return '值必须在 0 到 $maximum 之间。';
  }

  @override
  String get powerSettingConfigure => '配置任意有范围限制的电源设置';

  @override
  String get powerSettingConfigureDescription =>
      '仅当 Windows 实时提供最小值、最大值和步长时，才编辑 PowrProf 公开的设置。';

  @override
  String get searchPowerSettings => '搜索设置、说明、子组或 GUID';

  @override
  String get allPowerSubgroups => '所有电源设置组';

  @override
  String powerSettingCount(int count) {
    return '$count 项设置';
  }

  @override
  String powerSettingOptions(int count) {
    return '$count 个 Windows 定义的选项';
  }

  @override
  String get backToPowerPlans => '返回电源计划';

  @override
  String get powerPlanEditorHint =>
      '先复制一个计划来创建自己的配置，然后打开“详细信息”，逐项编辑其隐藏的交流/直流设置。';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return '范围 $minimum–$maximum，步长 $increment';
  }

  @override
  String get powerSettingBoundsUnavailable => 'Windows 未为此设置提供安全的值或范围。';

  @override
  String get delete => '删除';

  @override
  String get deletePowerPlan => '删除电源计划';

  @override
  String get deletePowerPlanDescription => '删除前先导出所选的非活动计划，并保留备份以便精确回滚。';

  @override
  String deletePowerPlanWarning(Object name) {
    return '删除 $name？ZapTweaks 会先导出一份恢复副本。';
  }

  @override
  String get firmwareTemperatures => '固件温度区域';

  @override
  String get firmwareTemperaturesDescription =>
      '读取一次 ACPI 温度区域。是否可用以及传感器含义取决于电脑固件；这些值不会被标注为 CPU 或 GPU 温度。';

  @override
  String get noThermalSensors => '此电脑未提供 ACPI 温度区域。';

  @override
  String get cpuFrequency => 'CPU 频率和核心停放';

  @override
  String get cpuFrequencyDescription =>
      '读取一次 Windows 处理器性能计数器。有效频率 = 基础频率 × 处理器性能百分比，与任务管理器的公式相同。可用于检查电源计划、睿频和核心停放的更改。只读。';

  @override
  String cpuEffectiveClock(Object mhz, Object nominal) {
    return '有效 $mhz MHz · 基础 $nominal MHz';
  }

  @override
  String cpuParkedCount(Object parked, Object total) {
    return '$total 个逻辑处理器中有 $parked 个已停放';
  }

  @override
  String get cpuParked => '已停放';

  @override
  String get cpuFrequencySource =>
      '来源：Processor Information 性能计数器（Win32_PerfFormattedData_Counters_ProcessorInformation），一次读取，为上一个计数器周期的平均值。不是峰值频率。各核心的值使用同一个标称频率，因此混合架构 CPU 的能效核读数偏高。';

  @override
  String get driverInventory => '驱动程序存储清单';

  @override
  String get installLocalDriver => '安装本地驱动包';

  @override
  String get installLocalDriverDescription => '安装前验证本地 INF、其签名目录以及硬件兼容性。';

  @override
  String get selectDevice => '选择一个当前设备';

  @override
  String get localInfPath => '本地 .inf 文件的绝对路径';

  @override
  String get verifyDriverPackage => '验证驱动包';

  @override
  String verifiedDriverPublisher(Object publisher, Object sha256) {
    return '已验证发布者：$publisher\nINF SHA-256：$sha256';
  }

  @override
  String get confirmLocalDriverInstall => '确认安装本地驱动';

  @override
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  ) {
    return '设备：$device\n签名发布者：$publisher\nINF SHA-256：$sha256\n\nWindows 可能会更换当前驱动并要求重启。回滚只能尽力而为。';
  }

  @override
  String get driverTools => '辅助流程';

  @override
  String get temporaryDriverUpdatesPause => '暂时将驱动排除在 Windows 质量更新之外';

  @override
  String get temporaryDriverUpdatesPauseDescription =>
      '使用有文档说明的 Windows 更新策略，为期 7 天或 30 天。ZapTweaks 会记录确切的原值，暂停到期时提醒；恢复需要你确认。';

  @override
  String get driverUpdatePolicy => 'Windows 更新驱动策略';

  @override
  String get driverUpdatePolicyDescription =>
      '将设备驱动排除在 Windows 质量更新之外，为期 7 天、30 天，或直到你明确恢复确切的原策略。';

  @override
  String get disableUntilRestored => '禁用直到恢复';

  @override
  String get driverUpdatePausePermanent => '在你恢复原策略之前，驱动更新将一直被排除。';

  @override
  String get driverUpdatePauseActive => '驱动更新暂停中';

  @override
  String get driverUpdatePauseExpired => '驱动更新暂停已到期——请恢复原策略';

  @override
  String driverUpdatePauseUntil(Object date) {
    return '计划到期：$date';
  }

  @override
  String get pauseSevenDays => '暂停 7 天';

  @override
  String get pauseThirtyDays => '暂停 30 天';

  @override
  String get restoreDriverUpdates => '恢复原策略';

  @override
  String get assistedDriverFlows => '已验证的辅助驱动流程';

  @override
  String get assistedDriverFlowsDescription =>
      'ZapTweaks 只打开厂商自己的来源和 Windows 界面。它不会运行可变的远程脚本，不会刷写固件，也不会悄悄移除驱动组件。';

  @override
  String get amdDriverFlow => 'AMD 驱动和软件';

  @override
  String get amdDriverFlowDescription => '打开 AMD 官方驱动选择器。下载前请核对检测到的产品。';

  @override
  String get nvidiaDriverFlow => 'NVIDIA 驱动';

  @override
  String get nvidiaDriverFlowDescription =>
      '打开 NVIDIA 官方手动驱动搜索。是否清洁安装仍由厂商安装程序中的明确选项决定。';

  @override
  String get intelDriverFlow => 'Intel Driver & Support Assistant';

  @override
  String get intelDriverFlowDescription => '打开 Intel 官方检测与支持流程。';

  @override
  String get windowsOptionalDrivers => 'Windows 可选驱动更新';

  @override
  String get windowsOptionalDriversDescription =>
      '在 Windows 设置中查看可选驱动更新；不会自动选择任何项目。';

  @override
  String get deviceManager => '设备管理器';

  @override
  String get deviceManagerDescription => '查看设备、状态代码、当前驱动和手动回滚选项。';

  @override
  String get openOfficialSource => '打开官方来源';

  @override
  String get openWindowsPanel => '打开 Windows 面板';

  @override
  String get searchDrivers => '搜索驱动程序存储';

  @override
  String get driverStoreSafetyNotice =>
      '此处只能移除已签名且未绑定的第三方驱动包。ZapTweaks 会先导出驱动包并计算哈希；恢复只能尽力而为，因为 Windows 可能分配不同的发布名称。';

  @override
  String get signed => '已签名';

  @override
  String get unsigned => '未签名';

  @override
  String get driverInUse => '使用中';

  @override
  String get driverUnbound => '未绑定';

  @override
  String get exportAndRemove => '导出并移除';

  @override
  String get confirmDriverRemoval => '确认从驱动程序存储中移除';

  @override
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  ) {
    return '发布名称：$published\n原始 INF：$inf\n发布者：$publisher\n版本：$version\n\n移除前 ZapTweaks 会导出驱动包并计算哈希。可能需要重启；恢复只能尽力而为。';
  }

  @override
  String get searchInstalledApps => '搜索已安装的应用';

  @override
  String get scanAllUsers => '扫描所有用户（UAC）';

  @override
  String get systemScopesComplete => '已包含所有用户和预配的 AppX 范围。';

  @override
  String get systemScopesIncomplete =>
      '仅包含当前用户和 winget 清单。扫描所有用户以包含系统 AppX 范围。';

  @override
  String get currentUser => '当前用户';

  @override
  String get allUsers => '所有用户';

  @override
  String get provisioned => '已预配';

  @override
  String get confirmAppxRemoval => '确认移除 AppX';

  @override
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  ) {
    return '应用：$name\n标识：$id\n范围：$scope\n恢复：$recovery\n\n只会移除列出的范围。此操作无法精确回滚。';
  }

  @override
  String get reinstallable => '有已验证的恢复来源';

  @override
  String get notReinstallable => '没有已验证的恢复来源';

  @override
  String get allCategories => '所有类别';

  @override
  String get installedOnly => '仅已安装';

  @override
  String get refreshInventory => '刷新清单';

  @override
  String get install => '安装';

  @override
  String get uninstall => '卸载';

  @override
  String get uninstallSelected => '卸载所选';

  @override
  String get openOfficialPage => '打开官方页面';

  @override
  String get installed => '已安装';

  @override
  String get notInstalled => '未安装';

  @override
  String get appInventoryUnavailable => '无法检测已安装的应用。';

  @override
  String get confirmBulkUninstall => '确认批量卸载';

  @override
  String confirmBulkUninstallMessage(Object apps) {
    return '将卸载以下应用：\n\n$apps';
  }

  @override
  String get appCatalogSources =>
      '目录合并自固定版本的 CTT WinUtil、Winhance 的净室候选项、TweakHub 以及所请求的官方来源。';

  @override
  String get tcpOptimizer => 'TCP 优化器';

  @override
  String get tcpOptimizerDescription =>
      '检查并配置 Windows TCP 模板、全局卸载、每应用 QoS 和可重复的网络诊断。';

  @override
  String get tcpNoRecommendation => '不会自动推荐任何值。回读结果或单次网络测试不能证明性能有所提升。';

  @override
  String get tcpLiveState => '实时 TCP 状态';

  @override
  String get tcpTemplates => 'TCP 模板';

  @override
  String get tcpGlobal => '全局 TCP 卸载';

  @override
  String get tcpAutotuning => '接收窗口自动调节';

  @override
  String get tcpHeuristics => '窗口缩放启发式设置';

  @override
  String get tcpEcn => 'ECN 功能';

  @override
  String get tcpCongestion => '拥塞控制';

  @override
  String get tcpRsc => '接收段合并 (RSC)';

  @override
  String get tcpRss => '全局接收端缩放 (RSS)';

  @override
  String get tcpConfigure => '配置';

  @override
  String get tcpChangePreview => 'TCP 更改预览';

  @override
  String get tcpCurrentValue => '当前值';

  @override
  String get tcpNewValue => '新值';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks 将保存当前准确值，通过一次 UAC 请求应用更改，回读并记入日志，同时保留准确回滚能力。';

  @override
  String get tcpUnsupported => '此 Windows 版本未提供';

  @override
  String get tcpAdapterRss => '打开每适配器 RSS 控制';

  @override
  String get rssAdapterState => '每适配器 RSS 状态';

  @override
  String get rssEnabled => 'RSS 已启用';

  @override
  String get rssProfile => 'RSS 配置文件';

  @override
  String get rssQueuesProcessors => '队列/处理器';

  @override
  String get tcpSettingOperationTitle => '配置 TCP 设置';

  @override
  String get tcpSettingOperationDescription =>
      '更改一个系统支持的 Windows TCP 模板或全局卸载值，并支持准确回滚。';

  @override
  String get qosPolicies => '应用程序 QoS 策略';

  @override
  String get qosDescription => '为一个可执行文件创建明确且持久的 QoS 策略。现有的非 ZapTweaks 策略保持只读。';

  @override
  String get qosCreate => '创建策略';

  @override
  String get qosEdit => '编辑';

  @override
  String get qosDelete => '删除';

  @override
  String get qosName => '策略名称';

  @override
  String get qosAppPath => '可执行文件路径';

  @override
  String get qosProtocol => '协议';

  @override
  String get qosSourcePort => '源端口（可选）';

  @override
  String get qosDestinationPort => '目标端口（可选）';

  @override
  String get qosDscp => 'DSCP 0–63（可选）';

  @override
  String get qosThrottleMbps => '限速 Mbit/s（可选）';

  @override
  String get qosOwnedOnly => '名称必须以“ZapTweaks - ”开头。仅更改所选策略；绝不会清除其他 QoS 策略。';

  @override
  String get qosDeleteConfirm => '删除所选 QoS 策略？其准确状态将保存在 ZapTweaks 日志中，以便回滚。';

  @override
  String get qosReadOnly => '只读';

  @override
  String get qosPolicyOperationTitle => '配置应用程序 QoS';

  @override
  String get qosPolicyOperationDescription =>
      '创建、编辑或删除一条经过验证的持久每应用 QoS 策略，并支持准确回滚。';

  @override
  String get networkDiagnostics => '更改前/后诊断';

  @override
  String get networkDiagnosticsDescription =>
      '在有限范围内测量 TCP 连接延迟、抖动、丢包和 HTTPS 下载吞吐量。结果是诊断依据，并非建议。';

  @override
  String get diagnosticEndpoint => '测试文件的直接 HTTPS URL';

  @override
  String get diagnosticNetworkCost => '测试最多从您输入的端点下载 10 MiB。未内置任何第三方端点。';

  @override
  String get diagnosticBaseline => '运行基准测试';

  @override
  String get diagnosticComparison => '运行对比测试';

  @override
  String get diagnosticCancel => '取消测量';

  @override
  String get diagnosticLatency => '延迟';

  @override
  String get diagnosticJitter => '抖动';

  @override
  String get diagnosticPacketLoss => '丢包率';

  @override
  String get diagnosticThroughput => '吞吐量';

  @override
  String get diagnosticRawSamples => '原始延迟样本';

  @override
  String get diagnosticDownloadedBytes => '已下载字节数';

  @override
  String get diagnosticDifference => '差值 B − A';

  @override
  String get tcpAttribution => '灵感来自 WINSPAR — powplowdevs（固定修订版）';

  @override
  String get openRecoveryHistory => '打开恢复和日志';

  @override
  String get manualRestoreTitle => '恢复原始手动设置';

  @override
  String get manualRestoreWarning =>
      '恢复记录的原始值，而非默认值。之后改动过的设置不会被覆盖。高风险设置需要专家模式和 UAC。恢复后请查看日志；可能仍需重启或注销。';

  @override
  String get cleanupUserTemp => 'UserTemp 清理';

  @override
  String get cleanupUserTempDescription =>
      '查看并选择当前用户 Temp 目录中的具体文件。不自动选择，不强制删除，也不删除文件夹。';

  @override
  String get cleanupSelectFiles => '预览并选择文件';

  @override
  String get cleanupShaderCache => 'GPU 着色器缓存清理';

  @override
  String get cleanupShaderCacheDescription =>
      '逐个文件夹预览当前用户的 DirectX、AMD、NVIDIA 和 Intel 着色器缓存，并只删除预览中找到的文件。驱动会重新生成它们，因此每个游戏首次启动时可能会卡顿。请先关闭游戏。不可撤销。';

  @override
  String get cleanupShaderCacheNone => '未找到 GPU 着色器缓存文件。';

  @override
  String get cleanupShaderCacheCompleted => '预览中的着色器缓存文件已删除，并已确认不再存在。';

  @override
  String get cleanupPreview => '预览';

  @override
  String get cleanupUserTempNone => '未找到 UserTemp 文件。';

  @override
  String get cleanupPermanentWarning =>
      '永久删除。无法回滚，也不会绕过权限或文件锁。请先关闭应用程序。若删除失败，之前的文件可能已被删除。';

  @override
  String get cleanupUserTempSelectionHint =>
      '尚未选择任何内容。只选择你认识的文件；此次预览之后创建的文件不包括在内。';

  @override
  String cleanupPreviewCount(int count, int bytes) {
    return '$count 个文件，$bytes 字节';
  }

  @override
  String get cleanupRecycleUnavailable => '回收站清理不可用：无法安全地预览并删除确切的项目。不会执行全部清空。';

  @override
  String get cleanupCrashReports => '崩溃转储和错误报告';

  @override
  String get cleanupCrashReportsDescription =>
      '删除你的程序的崩溃转储（%LOCALAPPDATA%\\CrashDumps）以及 Windows 错误报告的存档和队列。适用于某个游戏或应用多次崩溃之后。不会触及系统小型转储（蓝屏）。';

  @override
  String get cleanupCrashReportsNone => '没有可删除的崩溃转储或错误报告。';

  @override
  String get cleanupCrashReportsCompleted => '崩溃转储和错误报告已删除。';

  @override
  String get cleanupBrowserCache => '浏览器缓存';

  @override
  String get cleanupBrowserCacheDescription =>
      '删除 Chrome、Edge、Brave（所有配置文件）和 Firefox 的磁盘缓存。不会触及 Cookie、历史记录、密码和扩展；网页首次加载会稍慢。';

  @override
  String get cleanupBrowserCacheNone => '没有可删除的浏览器缓存文件。';

  @override
  String get cleanupBrowserCacheCompleted => '浏览器缓存已删除。';

  @override
  String cleanupBrowserRunning(String browsers) {
    return '请先关闭 $browsers（包括系统托盘中的：Edge 和 Chrome 可能在后台继续运行）。';
  }

  @override
  String thermalZoneLimited(String percent) {
    return '固件将 CPU 限制在 $percent%';
  }

  @override
  String get thermalSourceCounters =>
      '来源：Windows“Thermal Zone Information”计数器（由固件定义的 ACPI 区域，无需管理员权限）。区域是厂商选择的传感器，通常不是 CPU 核心本身。';

  @override
  String get thermalSourceAcpi =>
      '来源：MSAcpi_ThermalZoneTemperature（由固件定义的 ACPI 区域）。区域是厂商选择的传感器，通常不是 CPU 核心本身。';

  @override
  String get thermalSourceNone =>
      '此电脑的固件未提供任何 ACPI 温度区域（台式机主板上很常见）。宁可不显示，也不显示未经测量的值。';

  @override
  String get srumTab => '应用历史';

  @override
  String get srumTitle => '应用历史（SRUM）';

  @override
  String get srumDescription =>
      '过去 30 天内每个程序的网络、CPU 和磁盘使用情况，由 Windows 记录（System Resource Usage Monitor）。只读：ZapTweaks 读取数据库的卷影副本，之后将其删除。需要管理员权限。';

  @override
  String get srumRead => '读取历史';

  @override
  String get srumNotCollectingTitle => 'Windows 未在记录应用历史';

  @override
  String srumNotCollecting(String status, String startType, String date) {
    return '记录此历史的诊断策略服务当前为 $status（$startType）。数据截止于 $date。';
  }

  @override
  String get srumNoData => '过去 30 天内没有记录到使用情况。';

  @override
  String get srumNetwork => '网络（发送 / 接收）';

  @override
  String get srumCpu => 'CPU 时间（占所有程序的比例；其中后台部分）';

  @override
  String srumCpuShare(String share, String background) {
    return '$share% · 后台 $background%';
  }

  @override
  String get srumUnattributed => '未归属于任何程序';

  @override
  String srumSource(String first, String last) {
    return '来源：C:\\Windows\\System32\\sru\\SRUDB.dat，记录时间从 $first 到 $last。Windows 大约每小时写入一次。';
  }

  @override
  String get manualControls => '手动控制';

  @override
  String upToDate(String version) {
    return '你正在使用最新版本（$version）。';
  }

  @override
  String get startCapture => '开始捕获';

  @override
  String get batteryHealth => '电池健康';

  @override
  String get batteryHealthDescription => '电池相对设计容量仍能保持的容量。只读。';

  @override
  String get batteryGood => '良好';

  @override
  String get batteryFair => '有损耗';

  @override
  String get batteryPoor => '建议尽快更换';

  @override
  String get notAvailable => '不可用';

  @override
  String get batteryDesigned => '设计容量';

  @override
  String get batteryFullCharge => '完全充电容量';

  @override
  String get batteryWear => '损耗';

  @override
  String get batteryCycles => '充电循环';

  @override
  String get batteryCharge => '当前电量';

  @override
  String get batteryOnAc => '已接通电源';

  @override
  String get batteryOnBattery => '使用电池';

  @override
  String get batterySourceWmi =>
      '来源：root\\wmi BatteryStaticData、BatteryFullChargedCapacity、BatteryCycleCount 和 BatteryStatus，由电池固件报告。';

  @override
  String get batterySourceReport =>
      '来源：powercfg /batteryreport（临时 XML，读取后删除），由电池固件报告。';

  @override
  String get appTypeSystem => '系统';

  @override
  String get appTypeUser => '用户';

  @override
  String get appTypeStore => '应用商店';

  @override
  String get appSafetyRemovable => '可以移除';

  @override
  String get appSafetyCheckFirst => '先检查';

  @override
  String get appSafetyKeep => '保留';

  @override
  String get appReasonSystemComponent => 'Windows 或厂商的隐藏组件。';

  @override
  String get appReasonProtected => '其安装程序禁止移除。';

  @override
  String get appReasonUpdate => '其他程序的更新：请移除该程序。';

  @override
  String get appReasonWindowsPart => 'Windows 的一部分或其他应用需要的框架。';

  @override
  String get appReasonSharedDependency => '被其他应用使用（运行库、驱动或厂商面板）。';

  @override
  String get appReasonOptionalFeature => 'Windows 可选功能：请先了解哪些功能会失效。';

  @override
  String get appReasonMissingUninstaller => '未注册卸载程序。';

  @override
  String get appReasonUserInstalled => '由你或电脑厂商安装；没有其他程序依赖它。';

  @override
  String get appLabelMissingUninstaller => '无卸载程序';

  @override
  String get appLabelProtected => '受保护';

  @override
  String get appLabelSystemComponent => '系统组件';

  @override
  String get appLabelUpdate => '更新';

  @override
  String get filterAll => '全部';

  @override
  String get filterType => '类型';

  @override
  String get filterSafety => '安全性';

  @override
  String get filterSource => '来源';

  @override
  String get sourceWholePc => '整台电脑';

  @override
  String get sortBy => '排序';

  @override
  String get sortSize => '大小';

  @override
  String get sortName => '名称';

  @override
  String get sortDate => '安装日期';

  @override
  String appsShown(int count) {
    return '$count 个应用';
  }

  @override
  String selectionSummary(int count, String size) {
    return '已选 $count 个 · $size';
  }

  @override
  String selectionUnknownSizes(int count) {
    return '$count 个大小未知';
  }

  @override
  String get appsSource =>
      '来源：注册表 Uninstall 键（HKLM 64/32 位、HKCU）、Get-AppxPackage、用于重新安装 ID 的 winget export。大小：EstimatedSize，否则为安装文件夹。';

  @override
  String get noAppsMatch => '没有符合筛选条件的应用。';

  @override
  String reinstallableVia(String id) {
    return '重新安装：winget $id';
  }

  @override
  String get uninstallQueueTitle => '卸载队列';

  @override
  String get uninstallModeSilent => '静默';

  @override
  String get uninstallModeWindowed => '会打开窗口';

  @override
  String get uninstallManualNoUninstaller => '手动：未注册卸载程序。';

  @override
  String get uninstallManualUnsafe =>
      '手动：注册的命令会启动 shell 或脚本，因此 ZapTweaks 不会执行。';

  @override
  String get uninstallManualNotFound => '手动：卸载程序文件不存在。';

  @override
  String uninstallRunningWarning(String processes) {
    return '仍在从其文件夹运行：$processes。请先关闭。';
  }

  @override
  String get uninstallSimulate => '模拟：只规划并显示队列，不卸载任何内容';

  @override
  String get uninstallRestorePointNote => '先创建还原点。先逐个运行会打开窗口的卸载，再运行静默卸载。';

  @override
  String get uninstallStart => '开始卸载';

  @override
  String get restorePointCreating => '正在创建还原点…';

  @override
  String get restorePointFailed => '未创建还原点。系统保护可能已关闭。未做任何更改。';

  @override
  String get restorePointEnableAndRetry => '开启系统保护并重试';

  @override
  String get queueWaiting => '等待中';

  @override
  String get queueRunning => '进行中';

  @override
  String get queueDone => '完成';

  @override
  String get queueFailed => '失败';

  @override
  String get queueSkipped => '已跳过';

  @override
  String get queueSkip => '跳过';

  @override
  String get queueStop => '完成当前项后停止';

  @override
  String get queueSimulated => '模拟：未卸载任何内容。';

  @override
  String get uninstallStoreAppsHint => '所选应用商店应用请使用其所在行的卸载菜单。';

  @override
  String get leftoverSearch => '查找残留';

  @override
  String get leftoverTitle => '残留';

  @override
  String get leftoverGood => '确定';

  @override
  String get leftoverMedium => '可能';

  @override
  String get leftoverLow => '不确定';

  @override
  String get leftoverKindFolder => '文件夹';

  @override
  String get leftoverKindShortcut => '快捷方式';

  @override
  String get leftoverKindRegistry => '注册表项';

  @override
  String get leftoverKindRun => '启动项';

  @override
  String get leftoverKindTask => '计划任务';

  @override
  String get leftoverKindFirewall => '防火墙规则';

  @override
  String get leftoverNone => '未发现残留。';

  @override
  String leftoverRemoveSelected(int count) {
    return '移除所选（$count）';
  }

  @override
  String get leftoverBackupNote =>
      '默认只勾选“确定”的项目。移除前注册表项导出为 .reg，计划任务导出为 XML，防火墙规则导出为 JSON；文件和文件夹移入回收站。';

  @override
  String leftoverRemoved(String path) {
    return '残留已移除。备份位置：$path';
  }

  @override
  String get leftoverRefusedInvalid => '未移除：条目无效或不安全。';

  @override
  String get leftoverRefusedOutside => '未移除：超出 ZapTweaks 在此处可清理的范围。';

  @override
  String get leftoverRefusedShared => '未移除：与 Windows 或其他程序共用。';

  @override
  String get orphanFolders => '孤立文件夹';

  @override
  String get orphanFoldersNote =>
      'Program Files 中没有任何已安装程序引用的文件夹。便携工具或驱动包也可能如此，因此默认不勾选：请逐一检查。';

  @override
  String get openLocation => '打开位置';

  @override
  String get processesTab => '进程';

  @override
  String get searchProcesses => '搜索进程';

  @override
  String get sortMemory => '内存';

  @override
  String get sortCpu => 'CPU';

  @override
  String get processKindWindows => 'Windows';

  @override
  String get processKindMicrosoft => 'Microsoft 应用';

  @override
  String get processKindThirdParty => '第三方';

  @override
  String get processCanClose => '可以关闭';

  @override
  String get processLeaveRunning => '保持运行';

  @override
  String get processReasonCritical => 'Windows 需要它：关闭可能会注销或导致系统崩溃。';

  @override
  String get processReasonWindowsFolder => '从 Windows 文件夹运行或受保护。';

  @override
  String get processReasonService => '运行着一个服务：请在“服务”选项卡中管理。';

  @override
  String get processReasonSelf => '这是 ZapTweaks。';

  @override
  String get processReasonUserApp => '你启动的应用：关闭后未保存的内容会丢失。';

  @override
  String get processEnd => '结束进程';

  @override
  String processEndConfirm(String name) {
    return '结束 $name？未保存的内容将丢失。';
  }

  @override
  String get processEndChanged => '它已关闭，或其 ID 已属于其他进程：未结束任何进程。';

  @override
  String get processEndFailed => 'Windows 拒绝结束它。它可能以管理员身份运行。';

  @override
  String get searchOnline => '在线搜索';

  @override
  String get processOnlyClosable => '仅显示可关闭的';

  @override
  String get processNote => '快照：CPU 仅采样一次，刷新以重新读取。列表显示后再校验签名。系统进程从不建议关闭。';

  @override
  String get noProcessesMatch => '没有符合这些筛选条件的进程。';

  @override
  String signedBy(String signer) {
    return '签名者：$signer';
  }

  @override
  String get servicesTab => '服务';

  @override
  String get searchServices => '搜索服务';

  @override
  String get filterOrigin => '来源';

  @override
  String get originMicrosoft => 'Microsoft';

  @override
  String get serviceCanDisable => '可以禁用';

  @override
  String get serviceDependsOnUse => '取决于用途';

  @override
  String get serviceKeep => '保留';

  @override
  String get serviceStartAutomatic => '自动';

  @override
  String get serviceStartDelayed => '自动（延迟启动）';

  @override
  String get serviceStartManual => '手动';

  @override
  String get serviceStartDisabled => '已禁用';

  @override
  String get serviceStartBoot => '引导';

  @override
  String get serviceRunning => '正在运行';

  @override
  String get serviceStopped => '已停止';

  @override
  String get serviceSetDisabled => '禁用';

  @override
  String get serviceSetManual => '设为手动';

  @override
  String get serviceSetAutomatic => '设为自动';

  @override
  String serviceChangeTitle(String service) {
    return '更改 $service';
  }

  @override
  String serviceChangeConfirm(String from, String to, String reason) {
    return '启动类型：$from → $to。\n$reason\n在服务或 Windows 下次启动时生效。之后可立即撤销。';
  }

  @override
  String serviceChanged(String service, String to) {
    return '$service 现在为 $to。';
  }

  @override
  String get serviceUndo => '撤销';

  @override
  String get serviceNote =>
      '更改需要管理员权限，并在服务或 Windows 下次启动时生效。Windows 需要的服务从不建议更改；禁用其他服务依赖的服务会被拒绝。';

  @override
  String get noServicesMatch => '没有符合这些筛选条件的服务。';

  @override
  String get svcReasonTelemetry => '向 Microsoft 发送使用和诊断数据。你使用的功能都不会受影响。';

  @override
  String get svcReasonDeviceManagement => '遥测和工作或学校设备管理：仅当组织管理此电脑时才需要。';

  @override
  String get svcReasonCrashReports => '向 Microsoft 发送崩溃报告。崩溃仍会记录在此电脑上。';

  @override
  String get svcReasonRemoteRegistry => '允许其他计算机通过网络编辑此电脑的注册表。默认关闭。';

  @override
  String get svcReasonOfflineMaps => '为“地图”应用更新离线地图。';

  @override
  String get svcReasonMediaSharing => '在网络上共享 Windows Media Player 媒体库。';

  @override
  String get svcReasonRetailDemo => '商店演示模式。家用从不需要。';

  @override
  String get svcReasonXbox => '停用后：Xbox 应用、Game Pass、云存档和 Xbox 配件将无法使用。';

  @override
  String get svcReasonPrinting => '停用后：打印将无法使用，包括“打印到 PDF”。';

  @override
  String get svcReasonBluetooth => '停用后：蓝牙设备将无法连接。';

  @override
  String get svcReasonSearch => '停用后：开始菜单、设置和文件资源管理器中的搜索会变慢且不完整。';

  @override
  String get svcReasonSysMain => '预加载常用应用。停用后启动可能变慢，机械硬盘上尤其明显。';

  @override
  String get svcReasonTouchKeyboard => '停用后：触摸键盘、手写、表情面板和部分输入法将无法使用。';

  @override
  String get svcReasonLocation => '停用后：应用和“查找我的设备”将无法获取你的位置。';

  @override
  String get svcReasonBiometrics => '停用后：Windows Hello 人脸和指纹登录将无法使用。';

  @override
  String get svcReasonPhone => '停用后：通过“手机连接”拨打电话将无法使用。';

  @override
  String get svcReasonRemoteDesktop => '停用后：远程桌面连接到此电脑将无法使用。';

  @override
  String get svcReasonSmartCard => '停用后：智能卡和部分安全密钥将无法使用。';

  @override
  String get svcReasonParental => '停用后：Microsoft 家庭安全的限制将不再生效。';

  @override
  String get svcReasonNfc => '停用后：NFC 和非接触支付将无法使用。';

  @override
  String get svcReasonHotspot => '停用后：移动热点将无法使用。';

  @override
  String get svcReasonScanner => '停用后：扫描仪和部分相机将无法使用。';

  @override
  String get svcReasonCompatibility => '停用后：旧程序无法运行时，Windows 将不再提供修复。';

  @override
  String get svcReasonFax => '停用后：传真将无法使用。';

  @override
  String get svcReasonInsider => '停用后：将不再收到 Windows 预览体验版本。';

  @override
  String get svcReasonUpdates => 'Windows 更新需要它：停用后将收不到安全修复。';

  @override
  String get svcReasonSecurity => '保护此电脑（防病毒、防火墙、安全状态）。';

  @override
  String get svcReasonWindowsCore => 'Windows 需要它来提供声音、网络、日志或基本系统功能。';

  @override
  String get svcReasonNotReviewed => '属于 Windows 且未经审核：请保持原样。';

  @override
  String get svcReasonDriverService => '随驱动程序安装：除非你清楚其作用，否则请保持原样。';

  @override
  String get svcReasonMicrosoftApp => '属于 Microsoft 应用：停用后该应用可能无法运行或更新。';

  @override
  String get svcReasonThirdParty => '随其他程序安装：停用后该程序可能无法运行或更新。';

  @override
  String get serviceStartTypeAction => '更改启动';

  @override
  String get presetsTab => '预设';

  @override
  String get presetDebloatName => '仅精简';

  @override
  String get presetDebloatSummary => '移除很少有人使用的预装 Microsoft 应用。不更改其他内容。';

  @override
  String get presetCleanName => '干净';

  @override
  String get presetCleanSummary => '精简，并关闭遥测和不用的服务，以及无故随 Windows 启动的应用。';

  @override
  String get presetGamingName => '游戏';

  @override
  String get presetGamingSummary =>
      '干净，并加入游戏设置：不对运行中的应用节流，任务栏中可“结束任务”。保留 Xbox。';

  @override
  String get presetPrivacyName => '隐私';

  @override
  String get presetPrivacySummary =>
      '干净，并应用 Microsoft 指南中的隐私设置：广告 ID、跟踪、建议，诊断数据降至最低。';

  @override
  String get presetCompetitiveName => '竞技';

  @override
  String get presetCompetitiveSummary =>
      '移除其他预设移除的一切以及更多：常用应用、Xbox、打印、开机启动的启动器、游戏录制。另需手动进行驱动纯净安装和 WinSux。';

  @override
  String get presetAttention => '注意';

  @override
  String get presetAttentionNote =>
      '会移除很多内容，包括许多人常用的功能。不承诺任何 FPS、延迟或其他提升：这是一组更改，而非经测量的改进。';

  @override
  String get presetGroupApps => '移除的应用（当前用户）';

  @override
  String get presetGroupServices => '禁用的服务';

  @override
  String get presetGroupStartup => '关闭的启动项';

  @override
  String get presetGroupTweaks => '设置';

  @override
  String get presetGroupThirdParty => '第三方脚本和工具';

  @override
  String get presetGroupRestart => '重启';

  @override
  String get presetGroupReversible => '可撤销的内容';

  @override
  String get presetRestartNeeded => '完成后请重启：服务和启动项将在下次启动时生效。';

  @override
  String get presetRestartNone => '无需重启。';

  @override
  String get presetReversibleApps => '应用：可从 Microsoft Store 重新安装。';

  @override
  String get presetReversibleSettings =>
      '服务、启动项和设置：可在完成后立即点“撤销预设”，或稍后用事先创建的还原点恢复。';

  @override
  String get presetReversibleManual => '第三方步骤不由 ZapTweaks 执行：撤销请按作者的说明操作。';

  @override
  String get presetManualWhy =>
      '需手动执行：该脚本会下载并运行无法用哈希固定的其他文件，因此 ZapTweaks 不会运行它。';

  @override
  String get presetManualDriverClean => '显卡驱动纯净安装：在安全模式下运行 DDU，然后安装厂商最新驱动。';

  @override
  String get presetManualWinsux => 'WinSux：一个脚本完成 Windows 精简和设置。';

  @override
  String get presetPreview => '在此电脑上预览';

  @override
  String get presetPreviewLoading => '正在读取应用、服务、启动项和设置…';

  @override
  String get presetStatusApply => '待执行';

  @override
  String get presetStatusDone => '已设置';

  @override
  String get presetStatusSkipped => '已跳过';

  @override
  String get presetStatusManual => '手动';

  @override
  String get presetSkipNotInstalled => '未安装';

  @override
  String get presetSkipNotFound => '此电脑上不存在';

  @override
  String get presetSkipUnsupported => '此处不支持';

  @override
  String get presetSkipDuplicate => '名称重复：仅更改第一个';

  @override
  String presetCounts(int apply, int done, int skipped) {
    return '$apply 项待执行 · $done 项已设置 · $skipped 项已跳过';
  }

  @override
  String get presetConsent => '我已阅读完整列表并接受风险。';

  @override
  String get presetApply => '应用预设';

  @override
  String get presetApplyNote => '会先创建还原点；若失败则不做任何更改。管理员更改会请求一次 UAC。';

  @override
  String get presetApplying => '正在应用…';

  @override
  String presetReport(int ok, int failed) {
    return '完成：已更改 $ok 项，未更改 $failed 项。';
  }

  @override
  String get presetUndo => '撤销预设';

  @override
  String get presetUndone => '已撤销预设。已移除的应用不会自动恢复：请从 Store 重新安装。';

  @override
  String get presetNothingToDo => '无需操作：一切已设置完毕。';

  @override
  String get presetSaveAs => '另存为我的预设';

  @override
  String get presetSaveNote => '保存仍勾选的项目。分享文件即可导出；将文件放入文件夹即可导入。';

  @override
  String get presetName => '名称';

  @override
  String presetSaved(String path) {
    return '已保存：$path';
  }

  @override
  String get presetOpenFolder => '打开预设文件夹';

  @override
  String get presetUserTitle => '我的预设';

  @override
  String presetInvalidFile(String file, String error) {
    return '$file 未加载：$error';
  }

  @override
  String get presetItemPowerThrottling => '关闭对运行中应用的电源节流';

  @override
  String get presetItemEndTask => '任务栏菜单中的“结束任务”';

  @override
  String get presetItemAdvertisingId => '关闭广告 ID';

  @override
  String get presetItemLanguageList => '网站无法读取你的语言列表';

  @override
  String get presetItemAppLaunchTracking => 'Windows 不跟踪你启动的应用';

  @override
  String get presetItemTailoredExperiences => '不使用诊断数据提供个性化体验';

  @override
  String get presetItemCloudContent => '不显示云优化内容（建议）';

  @override
  String get presetItemDiagnosticData => '诊断数据：仅必需';

  @override
  String get presetItemLockScreenOverlay => '锁屏不显示提示';

  @override
  String get presetItemLockScreenFacts => '锁屏不显示趣闻';

  @override
  String get presetItemGameDvr => '关闭 Game Bar 游戏录制';

  @override
  String get presetSkipHasDependents => '其他服务依赖它，因此 Windows 不允许禁用。';

  @override
  String get settingsGeneral => '常规';

  @override
  String get settingsModes => '模式';

  @override
  String get settingsMaintenance => '维护';

  @override
  String get settingsAbout => '关于';

  @override
  String get openLogFolderDescription => '会话日志，包含 ZapTweaks 运行的每条命令。';

  @override
  String get redetectSystemStateDescription => '重新读取硬件和每项优化的状态。';

  @override
  String get profileTitle => '设置配置文件';

  @override
  String get profileDescription => '将 ZapTweaks 偏好设置保存到文件或从文件加载。';

  @override
  String get resetAppSettingsDescription =>
      '恢复 ZapTweaks 的默认偏好设置。不会更改 Windows。';

  @override
  String get expertModeOn => '开';

  @override
  String get expertModeOff => '关';
}
