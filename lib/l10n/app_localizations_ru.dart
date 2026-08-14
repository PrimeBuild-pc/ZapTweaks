// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Язык';

  @override
  String get languageDescription => 'Выберите язык ZapTweaks.';

  @override
  String get settings => 'Настройки';

  @override
  String get startWithWindows => 'Запускать с Windows';

  @override
  String get startWithWindowsDescription =>
      'Запускать ZapTweaks после входа в Windows.';

  @override
  String get openLogFolder => 'Открыть папку журналов';

  @override
  String get redetectSystemState => 'Повторно определить состояние системы';

  @override
  String get exportProfile => 'Экспортировать профиль';

  @override
  String get importProfile => 'Импортировать профиль';

  @override
  String get resetAppSettings => 'Сбросить настройки приложения';

  @override
  String get updates => 'Обновления';

  @override
  String get automaticUpdateNotifications =>
      'Автоматические уведомления об обновлениях';

  @override
  String get automaticUpdateDescription =>
      'Проверять при запуске и показывать индикатор. Обновления никогда не устанавливаются автоматически.';

  @override
  String get checking => 'Проверка...';

  @override
  String get checkNow => 'Проверить';

  @override
  String get viewRelease => 'Открыть релиз';

  @override
  String get updateNow => 'Обновить';

  @override
  String get applicationVersion => 'Версия приложения';

  @override
  String get dryRunMode => 'Режим симуляции';

  @override
  String get dryRunDescription => 'Симулирует команды без изменения Windows.';

  @override
  String get done => 'Готово';

  @override
  String get operationFailed => 'Сбой операции';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get updateAvailableDescription =>
      'Можно просмотреть примечания к выпуску или установить его напрямую.';
}
