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
      'Records a bounded 15-second Windows Performance Recorder trace and a DPC/ISR event-count report on demand. Counts are diagnostic signals, not proof of latency. No monitor remains active.';

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
  String get interruptConfiguration => 'Interrupts';

  @override
  String get interruptConfigurationDescription =>
      'Advanced, capability-gated MSI and group-0 interrupt-affinity controls for present display, network, and media devices. No value is recommended automatically.';

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
      'No present display, network, or media PCI device exposes compatible interrupt capabilities.';

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
