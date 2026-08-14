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

  @override
  String get updateAvailableShort => 'Доступно обновление';

  @override
  String get checkingForUpdates => 'Проверка обновлений';

  @override
  String get contactingReleaseServer => 'Обращение к серверу выпуска...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version доступна';
  }

  @override
  String installedVersion(Object version) {
    return 'Установленная версия: $version';
  }

  @override
  String get releaseNotesOnGitHub => 'Примечания к выпуску доступны на GitHub.';

  @override
  String get later => 'Позже';

  @override
  String get failed => 'Не удалось';

  @override
  String get downloadingUpdate => 'Загрузка обновления';

  @override
  String get downloadingUpdateDescription =>
      'Скачиваем и готовим установщик...';

  @override
  String get adminPrivilegesRequired => 'Требуются права администратора';

  @override
  String get adminRequiredBanner =>
      'Закройте приложение и запустите ZapTweaks с параметром «Запуск от имени администратора». Без повышения прав нельзя безопасно применять настройки системы.';

  @override
  String get cancel => 'Отмена';

  @override
  String get createRestorePoint => 'Создать точку восстановления';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks требуются права администратора для применения системных настроек.\n\nЗакройте приложение, щелкните правой кнопкой мыши исполняемый файл и выберите «Запуск от имени администратора».';

  @override
  String get understood => 'понял';

  @override
  String aboutVersion(Object version) {
    return 'Версия: v$version';
  }

  @override
  String get author => 'Автор: PrimeBuild';

  @override
  String get aboutDescription =>
      'Расширенный помощник по оптимизации для более глубоких рабочих процессов Windows в играх, оборудовании и диагностике.';

  @override
  String year(Object year) {
    return 'Год: $year';
  }

  @override
  String get close => 'Закрыть';

  @override
  String get github => 'GitHub';

  @override
  String get discord => 'Раздор';

  @override
  String get homeAndStats => 'Главная и статистика';

  @override
  String get cpuUsage => 'Использование ЦП';

  @override
  String get cpuUsageDescription =>
      'Использование в реальном времени по счетчикам Windows';

  @override
  String get gpuUsage => 'Использование графического процессора';

  @override
  String get gpuUsageDescription =>
      'Использование двигателя в реальном времени';

  @override
  String get vramUsage => 'Использование видеопамяти';

  @override
  String get memoryUsage => 'Использование памяти';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get installedRam => 'Установленная оперативная память';

  @override
  String get networkAdapters => 'Сетевые адаптеры';

  @override
  String get noConnectedAdapters => 'Подключенные адаптеры не обнаружены';

  @override
  String get audioDevices => 'Аудиоустройства';

  @override
  String get noAudioDevices => 'Аудиоустройства не обнаружены';

  @override
  String get noTweaksAvailable =>
      'Для вашей аппаратной конфигурации нет настроек.';

  @override
  String get detectedHardware => 'Обнаруженное оборудование';

  @override
  String get gpuUnknown => 'Графический процессор: Неизвестно';

  @override
  String cpuValue(Object value) {
    return 'ЦП: $value';
  }

  @override
  String gpuValue(Object value) {
    return 'Графический процессор: $value';
  }

  @override
  String ramValue(Object value) {
    return 'ОЗУ: $value';
  }

  @override
  String get enableAllVisible => 'Включить все видимое';

  @override
  String get disableAllVisible => 'Отключить все видимое';

  @override
  String get restartNow => 'Перезагрузить сейчас';

  @override
  String get restartRequired => 'Требуется перезагрузка';

  @override
  String get restartRequiredDescription =>
      'Для полного применения одного или нескольких изменений требуется перезагрузка системы.';

  @override
  String get advancedActionsIncluded => 'Расширенные действия включены';

  @override
  String get advancedActionsDescription =>
      'Внешние инструменты, действия средства запуска и утилиты на основе сценариев сгруппированы здесь для быстрой диагностики и рабочих процессов обслуживания.';

  @override
  String get aggressiveTweakWarning =>
      'Агрессивная настройка. Точка восстановления обязательна.';

  @override
  String get networkReconnectWarning =>
      'Может потребоваться повторное подключение сетевого адаптера или перезагрузка системы.';

  @override
  String get actionWarning => 'Предупреждение о действиях';

  @override
  String get unknownError => 'Неизвестная ошибка.';

  @override
  String get presets => 'Пресеты';

  @override
  String get presetFailed => 'Не удалось выполнить предустановку';

  @override
  String get safetyWarning => 'Предупреждение о безопасности';

  @override
  String get unavailable => 'Недоступно';

  @override
  String get powerPlans => 'Комплексные планы электропитания';

  @override
  String get powerPlansDescription =>
      'Импортируйте и активируйте пакетный план. ZapTweaks запоминает предыдущий активный план восстановления.';

  @override
  String get noPowerPlans =>
      'Никаких связанных планов электропитания не обнаружено.';

  @override
  String get working => 'Работаю...';

  @override
  String get importAndActivate => 'Импортируйте и активируйте';

  @override
  String get restorePreviousPlan => 'Восстановить предыдущий план';

  @override
  String get ran => 'Ран';
}
