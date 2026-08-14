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
  String get aggressiveTweakWarning => '激进的调整。还原点是必需的。';

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
}
