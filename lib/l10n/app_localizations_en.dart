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
}
