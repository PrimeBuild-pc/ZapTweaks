// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Langue';

  @override
  String get languageDescription =>
      'Choisissez la langue utilisée par ZapTweaks.';

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
  String get settings => 'Paramètres';

  @override
  String get startWithWindows => 'Démarrer avec Windows';

  @override
  String get startWithWindowsDescription =>
      'Lance ZapTweaks après votre connexion à Windows.';

  @override
  String get openLogFolder => 'Ouvrir le dossier des journaux';

  @override
  String get redetectSystemState => 'Redétecter l’état du système';

  @override
  String get exportProfile => 'Exporter le profil';

  @override
  String get importProfile => 'Importer le profil';

  @override
  String get resetAppSettings =>
      'Réinitialiser les paramètres de l’application';

  @override
  String get updates => 'Mises à jour';

  @override
  String get automaticUpdateNotifications =>
      'Notifications de mise à jour automatiques';

  @override
  String get automaticUpdateDescription =>
      'Vérifie au démarrage et affiche un indicateur. Les mises à jour ne sont jamais installées automatiquement.';

  @override
  String get checking => 'Vérification...';

  @override
  String get checkNow => 'Vérifier maintenant';

  @override
  String get viewRelease => 'Voir la version';

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get applicationVersion => 'Version de l’application';

  @override
  String get dryRunMode => 'Mode simulation';

  @override
  String get dryRunDescription => 'Simule les commandes sans modifier Windows.';

  @override
  String get done => 'Terminé';

  @override
  String get operationFailed => 'Échec de l’opération';

  @override
  String get updateAvailable => 'Une mise à jour est disponible';

  @override
  String get updateAvailableDescription =>
      'Vous pouvez consulter les notes de version ou l’installer directement.';

  @override
  String get updateAvailableShort => 'Mise à jour disponible';

  @override
  String get checkingForUpdates => 'Vérification des mises à jour';

  @override
  String get contactingReleaseServer => 'Contacter le serveur de version...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version est disponible';
  }

  @override
  String installedVersion(Object version) {
    return 'Version installée : $version';
  }

  @override
  String get releaseNotesOnGitHub =>
      'Les notes de version sont disponibles sur GitHub.';

  @override
  String get later => 'Plus tard';

  @override
  String get failed => 'Échec';

  @override
  String get downloadingUpdate => 'Téléchargement de la mise à jour';

  @override
  String get downloadingUpdateDescription =>
      'Téléchargement et préparation du programme d\'installation...';

  @override
  String get adminPrivilegesRequired =>
      'Les privilèges d\'administrateur sont requis';

  @override
  String get adminRequiredBanner =>
      'Fermez l\'application et lancez ZapTweaks avec \"Exécuter en tant qu\'administrateur\". Sans élévation, les modifications du système ne peuvent pas être appliquées en toute sécurité.';

  @override
  String get cancel => 'Annuler';

  @override
  String get createRestorePoint => 'Créer un point de restauration';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks a besoin des autorisations d\'administrateur pour appliquer les paramètres système.\n\nFermez l\'application, cliquez avec le bouton droit sur l\'exécutable et sélectionnez « Exécuter en tant qu\'administrateur ».';

  @override
  String get understood => 'Compris';

  @override
  String aboutVersion(Object version) {
    return 'Version : v$version';
  }

  @override
  String get author => 'Auteur : PrimeBuild';

  @override
  String get aboutDescription =>
      'Compagnon d\'optimisation avancé pour des flux de travail de jeu, de matériel et de diagnostic Windows plus approfondis.';

  @override
  String year(Object year) {
    return 'Année : $year';
  }

  @override
  String get close => 'Fermer';

  @override
  String get github => 'GitHub';

  @override
  String get discord => 'Discorde';

  @override
  String get homeAndStats => 'Accueil et statistiques';

  @override
  String get cpuUsage => 'Utilisation du processeur';

  @override
  String get cpuUsageDescription =>
      'Utilisation en temps réel à partir des compteurs Windows';

  @override
  String get gpuUsage => 'Utilisation du GPU';

  @override
  String get gpuUsageDescription => 'Utilisation du moteur en temps réel';

  @override
  String get vramUsage => 'Utilisation de la VRAM';

  @override
  String get memoryUsage => 'Utilisation de la mémoire';

  @override
  String get unknown => 'Inconnu';

  @override
  String get installedRam => 'RAM installée';

  @override
  String get networkAdapters => 'Adaptateurs réseau';

  @override
  String get noConnectedAdapters => 'Aucun adaptateur connecté détecté';

  @override
  String get audioDevices => 'Appareils audio';

  @override
  String get noAudioDevices => 'Aucun périphérique audio détecté';

  @override
  String get noTweaksAvailable =>
      'Aucun réglage n\'est disponible pour votre configuration matérielle.';

  @override
  String get detectedHardware => 'Matériel détecté';

  @override
  String get gpuUnknown => 'GPU : Inconnu';

  @override
  String cpuValue(Object value) {
    return 'Processeur : $value';
  }

  @override
  String gpuValue(Object value) {
    return 'GPU : $value';
  }

  @override
  String ramValue(Object value) {
    return 'RAM : $value';
  }

  @override
  String get enableAllVisible => 'Activer tout ce qui est visible';

  @override
  String get disableAllVisible => 'Désactiver tout ce qui est visible';

  @override
  String get restartNow => 'Redémarrer maintenant';

  @override
  String get restartRequired => 'Redémarrage requis';

  @override
  String get restartRequiredDescription =>
      'Un redémarrage du système est nécessaire pour appliquer complètement une ou plusieurs modifications.';

  @override
  String get advancedActionsIncluded => 'Actions avancées incluses';

  @override
  String get advancedActionsDescription =>
      'Les outils externes, les actions de lancement et les utilitaires basés sur des scripts sont regroupés ici pour des diagnostics rapides et des flux de travail de maintenance.';

  @override
  String get aggressiveTweakWarning =>
      'Ajustement agressif. Un point de restauration est recommandé.';

  @override
  String get networkReconnectWarning =>
      'Une reconnexion de la carte réseau ou un redémarrage du système peuvent être nécessaires.';

  @override
  String get actionWarning => 'Avertissement d\'action';

  @override
  String get unknownError => 'Erreur inconnue.';

  @override
  String get presets => 'Préréglages';

  @override
  String get presetFailed => 'Échec du préréglage';

  @override
  String get safetyWarning => 'Avertissement de sécurité';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get powerPlans => 'Forfaits d’alimentation groupés';

  @override
  String get powerPlansDescription =>
      'Importez et activez un forfait groupé. ZapTweaks se souvient du plan actif précédent pour la restauration.';

  @override
  String get noPowerPlans =>
      'Aucun plan d\'alimentation groupé n\'a été trouvé.';

  @override
  String get working => 'Travailler...';

  @override
  String get importAndActivate => 'Importer et activer';

  @override
  String get restorePreviousPlan => 'Restaurer le plan précédent';

  @override
  String get ran => 'Couru';

  @override
  String get gpuDrivers => 'Pilotes GPU';

  @override
  String get noGpuDrivers => 'Aucun pilote GPU détecté';

  @override
  String get chipsetDrivers => 'Pilotes de chipset';

  @override
  String get noChipsetDrivers => 'Aucun pilote de chipset détecté';

  @override
  String get monitors => 'Moniteurs';

  @override
  String get noMonitors => 'Aucun moniteur détecté';

  @override
  String get mice => 'Souris';

  @override
  String get noMice => 'Aucune souris détectée';

  @override
  String get keyboards => 'Claviers';

  @override
  String get noKeyboards => 'Aucun clavier détecté';

  @override
  String get restorePointPromptTitle => 'Créer un point de restauration ?';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks peut créer un point de restauration Windows avant de modifier les paramètres système. C\'est facultatif : si vous passez, la modification est appliquée quand même. La question n\'est posée qu\'une fois par session.';

  @override
  String get skip => 'Passer';

  @override
  String get continueAction => 'Continuer';

  @override
  String get tweaksSectionHeader => 'RÉGLAGES';

  @override
  String get startingUp => 'Démarrage de ZapTweaks';

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
  String get searchSections => 'Sections and integrated tools';

  @override
  String get searchApps => 'Search apps';

  @override
  String get searchCatalog => 'Operations and external tools';

  @override
  String get searchOpenResult => 'Open';

  @override
  String get searchExpertRequired => 'Enable Expert mode to open';

  @override
  String get noSearchResults =>
      'No matching sections, apps, operations, or tools.';

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
      'Records a bounded Windows Performance Recorder trace and produces a DPC/ISR diagnostic report on demand. No monitor remains active.';

  @override
  String get dpcLatencyAnalyzer => 'DPC / ISR latency analyzer';

  @override
  String get dpcLatencyAnalyzerDescription =>
      'Captures ETW on demand and reports DPC, ISR, hard-fault and context-switch activity, per-processor distribution, observed kernel-module names and ETW providers.';

  @override
  String get diagnosticNotCausality =>
      'Diagnostic signal, not a latency verdict';

  @override
  String get diagnosticNotCausalityDescription =>
      'Counts and observed module names help narrow an investigation but do not prove that a driver caused latency. Confirm with repeatable A/B/A traces and WPA or vendor tooling.';

  @override
  String get startDpcCapture => 'Start capture';

  @override
  String get openTraceFolder => 'Open trace folder';

  @override
  String captureInProgress(int seconds) {
    return 'Capturing for $seconds seconds… keep the workload running.';
  }

  @override
  String get traceDuration => 'Observed duration';

  @override
  String get hardFaults => 'Hard faults';

  @override
  String get contextSwitches => 'Context switches';

  @override
  String get totalEvents => 'Total ETW events';

  @override
  String get kernelModulesObserved =>
      'Kernel modules observed in DPC/ISR events';

  @override
  String get noKernelModulesObserved =>
      'The exported events did not expose kernel module names. Open the ETL in WPA for symbol-aware analysis.';

  @override
  String get dpcIsrByProcessor => 'DPC/ISR events by logical processor';

  @override
  String get noProcessorDistribution =>
      'Processor IDs were not present in the exported events.';

  @override
  String get topEtwProviders => 'Top ETW providers';

  @override
  String get noProviderData => 'No provider data was available.';

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
  String get interruptConfiguration => 'MSI Utility v3 & Interrupt Affinity';

  @override
  String get interruptConfigurationDescription =>
      'Advanced, capability-gated MSI and group-0 interrupt-affinity controls for present display, network, media, USB host, and HD audio devices. No value is recommended automatically.';

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
      'No present display, network, media, USB host, or HD audio PCI device exposes compatible interrupt capabilities.';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return 'Hardware: Line $line · MSI $msi · MSI-X $msix · maximum messages $maximum';
  }

  @override
  String get messageNumberLimit => 'Message number limit';

  @override
  String get interruptPriority => 'Interrupt priority policy';

  @override
  String get interruptPriorityDefault => 'Undefined / driver default';

  @override
  String get interruptPriorityLow => 'Low';

  @override
  String get interruptPriorityNormal => 'Normal';

  @override
  String get interruptPriorityHigh => 'High';

  @override
  String get interruptPolicy => 'Processor affinity policy';

  @override
  String get interruptPolicyDefault => 'Machine default';

  @override
  String get interruptPolicyAllClose => 'All close processors';

  @override
  String get interruptPolicyOneClose => 'One close processor';

  @override
  String get interruptPolicyAllProcessors => 'All processors';

  @override
  String get interruptPolicySpecified => 'Specified processors (group 0)';

  @override
  String get interruptPolicySpread => 'Spread messages across processors';

  @override
  String get selectLogicalProcessors =>
      'Select logical processors in processor group 0';

  @override
  String get affinitySelectAll => 'All logical processors';

  @override
  String get affinityClear => 'Clear';

  @override
  String get affinityPhysicalCores => 'One thread per physical core';

  @override
  String get affinityPerformanceCores => 'Performance cores';

  @override
  String get affinityEfficiencyCores => 'Efficiency cores';

  @override
  String get affinityParked => 'parked';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'NUMA node $index';
  }

  @override
  String get compatibleDevices => 'Compatible devices';

  @override
  String get msiEnabledDevices => 'MSI currently enabled';

  @override
  String get logicalProcessors => 'Logical processors';

  @override
  String get searchDevices => 'Search devices, instance IDs, or driver INF';

  @override
  String get driverUnknown => 'Driver INF unavailable';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return 'Current: $mode · messages $messages · priority $priority · policy $policy · mask $mask';
  }

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
  String get powerSettingConfigure => 'Configure any bounded power setting';

  @override
  String get powerSettingConfigureDescription =>
      'Edits a setting exposed by PowrProf only when Windows provides live minimum, maximum, and increment metadata.';

  @override
  String get searchPowerSettings =>
      'Search settings, descriptions, subgroups, or GUIDs';

  @override
  String get allPowerSubgroups => 'All power-setting groups';

  @override
  String powerSettingCount(int count) {
    return '$count settings';
  }

  @override
  String powerSettingOptions(int count) {
    return '$count Windows-defined options';
  }

  @override
  String get backToPowerPlans => 'Back to power plans';

  @override
  String get powerPlanEditorHint =>
      'Duplicate a plan to create your custom profile, then open Details and edit its hidden AC/DC settings one by one.';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Range $minimum–$maximum, step $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows did not expose safe values or bounds for this setting.';

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
  String get driverUpdatePolicy => 'Windows Update driver policy';

  @override
  String get driverUpdatePolicyDescription =>
      'Exclude device drivers from Windows quality updates for 7 days, 30 days, or until you explicitly restore the exact previous policy.';

  @override
  String get disableUntilRestored => 'Disable until restored';

  @override
  String get driverUpdatePausePermanent =>
      'Driver updates remain excluded until you restore the previous policy.';

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
  String get openWindowsPanel => 'Open Windows panel';

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

  @override
  String get tcpOptimizer => 'Optimiseur TCP';

  @override
  String get tcpOptimizerDescription =>
      'Inspectez et configurez les modèles TCP de Windows, les déchargements globaux, la QoS par application et des diagnostics réseau reproductibles.';

  @override
  String get tcpNoRecommendation =>
      'Aucune valeur n’est recommandée automatiquement. Une relecture ou un seul test réseau ne prouve pas un gain de performances.';

  @override
  String get tcpLiveState => 'État TCP actuel';

  @override
  String get tcpTemplates => 'Modèles TCP';

  @override
  String get tcpGlobal => 'Déchargements TCP globaux';

  @override
  String get tcpAutotuning => 'Réglage automatique de la fenêtre de réception';

  @override
  String get tcpHeuristics => 'Heuristique de mise à l’échelle de la fenêtre';

  @override
  String get tcpEcn => 'Prise en charge d’ECN';

  @override
  String get tcpCongestion => 'Contrôle de congestion';

  @override
  String get tcpRsc => 'Coalescence des segments reçus (RSC)';

  @override
  String get tcpRss => 'Mise à l’échelle globale côté réception (RSS)';

  @override
  String get tcpConfigure => 'Configurer';

  @override
  String get tcpChangePreview => 'Aperçu de la modification TCP';

  @override
  String get tcpCurrentValue => 'Valeur actuelle';

  @override
  String get tcpNewValue => 'Nouvelle valeur';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks enregistre la valeur actuelle exacte, applique la modification avec une demande UAC, la relit, la consigne et conserve une restauration exacte.';

  @override
  String get tcpUnsupported => 'Non exposé par cette version de Windows';

  @override
  String get tcpAdapterRss => 'Ouvrir les contrôles RSS par carte';

  @override
  String get rssAdapterState => 'État RSS par carte';

  @override
  String get rssEnabled => 'RSS activé';

  @override
  String get rssProfile => 'Profil RSS';

  @override
  String get rssQueuesProcessors => 'Files/processeurs';

  @override
  String get tcpSettingOperationTitle => 'Configurer le paramètre TCP';

  @override
  String get tcpSettingOperationDescription =>
      'Modifie un modèle TCP Windows ou une valeur de déchargement global pris en charge par le système, avec restauration exacte.';

  @override
  String get qosPolicies => 'Stratégies QoS des applications';

  @override
  String get qosDescription =>
      'Créez des stratégies QoS explicites et persistantes pour un exécutable. Les stratégies existantes qui ne proviennent pas de ZapTweaks restent en lecture seule.';

  @override
  String get qosCreate => 'Créer une stratégie';

  @override
  String get qosEdit => 'Modifier';

  @override
  String get qosDelete => 'Supprimer';

  @override
  String get qosName => 'Nom de la stratégie';

  @override
  String get qosAppPath => 'Chemin de l’exécutable';

  @override
  String get qosProtocol => 'Protocole';

  @override
  String get qosSourcePort => 'Port source (facultatif)';

  @override
  String get qosDestinationPort => 'Port de destination (facultatif)';

  @override
  String get qosDscp => 'DSCP 0–63 (facultatif)';

  @override
  String get qosThrottleMbps => 'Limite en Mbit/s (facultatif)';

  @override
  String get qosOwnedOnly =>
      'Les noms doivent commencer par « ZapTweaks - ». Seule la stratégie sélectionnée est modifiée ; les autres stratégies QoS ne sont jamais supprimées.';

  @override
  String get qosDeleteConfirm =>
      'Supprimer la stratégie QoS sélectionnée ? Son état exact est conservé dans le journal ZapTweaks pour permettre sa restauration.';

  @override
  String get qosReadOnly => 'Lecture seule';

  @override
  String get qosPolicyOperationTitle => 'Configurer la QoS d’application';

  @override
  String get qosPolicyOperationDescription =>
      'Crée, modifie ou supprime une stratégie QoS persistante et validée par application, avec restauration exacte.';

  @override
  String get networkDiagnostics => 'Diagnostic avant/après';

  @override
  String get networkDiagnosticsDescription =>
      'Mesurez de façon limitée la latence de connexion TCP, la gigue, la perte et le débit de téléchargement HTTPS. Les résultats sont des données de diagnostic, pas une recommandation.';

  @override
  String get diagnosticEndpoint => 'URL HTTPS directe du fichier de test';

  @override
  String get diagnosticNetworkCost =>
      'Le test télécharge au maximum 10 Mio depuis le point de terminaison saisi. Aucun point de terminaison tiers n’est intégré.';

  @override
  String get diagnosticBaseline => 'Lancer la mesure initiale';

  @override
  String get diagnosticComparison => 'Lancer la comparaison';

  @override
  String get diagnosticCancel => 'Annuler la mesure';

  @override
  String get diagnosticLatency => 'Latence';

  @override
  String get diagnosticJitter => 'Gigue';

  @override
  String get diagnosticPacketLoss => 'Perte de paquets';

  @override
  String get diagnosticThroughput => 'Débit';

  @override
  String get diagnosticRawSamples => 'Échantillons de latence bruts';

  @override
  String get diagnosticDownloadedBytes => 'Octets téléchargés';

  @override
  String get diagnosticDifference => 'Différence B − A';

  @override
  String get tcpAttribution =>
      'Inspiré de WINSPAR — powplowdevs (révision figée)';

  @override
  String get openRecoveryHistory => 'Ouvrir la restauration et le journal';
}
