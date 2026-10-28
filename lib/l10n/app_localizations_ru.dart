// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get externalDownload => 'Внешняя загрузка';

  @override
  String get appRequirements => 'Требования';

  @override
  String get appWarnings => 'Предупреждения';

  @override
  String get metricUnavailable => 'Н/Д';

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Язык';

  @override
  String get languageDescription => 'Выберите язык ZapTweaks.';

  @override
  String get appearance => 'Оформление';

  @override
  String get appearanceDescription =>
      'Следовать Windows или использовать постоянную светлую или тёмную тему приложения.';

  @override
  String get themeSystem => 'Как в Windows';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

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
      'Агрессивная настройка. Рекомендуется точка восстановления.';

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

  @override
  String get gpuDrivers => 'Драйверы графического процессора';

  @override
  String get noGpuDrivers => 'Драйверы графического процессора не обнаружены';

  @override
  String get chipsetDrivers => 'Драйверы чипсета';

  @override
  String get noChipsetDrivers => 'Драйверы чипсета не обнаружены';

  @override
  String get monitors => 'Мониторы';

  @override
  String get noMonitors => 'Мониторы не обнаружены';

  @override
  String get mice => 'Мыши';

  @override
  String get noMice => 'Мышей не обнаружено';

  @override
  String get keyboards => 'Клавиатуры';

  @override
  String get noKeyboards => 'Клавиатуры не обнаружены';

  @override
  String get restorePointPromptTitle => 'Создать точку восстановления?';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks может создать точку восстановления Windows перед изменением системных настроек. Это необязательно: если пропустить, изменение всё равно будет применено. Вопрос задаётся один раз за сеанс.';

  @override
  String get skip => 'Пропустить';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get tweaksSectionHeader => 'НАСТРОЙКИ';

  @override
  String get startingUp => 'Запуск ZapTweaks';

  @override
  String get expertMode => 'Режим эксперта';

  @override
  String get expertModeDescription =>
      'Показывать расширенные операции и внешние инструменты только после явного ручного согласия. По умолчанию выключен; ограничения безопасности продолжают действовать.';

  @override
  String get searchOperations => 'Поиск операций';

  @override
  String get searchResults => 'Результаты поиска';

  @override
  String get searchSections => 'Разделы и встроенные инструменты';

  @override
  String get searchApps => 'Поиск приложений';

  @override
  String get searchCatalog => 'Операции и внешние инструменты';

  @override
  String get searchOpenResult => 'Открыть';

  @override
  String get searchExpertRequired => 'Чтобы открыть, включите режим эксперта';

  @override
  String get noSearchResults =>
      'Нет подходящих разделов, приложений, операций или инструментов.';

  @override
  String get operationTaskbarEndTaskTitle =>
      '«Завершить задачу» на панели задач';

  @override
  String get operationTaskbarEndTaskDescription =>
      'Показывать «Завершить задачу» в контекстном меню приложений на панели задач.';

  @override
  String get appStore => 'Магазин приложений';

  @override
  String get appManagement => 'Установленные приложения';

  @override
  String get windowsAppTools => 'Инструменты приложений Windows';

  @override
  String get optionalFeatures => 'Дополнительные компоненты';

  @override
  String get searchOptionalFeatures => 'Поиск дополнительных компонентов';

  @override
  String get scanOptionalFeatures => 'Сканировать компоненты (UAC)';

  @override
  String get optionalFeaturesUacNotice =>
      'Список компонентов и каждое изменение проходят через разрешённый помощник. Сканирование ничего не меняет.';

  @override
  String get confirmOptionalFeatureChange =>
      'Подтвердите изменение дополнительного компонента';

  @override
  String confirmOptionalFeatureChangeMessage(Object name, Object action) {
    return 'Компонент: $name\nДействие: $action\n\nWindows может потребовать перезагрузку. Прежнее состояние сохраняется до изменения.';
  }

  @override
  String get enable => 'Включить';

  @override
  String get disable => 'Отключить';

  @override
  String get enabled => 'Включён';

  @override
  String get disabled => 'Отключён';

  @override
  String get enablePending => 'Включится после перезагрузки';

  @override
  String get disablePending => 'Отключится после перезагрузки';

  @override
  String get startupApps => 'Автозагрузка';

  @override
  String get searchStartupApps => 'Поиск в автозагрузке';

  @override
  String get openStartupSettings => 'Открыть параметры автозагрузки';

  @override
  String get openTaskManagerStartup =>
      'Открыть автозагрузку в диспетчере задач';

  @override
  String get startupInventoryNotice =>
      'Список автозагрузки только для чтения. Меняйте записи в параметрах Windows или в диспетчере задач.';

  @override
  String get guidedSetup => 'Пошаговая настройка';

  @override
  String get wizardInventory => 'Инвентаризация';

  @override
  String get wizardBaseline => 'Исходное состояние';

  @override
  String get wizardWindowsUpdate => 'Центр обновления Windows';

  @override
  String get wizardDrivers => 'Проверка драйверов';

  @override
  String get wizardApplications => 'Приложения';

  @override
  String get wizardDebloat => 'Выборочная очистка';

  @override
  String get wizardPrivacyInterface => 'Конфиденциальность и интерфейс';

  @override
  String get wizardPreview => 'Предпросмотр плана';

  @override
  String get wizardApply => 'Применение';

  @override
  String get wizardReport => 'Итоговый отчёт';

  @override
  String get wizardInventoryDescription =>
      'Прочитать оборудование, установленные пакеты winget и подключённые устройства до принятия решений.';

  @override
  String get runInventory => 'Запустить инвентаризацию';

  @override
  String inventorySummary(Object apps, Object devices) {
    return 'Найдено пакетов winget: $apps, подключённых устройств: $devices.';
  }

  @override
  String get wizardUpdateNotice =>
      'Проверьте Центр обновления Windows до изменения драйверов и приложений. ZapTweaks не устанавливает обновления автоматически.';

  @override
  String get openWindowsUpdate => 'Открыть Центр обновления Windows';

  @override
  String get updatesReviewed => 'Я проверил Центр обновления Windows';

  @override
  String driverInventorySummary(Object devices, Object missing) {
    return 'Подключённые устройства: $devices\nУстройства без привязанного INF: $missing';
  }

  @override
  String get wizardDebloatNotice =>
      'Ничего не удаляется неявно. Здесь можно выбрать только пакеты AppX текущего пользователя с проверенным источником восстановления; остальные удаления доступны в разделе Приложения → Установленные приложения с отдельным предпросмотром.';

  @override
  String get wizardPrivacyNotice =>
      'Параметры конфиденциальности и интерфейса не меняются, если явно не выбраны ниже.';

  @override
  String get noAppsSelected => 'Операции не выбраны. Мастер ничего не изменит.';

  @override
  String planContains(Object count) {
    return 'План содержит явных операций: $count:';
  }

  @override
  String readyToApply(Object count) {
    return 'Готово к применению операций с приложениями: $count. Каждый пакет проверяется после завершения winget.';
  }

  @override
  String get noPlanReport => 'Завершено без применения плана.';

  @override
  String get planStatus => 'Состояние плана';

  @override
  String get applyPlan => 'Применить план';

  @override
  String get back => 'Назад';

  @override
  String get finish => 'Готово';

  @override
  String get recovery => 'Восстановление';

  @override
  String get diagnosticTools => 'Инструменты диагностики';

  @override
  String get repairComponentStore =>
      'Восстановить хранилище компонентов Windows';

  @override
  String get repairComponentStoreDescription =>
      'Запускает DISM RestoreHealth, затем отдельную проверку ScanHealth. Это может занять много времени.';

  @override
  String get repairSystemFiles => 'Восстановить защищённые системные файлы';

  @override
  String get repairSystemFilesDescription =>
      'Запускает проверку и восстановление SFC, затем отдельный проход проверки.';

  @override
  String get confirmSystemRepair => 'Подтвердите восстановление Windows';

  @override
  String get systemRepairWarning =>
      'Восстановление может заменить повреждённые компоненты Windows, и ZapTweaks не сможет его откатить. Не выключайте ПК во время работы.';

  @override
  String get systemRepairVerified =>
      'Восстановление завершено, проверка пройдена.';

  @override
  String get runRepair => 'Запустить восстановление';

  @override
  String get operationCompleted => 'Операция завершена';

  @override
  String get captureEtwTrace => 'Записать трассировку производительности';

  @override
  String get captureEtwTraceDescription =>
      'Записывает ограниченную трассировку Windows Performance Recorder и по запросу строит диагностический отчёт DPC/ISR. Никакой мониторинг не остаётся включённым.';

  @override
  String get dpcLatencyAnalyzer => 'Анализ задержек DPC / ISR';

  @override
  String get dpcLatencyAnalyzerDescription =>
      'Записывает ETW по запросу и показывает активность DPC, ISR, жёстких ошибок страниц и переключений контекста, распределение по процессорам, замеченные модули ядра и поставщиков ETW.';

  @override
  String get diagnosticNotCausality =>
      'Диагностический сигнал, а не вердикт о задержке';

  @override
  String get diagnosticNotCausalityDescription =>
      'Счётчики и замеченные имена модулей помогают сузить поиск, но не доказывают, что задержку вызывает драйвер. Подтвердите повторяемыми записями A/B/A и WPA или инструментами производителя.';

  @override
  String get startDpcCapture => 'Начать запись';

  @override
  String get openTraceFolder => 'Открыть папку трассировок';

  @override
  String captureInProgress(int seconds) {
    return 'Запись $seconds с… не останавливайте нагрузку.';
  }

  @override
  String get traceDuration => 'Наблюдаемая длительность';

  @override
  String get hardFaults => 'Жёсткие ошибки страниц';

  @override
  String get contextSwitches => 'Переключения контекста';

  @override
  String get totalEvents => 'Всего событий ETW';

  @override
  String get kernelModulesObserved => 'Модули ядра в событиях DPC/ISR';

  @override
  String get noKernelModulesObserved =>
      'Экспортированные события не содержали имён модулей ядра. Откройте ETL в WPA для анализа с символами.';

  @override
  String get dpcIsrByProcessor => 'События DPC/ISR по логическим процессорам';

  @override
  String get noProcessorDistribution =>
      'Экспортированные события не содержали идентификаторов процессоров.';

  @override
  String get topEtwProviders => 'Основные поставщики ETW';

  @override
  String get noProviderData => 'Нет данных о поставщиках.';

  @override
  String etwTraceSaved(Object path) {
    return 'Трассировка сохранена: $path';
  }

  @override
  String get cleanupDiagnosticTraces => 'Удалить диагностические трассировки';

  @override
  String get cleanupDiagnosticTracesDescription =>
      'Ищет только файлы трассировок ZapTweaks, показывает точное число файлов и общий размер и удаляет их после подтверждения.';

  @override
  String cleanupTracePreview(int count, int bytes) {
    return 'Удалить файлы трассировок ZapTweaks ($count, $bytes байт)? Это нельзя отменить.';
  }

  @override
  String get cleanupTracesCompleted =>
      'Показанные трассировки удалены, их отсутствие проверено.';

  @override
  String get noDiagnosticTraces =>
      'Диагностические трассировки ZapTweaks не найдены.';

  @override
  String get hardwareMonitor => 'Монитор оборудования';

  @override
  String get dedicatedVramUsage => 'Занятая выделенная память GPU';

  @override
  String get dedicatedVramUsageDescription =>
      'Делает один снимок счётчиков производительности GPU Windows. После этого ничего не работает в фоне.';

  @override
  String vramUsageValue(Object megabytes) {
    return '$megabytes МБ';
  }

  @override
  String get captureNow => 'Снять сейчас';

  @override
  String get tweaks => 'Твики';

  @override
  String get searchPowerPlans => 'Поиск схем электропитания';

  @override
  String get activePowerPlan => 'Активна';

  @override
  String get activate => 'Активировать';

  @override
  String get details => 'Подробности';

  @override
  String get compare => 'Сравнить';

  @override
  String get noPowerDifferences =>
      'Различий между значениями от сети и от батареи нет.';

  @override
  String get importPowerPlan => 'Импорт .pow';

  @override
  String get importPowerPlanDescription =>
      'Импортирует выбранную локально схему электропитания после ограниченной подготовки с проверкой хеша.';

  @override
  String get exportActivePowerPlan => 'Экспорт активной схемы';

  @override
  String get restoreDefaultPowerSchemes => 'Восстановить схемы Windows';

  @override
  String get restoreDefaultPowerSchemesDescription =>
      'Экспортирует каждую текущую схему с хешем, прежде чем попросить Windows восстановить стандартные.';

  @override
  String get restoreDefaultPowerSchemesWarning =>
      'Заменить все текущие схемы электропитания стандартными схемами Windows? Сначала ZapTweaks экспортирует каждую схему для точного отката.';

  @override
  String get interruptConfiguration => 'MSI Utility v3 и привязка прерываний';

  @override
  String get interruptConfigurationDescription =>
      'Расширенные настройки MSI и привязки прерываний группы 0 с учётом возможностей для подключённых видео-, сетевых, мультимедийных устройств, USB-хостов и HD Audio. Значения автоматически не рекомендуются.';

  @override
  String get configureMsi => 'Настроить MSI';

  @override
  String get enableMsi => 'Включить прерывания, сигнализируемые сообщениями';

  @override
  String get configureInterruptAffinity => 'Настроить привязку';

  @override
  String get interruptChangeWarning =>
      'Неверная политика прерываний может сделать устройство недоступным до отката или перезагрузки. ZapTweaks проверяет аппаратные ограничения и сохраняет точные текущие значения.';

  @override
  String get affinityMaskHint => 'Шестнадцатеричная маска группы 0, например 3';

  @override
  String get invalidAffinityMask =>
      'Введите ненулевую каноническую шестнадцатеричную маску не длиннее 64 бит.';

  @override
  String msiRange(int maximum) {
    return 'Число сообщений должно быть от 1 до $maximum.';
  }

  @override
  String get noCompatibleInterruptDevices =>
      'Ни одно подключённое PCI-устройство (видео, сеть, мультимедиа, USB-хост, HD Audio) не поддерживает совместимые прерывания.';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return 'Оборудование: Line $line · MSI $msi · MSI-X $msix · максимум сообщений $maximum';
  }

  @override
  String get messageNumberLimit => 'Ограничение числа сообщений';

  @override
  String get interruptPriority => 'Политика приоритета прерываний';

  @override
  String get interruptPriorityDefault => 'Не задано / по умолчанию драйвера';

  @override
  String get interruptPriorityLow => 'Низкий';

  @override
  String get interruptPriorityNormal => 'Обычный';

  @override
  String get interruptPriorityHigh => 'Высокий';

  @override
  String get interruptPolicy => 'Политика привязки к процессорам';

  @override
  String get interruptPolicyDefault => 'По умолчанию для системы';

  @override
  String get interruptPolicyAllClose => 'Все близкие процессоры';

  @override
  String get interruptPolicyOneClose => 'Один близкий процессор';

  @override
  String get interruptPolicyAllProcessors => 'Все процессоры';

  @override
  String get interruptPolicySpecified => 'Указанные процессоры (группа 0)';

  @override
  String get interruptPolicySpread => 'Распределять сообщения по процессорам';

  @override
  String get selectLogicalProcessors =>
      'Выберите логические процессоры группы 0';

  @override
  String get affinitySelectAll => 'Все логические процессоры';

  @override
  String get affinityClear => 'Очистить';

  @override
  String get affinityPhysicalCores => 'Один поток на физическое ядро';

  @override
  String get affinityPerformanceCores => 'Производительные ядра';

  @override
  String get affinityEfficiencyCores => 'Энергоэффективные ядра';

  @override
  String get affinityParked => 'припарковано';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'Узел NUMA $index';
  }

  @override
  String get compatibleDevices => 'Совместимые устройства';

  @override
  String get msiEnabledDevices => 'MSI сейчас включён';

  @override
  String get logicalProcessors => 'Логические процессоры';

  @override
  String get searchDevices =>
      'Поиск устройств, идентификаторов экземпляров или INF драйвера';

  @override
  String get driverUnknown => 'INF драйвера недоступен';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return 'Сейчас: $mode · сообщения $messages · приоритет $priority · политика $policy · маска $mask';
  }

  @override
  String get renamePowerPlan => 'Переименовать схему электропитания';

  @override
  String get renamePowerPlanDescription =>
      'Меняет только отображаемое имя выбранной схемы и сохраняет исходное для отката.';

  @override
  String get rename => 'Переименовать';

  @override
  String get duplicate => 'Дублировать';

  @override
  String get duplicatePowerPlan => 'Дублировать схему электропитания';

  @override
  String get duplicatePowerPlanDescription =>
      'Создаёт и проверяет копию через PowrProf. Откат выполняется по возможности, так как GUID назначает Windows при создании.';

  @override
  String get apply => 'Применить';

  @override
  String get edit => 'Изменить';

  @override
  String powerValueRange(int maximum) {
    return 'Значения должны быть от 0 до $maximum.';
  }

  @override
  String get powerSettingConfigure =>
      'Настроить любой ограниченный параметр электропитания';

  @override
  String get powerSettingConfigureDescription =>
      'Меняет параметр, доступный через PowrProf, только если Windows сообщает текущие минимум, максимум и шаг.';

  @override
  String get searchPowerSettings =>
      'Поиск параметров, описаний, подгрупп или GUID';

  @override
  String get allPowerSubgroups => 'Все группы параметров электропитания';

  @override
  String powerSettingCount(int count) {
    return 'Параметров: $count';
  }

  @override
  String powerSettingOptions(int count) {
    return 'Вариантов, заданных Windows: $count';
  }

  @override
  String get backToPowerPlans => 'Назад к схемам электропитания';

  @override
  String get powerPlanEditorHint =>
      'Продублируйте схему, чтобы создать свой профиль, затем откройте «Подробности» и по одному меняйте её скрытые параметры для сети и батареи.';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Диапазон $minimum–$maximum, шаг $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows не предоставила безопасных значений или границ для этого параметра.';

  @override
  String get delete => 'Удалить';

  @override
  String get deletePowerPlan => 'Удалить схему электропитания';

  @override
  String get deletePowerPlanDescription =>
      'Экспортирует выбранную неактивную схему перед удалением и хранит копию для точного отката.';

  @override
  String deletePowerPlanWarning(Object name) {
    return 'Удалить $name? Сначала ZapTweaks экспортирует копию для восстановления.';
  }

  @override
  String get firmwareTemperatures => 'Тепловые зоны прошивки';

  @override
  String get firmwareTemperaturesDescription =>
      'Однократно читает тепловые зоны ACPI. Наличие и смысл датчиков зависят от прошивки ПК; значения не подписываются как температура CPU или GPU.';

  @override
  String get noThermalSensors => 'Этот ПК не предоставляет тепловых зон ACPI.';

  @override
  String get cpuFrequency => 'Частота CPU и парковка ядер';

  @override
  String get cpuFrequencyDescription =>
      'Делает один замер счётчиков производительности процессора Windows. Эффективная частота = базовая × % производительности процессора, та же формула, что в диспетчере задач. Помогает проверить изменения схемы электропитания, буста и парковки ядер. Только чтение.';

  @override
  String cpuEffectiveClock(Object mhz, Object nominal) {
    return '$mhz МГц эффективно · база $nominal МГц';
  }

  @override
  String cpuParkedCount(Object parked, Object total) {
    return 'Припарковано логических процессоров: $parked из $total';
  }

  @override
  String get cpuParked => 'припарковано';

  @override
  String get cpuFrequencySource =>
      'Источник: счётчики производительности Processor Information (Win32_PerfFormattedData_Counters_ProcessorInformation), один замер, усреднённый за последний интервал счётчика. Это не пиковая частота. Значения по ядрам используют одну номинальную частоту, поэтому энергоэффективные ядра гибридных CPU показываются завышенными.';

  @override
  String get driverInventory => 'Список хранилища драйверов';

  @override
  String get installLocalDriver => 'Установить локальный пакет драйвера';

  @override
  String get installLocalDriverDescription =>
      'Проверить локальный INF, его подписанный каталог и совместимость с оборудованием до установки.';

  @override
  String get selectDevice => 'Выберите подключённое устройство';

  @override
  String get localInfPath => 'Абсолютный путь к локальному файлу .inf';

  @override
  String get verifyDriverPackage => 'Проверить пакет';

  @override
  String verifiedDriverPublisher(Object publisher, Object sha256) {
    return 'Проверенный издатель: $publisher\nSHA-256 INF: $sha256';
  }

  @override
  String get confirmLocalDriverInstall =>
      'Подтвердите установку локального драйвера';

  @override
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  ) {
    return 'Устройство: $device\nПодписавший издатель: $publisher\nSHA-256 INF: $sha256\n\nWindows может сменить активный драйвер и потребовать перезагрузку. Откат выполняется по возможности.';
  }

  @override
  String get driverTools => 'Сопровождаемые сценарии';

  @override
  String get temporaryDriverUpdatesPause =>
      'Временно исключить драйверы из обновлений качества Windows';

  @override
  String get temporaryDriverUpdatesPauseDescription =>
      'Использует документированную политику Центра обновления Windows на 7 или 30 дней. ZapTweaks сохраняет точное прежнее значение и напоминает об окончании паузы; восстановление требует вашего подтверждения.';

  @override
  String get driverUpdatePolicy =>
      'Политика драйверов Центра обновления Windows';

  @override
  String get driverUpdatePolicyDescription =>
      'Исключить драйверы устройств из обновлений качества Windows на 7 дней, 30 дней или до явного восстановления точной прежней политики.';

  @override
  String get disableUntilRestored => 'Отключить до восстановления';

  @override
  String get driverUpdatePausePermanent =>
      'Обновления драйверов остаются исключёнными, пока вы не восстановите прежнюю политику.';

  @override
  String get driverUpdatePauseActive => 'Пауза обновлений драйверов включена';

  @override
  String get driverUpdatePauseExpired =>
      'Пауза обновлений драйверов истекла — восстановите прежнюю политику';

  @override
  String driverUpdatePauseUntil(Object date) {
    return 'Плановое окончание: $date';
  }

  @override
  String get pauseSevenDays => 'Пауза на 7 дней';

  @override
  String get pauseThirtyDays => 'Пауза на 30 дней';

  @override
  String get restoreDriverUpdates => 'Восстановить прежнюю политику';

  @override
  String get assistedDriverFlows =>
      'Проверенные и сопровождаемые сценарии для драйверов';

  @override
  String get assistedDriverFlowsDescription =>
      'ZapTweaks открывает только источники производителей и разделы Windows. Он не запускает изменяемые удалённые скрипты, не прошивает firmware и не удаляет компоненты драйверов незаметно.';

  @override
  String get amdDriverFlow => 'Драйверы и ПО AMD';

  @override
  String get amdDriverFlowDescription =>
      'Открыть официальный подбор драйверов AMD. Перед загрузкой проверьте определённый продукт.';

  @override
  String get nvidiaDriverFlow => 'Драйверы NVIDIA';

  @override
  String get nvidiaDriverFlowDescription =>
      'Открыть официальный ручной поиск драйверов NVIDIA. Чистая установка остаётся явным выбором в установщике производителя.';

  @override
  String get intelDriverFlow => 'Intel Driver & Support Assistant';

  @override
  String get intelDriverFlowDescription =>
      'Открыть официальный сценарий определения и поддержки Intel.';

  @override
  String get windowsOptionalDrivers =>
      'Необязательные обновления драйверов Windows';

  @override
  String get windowsOptionalDriversDescription =>
      'Просмотрите необязательные обновления драйверов в параметрах Windows; ничего не выбирается автоматически.';

  @override
  String get deviceManager => 'Диспетчер устройств';

  @override
  String get deviceManagerDescription =>
      'Просмотр устройств, кодов состояния, активных драйверов и ручного отката.';

  @override
  String get openOfficialSource => 'Открыть официальный источник';

  @override
  String get openWindowsPanel => 'Открыть раздел Windows';

  @override
  String get searchDrivers => 'Поиск в хранилище драйверов';

  @override
  String get driverStoreSafetyNotice =>
      'Здесь можно удалить только подписанные непривязанные пакеты сторонних производителей. Сначала ZapTweaks экспортирует пакет с хешем; восстановление выполняется по возможности, так как Windows может назначить другое опубликованное имя.';

  @override
  String get signed => 'Подписан';

  @override
  String get unsigned => 'Не подписан';

  @override
  String get driverInUse => 'Используется';

  @override
  String get driverUnbound => 'Не привязан';

  @override
  String get exportAndRemove => 'Экспортировать и удалить';

  @override
  String get confirmDriverRemoval =>
      'Подтвердите удаление из хранилища драйверов';

  @override
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  ) {
    return 'Опубликованное имя: $published\nИсходный INF: $inf\nИздатель: $publisher\nВерсия: $version\n\nПеред удалением ZapTweaks экспортирует пакет с хешем. Может потребоваться перезагрузка; восстановление выполняется по возможности.';
  }

  @override
  String get searchInstalledApps => 'Поиск установленных приложений';

  @override
  String get scanAllUsers => 'Сканировать всех пользователей (UAC)';

  @override
  String get systemScopesComplete =>
      'Включены области AppX всех пользователей и подготовленные пакеты.';

  @override
  String get systemScopesIncomplete =>
      'Только текущий пользователь и список winget. Просканируйте всех пользователей, чтобы включить системные области AppX.';

  @override
  String get currentUser => 'Текущий пользователь';

  @override
  String get allUsers => 'Все пользователи';

  @override
  String get provisioned => 'Подготовлен';

  @override
  String get confirmAppxRemoval => 'Подтвердите удаление AppX';

  @override
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  ) {
    return 'Приложение: $name\nИдентификатор: $id\nОбласть: $scope\nВосстановление: $recovery\n\nБудет удалена только указанная область. У этой операции нет точного отката.';
  }

  @override
  String get reinstallable => 'Есть проверенный источник восстановления';

  @override
  String get notReinstallable => 'Нет проверенного источника восстановления';

  @override
  String get allCategories => 'Все категории';

  @override
  String get installedOnly => 'Только установленные';

  @override
  String get refreshInventory => 'Обновить список';

  @override
  String get install => 'Установить';

  @override
  String get uninstall => 'Удалить';

  @override
  String get uninstallSelected => 'Удалить выбранные';

  @override
  String get openOfficialPage => 'Открыть официальную страницу';

  @override
  String get installed => 'Установлено';

  @override
  String get notInstalled => 'Не установлено';

  @override
  String get appInventoryUnavailable =>
      'Определение установленных приложений недоступно.';

  @override
  String get confirmBulkUninstall => 'Подтвердите массовое удаление';

  @override
  String confirmBulkUninstallMessage(Object apps) {
    return 'Будут удалены следующие приложения:\n\n$apps';
  }

  @override
  String get appCatalogSources =>
      'Каталог объединён из закреплённой версии CTT WinUtil, clean-room-кандидатов Winhance, TweakHub и запрошенных официальных источников.';

  @override
  String get tcpOptimizer => 'Оптимизатор TCP';

  @override
  String get tcpOptimizerDescription =>
      'Просмотр и настройка шаблонов TCP Windows, глобальных разгрузок, QoS для приложений и повторяемой диагностики сети.';

  @override
  String get tcpNoRecommendation =>
      'Ни одно значение не рекомендуется автоматически. Повторное чтение или один сетевой тест не доказывают прирост производительности.';

  @override
  String get tcpLiveState => 'Текущее состояние TCP';

  @override
  String get tcpTemplates => 'Шаблоны TCP';

  @override
  String get tcpGlobal => 'Глобальные разгрузки TCP';

  @override
  String get tcpAutotuning => 'Автонастройка окна приёма';

  @override
  String get tcpHeuristics => 'Эвристика масштабирования окна';

  @override
  String get tcpEcn => 'Поддержка ECN';

  @override
  String get tcpCongestion => 'Управление перегрузкой';

  @override
  String get tcpRsc => 'Объединение принимаемых сегментов (RSC)';

  @override
  String get tcpRss => 'Глобальное масштабирование приёма (RSS)';

  @override
  String get tcpConfigure => 'Настроить';

  @override
  String get tcpChangePreview => 'Предпросмотр изменения TCP';

  @override
  String get tcpCurrentValue => 'Текущее значение';

  @override
  String get tcpNewValue => 'Новое значение';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks сохранит точное текущее значение, применит изменение одним запросом UAC, повторно считает и запишет его в журнал, сохранив возможность точного отката.';

  @override
  String get tcpUnsupported => 'Не предоставляется этой сборкой Windows';

  @override
  String get tcpAdapterRss => 'Открыть управление RSS для адаптеров';

  @override
  String get rssAdapterState => 'Состояние RSS для адаптера';

  @override
  String get rssEnabled => 'RSS включён';

  @override
  String get rssProfile => 'Профиль RSS';

  @override
  String get rssQueuesProcessors => 'Очереди/процессоры';

  @override
  String get tcpSettingOperationTitle => 'Настроить параметр TCP';

  @override
  String get tcpSettingOperationDescription =>
      'Изменяет поддерживаемый системой шаблон TCP Windows или значение глобальной разгрузки с точным откатом.';

  @override
  String get qosPolicies => 'Политики QoS приложений';

  @override
  String get qosDescription =>
      'Создавайте явные постоянные политики QoS для одного исполняемого файла. Существующие политики не от ZapTweaks остаются доступными только для чтения.';

  @override
  String get qosCreate => 'Создать политику';

  @override
  String get qosEdit => 'Изменить';

  @override
  String get qosDelete => 'Удалить';

  @override
  String get qosName => 'Имя политики';

  @override
  String get qosAppPath => 'Путь к исполняемому файлу';

  @override
  String get qosProtocol => 'Протокол';

  @override
  String get qosSourcePort => 'Порт источника (необязательно)';

  @override
  String get qosDestinationPort => 'Порт назначения (необязательно)';

  @override
  String get qosDscp => 'DSCP 0–63 (необязательно)';

  @override
  String get qosThrottleMbps => 'Ограничение, Мбит/с (необязательно)';

  @override
  String get qosOwnedOnly =>
      'Имена должны начинаться с «ZapTweaks - ». Изменяется только выбранная политика; остальные политики QoS никогда не удаляются.';

  @override
  String get qosDeleteConfirm =>
      'Удалить выбранную политику QoS? Её точное состояние будет сохранено в журнале ZapTweaks для отката.';

  @override
  String get qosReadOnly => 'Только чтение';

  @override
  String get qosPolicyOperationTitle => 'Настроить QoS приложения';

  @override
  String get qosPolicyOperationDescription =>
      'Создаёт, изменяет или удаляет одну проверенную постоянную политику QoS для приложения с точным откатом.';

  @override
  String get networkDiagnostics => 'Диагностика до/после';

  @override
  String get networkDiagnosticsDescription =>
      'Ограниченно измеряет задержку TCP-подключения, джиттер, потери и скорость загрузки HTTPS. Результаты являются диагностическими данными, а не рекомендацией.';

  @override
  String get diagnosticEndpoint => 'Прямой HTTPS-адрес тестового файла';

  @override
  String get diagnosticNetworkCost =>
      'Тест загружает не более 10 МиБ с указанного адреса. Сторонние адреса не встроены.';

  @override
  String get diagnosticBaseline => 'Запустить исходное измерение';

  @override
  String get diagnosticComparison => 'Запустить сравнение';

  @override
  String get diagnosticCancel => 'Отменить измерение';

  @override
  String get diagnosticLatency => 'Задержка';

  @override
  String get diagnosticJitter => 'Джиттер';

  @override
  String get diagnosticPacketLoss => 'Потеря пакетов';

  @override
  String get diagnosticThroughput => 'Пропускная способность';

  @override
  String get diagnosticRawSamples => 'Исходные замеры задержки';

  @override
  String get diagnosticDownloadedBytes => 'Загружено байт';

  @override
  String get diagnosticDifference => 'Разница B − A';

  @override
  String get tcpAttribution =>
      'Вдохновлено WINSPAR — powplowdevs (зафиксированная ревизия)';

  @override
  String get openRecoveryHistory => 'Открыть восстановление и журнал';

  @override
  String get manualRestoreTitle => 'Восстановить исходные ручные настройки';

  @override
  String get manualRestoreWarning =>
      'Восстанавливаются сохранённые исходные значения, а не стандартные. Изменённые позже настройки не перезаписываются. Настройки высокого риска требуют режима эксперта и UAC. После восстановления проверьте журнал; перезагрузка или выход из системы могут по-прежнему понадобиться.';

  @override
  String get cleanupUserTemp => 'Очистка UserTemp';

  @override
  String get cleanupUserTempDescription =>
      'Просмотр и выбор конкретных файлов в папке Temp текущего пользователя. Без автоматического выбора, принудительного удаления и удаления папок.';

  @override
  String get cleanupSelectFiles => 'Просмотреть и выбрать файлы';

  @override
  String get cleanupShaderCache => 'Очистка кеша шейдеров GPU';

  @override
  String get cleanupShaderCacheDescription =>
      'Показывает по папкам кеши шейдеров DirectX, AMD, NVIDIA и Intel текущего пользователя и удаляет ровно те файлы, что найдены в этом предпросмотре. Драйвер создаст их заново, поэтому первый запуск каждой игры может подтормаживать. Сначала закройте игры. Необратимо.';

  @override
  String get cleanupShaderCacheNone => 'Файлы кеша шейдеров GPU не найдены.';

  @override
  String get cleanupShaderCacheCompleted =>
      'Показанные файлы кеша шейдеров удалены, их отсутствие проверено.';

  @override
  String get cleanupPreview => 'Предпросмотр';

  @override
  String get cleanupUserTempNone => 'Файлы UserTemp не найдены.';

  @override
  String get cleanupPermanentWarning =>
      'Безвозвратное удаление. Без отката и без обхода прав или блокировок. Сначала закройте приложения. Если удаление прервётся, часть файлов может быть уже удалена.';

  @override
  String get cleanupUserTempSelectionHint =>
      'Ничего не выбрано. Выбирайте только знакомые файлы; файлы, созданные после этого предпросмотра, не затрагиваются.';

  @override
  String cleanupPreviewCount(int count, int bytes) {
    return 'Файлов: $count, байт: $bytes';
  }

  @override
  String get cleanupRecycleUnavailable =>
      'Очистка корзины недоступна: точные элементы нельзя безопасно показать и удалить. Корзина целиком не очищается.';

  @override
  String get cleanupCrashReports => 'Дампы сбоев и отчёты об ошибках';

  @override
  String get cleanupCrashReportsDescription =>
      'Удаляет дампы сбоев ваших программ (%LOCALAPPDATA%\\CrashDumps), а также архив и очередь отчётов об ошибках Windows. Полезно, если игра или приложение часто падали. Системные мини-дампы (синие экраны) не затрагиваются.';

  @override
  String get cleanupCrashReportsNone =>
      'Нет дампов сбоев или отчётов об ошибках для удаления.';

  @override
  String get cleanupCrashReportsCompleted =>
      'Дампы сбоев и отчёты об ошибках удалены.';

  @override
  String get cleanupBrowserCache => 'Кеши браузеров';

  @override
  String get cleanupBrowserCacheDescription =>
      'Удаляет дисковые кеши Chrome, Edge, Brave (все профили) и Firefox. Файлы cookie, история, пароли и расширения не затрагиваются; страницы при первом открытии загружаются чуть медленнее.';

  @override
  String get cleanupBrowserCacheNone =>
      'Нет файлов кеша браузеров для удаления.';

  @override
  String get cleanupBrowserCacheCompleted => 'Кеши браузеров удалены.';

  @override
  String cleanupBrowserRunning(String browsers) {
    return 'Сначала закройте $browsers (в том числе в области уведомлений: Edge и Chrome могут работать в фоне).';
  }

  @override
  String thermalZoneLimited(String percent) {
    return 'прошивка ограничивает CPU до $percent%';
  }

  @override
  String get thermalSourceCounters =>
      'Источник: счётчики Windows «Thermal Zone Information» (зоны ACPI, заданные прошивкой, права администратора не нужны). Зона — это датчик, выбранный производителем; часто это не кристалл CPU.';

  @override
  String get thermalSourceAcpi =>
      'Источник: MSAcpi_ThermalZoneTemperature (зоны ACPI, заданные прошивкой). Зона — это датчик, выбранный производителем; часто это не кристалл CPU.';

  @override
  String get thermalSourceNone =>
      'Прошивка этого ПК не предоставляет тепловых зон ACPI (обычно для настольных плат). Лучше ничего не показывать, чем показать неизмеренное значение.';

  @override
  String get srumTab => 'История приложений';

  @override
  String get srumTitle => 'История приложений (SRUM)';

  @override
  String get srumDescription =>
      'Использование сети, CPU и диска каждой программой за последние 30 дней по записям Windows (System Resource Usage Monitor). Только чтение: ZapTweaks читает теневую копию базы данных и затем удаляет её. Нужны права администратора.';

  @override
  String get srumRead => 'Прочитать историю';

  @override
  String get srumNotCollectingTitle =>
      'Windows не записывает историю приложений';

  @override
  String srumNotCollecting(String status, String startType, String date) {
    return 'Служба политики диагностики, которая ведёт эту историю: $status ($startType). Данные заканчиваются $date.';
  }

  @override
  String get srumNoData => 'За последние 30 дней использование не записано.';

  @override
  String get srumNetwork => 'Сеть (отправлено / получено)';

  @override
  String get srumCpu => 'Время CPU (доля от всех программ; часть в фоне)';

  @override
  String srumCpuShare(String share, String background) {
    return '$share% · $background% в фоне';
  }

  @override
  String get srumUnattributed => 'Не отнесено к программе';

  @override
  String srumSource(String first, String last) {
    return 'Источник: C:\\Windows\\System32\\sru\\SRUDB.dat, записи с $first по $last. Windows записывает их примерно раз в час.';
  }

  @override
  String get manualControls => 'Ручные настройки';

  @override
  String upToDate(String version) {
    return 'У вас последняя версия ($version).';
  }

  @override
  String get startCapture => 'Начать запись';

  @override
  String get batteryHealth => 'Состояние батареи';

  @override
  String get batteryHealthDescription =>
      'Ёмкость, которую батарея ещё держит по сравнению с проектной. Только чтение.';

  @override
  String get batteryGood => 'Хорошее';

  @override
  String get batteryFair => 'Изношена';

  @override
  String get batteryPoor => 'Скоро заменить';

  @override
  String get notAvailable => 'Недоступно';

  @override
  String get batteryDesigned => 'Проектная ёмкость';

  @override
  String get batteryFullCharge => 'Ёмкость при полном заряде';

  @override
  String get batteryWear => 'Износ';

  @override
  String get batteryCycles => 'Циклы заряда';

  @override
  String get batteryCharge => 'Текущий заряд';

  @override
  String get batteryOnAc => 'Подключено к сети';

  @override
  String get batteryOnBattery => 'От батареи';

  @override
  String get batterySourceWmi =>
      'Источник: root\\wmi BatteryStaticData, BatteryFullChargedCapacity, BatteryCycleCount и BatteryStatus по данным прошивки батареи.';

  @override
  String get batterySourceReport =>
      'Источник: powercfg /batteryreport (временный XML, удаляется после чтения) по данным прошивки батареи.';

  @override
  String get appTypeSystem => 'Система';

  @override
  String get appTypeUser => 'Пользователь';

  @override
  String get appTypeStore => 'Store';

  @override
  String get appSafetyRemovable => 'Можно удалить';

  @override
  String get appSafetyCheckFirst => 'Сначала проверьте';

  @override
  String get appSafetyKeep => 'Оставить';

  @override
  String get appReasonSystemComponent =>
      'Скрытый компонент Windows или производителя.';

  @override
  String get appReasonProtected => 'Установщик запрещает удаление.';

  @override
  String get appReasonUpdate => 'Обновление другой программы: удалите её.';

  @override
  String get appReasonWindowsPart =>
      'Часть Windows или фреймворк, нужный другим приложениям.';

  @override
  String get appReasonSharedDependency =>
      'Используется другими приложениями (среда, драйвер или панель производителя).';

  @override
  String get appReasonOptionalFeature =>
      'Дополнительная функция Windows: посмотрите, что перестанет работать.';

  @override
  String get appReasonMissingUninstaller => 'Деинсталлятор не зарегистрирован.';

  @override
  String get appReasonUserInstalled =>
      'Установлено вами или производителем ПК; от него ничего не зависит.';

  @override
  String get appLabelMissingUninstaller => 'Без деинсталлятора';

  @override
  String get appLabelProtected => 'Защищено';

  @override
  String get appLabelSystemComponent => 'Системный компонент';

  @override
  String get appLabelUpdate => 'Обновление';

  @override
  String get filterAll => 'Все';

  @override
  String get filterType => 'Тип';

  @override
  String get filterSafety => 'Безопасность';

  @override
  String get filterSource => 'Источник';

  @override
  String get sourceWholePc => 'Весь ПК';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortSize => 'Размер';

  @override
  String get sortName => 'Имя';

  @override
  String get sortDate => 'Дата установки';

  @override
  String appsShown(int count) {
    return 'Приложений: $count';
  }

  @override
  String selectionSummary(int count, String size) {
    return 'Выбрано: $count · $size';
  }

  @override
  String selectionUnknownSizes(int count) {
    return 'Неизвестный размер: $count';
  }

  @override
  String get appsSource =>
      'Источник: ключи реестра Uninstall (HKLM 64/32 бит, HKCU), Get-AppxPackage, winget export для идентификаторов переустановки. Размер: EstimatedSize, иначе папка установки.';

  @override
  String get noAppsMatch => 'Нет приложений по этим фильтрам.';

  @override
  String reinstallableVia(String id) {
    return 'Переустановка: winget $id';
  }

  @override
  String get uninstallQueueTitle => 'Очередь удаления';

  @override
  String get uninstallModeSilent => 'Тихо';

  @override
  String get uninstallModeWindowed => 'Откроет окно';

  @override
  String get uninstallManualNoUninstaller =>
      'Вручную: деинсталлятор не зарегистрирован.';

  @override
  String get uninstallManualUnsafe =>
      'Вручную: команда запускает оболочку или скрипт, ZapTweaks её не выполняет.';

  @override
  String get uninstallManualNotFound =>
      'Вручную: файл деинсталлятора отсутствует.';

  @override
  String uninstallRunningWarning(String processes) {
    return 'Ещё запущено из своей папки: $processes. Сначала закройте.';
  }

  @override
  String get uninstallSimulate =>
      'Симуляция: показать очередь, ничего не удалять';

  @override
  String get uninstallRestorePointNote =>
      'Сначала создаётся точка восстановления. Сначала удаления с окном, по одному; затем тихие.';

  @override
  String get uninstallStart => 'Начать удаление';

  @override
  String get restorePointCreating => 'Создание точки восстановления…';

  @override
  String get restorePointFailed =>
      'Точка восстановления не создана. Защита системы может быть выключена. Ничего не изменено.';

  @override
  String get restorePointEnableAndRetry =>
      'Включить защиту системы и повторить';

  @override
  String get queueWaiting => 'Ожидает';

  @override
  String get queueRunning => 'Выполняется';

  @override
  String get queueDone => 'Готово';

  @override
  String get queueFailed => 'Ошибка';

  @override
  String get queueSkipped => 'Пропущено';

  @override
  String get queueSkip => 'Пропустить';

  @override
  String get queueStop => 'Остановить после текущего';

  @override
  String get queueSimulated => 'Симуляция: ничего не удалено.';

  @override
  String get uninstallStoreAppsHint =>
      'Приложения Store удаляются через меню «Удалить» в их строке.';

  @override
  String get leftoverSearch => 'Найти остатки';

  @override
  String get leftoverTitle => 'Остатки';

  @override
  String get leftoverGood => 'Точно';

  @override
  String get leftoverMedium => 'Вероятно';

  @override
  String get leftoverLow => 'Неясно';

  @override
  String get leftoverKindFolder => 'Папка';

  @override
  String get leftoverKindShortcut => 'Ярлык';

  @override
  String get leftoverKindRegistry => 'Раздел реестра';

  @override
  String get leftoverKindRun => 'Автозапуск';

  @override
  String get leftoverKindTask => 'Задача планировщика';

  @override
  String get leftoverKindFirewall => 'Правило брандмауэра';

  @override
  String get leftoverNone => 'Остатки не найдены.';

  @override
  String leftoverRemoveSelected(int count) {
    return 'Удалить выбранное ($count)';
  }

  @override
  String get leftoverBackupNote =>
      'Изначально выбраны только пункты «Точно». Перед удалением разделы реестра сохраняются в .reg, задачи в XML, правила брандмауэра в JSON; файлы и папки отправляются в корзину.';

  @override
  String leftoverRemoved(String path) {
    return 'Остатки удалены. Резервные копии: $path';
  }

  @override
  String get leftoverRefusedInvalid =>
      'Не удалено: неверная или небезопасная запись.';

  @override
  String get leftoverRefusedOutside =>
      'Не удалено: вне того, что ZapTweaks может очищать здесь.';

  @override
  String get leftoverRefusedShared =>
      'Не удалено: используется Windows или другими программами.';

  @override
  String get orphanFolders => 'Бесхозные папки';

  @override
  String get orphanFoldersNote =>
      'Папки в Program Files, на которые не ссылается ни одна установленная программа. Портативная утилита или набор драйверов выглядят так же, поэтому ничего не выбрано: проверьте каждую.';

  @override
  String get openLocation => 'Открыть расположение';

  @override
  String get processesTab => 'Процессы';

  @override
  String get searchProcesses => 'Поиск процессов';

  @override
  String get sortMemory => 'Память';

  @override
  String get sortCpu => 'ЦП';

  @override
  String get processKindWindows => 'Windows';

  @override
  String get processKindMicrosoft => 'Приложение Microsoft';

  @override
  String get processKindThirdParty => 'Сторонний';

  @override
  String get processCanClose => 'Можно закрыть';

  @override
  String get processLeaveRunning => 'Не закрывать';

  @override
  String get processReasonCritical =>
      'Нужен Windows: закрытие может завершить сеанс или обрушить систему.';

  @override
  String get processReasonWindowsFolder =>
      'Запущен из папки Windows или защищён.';

  @override
  String get processReasonService =>
      'Выполняет службу: управляйте ею на вкладке «Службы».';

  @override
  String get processReasonSelf => 'Это ZapTweaks.';

  @override
  String get processReasonUserApp =>
      'Запущенное вами приложение: при закрытии несохранённое теряется.';

  @override
  String get processEnd => 'Завершить процесс';

  @override
  String processEndConfirm(String name) {
    return 'Завершить $name? Несохранённое будет потеряно.';
  }

  @override
  String get processEndChanged =>
      'Он уже закрыт или его ID занят другим процессом: ничего не завершено.';

  @override
  String get processEndFailed =>
      'Windows отказалась его завершить. Возможно, он запущен от администратора.';

  @override
  String get searchOnline => 'Искать в интернете';

  @override
  String get processOnlyClosable => 'Только те, что можно закрыть';

  @override
  String get processNote =>
      'Снимок: ЦП — одно измерение, обновите, чтобы перечитать. Подписи проверяются после появления списка. Системные процессы никогда не предлагаются к закрытию.';

  @override
  String get noProcessesMatch => 'Нет процессов, подходящих под фильтры.';

  @override
  String signedBy(String signer) {
    return 'Подписано: $signer';
  }

  @override
  String get servicesTab => 'Службы';

  @override
  String get searchServices => 'Поиск служб';

  @override
  String get filterOrigin => 'Происхождение';

  @override
  String get originMicrosoft => 'Microsoft';

  @override
  String get serviceCanDisable => 'Можно отключить';

  @override
  String get serviceDependsOnUse => 'Зависит от использования';

  @override
  String get serviceKeep => 'Оставить';

  @override
  String get serviceStartAutomatic => 'Автоматически';

  @override
  String get serviceStartDelayed => 'Автоматически (отложенный запуск)';

  @override
  String get serviceStartManual => 'Вручную';

  @override
  String get serviceStartDisabled => 'Отключена';

  @override
  String get serviceStartBoot => 'Загрузка';

  @override
  String get serviceRunning => 'Выполняется';

  @override
  String get serviceStopped => 'Остановлена';

  @override
  String get serviceSetDisabled => 'Отключить';

  @override
  String get serviceSetManual => 'Сделать ручной';

  @override
  String get serviceSetAutomatic => 'Сделать автоматической';

  @override
  String serviceChangeTitle(String service) {
    return 'Изменить $service';
  }

  @override
  String serviceChangeConfirm(String from, String to, String reason) {
    return 'Тип запуска: $from → $to.\n$reason\nДействует со следующего запуска службы или Windows. Отменить можно сразу после.';
  }

  @override
  String serviceChanged(String service, String to) {
    return '$service: теперь $to.';
  }

  @override
  String get serviceUndo => 'Отменить';

  @override
  String get serviceNote =>
      'Изменения требуют прав администратора и действуют со следующего запуска службы или Windows. Нужные Windows службы никогда не предлагаются; отключение службы, от которой зависят другие, запрещено.';

  @override
  String get noServicesMatch => 'Нет служб, подходящих под фильтры.';

  @override
  String get svcReasonTelemetry =>
      'Отправляет данные об использовании и диагностике в Microsoft. Ничего из используемого не перестаёт работать.';

  @override
  String get svcReasonDeviceManagement =>
      'Телеметрия и управление устройствами работы или учёбы: нужна, только если ПК управляет организация.';

  @override
  String get svcReasonCrashReports =>
      'Отправляет отчёты о сбоях в Microsoft. Сбои по-прежнему записываются на этом ПК.';

  @override
  String get svcReasonRemoteRegistry =>
      'Позволяет другим компьютерам изменять реестр этого ПК по сети. По умолчанию выключена.';

  @override
  String get svcReasonOfflineMaps =>
      'Обновляет офлайн-карты для приложения «Карты».';

  @override
  String get svcReasonMediaSharing =>
      'Открывает доступ к библиотеке Windows Media Player по сети.';

  @override
  String get svcReasonRetailDemo => 'Демо-режим для магазинов. Дома не нужен.';

  @override
  String get svcReasonXbox =>
      'Без неё перестают работать приложение Xbox, Game Pass, облачные сохранения и аксессуары Xbox.';

  @override
  String get svcReasonPrinting =>
      'Без неё перестаёт работать печать, включая печать в PDF.';

  @override
  String get svcReasonBluetooth =>
      'Без неё Bluetooth-устройства перестают подключаться.';

  @override
  String get svcReasonSearch =>
      'Без неё поиск в «Пуске», «Параметрах» и проводнике становится медленным и неполным.';

  @override
  String get svcReasonSysMain =>
      'Заранее загружает часто используемые приложения. Без неё запуск может быть медленнее, особенно на HDD.';

  @override
  String get svcReasonTouchKeyboard =>
      'Без неё перестают работать сенсорная клавиатура, рукописный ввод, панель эмодзи и некоторые методы ввода.';

  @override
  String get svcReasonLocation =>
      'Без неё приложения и «Поиск устройства» не смогут определить ваше местоположение.';

  @override
  String get svcReasonBiometrics =>
      'Без неё перестаёт работать вход Windows Hello по лицу и отпечатку пальца.';

  @override
  String get svcReasonPhone =>
      'Без неё перестают работать звонки через «Связь с телефоном».';

  @override
  String get svcReasonRemoteDesktop =>
      'Без неё перестаёт работать удалённый рабочий стол к этому ПК.';

  @override
  String get svcReasonSmartCard =>
      'Без неё перестают работать смарт-карты и некоторые ключи безопасности.';

  @override
  String get svcReasonParental =>
      'Без неё ограничения Microsoft Family Safety больше не действуют.';

  @override
  String get svcReasonNfc =>
      'Без неё перестают работать NFC и бесконтактная оплата.';

  @override
  String get svcReasonHotspot =>
      'Без неё перестаёт работать мобильная точка доступа.';

  @override
  String get svcReasonScanner =>
      'Без неё перестают работать сканеры и некоторые камеры.';

  @override
  String get svcReasonCompatibility =>
      'Без неё Windows не предлагает исправления, если старая программа не запускается.';

  @override
  String get svcReasonFax => 'Без неё перестаёт работать факс.';

  @override
  String get svcReasonInsider =>
      'Без неё перестают приходить предварительные сборки Windows Insider.';

  @override
  String get svcReasonUpdates =>
      'Нужна Центру обновления Windows: без неё перестают приходить исправления безопасности.';

  @override
  String get svcReasonSecurity =>
      'Защищает этот ПК (антивирус, брандмауэр, состояние безопасности).';

  @override
  String get svcReasonWindowsCore =>
      'Нужна Windows для звука, сети, журналов или базовых функций.';

  @override
  String get svcReasonNotReviewed =>
      'Часть Windows, не проверена: оставьте как есть.';

  @override
  String get svcReasonDriverService =>
      'Установлена с драйвером: не трогайте, если не знаете, что она делает.';

  @override
  String get svcReasonMicrosoftApp =>
      'Принадлежит приложению Microsoft: без неё оно может перестать работать или обновляться.';

  @override
  String get svcReasonThirdParty =>
      'Установлена другой программой: без неё та может перестать работать или обновляться.';

  @override
  String get serviceStartTypeAction => 'Изменить запуск';

  @override
  String get presetsTab => 'Пресеты';

  @override
  String get presetDebloatName => 'Только очистка от лишнего';

  @override
  String get presetDebloatSummary =>
      'Удаляет предустановленные приложения Microsoft, которыми мало кто пользуется. Больше ничего не меняет.';

  @override
  String get presetCleanName => 'Чистый';

  @override
  String get presetCleanSummary =>
      'Очистка, плюс отключение телеметрии, ненужных служб и приложений, которые запускаются с Windows без причины.';

  @override
  String get presetGamingName => 'Игровой';

  @override
  String get presetGamingSummary =>
      'Чистый, плюс настройки для игр: без энергосберегающего ограничения приложений, «Завершить задачу» на панели. Xbox остаётся.';

  @override
  String get presetPrivacyName => 'Конфиденциальность';

  @override
  String get presetPrivacySummary =>
      'Чистый, плюс настройки конфиденциальности из руководства Microsoft: рекламный ID, отслеживание, рекомендации, диагностические данные по минимуму.';

  @override
  String get presetCompetitiveName => 'Competitive';

  @override
  String get presetCompetitiveSummary =>
      'Убирает всё, что и другие пресеты, и больше: часто используемые приложения, Xbox, печать, лаунчеры при запуске, запись игр. Плюс чистая установка драйвера и WinSux вручную.';

  @override
  String get presetAttention => 'Внимание';

  @override
  String get presetAttentionNote =>
      'Убирает многое, включая то, чем многие пользуются. Прирост FPS, задержки и прочего не обещается: это набор изменений, а не измеренное улучшение.';

  @override
  String get presetGroupApps => 'Удаляемые приложения (текущий пользователь)';

  @override
  String get presetGroupServices => 'Отключаемые службы';

  @override
  String get presetGroupStartup => 'Отключаемые элементы автозагрузки';

  @override
  String get presetGroupTweaks => 'Настройки';

  @override
  String get presetGroupThirdParty => 'Сторонние скрипты и инструменты';

  @override
  String get presetGroupRestart => 'Перезагрузка';

  @override
  String get presetGroupReversible => 'Что можно отменить';

  @override
  String get presetRestartNeeded =>
      'Перезагрузитесь после: службы и автозагрузка меняются при следующем запуске.';

  @override
  String get presetRestartNone => 'Перезагрузка не нужна.';

  @override
  String get presetReversibleApps =>
      'Приложения: переустановите из Microsoft Store.';

  @override
  String get presetReversibleSettings =>
      'Службы, автозагрузка и настройки: отмените сразу кнопкой «Отменить пресет» или позже точкой восстановления, созданной заранее.';

  @override
  String get presetReversibleManual =>
      'Сторонние шаги ZapTweaks не выполняет: для отмены следуйте инструкциям автора.';

  @override
  String get presetManualWhy =>
      'Вручную: скрипт скачивает и запускает другие файлы, которые нельзя закрепить хешем, поэтому ZapTweaks его не запускает.';

  @override
  String get presetManualDriverClean =>
      'Чистая установка видеодрайвера: DDU в безопасном режиме, затем свежий драйвер от производителя.';

  @override
  String get presetManualWinsux =>
      'WinSux: очистка и настройки Windows одним скриптом.';

  @override
  String get presetPreview => 'Предпросмотр на этом ПК';

  @override
  String get presetPreviewLoading =>
      'Чтение приложений, служб, автозагрузки и настроек…';

  @override
  String get presetStatusApply => 'Сделать';

  @override
  String get presetStatusDone => 'Уже сделано';

  @override
  String get presetStatusSkipped => 'Пропущено';

  @override
  String get presetStatusManual => 'Вручную';

  @override
  String get presetSkipNotInstalled => 'не установлено';

  @override
  String get presetSkipNotFound => 'нет на этом ПК';

  @override
  String get presetSkipUnsupported => 'здесь не поддерживается';

  @override
  String get presetSkipDuplicate => 'одно имя дважды: меняется только первая';

  @override
  String presetCounts(int apply, int done, int skipped) {
    return '$apply сделать · $done уже сделано · $skipped пропущено';
  }

  @override
  String get presetConsent => 'Я прочитал весь список и принимаю риск.';

  @override
  String get presetApply => 'Применить пресет';

  @override
  String get presetApplyNote =>
      'Сначала создаётся точка восстановления; если не удалось, ничего не меняется. Изменения администратора запрашивают UAC один раз.';

  @override
  String get presetApplying => 'Применение…';

  @override
  String presetReport(int ok, int failed) {
    return 'Готово: изменено $ok, не изменено $failed.';
  }

  @override
  String get presetUndo => 'Отменить пресет';

  @override
  String get presetUndone =>
      'Пресет отменён. Удалённые приложения не вернутся сами: установите их из Store.';

  @override
  String get presetNothingToDo => 'Нечего делать: всё уже сделано.';

  @override
  String get presetSaveAs => 'Сохранить как свой пресет';

  @override
  String get presetSaveNote =>
      'Сохраняет отмеченные пункты. Поделитесь файлом для экспорта; положите файл в папку для импорта.';

  @override
  String get presetName => 'Название';

  @override
  String presetSaved(String path) {
    return 'Сохранено: $path';
  }

  @override
  String get presetOpenFolder => 'Открыть папку пресетов';

  @override
  String get presetUserTitle => 'Мои пресеты';

  @override
  String presetInvalidFile(String file, String error) {
    return '$file не загружен: $error';
  }

  @override
  String get presetItemPowerThrottling =>
      'Энергосберегающее ограничение приложений выключено';

  @override
  String get presetItemEndTask => '«Завершить задачу» в меню панели задач';

  @override
  String get presetItemAdvertisingId => 'Рекламный идентификатор выключен';

  @override
  String get presetItemLanguageList => 'Сайты не видят список ваших языков';

  @override
  String get presetItemAppLaunchTracking =>
      'Windows не отслеживает запуск приложений';

  @override
  String get presetItemTailoredExperiences =>
      'Без персонализации по диагностическим данным';

  @override
  String get presetItemCloudContent => 'Без облачного контента (рекомендаций)';

  @override
  String get presetItemDiagnosticData =>
      'Диагностические данные: только обязательные';

  @override
  String get presetItemLockScreenOverlay =>
      'Без подсказок на экране блокировки';

  @override
  String get presetItemLockScreenFacts =>
      'Без интересных фактов на экране блокировки';

  @override
  String get presetItemGameDvr => 'Запись игр Game Bar выключена';

  @override
  String get presetSkipHasDependents =>
      'От него зависят другие службы, поэтому Windows не позволяет его отключить.';

  @override
  String get settingsGeneral => 'Общие';

  @override
  String get settingsModes => 'Режимы';

  @override
  String get settingsMaintenance => 'Обслуживание';

  @override
  String get settingsAbout => 'О программе';

  @override
  String get openLogFolderDescription =>
      'Журналы сеансов со всеми командами, выполненными ZapTweaks.';

  @override
  String get redetectSystemStateDescription =>
      'Заново прочитать оборудование и состояние каждого твика.';

  @override
  String get profileTitle => 'Профиль настроек';

  @override
  String get profileDescription =>
      'Сохранить настройки ZapTweaks в файл или загрузить их из файла.';

  @override
  String get resetAppSettingsDescription =>
      'Вернуть настройки ZapTweaks по умолчанию. Windows не изменяется.';

  @override
  String get expertModeOn => 'Вкл.';

  @override
  String get expertModeOff => 'Выкл.';
}
