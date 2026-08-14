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
}
