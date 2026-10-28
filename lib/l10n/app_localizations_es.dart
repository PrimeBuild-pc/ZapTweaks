// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get externalDownload => 'Descarga externa';

  @override
  String get appRequirements => 'Requisitos';

  @override
  String get appWarnings => 'Advertencias';

  @override
  String get metricUnavailable => 'N/D';

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Elige el idioma que usa ZapTweaks.';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceDescription =>
      'Seguir a Windows o usar un tema fijo claro u oscuro en la app.';

  @override
  String get themeSystem => 'Predeterminado de Windows';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

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
  String get expertMode => 'Modo experto';

  @override
  String get expertModeDescription =>
      'Muestra operaciones avanzadas y herramientas externas solo tras un consentimiento manual explícito. Está desactivado por defecto; las restricciones de seguridad siguen vigentes.';

  @override
  String get searchOperations => 'Buscar operaciones';

  @override
  String get searchResults => 'Resultados de búsqueda';

  @override
  String get searchSections => 'Secciones y herramientas integradas';

  @override
  String get searchApps => 'Buscar apps';

  @override
  String get searchCatalog => 'Operaciones y herramientas externas';

  @override
  String get searchOpenResult => 'Abrir';

  @override
  String get searchExpertRequired => 'Activa el modo experto para abrir';

  @override
  String get noSearchResults =>
      'No hay secciones, apps, operaciones ni herramientas que coincidan.';

  @override
  String get operationTaskbarEndTaskTitle =>
      'Finalizar tarea en la barra de tareas';

  @override
  String get operationTaskbarEndTaskDescription =>
      'Muestra Finalizar tarea en el menú contextual de las apps de la barra de tareas.';

  @override
  String get appStore => 'Tienda de apps';

  @override
  String get appManagement => 'Apps instaladas';

  @override
  String get windowsAppTools => 'Herramientas de apps de Windows';

  @override
  String get optionalFeatures => 'Características opcionales';

  @override
  String get searchOptionalFeatures => 'Buscar características opcionales';

  @override
  String get scanOptionalFeatures => 'Analizar características (UAC)';

  @override
  String get optionalFeaturesUacNotice =>
      'El inventario de características y cada cambio pasan por el asistente autorizado. El análisis no cambia nada.';

  @override
  String get confirmOptionalFeatureChange =>
      'Confirmar cambio de característica opcional';

  @override
  String confirmOptionalFeatureChangeMessage(Object name, Object action) {
    return 'Característica: $name\nAcción: $action\n\nWindows puede pedir un reinicio. El estado anterior se guarda antes del cambio.';
  }

  @override
  String get enable => 'Activar';

  @override
  String get disable => 'Desactivar';

  @override
  String get enabled => 'Activada';

  @override
  String get disabled => 'Desactivada';

  @override
  String get enablePending => 'Activación pendiente de reinicio';

  @override
  String get disablePending => 'Desactivación pendiente de reinicio';

  @override
  String get startupApps => 'Apps de inicio';

  @override
  String get searchStartupApps => 'Buscar apps de inicio';

  @override
  String get openStartupSettings => 'Abrir configuración de inicio';

  @override
  String get openTaskManagerStartup =>
      'Abrir Inicio en el Administrador de tareas';

  @override
  String get startupInventoryNotice =>
      'Inventario de inicio de solo lectura. Usa Configuración de Windows o el Administrador de tareas para cambiar una entrada.';

  @override
  String get guidedSetup => 'Configuración guiada';

  @override
  String get wizardInventory => 'Inventario';

  @override
  String get wizardBaseline => 'Punto de partida';

  @override
  String get wizardWindowsUpdate => 'Windows Update';

  @override
  String get wizardDrivers => 'Revisión de controladores';

  @override
  String get wizardApplications => 'Aplicaciones';

  @override
  String get wizardDebloat => 'Limpieza selectiva';

  @override
  String get wizardPrivacyInterface => 'Privacidad e interfaz';

  @override
  String get wizardPreview => 'Vista previa del plan';

  @override
  String get wizardApply => 'Aplicar';

  @override
  String get wizardReport => 'Informe final';

  @override
  String get wizardInventoryDescription =>
      'Lee el hardware, los paquetes winget instalados y los dispositivos presentes antes de elegir nada.';

  @override
  String get runInventory => 'Hacer inventario';

  @override
  String inventorySummary(Object apps, Object devices) {
    return 'Se detectaron $apps paquetes winget y $devices dispositivos presentes.';
  }

  @override
  String get wizardUpdateNotice =>
      'Revisa Windows Update antes de cambiar controladores y apps. ZapTweaks no instala actualizaciones automáticamente.';

  @override
  String get openWindowsUpdate => 'Abrir Windows Update';

  @override
  String get updatesReviewed => 'He revisado Windows Update';

  @override
  String driverInventorySummary(Object devices, Object missing) {
    return 'Dispositivos presentes: $devices\nDispositivos sin INF asociado: $missing';
  }

  @override
  String get wizardDebloatNotice =>
      'Ninguna limpieza es implícita. Aquí solo se pueden elegir paquetes AppX del usuario actual con una fuente de restauración verificada; las demás eliminaciones siguen en App → Apps instaladas con su propia vista previa.';

  @override
  String get wizardPrivacyNotice =>
      'Los ajustes de privacidad e interfaz no cambian salvo que los elijas expresamente abajo.';

  @override
  String get noAppsSelected =>
      'No hay operaciones seleccionadas. El asistente no hará cambios.';

  @override
  String planContains(Object count) {
    return 'El plan contiene $count operación(es) explícita(s):';
  }

  @override
  String readyToApply(Object count) {
    return 'Listo para aplicar $count operación(es) de apps. Cada paquete se verifica cuando winget termina.';
  }

  @override
  String get noPlanReport => 'Terminado sin aplicar ningún plan.';

  @override
  String get planStatus => 'Estado del plan';

  @override
  String get applyPlan => 'Aplicar plan';

  @override
  String get back => 'Atrás';

  @override
  String get finish => 'Terminar';

  @override
  String get recovery => 'Recuperación';

  @override
  String get diagnosticTools => 'Herramientas de diagnóstico';

  @override
  String get repairComponentStore =>
      'Reparar el almacén de componentes de Windows';

  @override
  String get repairComponentStoreDescription =>
      'Ejecuta DISM RestoreHealth y después una verificación ScanHealth aparte. Puede tardar mucho.';

  @override
  String get repairSystemFiles => 'Reparar archivos protegidos del sistema';

  @override
  String get repairSystemFilesDescription =>
      'Ejecuta un análisis y reparación SFC y después una pasada de verificación aparte.';

  @override
  String get confirmSystemRepair => 'Confirmar reparación de Windows';

  @override
  String get systemRepairWarning =>
      'La reparación puede sustituir componentes dañados de Windows y ZapTweaks no puede deshacerla. No apagues el PC mientras se ejecuta.';

  @override
  String get systemRepairVerified =>
      'Reparación completada y verificación superada.';

  @override
  String get runRepair => 'Reparar';

  @override
  String get operationCompleted => 'Operación completada';

  @override
  String get captureEtwTrace => 'Capturar seguimiento de rendimiento';

  @override
  String get captureEtwTraceDescription =>
      'Graba un seguimiento acotado de Windows Performance Recorder y genera un informe de diagnóstico DPC/ISR a petición. No queda ningún monitor activo.';

  @override
  String get dpcLatencyAnalyzer => 'Analizador de latencia DPC / ISR';

  @override
  String get dpcLatencyAnalyzerDescription =>
      'Captura ETW a petición e informa de la actividad DPC, ISR, de fallos graves de página y de cambios de contexto, su reparto por procesador, los módulos de kernel observados y los proveedores ETW.';

  @override
  String get diagnosticNotCausality =>
      'Señal de diagnóstico, no un veredicto de latencia';

  @override
  String get diagnosticNotCausalityDescription =>
      'Los recuentos y los nombres de módulo observados ayudan a acotar una investigación, pero no prueban que un controlador cause la latencia. Confírmalo con capturas A/B/A repetibles y WPA o herramientas del fabricante.';

  @override
  String get startDpcCapture => 'Iniciar captura';

  @override
  String get openTraceFolder => 'Abrir carpeta de seguimientos';

  @override
  String captureInProgress(int seconds) {
    return 'Capturando durante $seconds segundos… mantén la carga en marcha.';
  }

  @override
  String get traceDuration => 'Duración observada';

  @override
  String get hardFaults => 'Fallos graves de página';

  @override
  String get contextSwitches => 'Cambios de contexto';

  @override
  String get totalEvents => 'Eventos ETW totales';

  @override
  String get kernelModulesObserved =>
      'Módulos de kernel observados en eventos DPC/ISR';

  @override
  String get noKernelModulesObserved =>
      'Los eventos exportados no incluían nombres de módulos de kernel. Abre el ETL en WPA para un análisis con símbolos.';

  @override
  String get dpcIsrByProcessor => 'Eventos DPC/ISR por procesador lógico';

  @override
  String get noProcessorDistribution =>
      'Los eventos exportados no incluían ID de procesador.';

  @override
  String get topEtwProviders => 'Principales proveedores ETW';

  @override
  String get noProviderData => 'No hay datos de proveedores.';

  @override
  String etwTraceSaved(Object path) {
    return 'Seguimiento guardado en $path';
  }

  @override
  String get cleanupDiagnosticTraces => 'Eliminar seguimientos de diagnóstico';

  @override
  String get cleanupDiagnosticTracesDescription =>
      'Busca solo los archivos de seguimiento de ZapTweaks, muestra el número exacto de archivos y el total de bytes, y los elimina tras confirmar.';

  @override
  String cleanupTracePreview(int count, int bytes) {
    return '¿Eliminar $count archivos de seguimiento de ZapTweaks ($bytes bytes)? No se puede deshacer.';
  }

  @override
  String get cleanupTracesCompleted =>
      'Los seguimientos mostrados se eliminaron y se comprobó que ya no existen.';

  @override
  String get noDiagnosticTraces =>
      'No se encontraron seguimientos de diagnóstico de ZapTweaks.';

  @override
  String get hardwareMonitor => 'Monitor de hardware';

  @override
  String get dedicatedVramUsage => 'Memoria de GPU dedicada en uso';

  @override
  String get dedicatedVramUsageDescription =>
      'Toma una sola lectura de los contadores de rendimiento de GPU de Windows. Después no queda nada en marcha.';

  @override
  String vramUsageValue(Object megabytes) {
    return '$megabytes MB';
  }

  @override
  String get captureNow => 'Capturar ahora';

  @override
  String get tweaks => 'Ajustes';

  @override
  String get searchPowerPlans => 'Buscar planes de energía';

  @override
  String get activePowerPlan => 'Activo';

  @override
  String get activate => 'Activar';

  @override
  String get details => 'Detalles';

  @override
  String get compare => 'Comparar';

  @override
  String get noPowerDifferences =>
      'No hay diferencias entre los valores con corriente y con batería.';

  @override
  String get importPowerPlan => 'Importar .pow';

  @override
  String get importPowerPlanDescription =>
      'Importa un plan de energía elegido localmente tras una preparación acotada y verificada por hash.';

  @override
  String get exportActivePowerPlan => 'Exportar plan activo';

  @override
  String get restoreDefaultPowerSchemes => 'Restaurar valores de Windows';

  @override
  String get restoreDefaultPowerSchemesDescription =>
      'Exporta con hash cada esquema actual antes de pedir a Windows que restaure los predeterminados.';

  @override
  String get restoreDefaultPowerSchemesWarning =>
      '¿Sustituir todos los esquemas de energía actuales por los predeterminados de Windows? ZapTweaks exportará antes cada esquema para poder deshacerlo exactamente.';

  @override
  String get interruptConfiguration =>
      'MSI Utility v3 y afinidad de interrupciones';

  @override
  String get interruptConfigurationDescription =>
      'Controles avanzados de MSI y afinidad de interrupciones del grupo 0, según la capacidad, para dispositivos de pantalla, red, multimedia, host USB y audio HD presentes. No se recomienda ningún valor automáticamente.';

  @override
  String get configureMsi => 'Configurar MSI';

  @override
  String get enableMsi => 'Activar interrupciones señalizadas por mensaje';

  @override
  String get configureInterruptAffinity => 'Configurar afinidad';

  @override
  String get interruptChangeWarning =>
      'Una directiva de interrupciones no válida puede dejar el dispositivo inutilizable hasta deshacer o reiniciar. ZapTweaks valida los límites del hardware y guarda los valores actuales exactos.';

  @override
  String get affinityMaskHint =>
      'Máscara hexadecimal del grupo 0, por ejemplo 3';

  @override
  String get invalidAffinityMask =>
      'Introduce una máscara hexadecimal canónica distinta de cero y de 64 bits como máximo.';

  @override
  String msiRange(int maximum) {
    return 'El número de mensajes debe estar entre 1 y $maximum.';
  }

  @override
  String get noCompatibleInterruptDevices =>
      'Ningún dispositivo PCI presente de pantalla, red, multimedia, host USB o audio HD ofrece capacidades de interrupción compatibles.';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return 'Hardware: Line $line · MSI $msi · MSI-X $msix · máximo de mensajes $maximum';
  }

  @override
  String get messageNumberLimit => 'Límite de número de mensajes';

  @override
  String get interruptPriority => 'Directiva de prioridad de interrupción';

  @override
  String get interruptPriorityDefault =>
      'Sin definir / predeterminado del controlador';

  @override
  String get interruptPriorityLow => 'Baja';

  @override
  String get interruptPriorityNormal => 'Normal';

  @override
  String get interruptPriorityHigh => 'Alta';

  @override
  String get interruptPolicy => 'Directiva de afinidad de procesador';

  @override
  String get interruptPolicyDefault => 'Predeterminado del equipo';

  @override
  String get interruptPolicyAllClose => 'Todos los procesadores cercanos';

  @override
  String get interruptPolicyOneClose => 'Un procesador cercano';

  @override
  String get interruptPolicyAllProcessors => 'Todos los procesadores';

  @override
  String get interruptPolicySpecified => 'Procesadores indicados (grupo 0)';

  @override
  String get interruptPolicySpread => 'Repartir mensajes entre procesadores';

  @override
  String get selectLogicalProcessors =>
      'Elige procesadores lógicos del grupo de procesadores 0';

  @override
  String get affinitySelectAll => 'Todos los procesadores lógicos';

  @override
  String get affinityClear => 'Borrar';

  @override
  String get affinityPhysicalCores => 'Un hilo por núcleo físico';

  @override
  String get affinityPerformanceCores => 'Núcleos de rendimiento';

  @override
  String get affinityEfficiencyCores => 'Núcleos de eficiencia';

  @override
  String get affinityParked => 'aparcado';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'Nodo NUMA $index';
  }

  @override
  String get compatibleDevices => 'Dispositivos compatibles';

  @override
  String get msiEnabledDevices => 'MSI activado ahora';

  @override
  String get logicalProcessors => 'Procesadores lógicos';

  @override
  String get searchDevices =>
      'Buscar dispositivos, ID de instancia o INF del controlador';

  @override
  String get driverUnknown => 'INF del controlador no disponible';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return 'Actual: $mode · mensajes $messages · prioridad $priority · directiva $policy · máscara $mask';
  }

  @override
  String get renamePowerPlan => 'Cambiar nombre del plan de energía';

  @override
  String get renamePowerPlanDescription =>
      'Cambia solo el nombre visible del plan elegido y conserva el original para deshacer.';

  @override
  String get rename => 'Cambiar nombre';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get duplicatePowerPlan => 'Duplicar plan de energía';

  @override
  String get duplicatePowerPlanDescription =>
      'Crea y verifica una copia con PowrProf. Deshacer es posible solo en la medida de lo posible, porque Windows asigna el GUID al crearla.';

  @override
  String get apply => 'Aplicar';

  @override
  String get edit => 'Editar';

  @override
  String powerValueRange(int maximum) {
    return 'Los valores deben estar entre 0 y $maximum.';
  }

  @override
  String get powerSettingConfigure =>
      'Configurar cualquier ajuste de energía acotado';

  @override
  String get powerSettingConfigureDescription =>
      'Edita un ajuste que expone PowrProf solo cuando Windows facilita en vivo el mínimo, el máximo y el incremento.';

  @override
  String get searchPowerSettings =>
      'Buscar ajustes, descripciones, subgrupos o GUID';

  @override
  String get allPowerSubgroups => 'Todos los grupos de ajustes de energía';

  @override
  String powerSettingCount(int count) {
    return '$count ajustes';
  }

  @override
  String powerSettingOptions(int count) {
    return '$count opciones definidas por Windows';
  }

  @override
  String get backToPowerPlans => 'Volver a los planes de energía';

  @override
  String get powerPlanEditorHint =>
      'Duplica un plan para crear tu perfil y luego abre Detalles para editar uno a uno sus ajustes ocultos con corriente y con batería.';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Intervalo $minimum–$maximum, paso $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows no expuso valores ni límites seguros para este ajuste.';

  @override
  String get delete => 'Eliminar';

  @override
  String get deletePowerPlan => 'Eliminar plan de energía';

  @override
  String get deletePowerPlanDescription =>
      'Exporta el plan inactivo elegido antes de eliminarlo y conserva la copia para deshacer exactamente.';

  @override
  String deletePowerPlanWarning(Object name) {
    return '¿Eliminar $name? ZapTweaks exportará antes una copia de recuperación.';
  }

  @override
  String get firmwareTemperatures => 'Zonas térmicas del firmware';

  @override
  String get firmwareTemperaturesDescription =>
      'Lee una vez las zonas térmicas ACPI. Su disponibilidad y el significado del sensor dependen del firmware del PC; los valores no se etiquetan como temperatura de CPU o GPU.';

  @override
  String get noThermalSensors => 'Este PC no expone zonas térmicas ACPI.';

  @override
  String get cpuFrequency => 'Frecuencia de CPU y aparcamiento de núcleos';

  @override
  String get cpuFrequencyDescription =>
      'Toma una lectura de los contadores de rendimiento del procesador de Windows. La frecuencia efectiva es la base × % de rendimiento del procesador, la misma fórmula que el Administrador de tareas. Sirve para comprobar cambios de plan de energía, boost y aparcamiento de núcleos. Solo lectura.';

  @override
  String cpuEffectiveClock(Object mhz, Object nominal) {
    return '$mhz MHz efectivos · base $nominal MHz';
  }

  @override
  String cpuParkedCount(Object parked, Object total) {
    return '$parked de $total procesadores lógicos aparcados';
  }

  @override
  String get cpuParked => 'aparcado';

  @override
  String get cpuFrequencySource =>
      'Fuente: contadores de rendimiento Processor Information (Win32_PerfFormattedData_Counters_ProcessorInformation), una lectura promediada en el último intervalo del contador. No es la frecuencia máxima. Los valores por núcleo usan una sola frecuencia nominal, así que los núcleos de eficiencia de las CPU híbridas salen altos.';

  @override
  String get driverInventory => 'Inventario del almacén de controladores';

  @override
  String get installLocalDriver => 'Instalar un paquete de controlador local';

  @override
  String get installLocalDriverDescription =>
      'Verifica un INF local, su catálogo firmado y la compatibilidad con el hardware antes de instalar.';

  @override
  String get selectDevice => 'Elige un dispositivo presente';

  @override
  String get localInfPath => 'Ruta absoluta del archivo .inf local';

  @override
  String get verifyDriverPackage => 'Verificar paquete';

  @override
  String verifiedDriverPublisher(Object publisher, Object sha256) {
    return 'Editor verificado: $publisher\nSHA-256 del INF: $sha256';
  }

  @override
  String get confirmLocalDriverInstall =>
      'Confirmar instalación del controlador local';

  @override
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  ) {
    return 'Dispositivo: $device\nEditor firmado: $publisher\nSHA-256 del INF: $sha256\n\nWindows puede cambiar el controlador activo y pedir un reinicio. Deshacer es posible solo en la medida de lo posible.';
  }

  @override
  String get driverTools => 'Flujos asistidos';

  @override
  String get temporaryDriverUpdatesPause =>
      'Excluir temporalmente los controladores de las actualizaciones de calidad de Windows';

  @override
  String get temporaryDriverUpdatesPauseDescription =>
      'Usa la directiva documentada de Windows Update durante 7 o 30 días. ZapTweaks guarda el valor anterior exacto y avisa cuando la pausa vence; restaurarlo requiere tu confirmación.';

  @override
  String get driverUpdatePolicy =>
      'Directiva de controladores de Windows Update';

  @override
  String get driverUpdatePolicyDescription =>
      'Excluye los controladores de dispositivos de las actualizaciones de calidad de Windows durante 7 días, 30 días o hasta que restaures expresamente la directiva anterior exacta.';

  @override
  String get disableUntilRestored => 'Desactivar hasta restaurar';

  @override
  String get driverUpdatePausePermanent =>
      'Las actualizaciones de controladores siguen excluidas hasta que restaures la directiva anterior.';

  @override
  String get driverUpdatePauseActive =>
      'Pausa de actualizaciones de controladores activa';

  @override
  String get driverUpdatePauseExpired =>
      'La pausa de controladores venció: restaura la directiva anterior';

  @override
  String driverUpdatePauseUntil(Object date) {
    return 'Vencimiento previsto: $date';
  }

  @override
  String get pauseSevenDays => 'Pausar 7 días';

  @override
  String get pauseThirtyDays => 'Pausar 30 días';

  @override
  String get restoreDriverUpdates => 'Restaurar directiva anterior';

  @override
  String get assistedDriverFlows =>
      'Flujos de controladores verificados y asistidos';

  @override
  String get assistedDriverFlowsDescription =>
      'ZapTweaks solo abre fuentes de los fabricantes y paneles de Windows. No ejecuta scripts remotos modificables, no actualiza firmware ni quita componentes de controladores sin avisar.';

  @override
  String get amdDriverFlow => 'Controladores y software de AMD';

  @override
  String get amdDriverFlowDescription =>
      'Abre el selector oficial de controladores de AMD. Comprueba el producto detectado antes de descargar.';

  @override
  String get nvidiaDriverFlow => 'Controladores de NVIDIA';

  @override
  String get nvidiaDriverFlowDescription =>
      'Abre la búsqueda manual oficial de controladores de NVIDIA. La instalación limpia sigue siendo una opción explícita del instalador del fabricante.';

  @override
  String get intelDriverFlow => 'Intel Driver & Support Assistant';

  @override
  String get intelDriverFlowDescription =>
      'Abre el flujo oficial de detección y soporte de Intel.';

  @override
  String get windowsOptionalDrivers =>
      'Actualizaciones opcionales de controladores de Windows';

  @override
  String get windowsOptionalDriversDescription =>
      'Revisa las actualizaciones opcionales de controladores en Configuración de Windows; no se elige nada automáticamente.';

  @override
  String get deviceManager => 'Administrador de dispositivos';

  @override
  String get deviceManagerDescription =>
      'Revisa dispositivos, códigos de estado, controladores activos y opciones manuales para revertir.';

  @override
  String get openOfficialSource => 'Abrir fuente oficial';

  @override
  String get openWindowsPanel => 'Abrir panel de Windows';

  @override
  String get searchDrivers => 'Buscar en el almacén de controladores';

  @override
  String get driverStoreSafetyNotice =>
      'Aquí solo se pueden quitar paquetes de terceros firmados y sin asociar. ZapTweaks exporta antes el paquete con hash; restaurarlo es posible solo en la medida de lo posible, porque Windows puede asignar otro nombre publicado.';

  @override
  String get signed => 'Firmado';

  @override
  String get unsigned => 'Sin firmar';

  @override
  String get driverInUse => 'En uso';

  @override
  String get driverUnbound => 'Sin asociar';

  @override
  String get exportAndRemove => 'Exportar y quitar';

  @override
  String get confirmDriverRemoval =>
      'Confirmar eliminación del almacén de controladores';

  @override
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  ) {
    return 'Nombre publicado: $published\nINF original: $inf\nEditor: $publisher\nVersión: $version\n\nZapTweaks exportará el paquete con hash antes de quitarlo. Puede hacer falta reiniciar; restaurarlo es posible solo en la medida de lo posible.';
  }

  @override
  String get searchInstalledApps => 'Buscar apps instaladas';

  @override
  String get scanAllUsers => 'Analizar todos los usuarios (UAC)';

  @override
  String get systemScopesComplete =>
      'Se incluyen los ámbitos AppX de todos los usuarios y aprovisionados.';

  @override
  String get systemScopesIncomplete =>
      'Solo usuario actual e inventario winget. Analiza todos los usuarios para incluir los ámbitos AppX del sistema.';

  @override
  String get currentUser => 'Usuario actual';

  @override
  String get allUsers => 'Todos los usuarios';

  @override
  String get provisioned => 'Aprovisionado';

  @override
  String get confirmAppxRemoval => 'Confirmar eliminación de AppX';

  @override
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  ) {
    return 'App: $name\nIdentidad: $id\nÁmbito: $scope\nRecuperación: $recovery\n\nSolo se quitará el ámbito indicado. Esta operación no se puede deshacer exactamente.';
  }

  @override
  String get reinstallable => 'Fuente de restauración verificada disponible';

  @override
  String get notReinstallable => 'Sin fuente de restauración verificada';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get installedOnly => 'Solo instaladas';

  @override
  String get refreshInventory => 'Actualizar inventario';

  @override
  String get install => 'Instalar';

  @override
  String get uninstall => 'Desinstalar';

  @override
  String get uninstallSelected => 'Desinstalar selección';

  @override
  String get openOfficialPage => 'Abrir página oficial';

  @override
  String get installed => 'Instalada';

  @override
  String get notInstalled => 'No instalada';

  @override
  String get appInventoryUnavailable =>
      'La detección de apps instaladas no está disponible.';

  @override
  String get confirmBulkUninstall => 'Confirmar desinstalación múltiple';

  @override
  String confirmBulkUninstallMessage(Object apps) {
    return 'Se desinstalarán estas apps:\n\n$apps';
  }

  @override
  String get appCatalogSources =>
      'Catálogo combinado de CTT WinUtil fijado, candidatos clean-room de Winhance, TweakHub y fuentes oficiales solicitadas.';

  @override
  String get tcpOptimizer => 'Optimizador TCP';

  @override
  String get tcpOptimizerDescription =>
      'Inspecciona y configura las plantillas TCP de Windows, las descargas globales, la QoS por aplicación y los diagnósticos de red repetibles.';

  @override
  String get tcpNoRecommendation =>
      'No se recomienda ningún valor automáticamente. Una lectura posterior o una sola prueba de red no demuestra una mejora de rendimiento.';

  @override
  String get tcpLiveState => 'Estado TCP actual';

  @override
  String get tcpTemplates => 'Plantillas TCP';

  @override
  String get tcpGlobal => 'Descargas TCP globales';

  @override
  String get tcpAutotuning => 'Ajuste automático de la ventana de recepción';

  @override
  String get tcpHeuristics => 'Heurística de escalado de ventana';

  @override
  String get tcpEcn => 'Compatibilidad con ECN';

  @override
  String get tcpCongestion => 'Control de congestión';

  @override
  String get tcpRsc => 'Coalescencia de segmentos recibidos (RSC)';

  @override
  String get tcpRss => 'Escalado global del lado de recepción (RSS)';

  @override
  String get tcpConfigure => 'Configurar';

  @override
  String get tcpChangePreview => 'Vista previa del cambio TCP';

  @override
  String get tcpCurrentValue => 'Valor actual';

  @override
  String get tcpNewValue => 'Nuevo valor';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks guardará el valor actual exacto, aplicará el cambio con una solicitud de UAC, volverá a leerlo, lo registrará y conservará una restauración exacta.';

  @override
  String get tcpUnsupported => 'No disponible en esta compilación de Windows';

  @override
  String get tcpAdapterRss => 'Abrir controles RSS por adaptador';

  @override
  String get rssAdapterState => 'Estado RSS por adaptador';

  @override
  String get rssEnabled => 'RSS habilitado';

  @override
  String get rssProfile => 'Perfil RSS';

  @override
  String get rssQueuesProcessors => 'Colas/procesadores';

  @override
  String get tcpSettingOperationTitle => 'Configurar ajuste TCP';

  @override
  String get tcpSettingOperationDescription =>
      'Cambia una plantilla TCP de Windows o un valor de descarga global admitido por el sistema, con restauración exacta.';

  @override
  String get qosPolicies => 'Políticas QoS de aplicaciones';

  @override
  String get qosDescription =>
      'Crea políticas QoS persistentes y explícitas para un ejecutable. Las políticas existentes que no sean de ZapTweaks permanecen en modo de solo lectura.';

  @override
  String get qosCreate => 'Crear política';

  @override
  String get qosEdit => 'Editar';

  @override
  String get qosDelete => 'Eliminar';

  @override
  String get qosName => 'Nombre de la política';

  @override
  String get qosAppPath => 'Ruta del ejecutable';

  @override
  String get qosProtocol => 'Protocolo';

  @override
  String get qosSourcePort => 'Puerto de origen (opcional)';

  @override
  String get qosDestinationPort => 'Puerto de destino (opcional)';

  @override
  String get qosDscp => 'DSCP 0–63 (opcional)';

  @override
  String get qosThrottleMbps => 'Límite en Mbit/s (opcional)';

  @override
  String get qosOwnedOnly =>
      'Los nombres deben comenzar por «ZapTweaks - ». Solo se modifica la política seleccionada; las demás políticas QoS nunca se eliminan.';

  @override
  String get qosDeleteConfirm =>
      '¿Eliminar la política QoS seleccionada? Su estado exacto se guarda en el diario de ZapTweaks para poder restaurarlo.';

  @override
  String get qosReadOnly => 'Solo lectura';

  @override
  String get qosPolicyOperationTitle => 'Configurar QoS de aplicación';

  @override
  String get qosPolicyOperationDescription =>
      'Crea, edita o elimina una política QoS persistente y validada por aplicación con restauración exacta.';

  @override
  String get networkDiagnostics => 'Diagnóstico antes/después';

  @override
  String get networkDiagnosticsDescription =>
      'Mide con límites la latencia de conexión TCP, la fluctuación, la pérdida y el rendimiento de descarga HTTPS. Los resultados son datos de diagnóstico, no una recomendación.';

  @override
  String get diagnosticEndpoint => 'URL HTTPS directa del archivo de prueba';

  @override
  String get diagnosticNetworkCost =>
      'La prueba descarga como máximo 10 MiB del extremo introducido. No se incluye ningún extremo de terceros.';

  @override
  String get diagnosticBaseline => 'Ejecutar medición inicial';

  @override
  String get diagnosticComparison => 'Ejecutar comparación';

  @override
  String get diagnosticCancel => 'Cancelar medición';

  @override
  String get diagnosticLatency => 'Latencia';

  @override
  String get diagnosticJitter => 'Fluctuación';

  @override
  String get diagnosticPacketLoss => 'Pérdida de paquetes';

  @override
  String get diagnosticThroughput => 'Rendimiento';

  @override
  String get diagnosticRawSamples => 'Muestras de latencia sin procesar';

  @override
  String get diagnosticDownloadedBytes => 'Bytes descargados';

  @override
  String get diagnosticDifference => 'Diferencia B − A';

  @override
  String get tcpAttribution =>
      'Inspirado en WINSPAR — powplowdevs (revisión fijada)';

  @override
  String get openRecoveryHistory => 'Abrir restauración y diario';

  @override
  String get manualRestoreTitle => 'Restaurar los ajustes manuales originales';

  @override
  String get manualRestoreWarning =>
      'Restaura los originales guardados, no los predeterminados. Los ajustes cambiados después no se sobrescriben. Los ajustes de alto riesgo requieren modo experto y UAC. Revisa el registro tras restaurar; puede seguir haciendo falta reiniciar o cerrar sesión.';

  @override
  String get cleanupUserTemp => 'Limpieza de UserTemp';

  @override
  String get cleanupUserTempDescription =>
      'Revisa y elige archivos concretos de la carpeta Temp del usuario actual. Sin selección automática, sin borrado forzado y sin quitar carpetas.';

  @override
  String get cleanupSelectFiles => 'Ver y elegir archivos';

  @override
  String get cleanupShaderCache =>
      'Limpieza de la caché de sombreadores de GPU';

  @override
  String get cleanupShaderCacheDescription =>
      'Muestra, carpeta por carpeta, las cachés de sombreadores de DirectX, AMD, NVIDIA e Intel del usuario actual y elimina exactamente los archivos encontrados en esa vista previa. El controlador las regenera, así que el primer inicio de cada juego puede ir a tirones. Cierra antes los juegos. No se puede deshacer.';

  @override
  String get cleanupShaderCacheNone =>
      'No se encontraron archivos de caché de sombreadores de GPU.';

  @override
  String get cleanupShaderCacheCompleted =>
      'Los archivos de caché mostrados se eliminaron y se comprobó que ya no existen.';

  @override
  String get cleanupPreview => 'Vista previa';

  @override
  String get cleanupUserTempNone => 'No se encontraron archivos en UserTemp.';

  @override
  String get cleanupPermanentWarning =>
      'Eliminación definitiva. Sin deshacer y sin saltarse permisos ni bloqueos. Cierra antes las aplicaciones. Si la eliminación falla, puede que ya se hayan quitado archivos anteriores.';

  @override
  String get cleanupUserTempSelectionHint =>
      'No hay nada seleccionado. Elige solo archivos que reconozcas; los creados después de esta vista previa quedan fuera.';

  @override
  String cleanupPreviewCount(int count, int bytes) {
    return '$count archivos, $bytes bytes';
  }

  @override
  String get cleanupRecycleUnavailable =>
      'La limpieza de la Papelera no está disponible: no se pueden mostrar y eliminar con seguridad los elementos exactos. No se vacía todo.';

  @override
  String get cleanupCrashReports => 'Volcados de bloqueo e informes de errores';

  @override
  String get cleanupCrashReportsDescription =>
      'Elimina los volcados de bloqueo de tus programas (%LOCALAPPDATA%\\CrashDumps) y el archivo y la cola de Informe de errores de Windows. Útil cuando un juego o una app se ha bloqueado muchas veces. Los minivolcados del sistema (pantallas azules) no se tocan.';

  @override
  String get cleanupCrashReportsNone =>
      'No hay volcados ni informes de errores que eliminar.';

  @override
  String get cleanupCrashReportsCompleted =>
      'Volcados de bloqueo e informes de errores eliminados.';

  @override
  String get cleanupBrowserCache => 'Cachés del navegador';

  @override
  String get cleanupBrowserCacheDescription =>
      'Elimina las cachés en disco de Chrome, Edge, Brave (todos los perfiles) y Firefox. No toca cookies, historial, contraseñas ni extensiones; las páginas cargan algo más despacio la primera vez.';

  @override
  String get cleanupBrowserCacheNone =>
      'No hay archivos de caché del navegador que eliminar.';

  @override
  String get cleanupBrowserCacheCompleted => 'Cachés del navegador eliminadas.';

  @override
  String cleanupBrowserRunning(String browsers) {
    return 'Cierra antes $browsers (también desde la bandeja del sistema: Edge y Chrome pueden seguir en segundo plano).';
  }

  @override
  String thermalZoneLimited(String percent) {
    return 'el firmware limita la CPU al $percent %';
  }

  @override
  String get thermalSourceCounters =>
      'Fuente: contadores de Windows «Thermal Zone Information» (zonas ACPI definidas por el firmware, sin permisos de administrador). Una zona es un sensor elegido por el fabricante; a menudo no es el chip de la CPU.';

  @override
  String get thermalSourceAcpi =>
      'Fuente: MSAcpi_ThermalZoneTemperature (zonas ACPI definidas por el firmware). Una zona es un sensor elegido por el fabricante; a menudo no es el chip de la CPU.';

  @override
  String get thermalSourceNone =>
      'El firmware de este PC no expone ninguna zona térmica ACPI (habitual en placas de sobremesa). No se muestra nada en lugar de un valor no medido.';

  @override
  String get srumTab => 'Historial de apps';

  @override
  String get srumTitle => 'Historial de apps (SRUM)';

  @override
  String get srumDescription =>
      'Uso de red, CPU y disco de cada programa en los últimos 30 días, tal como lo registra Windows (System Resource Usage Monitor). Solo lectura: ZapTweaks lee una instantánea de la base de datos y la elimina después. Requiere permisos de administrador.';

  @override
  String get srumRead => 'Leer historial';

  @override
  String get srumNotCollectingTitle =>
      'Windows no está registrando el historial de apps';

  @override
  String srumNotCollecting(String status, String startType, String date) {
    return 'El Servicio de directivas de diagnóstico, que registra este historial, está $status ($startType). Los datos terminan el $date.';
  }

  @override
  String get srumNoData => 'No hay uso registrado en los últimos 30 días.';

  @override
  String get srumNetwork => 'Red (enviado / recibido)';

  @override
  String get srumCpu =>
      'Tiempo de CPU (parte del total de programas; parte en segundo plano)';

  @override
  String srumCpuShare(String share, String background) {
    return '$share % · $background % en segundo plano';
  }

  @override
  String get srumUnattributed => 'Sin atribuir a un programa';

  @override
  String srumSource(String first, String last) {
    return 'Fuente: C:\\Windows\\System32\\sru\\SRUDB.dat, registros del $first al $last. Windows los escribe aproximadamente una vez por hora.';
  }

  @override
  String get manualControls => 'Controles manuales';

  @override
  String upToDate(String version) {
    return 'Estás usando la versión más reciente ($version).';
  }

  @override
  String get startCapture => 'Iniciar captura';

  @override
  String get batteryHealth => 'Estado de la batería';

  @override
  String get batteryHealthDescription =>
      'Capacidad que la batería aún conserva frente a la de diseño. Solo lectura.';

  @override
  String get batteryGood => 'Buena';

  @override
  String get batteryFair => 'Desgastada';

  @override
  String get batteryPoor => 'Reemplazar pronto';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get batteryDesigned => 'Capacidad de diseño';

  @override
  String get batteryFullCharge => 'Capacidad de carga completa';

  @override
  String get batteryWear => 'Desgaste';

  @override
  String get batteryCycles => 'Ciclos de carga';

  @override
  String get batteryCharge => 'Carga actual';

  @override
  String get batteryOnAc => 'Conectada';

  @override
  String get batteryOnBattery => 'Con batería';

  @override
  String get batterySourceWmi =>
      'Fuente: root\\wmi BatteryStaticData, BatteryFullChargedCapacity, BatteryCycleCount y BatteryStatus, según el firmware de la batería.';

  @override
  String get batterySourceReport =>
      'Fuente: powercfg /batteryreport (XML temporal, eliminado tras leerlo), según el firmware de la batería.';

  @override
  String get appTypeSystem => 'Sistema';

  @override
  String get appTypeUser => 'Usuario';

  @override
  String get appTypeStore => 'Store';

  @override
  String get appSafetyRemovable => 'Se puede quitar';

  @override
  String get appSafetyCheckFirst => 'Revisar antes';

  @override
  String get appSafetyKeep => 'Mantener';

  @override
  String get appReasonSystemComponent =>
      'Componente oculto de Windows o del fabricante.';

  @override
  String get appReasonProtected => 'Su instalador impide quitarla.';

  @override
  String get appReasonUpdate =>
      'Actualización de otro programa: quita ese programa.';

  @override
  String get appReasonWindowsPart =>
      'Parte de Windows o un framework que usan otras apps.';

  @override
  String get appReasonSharedDependency =>
      'La usan otras apps (runtime, driver o panel del fabricante).';

  @override
  String get appReasonOptionalFeature =>
      'Función opcional de Windows: lee qué deja de funcionar.';

  @override
  String get appReasonMissingUninstaller => 'No hay desinstalador registrado.';

  @override
  String get appReasonUserInstalled =>
      'Instalada por ti o el fabricante; nada más depende de ella.';

  @override
  String get appLabelMissingUninstaller => 'Sin desinstalador';

  @override
  String get appLabelProtected => 'Protegida';

  @override
  String get appLabelSystemComponent => 'Componente del sistema';

  @override
  String get appLabelUpdate => 'Actualización';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterSafety => 'Seguridad';

  @override
  String get filterSource => 'Origen';

  @override
  String get sourceWholePc => 'Todo el PC';

  @override
  String get sortBy => 'Ordenar';

  @override
  String get sortSize => 'Tamaño';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortDate => 'Fecha de instalación';

  @override
  String appsShown(int count) {
    return '$count apps';
  }

  @override
  String selectionSummary(int count, String size) {
    return '$count seleccionadas · $size';
  }

  @override
  String selectionUnknownSizes(int count) {
    return '$count con tamaño desconocido';
  }

  @override
  String get appsSource =>
      'Fuente: claves Uninstall del registro (HKLM 64/32 bits, HKCU), Get-AppxPackage, winget export para ids de reinstalación. Tamaño: EstimatedSize o la carpeta de instalación.';

  @override
  String get noAppsMatch => 'Ninguna app coincide con estos filtros.';

  @override
  String reinstallableVia(String id) {
    return 'Reinstalar: winget $id';
  }

  @override
  String get uninstallQueueTitle => 'Cola de desinstalación';

  @override
  String get uninstallModeSilent => 'Silenciosa';

  @override
  String get uninstallModeWindowed => 'Abre su ventana';

  @override
  String get uninstallManualNoUninstaller =>
      'Manual: no hay desinstalador registrado.';

  @override
  String get uninstallManualUnsafe =>
      'Manual: el comando registrado inicia un shell o script, por eso ZapTweaks no lo ejecuta.';

  @override
  String get uninstallManualNotFound =>
      'Manual: falta el archivo del desinstalador.';

  @override
  String uninstallRunningWarning(String processes) {
    return 'Aún en ejecución desde su carpeta: $processes. Ciérralo antes.';
  }

  @override
  String get uninstallSimulate =>
      'Simulación: preparar y mostrar la cola sin desinstalar nada';

  @override
  String get uninstallRestorePointNote =>
      'Primero se crea un punto de restauración. Primero las que abren ventana, una a una; luego las silenciosas.';

  @override
  String get uninstallStart => 'Iniciar desinstalación';

  @override
  String get restorePointCreating => 'Creando punto de restauración…';

  @override
  String get restorePointFailed =>
      'No se creó el punto de restauración. La Protección del sistema puede estar desactivada. No se ha cambiado nada.';

  @override
  String get restorePointEnableAndRetry =>
      'Activar la Protección del sistema y reintentar';

  @override
  String get queueWaiting => 'En espera';

  @override
  String get queueRunning => 'En curso';

  @override
  String get queueDone => 'Hecha';

  @override
  String get queueFailed => 'Fallida';

  @override
  String get queueSkipped => 'Omitida';

  @override
  String get queueSkip => 'Omitir';

  @override
  String get queueStop => 'Detener tras la actual';

  @override
  String get queueSimulated => 'Simulación: no se desinstaló nada.';

  @override
  String get uninstallStoreAppsHint =>
      'Las apps de la Store seleccionadas se quitan con el menú Desinstalar de su fila.';

  @override
  String get leftoverSearch => 'Buscar restos';

  @override
  String get leftoverTitle => 'Restos';

  @override
  String get leftoverGood => 'Seguro';

  @override
  String get leftoverMedium => 'Probable';

  @override
  String get leftoverLow => 'Incierto';

  @override
  String get leftoverKindFolder => 'Carpeta';

  @override
  String get leftoverKindShortcut => 'Acceso directo';

  @override
  String get leftoverKindRegistry => 'Clave del registro';

  @override
  String get leftoverKindRun => 'Entrada de inicio';

  @override
  String get leftoverKindTask => 'Tarea programada';

  @override
  String get leftoverKindFirewall => 'Regla de firewall';

  @override
  String get leftoverNone => 'No se encontraron restos.';

  @override
  String leftoverRemoveSelected(int count) {
    return 'Quitar seleccionados ($count)';
  }

  @override
  String get leftoverBackupNote =>
      'Solo los elementos Seguros empiezan seleccionados. Antes de quitar, las claves se exportan a .reg, las tareas a XML y las reglas de firewall a JSON; archivos y carpetas van a la Papelera.';

  @override
  String leftoverRemoved(String path) {
    return 'Restos quitados. Copias: $path';
  }

  @override
  String get leftoverRefusedInvalid =>
      'No se quita: entrada no válida o insegura.';

  @override
  String get leftoverRefusedOutside =>
      'No se quita: fuera de lo que ZapTweaks puede limpiar aquí.';

  @override
  String get leftoverRefusedShared =>
      'No se quita: compartido con Windows u otros programas.';

  @override
  String get orphanFolders => 'Carpetas huérfanas';

  @override
  String get orphanFoldersNote =>
      'Carpetas de Program Files a las que no apunta ningún programa instalado. Una herramienta portátil o un kit de drivers puede parecer igual, por eso nada está seleccionado: revisa cada una.';

  @override
  String get openLocation => 'Abrir ubicación';

  @override
  String get processesTab => 'Procesos';

  @override
  String get searchProcesses => 'Buscar procesos';

  @override
  String get sortMemory => 'Memoria';

  @override
  String get sortCpu => 'CPU';

  @override
  String get processKindWindows => 'Windows';

  @override
  String get processKindMicrosoft => 'App de Microsoft';

  @override
  String get processKindThirdParty => 'Terceros';

  @override
  String get processCanClose => 'Se puede cerrar';

  @override
  String get processLeaveRunning => 'Déjalo activo';

  @override
  String get processReasonCritical =>
      'Windows lo necesita: cerrarlo puede cerrar tu sesión o bloquear el sistema.';

  @override
  String get processReasonWindowsFolder =>
      'Se ejecuta desde la carpeta de Windows o está protegido.';

  @override
  String get processReasonService =>
      'Ejecuta un servicio: gestiónalo desde la pestaña Servicios.';

  @override
  String get processReasonSelf => 'Es ZapTweaks.';

  @override
  String get processReasonUserApp =>
      'Una app que iniciaste: al cerrarla pierdes lo no guardado.';

  @override
  String get processEnd => 'Finalizar proceso';

  @override
  String processEndConfirm(String name) {
    return '¿Finalizar $name? Lo no guardado se pierde.';
  }

  @override
  String get processEndChanged =>
      'Ya se había cerrado o su ID ahora es de otro proceso: no se finalizó nada.';

  @override
  String get processEndFailed =>
      'Windows se negó a finalizarlo. Puede ejecutarse como administrador.';

  @override
  String get searchOnline => 'Buscar en línea';

  @override
  String get processOnlyClosable => 'Solo los que se pueden cerrar';

  @override
  String get processNote =>
      'Una instantánea: la CPU es una sola muestra, actualiza para volver a leerla. Las firmas se comprueban cuando aparece la lista. Los procesos del sistema nunca se ofrecen para cerrar.';

  @override
  String get noProcessesMatch => 'Ningún proceso coincide con estos filtros.';

  @override
  String signedBy(String signer) {
    return 'Firmado por $signer';
  }

  @override
  String get servicesTab => 'Servicios';

  @override
  String get searchServices => 'Buscar servicios';

  @override
  String get filterOrigin => 'Origen';

  @override
  String get originMicrosoft => 'Microsoft';

  @override
  String get serviceCanDisable => 'Se puede desactivar';

  @override
  String get serviceDependsOnUse => 'Depende del uso';

  @override
  String get serviceKeep => 'Mantenlo';

  @override
  String get serviceStartAutomatic => 'Automático';

  @override
  String get serviceStartDelayed => 'Automático (retrasado)';

  @override
  String get serviceStartManual => 'Manual';

  @override
  String get serviceStartDisabled => 'Desactivado';

  @override
  String get serviceStartBoot => 'Arranque';

  @override
  String get serviceRunning => 'En ejecución';

  @override
  String get serviceStopped => 'Detenido';

  @override
  String get serviceSetDisabled => 'Desactivar';

  @override
  String get serviceSetManual => 'Poner en manual';

  @override
  String get serviceSetAutomatic => 'Poner en automático';

  @override
  String serviceChangeTitle(String service) {
    return 'Cambiar $service';
  }

  @override
  String serviceChangeConfirm(String from, String to, String reason) {
    return 'Tipo de inicio: $from → $to.\n$reason\nSe aplica en el próximo inicio del servicio o de Windows. Puedes deshacerlo justo después.';
  }

  @override
  String serviceChanged(String service, String to) {
    return '$service ahora está en $to.';
  }

  @override
  String get serviceUndo => 'Deshacer';

  @override
  String get serviceNote =>
      'Los cambios piden permisos de administrador y se aplican en el próximo inicio del servicio o de Windows. Nunca se ofrecen los servicios que Windows necesita; desactivar un servicio del que dependen otros se rechaza.';

  @override
  String get noServicesMatch => 'Ningún servicio coincide con estos filtros.';

  @override
  String get svcReasonTelemetry =>
      'Envía datos de uso y diagnóstico a Microsoft. Nada de lo que usas deja de funcionar.';

  @override
  String get svcReasonDeviceManagement =>
      'Telemetría y gestión de dispositivos de trabajo o escuela: solo hace falta si una organización administra este PC.';

  @override
  String get svcReasonCrashReports =>
      'Envía informes de bloqueos a Microsoft. Los bloqueos se siguen registrando en este PC.';

  @override
  String get svcReasonRemoteRegistry =>
      'Permite a otros equipos editar el registro de este PC por la red. Desactivado de serie.';

  @override
  String get svcReasonOfflineMaps =>
      'Actualiza los mapas sin conexión de la app Mapas.';

  @override
  String get svcReasonMediaSharing =>
      'Comparte en red la biblioteca de Windows Media Player.';

  @override
  String get svcReasonRetailDemo =>
      'Modo demo para tiendas. En casa nunca hace falta.';

  @override
  String get svcReasonXbox =>
      'Sin él: la app Xbox, Game Pass, los guardados en la nube y los accesorios Xbox dejan de funcionar.';

  @override
  String get svcReasonPrinting =>
      'Sin él: deja de funcionar la impresión, incluida Imprimir en PDF.';

  @override
  String get svcReasonBluetooth =>
      'Sin él: los dispositivos Bluetooth dejan de conectarse.';

  @override
  String get svcReasonSearch =>
      'Sin él: la búsqueda en Inicio, Configuración y el Explorador se vuelve lenta e incompleta.';

  @override
  String get svcReasonSysMain =>
      'Precarga las apps que usas a menudo. Sin él, los inicios pueden ser más lentos, sobre todo en discos duros.';

  @override
  String get svcReasonTouchKeyboard =>
      'Sin él: el teclado táctil, la escritura a mano, el panel de emojis y algunos métodos de entrada dejan de funcionar.';

  @override
  String get svcReasonLocation =>
      'Sin él: las apps y Buscar mi dispositivo ya no pueden obtener tu ubicación.';

  @override
  String get svcReasonBiometrics =>
      'Sin él: el inicio de sesión con cara y huella de Windows Hello deja de funcionar.';

  @override
  String get svcReasonPhone =>
      'Sin él: las llamadas con Vínculo móvil dejan de funcionar.';

  @override
  String get svcReasonRemoteDesktop =>
      'Sin él: deja de funcionar el Escritorio remoto hacia este PC.';

  @override
  String get svcReasonSmartCard =>
      'Sin él: las tarjetas inteligentes y algunas llaves de seguridad dejan de funcionar.';

  @override
  String get svcReasonParental =>
      'Sin él: los límites de Microsoft Family Safety dejan de aplicarse.';

  @override
  String get svcReasonNfc =>
      'Sin él: NFC y el pago sin contacto dejan de funcionar.';

  @override
  String get svcReasonHotspot =>
      'Sin él: la zona con cobertura inalámbrica móvil deja de funcionar.';

  @override
  String get svcReasonScanner =>
      'Sin él: los escáneres y algunas cámaras dejan de funcionar.';

  @override
  String get svcReasonCompatibility =>
      'Sin él: Windows ya no ofrece arreglos cuando un programa antiguo no arranca.';

  @override
  String get svcReasonFax => 'Sin él: el fax deja de funcionar.';

  @override
  String get svcReasonInsider =>
      'Sin él: dejan de llegar las compilaciones de Windows Insider.';

  @override
  String get svcReasonUpdates =>
      'Windows Update lo necesita: sin él dejan de llegar las correcciones de seguridad.';

  @override
  String get svcReasonSecurity =>
      'Protege este PC (antivirus, firewall, estado de seguridad).';

  @override
  String get svcReasonWindowsCore =>
      'Windows lo necesita para sonido, red, registros o funciones básicas.';

  @override
  String get svcReasonNotReviewed =>
      'Parte de Windows y no revisado: déjalo como está.';

  @override
  String get svcReasonDriverService =>
      'Instalado con un controlador: déjalo, salvo que sepas qué hace.';

  @override
  String get svcReasonMicrosoftApp =>
      'Pertenece a una app de Microsoft: sin él, esa app puede dejar de funcionar o de actualizarse.';

  @override
  String get svcReasonThirdParty =>
      'Instalado con otro programa: sin él, ese programa puede dejar de funcionar o de actualizarse.';

  @override
  String get serviceStartTypeAction => 'Cambiar inicio';

  @override
  String get presetsTab => 'Preajustes';

  @override
  String get presetDebloatName => 'Solo debloat';

  @override
  String get presetDebloatSummary =>
      'Quita apps de Microsoft preinstaladas que poca gente usa. No cambia nada más.';

  @override
  String get presetCleanName => 'Limpio';

  @override
  String get presetCleanSummary =>
      'Debloat, más servicios de telemetría y sin uso apagados y apps que arrancan con Windows sin motivo.';

  @override
  String get presetGamingName => 'Gaming';

  @override
  String get presetGamingSummary =>
      'Limpio, más ajustes para jugar: sin limitación de energía de las apps, Finalizar tarea en la barra. Xbox se queda.';

  @override
  String get presetPrivacyName => 'Privacidad';

  @override
  String get presetPrivacySummary =>
      'Limpio, más los ajustes de privacidad de la guía de Microsoft: ID de publicidad, seguimiento, sugerencias, datos de diagnóstico al mínimo.';

  @override
  String get presetCompetitiveName => 'Competitive';

  @override
  String get presetCompetitiveSummary =>
      'Quita todo lo que quitan los otros y más: apps que mucha gente usa, Xbox, impresión, launchers al inicio, grabación de juegos. Más instalación limpia de drivers y WinSux, a mano.';

  @override
  String get presetAttention => 'Atención';

  @override
  String get presetAttentionNote =>
      'Quita mucho, incluidas cosas que mucha gente usa. No promete FPS, latencia ni otras mejoras: es un conjunto de cambios, no una mejora medida.';

  @override
  String get presetGroupApps => 'Apps que quita (usuario actual)';

  @override
  String get presetGroupServices => 'Servicios que desactiva';

  @override
  String get presetGroupStartup => 'Entradas de inicio que apaga';

  @override
  String get presetGroupTweaks => 'Ajustes';

  @override
  String get presetGroupThirdParty => 'Scripts y herramientas de terceros';

  @override
  String get presetGroupRestart => 'Reinicio';

  @override
  String get presetGroupReversible => 'Qué se puede deshacer';

  @override
  String get presetRestartNeeded =>
      'Reinicia después: los servicios y el inicio cambian en el próximo arranque.';

  @override
  String get presetRestartNone => 'No hace falta reiniciar.';

  @override
  String get presetReversibleApps =>
      'Apps: se reinstalan desde Microsoft Store.';

  @override
  String get presetReversibleSettings =>
      'Servicios, inicio y ajustes: deshazlos justo después con Deshacer preajuste, o más tarde con el punto de restauración creado antes.';

  @override
  String get presetReversibleManual =>
      'ZapTweaks no ejecuta los pasos de terceros: para deshacerlos sigue las instrucciones del autor.';

  @override
  String get presetManualWhy =>
      'A mano: el script descarga y ejecuta otros archivos que no se pueden fijar con un hash, así que ZapTweaks no lo ejecuta.';

  @override
  String get presetManualDriverClean =>
      'Instalación limpia del driver gráfico: DDU en modo seguro y luego el último driver del fabricante.';

  @override
  String get presetManualWinsux =>
      'WinSux: debloat y ajustes de Windows en un solo script.';

  @override
  String get presetPreview => 'Vista previa en este PC';

  @override
  String get presetPreviewLoading =>
      'Leyendo apps, servicios, inicio y ajustes…';

  @override
  String get presetStatusApply => 'Por hacer';

  @override
  String get presetStatusDone => 'Ya hecho';

  @override
  String get presetStatusSkipped => 'Omitido';

  @override
  String get presetStatusManual => 'A mano';

  @override
  String get presetSkipNotInstalled => 'no instalada';

  @override
  String get presetSkipNotFound => 'no está en este PC';

  @override
  String get presetSkipUnsupported => 'no compatible aquí';

  @override
  String get presetSkipDuplicate =>
      'mismo nombre dos veces: solo cambia la primera';

  @override
  String presetCounts(int apply, int done, int skipped) {
    return '$apply por hacer · $done ya hechos · $skipped omitidos';
  }

  @override
  String get presetConsent => 'He leído la lista completa y acepto el riesgo.';

  @override
  String get presetApply => 'Aplicar preajuste';

  @override
  String get presetApplyNote =>
      'Primero se crea un punto de restauración; si falla no cambia nada. Los cambios de administrador piden UAC una vez.';

  @override
  String get presetApplying => 'Aplicando…';

  @override
  String presetReport(int ok, int failed) {
    return 'Hecho: $ok cambiadas, $failed sin cambiar.';
  }

  @override
  String get presetUndo => 'Deshacer preajuste';

  @override
  String get presetUndone =>
      'Preajuste deshecho. Las apps quitadas siguen quitadas: reinstálalas desde la Store.';

  @override
  String get presetNothingToDo => 'Nada que hacer: todo está ya hecho.';

  @override
  String get presetSaveAs => 'Guardar como mi preajuste';

  @override
  String get presetSaveNote =>
      'Guarda los elementos aún marcados. Comparte el archivo para exportarlo; pon uno en la carpeta para importarlo.';

  @override
  String get presetName => 'Nombre';

  @override
  String presetSaved(String path) {
    return 'Guardado: $path';
  }

  @override
  String get presetOpenFolder => 'Abrir carpeta de preajustes';

  @override
  String get presetUserTitle => 'Mis preajustes';

  @override
  String presetInvalidFile(String file, String error) {
    return '$file no cargado: $error';
  }

  @override
  String get presetItemPowerThrottling =>
      'Limitación de energía de las apps desactivada';

  @override
  String get presetItemEndTask =>
      'Finalizar tarea en el menú de la barra de tareas';

  @override
  String get presetItemAdvertisingId => 'ID de publicidad desactivado';

  @override
  String get presetItemLanguageList => 'Los sitios no leen tu lista de idiomas';

  @override
  String get presetItemAppLaunchTracking =>
      'Windows no registra las apps que abres';

  @override
  String get presetItemTailoredExperiences =>
      'Sin experiencias personalizadas con datos de diagnóstico';

  @override
  String get presetItemCloudContent =>
      'Sin contenido optimizado en la nube (sugerencias)';

  @override
  String get presetItemDiagnosticData =>
      'Datos de diagnóstico: solo los obligatorios';

  @override
  String get presetItemLockScreenOverlay =>
      'Sin sugerencias en la pantalla de bloqueo';

  @override
  String get presetItemLockScreenFacts =>
      'Sin curiosidades en la pantalla de bloqueo';

  @override
  String get presetItemGameDvr => 'Grabación de juegos de Game Bar desactivada';

  @override
  String get presetSkipHasDependents =>
      'Otros servicios dependen de él, así que Windows no permite desactivarlo.';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsModes => 'Modos';

  @override
  String get settingsMaintenance => 'Mantenimiento';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get openLogFolderDescription =>
      'Registros de sesión con cada comando que ejecutó ZapTweaks.';

  @override
  String get redetectSystemStateDescription =>
      'Vuelve a leer el hardware y el estado de cada ajuste.';

  @override
  String get profileTitle => 'Perfil de configuración';

  @override
  String get profileDescription =>
      'Guarda las preferencias de ZapTweaks en un archivo o cárgalas desde uno.';

  @override
  String get resetAppSettingsDescription =>
      'Vuelve a las preferencias predeterminadas de ZapTweaks. Windows no cambia.';

  @override
  String get expertModeOn => 'Activado';

  @override
  String get expertModeOff => 'Desactivado';
}
