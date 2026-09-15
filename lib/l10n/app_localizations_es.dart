// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Elige el idioma que usa ZapTweaks.';

  @override
  String get settings => 'Configuración';

  @override
  String get startWithWindows => 'Iniciar con Windows';

  @override
  String get startWithWindowsDescription =>
      'Inicia ZapTweaks después de iniciar sesión en Windows.';

  @override
  String get openLogFolder => 'Abrir carpeta de registros';

  @override
  String get redetectSystemState => 'Volver a detectar el estado del sistema';

  @override
  String get exportProfile => 'Exportar perfil';

  @override
  String get importProfile => 'Importar perfil';

  @override
  String get resetAppSettings => 'Restablecer ajustes de la aplicación';

  @override
  String get updates => 'Actualizaciones';

  @override
  String get automaticUpdateNotifications =>
      'Notificaciones automáticas de actualización';

  @override
  String get automaticUpdateDescription =>
      'Comprueba al iniciar y muestra un indicador. Las actualizaciones nunca se instalan automáticamente.';

  @override
  String get checking => 'Comprobando...';

  @override
  String get checkNow => 'Comprobar ahora';

  @override
  String get viewRelease => 'Ver versión';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get applicationVersion => 'Versión de la aplicación';

  @override
  String get dryRunMode => 'Modo de simulación';

  @override
  String get dryRunDescription => 'Simula comandos sin modificar Windows.';

  @override
  String get done => 'Hecho';

  @override
  String get operationFailed => 'Operación fallida';

  @override
  String get updateAvailable => 'Hay una actualización disponible';

  @override
  String get updateAvailableDescription =>
      'Puedes revisar las notas de la versión o instalarla directamente.';

  @override
  String get updateAvailableShort => 'Actualización disponible';

  @override
  String get checkingForUpdates => 'Buscando actualizaciones';

  @override
  String get contactingReleaseServer => 'Contacting the release server...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version está disponible';
  }

  @override
  String installedVersion(Object version) {
    return 'Versión instalada: $version';
  }

  @override
  String get releaseNotesOnGitHub =>
      'Las notas de la versión están disponibles en GitHub.';

  @override
  String get later => 'Más tarde';

  @override
  String get failed => 'Fallido';

  @override
  String get downloadingUpdate => 'Descargando actualización';

  @override
  String get downloadingUpdateDescription =>
      'Downloading and preparing the installer...';

  @override
  String get adminPrivilegesRequired =>
      'Se requieren privilegios de administrador';

  @override
  String get adminRequiredBanner =>
      'Cierra la aplicación e inicia ZapTweaks con \"Ejecutar como administrador\". Sin elevación, los ajustes del sistema no se pueden aplicar de forma segura.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get createRestorePoint => 'Crear punto de restauración';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks necesita permisos de administrador para aplicar la configuración del sistema.\n\nCierre la aplicación, haga clic derecho en el ejecutable y seleccione \"Ejecutar como administrador\".';

  @override
  String get understood => 'entendido';

  @override
  String aboutVersion(Object version) {
    return 'Versión: v$version';
  }

  @override
  String get author => 'Autor: PrimeBuild';

  @override
  String get aboutDescription =>
      'Compañero de optimización avanzada para flujos de trabajo de diagnóstico, hardware y juegos de Windows más profundos.';

  @override
  String year(Object year) {
    return 'Año: $year';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get github => 'GitHub';

  @override
  String get discord => 'discordia';

  @override
  String get homeAndStats => 'Inicio y estadísticas';

  @override
  String get cpuUsage => 'Uso de CPU';

  @override
  String get cpuUsageDescription =>
      'Utilización en tiempo real de los contadores de Windows';

  @override
  String get gpuUsage => 'Uso de GPU';

  @override
  String get gpuUsageDescription => 'Utilización del motor en tiempo real';

  @override
  String get vramUsage => 'Uso de VRAM';

  @override
  String get memoryUsage => 'Uso de la memoria';

  @override
  String get unknown => 'Desconocido';

  @override
  String get installedRam => 'RAM instalada';

  @override
  String get networkAdapters => 'Adaptadores de red';

  @override
  String get noConnectedAdapters => 'No se detectaron adaptadores conectados';

  @override
  String get audioDevices => 'Dispositivos de audio';

  @override
  String get noAudioDevices => 'No se detectaron dispositivos de audio';

  @override
  String get noTweaksAvailable =>
      'No hay ajustes disponibles para la configuración de su hardware.';

  @override
  String get detectedHardware => 'Hardware detectado';

  @override
  String get gpuUnknown => 'GPU: Desconocido';

  @override
  String cpuValue(Object value) {
    return 'CPU: $value';
  }

  @override
  String gpuValue(Object value) {
    return 'GPU: $value';
  }

  @override
  String ramValue(Object value) {
    return 'RAM: $value';
  }

  @override
  String get enableAllVisible => 'Habilitar todo lo visible';

  @override
  String get disableAllVisible => 'Desactivar todo lo visible';

  @override
  String get restartNow => 'Reiniciar ahora';

  @override
  String get restartRequired => 'Reiniciar requerido';

  @override
  String get restartRequiredDescription =>
      'Es necesario reiniciar el sistema para aplicar completamente uno o más cambios.';

  @override
  String get advancedActionsIncluded => 'Acciones avanzadas incluidas';

  @override
  String get advancedActionsDescription =>
      'Aquí se agrupan herramientas externas, acciones del iniciador y utilidades basadas en scripts para diagnósticos rápidos y flujos de trabajo de mantenimiento.';

  @override
  String get aggressiveTweakWarning =>
      'Ajuste agresivo. Se recomienda un punto de restauración.';

  @override
  String get networkReconnectWarning =>
      'Es posible que sea necesario volver a conectar el adaptador de red o reiniciar el sistema.';

  @override
  String get actionWarning => 'Advertencia de acción';

  @override
  String get unknownError => 'Error desconocido.';

  @override
  String get presets => 'Preajustes';

  @override
  String get presetFailed => 'Preajuste fallido';

  @override
  String get safetyWarning => 'Advertencia de seguridad';

  @override
  String get unavailable => 'No disponible';

  @override
  String get powerPlans => 'Planes de energía incluidos';

  @override
  String get powerPlansDescription =>
      'Importe y active un plan incluido. ZapTweaks recuerda el plan activo anterior para restaurar.';

  @override
  String get noPowerPlans => 'No se encontraron planes de energía agrupados.';

  @override
  String get working => 'Trabajando...';

  @override
  String get importAndActivate => 'Importar y activar';

  @override
  String get restorePreviousPlan => 'Restaurar plan anterior';

  @override
  String get ran => 'corrió';

  @override
  String get gpuDrivers => 'Controladores de GPU';

  @override
  String get noGpuDrivers => 'No se detectaron controladores de GPU';

  @override
  String get chipsetDrivers => 'Controladores de conjuntos de chips';

  @override
  String get noChipsetDrivers => 'No se detectaron controladores de chipset';

  @override
  String get monitors => 'Monitores';

  @override
  String get noMonitors => 'No se detectaron monitores';

  @override
  String get mice => 'ratones';

  @override
  String get noMice => 'No se detectaron ratones';

  @override
  String get keyboards => 'Teclados';

  @override
  String get noKeyboards => 'No se detectaron teclados';

  @override
  String get restorePointPromptTitle => '¿Crear un punto de restauración?';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks puede crear un punto de restauración de Windows antes de cambiar la configuración del sistema. Es opcional: si lo omites, el cambio se aplica igualmente. Solo se pregunta una vez por sesión.';

  @override
  String get skip => 'Omitir';

  @override
  String get continueAction => 'Continuar';

  @override
  String get tweaksSectionHeader => 'AJUSTES';

  @override
  String get startingUp => 'Iniciando ZapTweaks';

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
