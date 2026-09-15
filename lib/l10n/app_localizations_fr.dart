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
  String get renamePowerPlan => 'Rename power plan';

  @override
  String get renamePowerPlanDescription =>
      'Changes only the selected plan\'s display name and preserves the original name for rollback.';

  @override
  String get rename => 'Rename';

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
