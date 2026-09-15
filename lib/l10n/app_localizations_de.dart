// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Sprache';

  @override
  String get languageDescription => 'Wähle die Sprache für ZapTweaks.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get startWithWindows => 'Mit Windows starten';

  @override
  String get startWithWindowsDescription =>
      'ZapTweaks nach der Windows-Anmeldung starten.';

  @override
  String get openLogFolder => 'Protokollordner öffnen';

  @override
  String get redetectSystemState => 'Systemstatus erneut erkennen';

  @override
  String get exportProfile => 'Profil exportieren';

  @override
  String get importProfile => 'Profil importieren';

  @override
  String get resetAppSettings => 'App-Einstellungen zurücksetzen';

  @override
  String get updates => 'Updates';

  @override
  String get automaticUpdateNotifications =>
      'Automatische Update-Benachrichtigungen';

  @override
  String get automaticUpdateDescription =>
      'Beim Start prüfen und einen Hinweis anzeigen. Updates werden nie automatisch installiert.';

  @override
  String get checking => 'Wird geprüft...';

  @override
  String get checkNow => 'Jetzt prüfen';

  @override
  String get viewRelease => 'Release anzeigen';

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get applicationVersion => 'App-Version';

  @override
  String get dryRunMode => 'Testmodus';

  @override
  String get dryRunDescription => 'Befehle simulieren, ohne Windows zu ändern.';

  @override
  String get done => 'Fertig';

  @override
  String get operationFailed => 'Vorgang fehlgeschlagen';

  @override
  String get updateAvailable => 'Ein Update ist verfügbar';

  @override
  String get updateAvailableDescription =>
      'Sie können die Versionshinweise ansehen oder es direkt installieren.';

  @override
  String get updateAvailableShort => 'Update verfügbar';

  @override
  String get checkingForUpdates => 'Suche nach Updates';

  @override
  String get contactingReleaseServer =>
      'Kontakt zum Release-Server wird aufgenommen...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version ist verfügbar';
  }

  @override
  String installedVersion(Object version) {
    return 'Installierte Version: $version';
  }

  @override
  String get releaseNotesOnGitHub =>
      'Versionshinweise sind auf GitHub verfügbar.';

  @override
  String get later => 'Später';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get downloadingUpdate => 'Update wird heruntergeladen';

  @override
  String get downloadingUpdateDescription =>
      'Herunterladen und Vorbereiten des Installationsprogramms...';

  @override
  String get adminPrivilegesRequired =>
      'Es sind Administratorrechte erforderlich';

  @override
  String get adminRequiredBanner =>
      'Schließen Sie die App und starten Sie ZapTweaks mit „Als Administrator ausführen“. Ohne Erhöhung können Systemanpassungen nicht sicher angewendet werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get createRestorePoint => 'Wiederherstellungspunkt erstellen';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks benötigt Administratorrechte, um Systemeinstellungen anzuwenden.\n\nSchließen Sie die App, klicken Sie mit der rechten Maustaste auf die ausführbare Datei und wählen Sie „Als Administrator ausführen“.';

  @override
  String get understood => 'Verstanden';

  @override
  String aboutVersion(Object version) {
    return 'Version: v$version';
  }

  @override
  String get author => 'Autor: PrimeBuild';

  @override
  String get aboutDescription =>
      'Erweiterter Optimierungsbegleiter für tiefergehende Windows-Gaming-, Hardware- und Diagnose-Workflows.';

  @override
  String year(Object year) {
    return 'Jahr: $year';
  }

  @override
  String get close => 'Schließen';

  @override
  String get github => 'GitHub';

  @override
  String get discord => 'Zwietracht';

  @override
  String get homeAndStats => 'Startseite & Statistiken';

  @override
  String get cpuUsage => 'CPU-Auslastung';

  @override
  String get cpuUsageDescription => 'Echtzeitnutzung von Windows-Zählern';

  @override
  String get gpuUsage => 'GPU-Nutzung';

  @override
  String get gpuUsageDescription => 'Echtzeit-Engine-Auslastung';

  @override
  String get vramUsage => 'VRAM-Nutzung';

  @override
  String get memoryUsage => 'Speichernutzung';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get installedRam => 'Installierter RAM';

  @override
  String get networkAdapters => 'Netzwerkadapter';

  @override
  String get noConnectedAdapters => 'Keine angeschlossenen Adapter erkannt';

  @override
  String get audioDevices => 'Audiogeräte';

  @override
  String get noAudioDevices => 'Keine Audiogeräte erkannt';

  @override
  String get noTweaksAvailable =>
      'Für Ihre Hardwarekonfiguration sind keine Optimierungen möglich.';

  @override
  String get detectedHardware => 'Erkannte Hardware';

  @override
  String get gpuUnknown => 'GPU: Unbekannt';

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
  String get enableAllVisible => 'Alles sichtbar aktivieren';

  @override
  String get disableAllVisible => 'Alle sichtbaren deaktivieren';

  @override
  String get restartNow => 'Starten Sie jetzt neu';

  @override
  String get restartRequired => 'Neustart erforderlich';

  @override
  String get restartRequiredDescription =>
      'Um eine oder mehrere Änderungen vollständig zu übernehmen, ist ein Systemneustart erforderlich.';

  @override
  String get advancedActionsIncluded => 'Erweiterte Aktionen enthalten';

  @override
  String get advancedActionsDescription =>
      'Externe Tools, Startaktionen und skriptgesteuerte Dienstprogramme sind hier für schnelle Diagnose- und Wartungsworkflows gruppiert.';

  @override
  String get aggressiveTweakWarning =>
      'Aggressiver Tweak. Ein Wiederherstellungspunkt wird empfohlen.';

  @override
  String get networkReconnectWarning =>
      'Möglicherweise ist eine erneute Verbindung des Netzwerkadapters oder ein Neustart des Systems erforderlich.';

  @override
  String get actionWarning => 'Aktionswarnung';

  @override
  String get unknownError => 'Unbekannter Fehler.';

  @override
  String get presets => 'Voreinstellungen';

  @override
  String get presetFailed => 'Voreinstellung fehlgeschlagen';

  @override
  String get safetyWarning => 'Sicherheitswarnung';

  @override
  String get unavailable => 'Nicht verfügbar';

  @override
  String get powerPlans => 'Gebündelte Energiepläne';

  @override
  String get powerPlansDescription =>
      'Importieren und aktivieren Sie einen gebündelten Plan. ZapTweaks merkt sich den vorherigen aktiven Plan zur Wiederherstellung.';

  @override
  String get noPowerPlans =>
      'Es wurden keine gebündelten Energiepläne gefunden.';

  @override
  String get working => 'Arbeiten...';

  @override
  String get importAndActivate => 'Importieren und aktivieren';

  @override
  String get restorePreviousPlan => 'Vorherigen Plan wiederherstellen';

  @override
  String get ran => 'Ran';

  @override
  String get gpuDrivers => 'GPU-Treiber';

  @override
  String get noGpuDrivers => 'Keine GPU-Treiber erkannt';

  @override
  String get chipsetDrivers => 'Chipsatztreiber';

  @override
  String get noChipsetDrivers => 'Keine Chipsatztreiber erkannt';

  @override
  String get monitors => 'Monitore';

  @override
  String get noMonitors => 'Keine Monitore erkannt';

  @override
  String get mice => 'Mäuse';

  @override
  String get noMice => 'Keine Mäuse entdeckt';

  @override
  String get keyboards => 'Tastaturen';

  @override
  String get noKeyboards => 'Keine Tastaturen erkannt';

  @override
  String get restorePointPromptTitle => 'Wiederherstellungspunkt erstellen?';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks kann vor Systemänderungen einen Windows-Wiederherstellungspunkt erstellen. Das ist optional: Beim Überspringen wird die Änderung trotzdem angewendet. Die Frage erscheint nur einmal pro Sitzung.';

  @override
  String get skip => 'Überspringen';

  @override
  String get continueAction => 'Fortfahren';

  @override
  String get tweaksSectionHeader => 'TWEAKS';

  @override
  String get startingUp => 'ZapTweaks wird gestartet';

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
