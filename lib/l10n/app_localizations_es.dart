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
