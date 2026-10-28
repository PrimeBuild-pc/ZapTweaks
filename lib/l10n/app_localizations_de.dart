// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get externalDownload => 'Externer Download';

  @override
  String get appRequirements => 'Voraussetzungen';

  @override
  String get appWarnings => 'Warnungen';

  @override
  String get metricUnavailable => 'k. A.';

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Sprache';

  @override
  String get languageDescription => 'Wähle die Sprache für ZapTweaks.';

  @override
  String get appearance => 'Darstellung';

  @override
  String get appearanceDescription =>
      'Windows folgen oder ein festes helles oder dunkles App-Design verwenden.';

  @override
  String get themeSystem => 'Windows-Standard';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

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
  String get expertMode => 'Expertenmodus';

  @override
  String get expertModeDescription =>
      'Erweiterte Vorgänge und externe Tools erst nach ausdrücklicher manueller Zustimmung anzeigen. Standardmäßig aus; Sicherheitsbeschränkungen gelten weiterhin.';

  @override
  String get searchOperations => 'Vorgänge suchen';

  @override
  String get searchResults => 'Suchergebnisse';

  @override
  String get searchSections => 'Bereiche und integrierte Tools';

  @override
  String get searchApps => 'Apps suchen';

  @override
  String get searchCatalog => 'Vorgänge und externe Tools';

  @override
  String get searchOpenResult => 'Öffnen';

  @override
  String get searchExpertRequired => 'Zum Öffnen Expertenmodus aktivieren';

  @override
  String get noSearchResults =>
      'Keine passenden Bereiche, Apps, Vorgänge oder Tools.';

  @override
  String get operationTaskbarEndTaskTitle => 'Task beenden in der Taskleiste';

  @override
  String get operationTaskbarEndTaskDescription =>
      '„Task beenden“ im Kontextmenü der Taskleisten-Apps anzeigen.';

  @override
  String get appStore => 'App-Store';

  @override
  String get appManagement => 'Installierte Apps';

  @override
  String get windowsAppTools => 'Windows-App-Tools';

  @override
  String get optionalFeatures => 'Optionale Features';

  @override
  String get searchOptionalFeatures => 'Optionale Features suchen';

  @override
  String get scanOptionalFeatures => 'Features scannen (UAC)';

  @override
  String get optionalFeaturesUacNotice =>
      'Die Feature-Inventur und jede Änderung laufen über den zugelassenen Helfer. Beim Scannen wird nichts geändert.';

  @override
  String get confirmOptionalFeatureChange =>
      'Änderung des optionalen Features bestätigen';

  @override
  String confirmOptionalFeatureChangeMessage(Object name, Object action) {
    return 'Feature: $name\nAktion: $action\n\nWindows erfordert eventuell einen Neustart. Der vorherige Zustand wird vor der Änderung gespeichert.';
  }

  @override
  String get enable => 'Aktivieren';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get enablePending => 'Aktivierung nach Neustart';

  @override
  String get disablePending => 'Deaktivierung nach Neustart';

  @override
  String get startupApps => 'Autostart-Apps';

  @override
  String get searchStartupApps => 'Autostart-Apps suchen';

  @override
  String get openStartupSettings => 'Autostart-Einstellungen öffnen';

  @override
  String get openTaskManagerStartup => 'Autostart im Task-Manager öffnen';

  @override
  String get startupInventoryNotice =>
      'Autostart-Inventur nur zum Lesen. Einträge in den Windows-Einstellungen oder im Task-Manager ändern.';

  @override
  String get guidedSetup => 'Geführte Einrichtung';

  @override
  String get wizardInventory => 'Inventur';

  @override
  String get wizardBaseline => 'Ausgangslage';

  @override
  String get wizardWindowsUpdate => 'Windows Update';

  @override
  String get wizardDrivers => 'Treiberprüfung';

  @override
  String get wizardApplications => 'Anwendungen';

  @override
  String get wizardDebloat => 'Gezieltes Entschlacken';

  @override
  String get wizardPrivacyInterface => 'Datenschutz und Oberfläche';

  @override
  String get wizardPreview => 'Planvorschau';

  @override
  String get wizardApply => 'Anwenden';

  @override
  String get wizardReport => 'Abschlussbericht';

  @override
  String get wizardInventoryDescription =>
      'Hardware, installierte winget-Pakete und vorhandene Geräte lesen, bevor Entscheidungen fallen.';

  @override
  String get runInventory => 'Inventur starten';

  @override
  String inventorySummary(Object apps, Object devices) {
    return '$apps winget-Pakete und $devices vorhandene Geräte erkannt.';
  }

  @override
  String get wizardUpdateNotice =>
      'Windows Update vor Treiber- und App-Änderungen prüfen. ZapTweaks installiert keine Updates automatisch.';

  @override
  String get openWindowsUpdate => 'Windows Update öffnen';

  @override
  String get updatesReviewed => 'Ich habe Windows Update geprüft';

  @override
  String driverInventorySummary(Object devices, Object missing) {
    return 'Vorhandene Geräte: $devices\nGeräte ohne zugeordnete INF: $missing';
  }

  @override
  String get wizardDebloatNotice =>
      'Keine Entschlackung erfolgt stillschweigend. Hier sind nur AppX-Pakete des aktuellen Benutzers mit geprüfter Wiederherstellungsquelle wählbar; andere Entfernungen bleiben unter App → Installierte Apps mit eigener Vorschau verfügbar.';

  @override
  String get wizardPrivacyNotice =>
      'Datenschutz- und Oberflächeneinstellungen bleiben unverändert, sofern sie unten nicht ausdrücklich gewählt werden.';

  @override
  String get noAppsSelected =>
      'Keine Vorgänge ausgewählt. Der Assistent ändert nichts.';

  @override
  String planContains(Object count) {
    return 'Der Plan enthält $count ausdrückliche Vorgänge:';
  }

  @override
  String readyToApply(Object count) {
    return 'Bereit, $count App-Vorgänge anzuwenden. Jedes Paket wird nach Abschluss von winget geprüft.';
  }

  @override
  String get noPlanReport => 'Beendet, ohne einen Plan anzuwenden.';

  @override
  String get planStatus => 'Planstatus';

  @override
  String get applyPlan => 'Plan anwenden';

  @override
  String get back => 'Zurück';

  @override
  String get finish => 'Fertig';

  @override
  String get recovery => 'Wiederherstellung';

  @override
  String get diagnosticTools => 'Diagnosetools';

  @override
  String get repairComponentStore => 'Windows-Komponentenspeicher reparieren';

  @override
  String get repairComponentStoreDescription =>
      'Führt DISM RestoreHealth und danach eine eigene ScanHealth-Prüfung aus. Das kann lange dauern.';

  @override
  String get repairSystemFiles => 'Geschützte Systemdateien reparieren';

  @override
  String get repairSystemFilesDescription =>
      'Führt eine SFC-Prüfung mit Reparatur und danach einen eigenen Prüfdurchlauf aus.';

  @override
  String get confirmSystemRepair => 'Windows-Reparatur bestätigen';

  @override
  String get systemRepairWarning =>
      'Die Reparatur kann beschädigte Windows-Komponenten ersetzen und lässt sich von ZapTweaks nicht rückgängig machen. Den PC währenddessen nicht ausschalten.';

  @override
  String get systemRepairVerified =>
      'Reparatur abgeschlossen, Prüfdurchlauf erfolgreich.';

  @override
  String get runRepair => 'Reparatur starten';

  @override
  String get operationCompleted => 'Vorgang abgeschlossen';

  @override
  String get captureEtwTrace => 'Leistungsablaufverfolgung aufzeichnen';

  @override
  String get captureEtwTraceDescription =>
      'Zeichnet eine begrenzte Windows Performance Recorder-Ablaufverfolgung auf und erstellt bei Bedarf einen DPC/ISR-Diagnosebericht. Danach bleibt keine Überwachung aktiv.';

  @override
  String get dpcLatencyAnalyzer => 'DPC/ISR-Latenzanalyse';

  @override
  String get dpcLatencyAnalyzerDescription =>
      'Zeichnet ETW bei Bedarf auf und meldet DPC-, ISR-, Hard-Fault- und Kontextwechsel-Aktivität, die Verteilung pro Prozessor, beobachtete Kernelmodule und ETW-Anbieter.';

  @override
  String get diagnosticNotCausality => 'Diagnosesignal, kein Latenzurteil';

  @override
  String get diagnosticNotCausalityDescription =>
      'Zählwerte und beobachtete Modulnamen grenzen eine Untersuchung ein, beweisen aber nicht, dass ein Treiber die Latenz verursacht. Mit wiederholbaren A/B/A-Aufzeichnungen und WPA oder Herstellertools bestätigen.';

  @override
  String get startDpcCapture => 'Aufzeichnung starten';

  @override
  String get openTraceFolder => 'Ablaufverfolgungsordner öffnen';

  @override
  String captureInProgress(int seconds) {
    return 'Aufzeichnung läuft $seconds Sekunden… die Last weiterlaufen lassen.';
  }

  @override
  String get traceDuration => 'Beobachtete Dauer';

  @override
  String get hardFaults => 'Hard Faults';

  @override
  String get contextSwitches => 'Kontextwechsel';

  @override
  String get totalEvents => 'ETW-Ereignisse gesamt';

  @override
  String get kernelModulesObserved =>
      'In DPC/ISR-Ereignissen beobachtete Kernelmodule';

  @override
  String get noKernelModulesObserved =>
      'Die exportierten Ereignisse enthielten keine Kernelmodulnamen. Die ETL in WPA für eine Analyse mit Symbolen öffnen.';

  @override
  String get dpcIsrByProcessor => 'DPC/ISR-Ereignisse pro logischem Prozessor';

  @override
  String get noProcessorDistribution =>
      'Die exportierten Ereignisse enthielten keine Prozessor-IDs.';

  @override
  String get topEtwProviders => 'Häufigste ETW-Anbieter';

  @override
  String get noProviderData => 'Keine Anbieterdaten verfügbar.';

  @override
  String etwTraceSaved(Object path) {
    return 'Ablaufverfolgung gespeichert unter $path';
  }

  @override
  String get cleanupDiagnosticTraces => 'Diagnose-Ablaufverfolgungen löschen';

  @override
  String get cleanupDiagnosticTracesDescription =>
      'Sucht nur ZapTweaks-Ablaufverfolgungen, zeigt genaue Dateianzahl und Größe und löscht sie nach Bestätigung.';

  @override
  String cleanupTracePreview(int count, int bytes) {
    return '$count ZapTweaks-Ablaufverfolgungen ($bytes Bytes) löschen? Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get cleanupTracesCompleted =>
      'Die angezeigten Diagnose-Ablaufverfolgungen wurden gelöscht und ihr Fehlen geprüft.';

  @override
  String get noDiagnosticTraces =>
      'Keine ZapTweaks-Diagnose-Ablaufverfolgungen gefunden.';

  @override
  String get hardwareMonitor => 'Hardwaremonitor';

  @override
  String get dedicatedVramUsage => 'Belegter dedizierter GPU-Speicher';

  @override
  String get dedicatedVramUsageDescription =>
      'Liest einmal die GPU-Leistungsindikatoren von Windows. Danach läuft nichts weiter.';

  @override
  String vramUsageValue(Object megabytes) {
    return '$megabytes MB';
  }

  @override
  String get captureNow => 'Jetzt erfassen';

  @override
  String get tweaks => 'Tweaks';

  @override
  String get searchPowerPlans => 'Energiepläne suchen';

  @override
  String get activePowerPlan => 'Aktiv';

  @override
  String get activate => 'Aktivieren';

  @override
  String get details => 'Details';

  @override
  String get compare => 'Vergleichen';

  @override
  String get noPowerDifferences =>
      'Keine Unterschiede zwischen Netz- und Akkuwerten gefunden.';

  @override
  String get importPowerPlan => '.pow importieren';

  @override
  String get importPowerPlanDescription =>
      'Importiert einen lokal gewählten Energieplan nach begrenzter, per Hash geprüfter Bereitstellung.';

  @override
  String get exportActivePowerPlan => 'Aktiven Plan exportieren';

  @override
  String get restoreDefaultPowerSchemes => 'Windows-Standards wiederherstellen';

  @override
  String get restoreDefaultPowerSchemesDescription =>
      'Exportiert jedes aktuelle Schema mit Hash, bevor Windows die Standards wiederherstellt.';

  @override
  String get restoreDefaultPowerSchemesWarning =>
      'Alle aktuellen Energieschemas durch die Windows-Standards ersetzen? ZapTweaks exportiert zuerst jedes Schema für eine exakte Rücknahme.';

  @override
  String get interruptConfiguration => 'MSI Utility v3 & Interrupt-Affinität';

  @override
  String get interruptConfigurationDescription =>
      'Erweiterte, fähigkeitsabhängige MSI- und Gruppe-0-Interrupt-Affinitätseinstellungen für vorhandene Grafik-, Netzwerk-, Medien-, USB-Host- und HD-Audio-Geräte. Kein Wert wird automatisch empfohlen.';

  @override
  String get configureMsi => 'MSI konfigurieren';

  @override
  String get enableMsi => 'Message Signaled Interrupts aktivieren';

  @override
  String get configureInterruptAffinity => 'Affinität konfigurieren';

  @override
  String get interruptChangeWarning =>
      'Eine ungültige Interrupt-Richtlinie kann das Gerät bis zur Rücknahme oder zum Neustart unbrauchbar machen. ZapTweaks prüft die Hardwaregrenzen und sichert die genauen aktuellen Werte.';

  @override
  String get affinityMaskHint => 'Hexadezimale Maske für Gruppe 0, z. B. 3';

  @override
  String get invalidAffinityMask =>
      'Eine kanonische hexadezimale Maske ungleich null mit höchstens 64 Bit eingeben.';

  @override
  String msiRange(int maximum) {
    return 'Die Nachrichtenanzahl muss zwischen 1 und $maximum liegen.';
  }

  @override
  String get noCompatibleInterruptDevices =>
      'Kein vorhandenes PCI-Gerät für Grafik, Netzwerk, Medien, USB-Host oder HD-Audio bietet kompatible Interrupt-Fähigkeiten.';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return 'Hardware: Line $line · MSI $msi · MSI-X $msix · maximale Nachrichten $maximum';
  }

  @override
  String get messageNumberLimit => 'Begrenzung der Nachrichtenanzahl';

  @override
  String get interruptPriority => 'Interrupt-Prioritätsrichtlinie';

  @override
  String get interruptPriorityDefault => 'Nicht festgelegt / Treiberstandard';

  @override
  String get interruptPriorityLow => 'Niedrig';

  @override
  String get interruptPriorityNormal => 'Normal';

  @override
  String get interruptPriorityHigh => 'Hoch';

  @override
  String get interruptPolicy => 'Prozessor-Affinitätsrichtlinie';

  @override
  String get interruptPolicyDefault => 'Systemstandard';

  @override
  String get interruptPolicyAllClose => 'Alle nahen Prozessoren';

  @override
  String get interruptPolicyOneClose => 'Ein naher Prozessor';

  @override
  String get interruptPolicyAllProcessors => 'Alle Prozessoren';

  @override
  String get interruptPolicySpecified => 'Festgelegte Prozessoren (Gruppe 0)';

  @override
  String get interruptPolicySpread => 'Nachrichten auf Prozessoren verteilen';

  @override
  String get selectLogicalProcessors =>
      'Logische Prozessoren in Prozessorgruppe 0 wählen';

  @override
  String get affinitySelectAll => 'Alle logischen Prozessoren';

  @override
  String get affinityClear => 'Leeren';

  @override
  String get affinityPhysicalCores => 'Ein Thread pro physischem Kern';

  @override
  String get affinityPerformanceCores => 'Leistungskerne';

  @override
  String get affinityEfficiencyCores => 'Effizienzkerne';

  @override
  String get affinityParked => 'geparkt';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'NUMA-Knoten $index';
  }

  @override
  String get compatibleDevices => 'Kompatible Geräte';

  @override
  String get msiEnabledDevices => 'MSI derzeit aktiviert';

  @override
  String get logicalProcessors => 'Logische Prozessoren';

  @override
  String get searchDevices => 'Geräte, Instanz-IDs oder Treiber-INF suchen';

  @override
  String get driverUnknown => 'Treiber-INF nicht verfügbar';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return 'Aktuell: $mode · Nachrichten $messages · Priorität $priority · Richtlinie $policy · Maske $mask';
  }

  @override
  String get renamePowerPlan => 'Energieplan umbenennen';

  @override
  String get renamePowerPlanDescription =>
      'Ändert nur den Anzeigenamen des gewählten Plans und behält den ursprünglichen Namen für die Rücknahme.';

  @override
  String get rename => 'Umbenennen';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get duplicatePowerPlan => 'Energieplan duplizieren';

  @override
  String get duplicatePowerPlanDescription =>
      'Erstellt und prüft eine PowrProf-Kopie. Die Rücknahme ist nach bestem Bemühen, da Windows die GUID beim Erstellen vergibt.';

  @override
  String get apply => 'Anwenden';

  @override
  String get edit => 'Bearbeiten';

  @override
  String powerValueRange(int maximum) {
    return 'Werte müssen zwischen 0 und $maximum liegen.';
  }

  @override
  String get powerSettingConfigure =>
      'Beliebige begrenzte Energieeinstellung konfigurieren';

  @override
  String get powerSettingConfigureDescription =>
      'Bearbeitet eine von PowrProf bereitgestellte Einstellung nur, wenn Windows aktuelle Minimum-, Maximum- und Schrittwerte liefert.';

  @override
  String get searchPowerSettings =>
      'Einstellungen, Beschreibungen, Untergruppen oder GUIDs suchen';

  @override
  String get allPowerSubgroups => 'Alle Gruppen von Energieeinstellungen';

  @override
  String powerSettingCount(int count) {
    return '$count Einstellungen';
  }

  @override
  String powerSettingOptions(int count) {
    return '$count von Windows definierte Optionen';
  }

  @override
  String get backToPowerPlans => 'Zurück zu den Energieplänen';

  @override
  String get powerPlanEditorHint =>
      'Einen Plan duplizieren, um ein eigenes Profil anzulegen, dann Details öffnen und die versteckten Netz-/Akku-Einstellungen einzeln bearbeiten.';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Bereich $minimum–$maximum, Schritt $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows hat für diese Einstellung keine sicheren Werte oder Grenzen geliefert.';

  @override
  String get delete => 'Löschen';

  @override
  String get deletePowerPlan => 'Energieplan löschen';

  @override
  String get deletePowerPlanDescription =>
      'Exportiert den gewählten inaktiven Plan vor dem Löschen und behält die Sicherung für eine exakte Rücknahme.';

  @override
  String deletePowerPlanWarning(Object name) {
    return '$name löschen? ZapTweaks exportiert zuerst eine Wiederherstellungskopie.';
  }

  @override
  String get firmwareTemperatures => 'Firmware-Temperaturzonen';

  @override
  String get firmwareTemperaturesDescription =>
      'Liest ACPI-Temperaturzonen einmal aus. Verfügbarkeit und Bedeutung der Sensoren hängen von der Firmware ab; die Werte werden nicht als CPU- oder GPU-Temperatur bezeichnet.';

  @override
  String get noThermalSensors =>
      'Dieser PC stellt keine ACPI-Temperaturzonen bereit.';

  @override
  String get cpuFrequency => 'CPU-Takt und Core Parking';

  @override
  String get cpuFrequencyDescription =>
      'Liest einmal die Prozessor-Leistungsindikatoren von Windows. Der effektive Takt ist Basistakt × % Prozessorleistung, dieselbe Formel wie im Task-Manager. Damit lassen sich Änderungen an Energieplan, Boost und Core Parking prüfen. Nur Lesen.';

  @override
  String cpuEffectiveClock(Object mhz, Object nominal) {
    return '$mhz MHz effektiv · Basis $nominal MHz';
  }

  @override
  String cpuParkedCount(Object parked, Object total) {
    return '$parked von $total logischen Prozessoren geparkt';
  }

  @override
  String get cpuParked => 'geparkt';

  @override
  String get cpuFrequencySource =>
      'Quelle: Leistungsindikatoren „Processor Information“ (Win32_PerfFormattedData_Counters_ProcessorInformation), ein Messwert über das letzte Indikatorintervall gemittelt. Kein Spitzentakt. Werte pro Kern nutzen einen einzigen Nenntakt, daher erscheinen Effizienzkerne hybrider CPUs zu hoch.';

  @override
  String get driverInventory => 'Driver-Store-Inventur';

  @override
  String get installLocalDriver => 'Lokales Treiberpaket installieren';

  @override
  String get installLocalDriverDescription =>
      'Lokale INF, signierten Katalog und Hardwarekompatibilität vor der Installation prüfen.';

  @override
  String get selectDevice => 'Vorhandenes Gerät wählen';

  @override
  String get localInfPath => 'Absoluter Pfad zur lokalen .inf-Datei';

  @override
  String get verifyDriverPackage => 'Paket prüfen';

  @override
  String verifiedDriverPublisher(Object publisher, Object sha256) {
    return 'Geprüfter Herausgeber: $publisher\nINF SHA-256: $sha256';
  }

  @override
  String get confirmLocalDriverInstall =>
      'Installation des lokalen Treibers bestätigen';

  @override
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  ) {
    return 'Gerät: $device\nSignierter Herausgeber: $publisher\nINF SHA-256: $sha256\n\nWindows kann den aktiven Treiber wechseln und einen Neustart verlangen. Die Rücknahme ist nach bestem Bemühen.';
  }

  @override
  String get driverTools => 'Begleitete Abläufe';

  @override
  String get temporaryDriverUpdatesPause =>
      'Treiber vorübergehend von Windows-Qualitätsupdates ausschließen';

  @override
  String get temporaryDriverUpdatesPauseDescription =>
      'Nutzt die dokumentierte Windows Update-Richtlinie für 7 oder 30 Tage. ZapTweaks speichert den genauen vorherigen Wert und erinnert, wenn die Pause abläuft; die Wiederherstellung erfordert Ihre Bestätigung.';

  @override
  String get driverUpdatePolicy => 'Windows Update-Treiberrichtlinie';

  @override
  String get driverUpdatePolicyDescription =>
      'Gerätetreiber für 7 Tage, 30 Tage oder bis zur ausdrücklichen Wiederherstellung der genauen vorherigen Richtlinie von Windows-Qualitätsupdates ausschließen.';

  @override
  String get disableUntilRestored => 'Bis zur Wiederherstellung deaktivieren';

  @override
  String get driverUpdatePausePermanent =>
      'Treiberupdates bleiben ausgeschlossen, bis die vorherige Richtlinie wiederhergestellt wird.';

  @override
  String get driverUpdatePauseActive => 'Treiberupdate-Pause aktiv';

  @override
  String get driverUpdatePauseExpired =>
      'Treiberupdate-Pause abgelaufen – vorherige Richtlinie wiederherstellen';

  @override
  String driverUpdatePauseUntil(Object date) {
    return 'Geplantes Ende: $date';
  }

  @override
  String get pauseSevenDays => '7 Tage pausieren';

  @override
  String get pauseThirtyDays => '30 Tage pausieren';

  @override
  String get restoreDriverUpdates => 'Vorherige Richtlinie wiederherstellen';

  @override
  String get assistedDriverFlows => 'Geprüfte und begleitete Treiberabläufe';

  @override
  String get assistedDriverFlowsDescription =>
      'ZapTweaks öffnet nur Quellen der Hersteller und Windows-Oberflächen. Es führt keine veränderlichen Remote-Skripte aus, flasht keine Firmware und entfernt keine Treiberkomponenten stillschweigend.';

  @override
  String get amdDriverFlow => 'AMD-Treiber und -Software';

  @override
  String get amdDriverFlowDescription =>
      'Die offizielle AMD-Treiberauswahl öffnen. Vor dem Download das erkannte Produkt prüfen.';

  @override
  String get nvidiaDriverFlow => 'NVIDIA-Treiber';

  @override
  String get nvidiaDriverFlowDescription =>
      'Die offizielle manuelle NVIDIA-Treibersuche öffnen. Eine saubere Installation bleibt eine ausdrückliche Wahl im Herstellerinstaller.';

  @override
  String get intelDriverFlow => 'Intel Driver & Support Assistant';

  @override
  String get intelDriverFlowDescription =>
      'Den offiziellen Erkennungs- und Supportablauf von Intel öffnen.';

  @override
  String get windowsOptionalDrivers => 'Optionale Windows-Treiberupdates';

  @override
  String get windowsOptionalDriversDescription =>
      'Optionale Treiberupdates in den Windows-Einstellungen prüfen; nichts wird automatisch ausgewählt.';

  @override
  String get deviceManager => 'Geräte-Manager';

  @override
  String get deviceManagerDescription =>
      'Geräte, Statuscodes, aktive Treiber und manuelle Rücknahmeoptionen prüfen.';

  @override
  String get openOfficialSource => 'Offizielle Quelle öffnen';

  @override
  String get openWindowsPanel => 'Windows-Bereich öffnen';

  @override
  String get searchDrivers => 'Driver Store durchsuchen';

  @override
  String get driverStoreSafetyNotice =>
      'Hier lassen sich nur signierte, nicht zugeordnete Drittanbieterpakete entfernen. ZapTweaks exportiert das Paket zuerst mit Hash; die Wiederherstellung ist nach bestem Bemühen, da Windows einen anderen veröffentlichten Namen vergeben kann.';

  @override
  String get signed => 'Signiert';

  @override
  String get unsigned => 'Nicht signiert';

  @override
  String get driverInUse => 'In Verwendung';

  @override
  String get driverUnbound => 'Nicht zugeordnet';

  @override
  String get exportAndRemove => 'Exportieren und entfernen';

  @override
  String get confirmDriverRemoval =>
      'Entfernen aus dem Driver Store bestätigen';

  @override
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  ) {
    return 'Veröffentlichter Name: $published\nUrsprüngliche INF: $inf\nHerausgeber: $publisher\nVersion: $version\n\nZapTweaks exportiert das Paket vor dem Entfernen mit Hash. Ein Neustart kann nötig sein; die Wiederherstellung ist nach bestem Bemühen.';
  }

  @override
  String get searchInstalledApps => 'Installierte Apps suchen';

  @override
  String get scanAllUsers => 'Alle Benutzer scannen (UAC)';

  @override
  String get systemScopesComplete =>
      'AppX-Bereiche aller Benutzer und bereitgestellte Pakete sind enthalten.';

  @override
  String get systemScopesIncomplete =>
      'Nur aktueller Benutzer und winget-Inventur. Alle Benutzer scannen, um System-AppX-Bereiche einzuschließen.';

  @override
  String get currentUser => 'Aktueller Benutzer';

  @override
  String get allUsers => 'Alle Benutzer';

  @override
  String get provisioned => 'Bereitgestellt';

  @override
  String get confirmAppxRemoval => 'Entfernen der AppX bestätigen';

  @override
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  ) {
    return 'App: $name\nIdentität: $id\nBereich: $scope\nWiederherstellung: $recovery\n\nNur der angegebene Bereich wird entfernt. Dieser Vorgang hat keine exakte Rücknahme.';
  }

  @override
  String get reinstallable => 'Geprüfte Wiederherstellungsquelle verfügbar';

  @override
  String get notReinstallable => 'Keine geprüfte Wiederherstellungsquelle';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get installedOnly => 'Nur installierte';

  @override
  String get refreshInventory => 'Inventur aktualisieren';

  @override
  String get install => 'Installieren';

  @override
  String get uninstall => 'Deinstallieren';

  @override
  String get uninstallSelected => 'Auswahl deinstallieren';

  @override
  String get openOfficialPage => 'Offizielle Seite öffnen';

  @override
  String get installed => 'Installiert';

  @override
  String get notInstalled => 'Nicht installiert';

  @override
  String get appInventoryUnavailable =>
      'Die Erkennung installierter Apps ist nicht verfügbar.';

  @override
  String get confirmBulkUninstall => 'Sammeldeinstallation bestätigen';

  @override
  String confirmBulkUninstallMessage(Object apps) {
    return 'Folgende Apps werden deinstalliert:\n\n$apps';
  }

  @override
  String get appCatalogSources =>
      'Katalog zusammengeführt aus fixiertem CTT WinUtil, Clean-Room-Kandidaten von Winhance, TweakHub und gewünschten offiziellen Quellen.';

  @override
  String get tcpOptimizer => 'TCP-Optimierer';

  @override
  String get tcpOptimizerDescription =>
      'Windows-TCP-Vorlagen, globale Offloads, QoS pro Anwendung und wiederholbare Netzwerkdiagnosen prüfen und konfigurieren.';

  @override
  String get tcpNoRecommendation =>
      'Kein Wert wird automatisch empfohlen. Ein Auslesen oder ein einzelner Netzwerktest belegt keinen Leistungsvorteil.';

  @override
  String get tcpLiveState => 'Aktueller TCP-Status';

  @override
  String get tcpTemplates => 'TCP-Vorlagen';

  @override
  String get tcpGlobal => 'Globale TCP-Offloads';

  @override
  String get tcpAutotuning => 'Autotuning des Empfangsfensters';

  @override
  String get tcpHeuristics => 'Heuristik der Fensterskalierung';

  @override
  String get tcpEcn => 'ECN-Unterstützung';

  @override
  String get tcpCongestion => 'Überlastungssteuerung';

  @override
  String get tcpRsc => 'Empfangssegment-Zusammenführung (RSC)';

  @override
  String get tcpRss => 'Globales Receive-Side Scaling (RSS)';

  @override
  String get tcpConfigure => 'Konfigurieren';

  @override
  String get tcpChangePreview => 'Vorschau der TCP-Änderung';

  @override
  String get tcpCurrentValue => 'Aktueller Wert';

  @override
  String get tcpNewValue => 'Neuer Wert';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks sichert den exakten aktuellen Wert, wendet die Änderung mit einer UAC-Anfrage an, liest sie zurück, protokolliert sie und ermöglicht die exakte Wiederherstellung.';

  @override
  String get tcpUnsupported => 'Von diesem Windows-Build nicht bereitgestellt';

  @override
  String get tcpAdapterRss => 'RSS-Steuerung pro Adapter öffnen';

  @override
  String get rssAdapterState => 'RSS-Status pro Adapter';

  @override
  String get rssEnabled => 'RSS aktiviert';

  @override
  String get rssProfile => 'RSS-Profil';

  @override
  String get rssQueuesProcessors => 'Warteschlangen/Prozessoren';

  @override
  String get tcpSettingOperationTitle => 'TCP-Einstellung konfigurieren';

  @override
  String get tcpSettingOperationDescription =>
      'Ändert eine von den Systemfunktionen unterstützte Windows-TCP-Vorlage oder einen globalen Offload-Wert mit exakter Wiederherstellung.';

  @override
  String get qosPolicies => 'QoS-Richtlinien für Anwendungen';

  @override
  String get qosDescription =>
      'Explizite dauerhafte QoS-Richtlinien für eine ausführbare Datei erstellen. Vorhandene Richtlinien, die nicht von ZapTweaks stammen, bleiben schreibgeschützt.';

  @override
  String get qosCreate => 'Richtlinie erstellen';

  @override
  String get qosEdit => 'Bearbeiten';

  @override
  String get qosDelete => 'Löschen';

  @override
  String get qosName => 'Richtlinienname';

  @override
  String get qosAppPath => 'Pfad zur ausführbaren Datei';

  @override
  String get qosProtocol => 'Protokoll';

  @override
  String get qosSourcePort => 'Quellport (optional)';

  @override
  String get qosDestinationPort => 'Zielport (optional)';

  @override
  String get qosDscp => 'DSCP 0–63 (optional)';

  @override
  String get qosThrottleMbps => 'Drosselung in Mbit/s (optional)';

  @override
  String get qosOwnedOnly =>
      'Namen müssen mit „ZapTweaks - “ beginnen. Nur die ausgewählte Richtlinie wird geändert; andere QoS-Richtlinien werden niemals gelöscht.';

  @override
  String get qosDeleteConfirm =>
      'Ausgewählte QoS-Richtlinie löschen? Ihr exakter Zustand wird für die Wiederherstellung im ZapTweaks-Journal gespeichert.';

  @override
  String get qosReadOnly => 'Schreibgeschützt';

  @override
  String get qosPolicyOperationTitle => 'Anwendungs-QoS konfigurieren';

  @override
  String get qosPolicyOperationDescription =>
      'Erstellt, bearbeitet oder entfernt eine validierte dauerhafte QoS-Richtlinie pro Anwendung mit exakter Wiederherstellung.';

  @override
  String get networkDiagnostics => 'Vorher-/Nachher-Diagnose';

  @override
  String get networkDiagnosticsDescription =>
      'Begrenzt TCP-Verbindungslatenz, Jitter, Verlust und HTTPS-Download-Durchsatz messen. Die Ergebnisse sind Diagnosewerte und keine Empfehlung.';

  @override
  String get diagnosticEndpoint => 'Direkte HTTPS-URL der Testdatei';

  @override
  String get diagnosticNetworkCost =>
      'Der Test lädt höchstens 10 MiB vom eingegebenen Endpunkt herunter. Es ist kein Drittanbieter-Endpunkt integriert.';

  @override
  String get diagnosticBaseline => 'Ausgangsmessung starten';

  @override
  String get diagnosticComparison => 'Vergleichsmessung starten';

  @override
  String get diagnosticCancel => 'Messung abbrechen';

  @override
  String get diagnosticLatency => 'Latenz';

  @override
  String get diagnosticJitter => 'Jitter';

  @override
  String get diagnosticPacketLoss => 'Paketverlust';

  @override
  String get diagnosticThroughput => 'Durchsatz';

  @override
  String get diagnosticRawSamples => 'Unverarbeitete Latenzmesswerte';

  @override
  String get diagnosticDownloadedBytes => 'Heruntergeladene Bytes';

  @override
  String get diagnosticDifference => 'Differenz B − A';

  @override
  String get tcpAttribution =>
      'Inspiriert von WINSPAR — powplowdevs (fixierte Revision)';

  @override
  String get openRecoveryHistory => 'Wiederherstellung und Journal öffnen';

  @override
  String get manualRestoreTitle =>
      'Ursprüngliche manuelle Einstellungen wiederherstellen';

  @override
  String get manualRestoreWarning =>
      'Stellt die gespeicherten Originale wieder her, nicht die Standards. Geänderte Einstellungen werden nicht überschrieben. Riskante Einstellungen erfordern Expertenmodus und UAC. Nach der Wiederherstellung das Protokoll prüfen; Neustart oder Abmeldung können weiterhin nötig sein.';

  @override
  String get cleanupUserTemp => 'UserTemp bereinigen';

  @override
  String get cleanupUserTempDescription =>
      'Genaue Dateien im Temp-Ordner des aktuellen Benutzers prüfen und wählen. Keine automatische Auswahl, kein erzwungenes Löschen und kein Entfernen von Ordnern.';

  @override
  String get cleanupSelectFiles => 'Dateien anzeigen und wählen';

  @override
  String get cleanupShaderCache => 'GPU-Shader-Cache bereinigen';

  @override
  String get cleanupShaderCacheDescription =>
      'Zeigt die DirectX-, AMD-, NVIDIA- und Intel-Shader-Caches des aktuellen Benutzers Ordner für Ordner an und löscht genau die in dieser Vorschau gefundenen Dateien. Der Treiber baut sie neu auf, daher kann der erste Start jedes Spiels ruckeln. Vorher Spiele schließen. Nicht umkehrbar.';

  @override
  String get cleanupShaderCacheNone =>
      'Keine GPU-Shader-Cache-Dateien gefunden.';

  @override
  String get cleanupShaderCacheCompleted =>
      'Die angezeigten Shader-Cache-Dateien wurden gelöscht und ihr Fehlen geprüft.';

  @override
  String get cleanupPreview => 'Vorschau';

  @override
  String get cleanupUserTempNone => 'Keine UserTemp-Dateien gefunden.';

  @override
  String get cleanupPermanentWarning =>
      'Endgültiges Löschen. Keine Rücknahme und kein Umgehen von Berechtigungen oder Sperren. Vorher Anwendungen schließen. Schlägt das Löschen fehl, können frühere Dateien bereits entfernt sein.';

  @override
  String get cleanupUserTempSelectionHint =>
      'Nichts ist ausgewählt. Nur Dateien wählen, die Sie kennen; nach dieser Vorschau erstellte Dateien sind ausgeschlossen.';

  @override
  String cleanupPreviewCount(int count, int bytes) {
    return '$count Dateien, $bytes Bytes';
  }

  @override
  String get cleanupRecycleUnavailable =>
      'Papierkorb-Bereinigung nicht verfügbar: Die genauen Elemente lassen sich nicht sicher anzeigen und löschen. Es wird nicht alles geleert.';

  @override
  String get cleanupCrashReports => 'Absturzabbilder und Fehlerberichte';

  @override
  String get cleanupCrashReportsDescription =>
      'Löscht die Absturzabbilder Ihrer Programme (%LOCALAPPDATA%\\CrashDumps) sowie Archiv und Warteschlange der Windows-Fehlerberichterstattung. Nützlich, wenn ein Spiel oder eine App oft abgestürzt ist. System-Minidumps (Bluescreens) bleiben unberührt.';

  @override
  String get cleanupCrashReportsNone =>
      'Keine Absturzabbilder oder Fehlerberichte zu löschen.';

  @override
  String get cleanupCrashReportsCompleted =>
      'Absturzabbilder und Fehlerberichte gelöscht.';

  @override
  String get cleanupBrowserCache => 'Browser-Caches';

  @override
  String get cleanupBrowserCacheDescription =>
      'Löscht die Festplatten-Caches von Chrome, Edge, Brave (alle Profile) und Firefox. Cookies, Verlauf, Passwörter und Erweiterungen bleiben unberührt; Seiten laden beim ersten Mal etwas langsamer.';

  @override
  String get cleanupBrowserCacheNone =>
      'Keine Browser-Cache-Dateien zu löschen.';

  @override
  String get cleanupBrowserCacheCompleted => 'Browser-Caches gelöscht.';

  @override
  String cleanupBrowserRunning(String browsers) {
    return 'Zuerst $browsers schließen (auch im Infobereich: Edge und Chrome können im Hintergrund weiterlaufen).';
  }

  @override
  String thermalZoneLimited(String percent) {
    return 'die Firmware begrenzt die CPU auf $percent %';
  }

  @override
  String get thermalSourceCounters =>
      'Quelle: Windows-Leistungsindikatoren „Thermal Zone Information“ (von der Firmware definierte ACPI-Zonen, keine Administratorrechte nötig). Eine Zone ist ein vom Hersteller gewählter Sensor und oft nicht der CPU-Chip.';

  @override
  String get thermalSourceAcpi =>
      'Quelle: MSAcpi_ThermalZoneTemperature (von der Firmware definierte ACPI-Zonen). Eine Zone ist ein vom Hersteller gewählter Sensor und oft nicht der CPU-Chip.';

  @override
  String get thermalSourceNone =>
      'Die Firmware dieses PCs stellt keine ACPI-Temperaturzone bereit (bei Desktop-Mainboards üblich). Es wird nichts angezeigt statt eines nicht gemessenen Werts.';

  @override
  String get srumTab => 'App-Verlauf';

  @override
  String get srumTitle => 'App-Verlauf (SRUM)';

  @override
  String get srumDescription =>
      'Netzwerk-, CPU- und Datenträgernutzung jedes Programms in den letzten 30 Tagen, wie von Windows aufgezeichnet (System Resource Usage Monitor). Nur Lesen: ZapTweaks liest eine Schattenkopie der Datenbank und löscht sie danach. Erfordert Administratorrechte.';

  @override
  String get srumRead => 'Verlauf lesen';

  @override
  String get srumNotCollectingTitle =>
      'Windows zeichnet keinen App-Verlauf auf';

  @override
  String srumNotCollecting(String status, String startType, String date) {
    return 'Der Diagnoserichtliniendienst, der diesen Verlauf aufzeichnet, ist $status ($startType). Die Daten enden am $date.';
  }

  @override
  String get srumNoData =>
      'In den letzten 30 Tagen wurde keine Nutzung aufgezeichnet.';

  @override
  String get srumNetwork => 'Netzwerk (gesendet / empfangen)';

  @override
  String get srumCpu =>
      'CPU-Zeit (Anteil an allen Programmen; davon im Hintergrund)';

  @override
  String srumCpuShare(String share, String background) {
    return '$share % · $background % im Hintergrund';
  }

  @override
  String get srumUnattributed => 'Keinem Programm zugeordnet';

  @override
  String srumSource(String first, String last) {
    return 'Quelle: C:\\Windows\\System32\\sru\\SRUDB.dat, Einträge vom $first bis $last. Windows schreibt sie etwa einmal pro Stunde.';
  }

  @override
  String get manualControls => 'Manuelle Steuerung';

  @override
  String upToDate(String version) {
    return 'Du verwendest die neueste Version ($version).';
  }

  @override
  String get startCapture => 'Aufzeichnung starten';

  @override
  String get batteryHealth => 'Akkuzustand';

  @override
  String get batteryHealthDescription =>
      'Kapazität, die der Akku im Vergleich zum Auslegungswert noch hält. Nur lesen.';

  @override
  String get batteryGood => 'Gut';

  @override
  String get batteryFair => 'Abgenutzt';

  @override
  String get batteryPoor => 'Bald ersetzen';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get batteryDesigned => 'Auslegungskapazität';

  @override
  String get batteryFullCharge => 'Kapazität bei Vollladung';

  @override
  String get batteryWear => 'Verschleiß';

  @override
  String get batteryCycles => 'Ladezyklen';

  @override
  String get batteryCharge => 'Aktuelle Ladung';

  @override
  String get batteryOnAc => 'Am Netz';

  @override
  String get batteryOnBattery => 'Akkubetrieb';

  @override
  String get batterySourceWmi =>
      'Quelle: root\\wmi BatteryStaticData, BatteryFullChargedCapacity, BatteryCycleCount und BatteryStatus, wie von der Akku-Firmware gemeldet.';

  @override
  String get batterySourceReport =>
      'Quelle: powercfg /batteryreport (temporäres XML, nach dem Lesen gelöscht), wie von der Akku-Firmware gemeldet.';

  @override
  String get appTypeSystem => 'System';

  @override
  String get appTypeUser => 'Benutzer';

  @override
  String get appTypeStore => 'Store';

  @override
  String get appSafetyRemovable => 'Entfernbar';

  @override
  String get appSafetyCheckFirst => 'Erst prüfen';

  @override
  String get appSafetyKeep => 'Behalten';

  @override
  String get appReasonSystemComponent =>
      'Versteckte Windows- oder Herstellerkomponente.';

  @override
  String get appReasonProtected => 'Sein Installer verbietet das Entfernen.';

  @override
  String get appReasonUpdate =>
      'Update eines anderen Programms: entferne stattdessen dieses.';

  @override
  String get appReasonWindowsPart =>
      'Teil von Windows oder ein von anderen Apps benötigtes Framework.';

  @override
  String get appReasonSharedDependency =>
      'Von anderen Apps genutzt (Laufzeit, Treiber oder Herstellerpanel).';

  @override
  String get appReasonOptionalFeature =>
      'Optionale Windows-Funktion: lies, was nicht mehr funktioniert.';

  @override
  String get appReasonMissingUninstaller =>
      'Kein Deinstallationsprogramm registriert.';

  @override
  String get appReasonUserInstalled =>
      'Von dir oder dem PC-Hersteller installiert; nichts anderes hängt davon ab.';

  @override
  String get appLabelMissingUninstaller => 'Ohne Deinstaller';

  @override
  String get appLabelProtected => 'Geschützt';

  @override
  String get appLabelSystemComponent => 'Systemkomponente';

  @override
  String get appLabelUpdate => 'Update';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterType => 'Typ';

  @override
  String get filterSafety => 'Sicherheit';

  @override
  String get filterSource => 'Quelle';

  @override
  String get sourceWholePc => 'Ganzer PC';

  @override
  String get sortBy => 'Sortieren';

  @override
  String get sortSize => 'Größe';

  @override
  String get sortName => 'Name';

  @override
  String get sortDate => 'Installationsdatum';

  @override
  String appsShown(int count) {
    return '$count Apps';
  }

  @override
  String selectionSummary(int count, String size) {
    return '$count ausgewählt · $size';
  }

  @override
  String selectionUnknownSizes(int count) {
    return '$count mit unbekannter Größe';
  }

  @override
  String get appsSource =>
      'Quelle: Uninstall-Registrierungsschlüssel (HKLM 64/32 Bit, HKCU), Get-AppxPackage, winget export für Neuinstallations-IDs. Größe: EstimatedSize, sonst der Installationsordner.';

  @override
  String get noAppsMatch => 'Keine App entspricht diesen Filtern.';

  @override
  String reinstallableVia(String id) {
    return 'Neuinstallation: winget $id';
  }

  @override
  String get uninstallQueueTitle => 'Deinstallationswarteschlange';

  @override
  String get uninstallModeSilent => 'Still';

  @override
  String get uninstallModeWindowed => 'Öffnet ein Fenster';

  @override
  String get uninstallManualNoUninstaller =>
      'Manuell: kein Deinstaller registriert.';

  @override
  String get uninstallManualUnsafe =>
      'Manuell: Der registrierte Befehl startet eine Shell oder ein Skript; ZapTweaks führt ihn nicht aus.';

  @override
  String get uninstallManualNotFound => 'Manuell: Die Deinstaller-Datei fehlt.';

  @override
  String uninstallRunningWarning(String processes) {
    return 'Läuft noch aus seinem Ordner: $processes. Zuerst schließen.';
  }

  @override
  String get uninstallSimulate =>
      'Simulation: Warteschlange planen und zeigen, nichts deinstallieren';

  @override
  String get uninstallRestorePointNote =>
      'Zuerst wird ein Wiederherstellungspunkt erstellt. Programme mit Fenster laufen zuerst, eins nach dem anderen; stille folgen.';

  @override
  String get uninstallStart => 'Deinstallation starten';

  @override
  String get restorePointCreating => 'Wiederherstellungspunkt wird erstellt…';

  @override
  String get restorePointFailed =>
      'Der Wiederherstellungspunkt wurde nicht erstellt. Der Computerschutz ist eventuell aus. Nichts wurde geändert.';

  @override
  String get restorePointEnableAndRetry =>
      'Computerschutz einschalten und erneut versuchen';

  @override
  String get queueWaiting => 'Wartet';

  @override
  String get queueRunning => 'Läuft';

  @override
  String get queueDone => 'Fertig';

  @override
  String get queueFailed => 'Fehlgeschlagen';

  @override
  String get queueSkipped => 'Übersprungen';

  @override
  String get queueSkip => 'Überspringen';

  @override
  String get queueStop => 'Nach dem aktuellen stoppen';

  @override
  String get queueSimulated => 'Simulation: Es wurde nichts deinstalliert.';

  @override
  String get uninstallStoreAppsHint =>
      'Store-Apps in der Auswahl über das Menü Deinstallieren ihrer Zeile entfernen.';

  @override
  String get leftoverSearch => 'Nach Resten suchen';

  @override
  String get leftoverTitle => 'Reste';

  @override
  String get leftoverGood => 'Sicher';

  @override
  String get leftoverMedium => 'Wahrscheinlich';

  @override
  String get leftoverLow => 'Unsicher';

  @override
  String get leftoverKindFolder => 'Ordner';

  @override
  String get leftoverKindShortcut => 'Verknüpfung';

  @override
  String get leftoverKindRegistry => 'Registrierungsschlüssel';

  @override
  String get leftoverKindRun => 'Autostart-Eintrag';

  @override
  String get leftoverKindTask => 'Geplante Aufgabe';

  @override
  String get leftoverKindFirewall => 'Firewallregel';

  @override
  String get leftoverNone => 'Keine Reste gefunden.';

  @override
  String leftoverRemoveSelected(int count) {
    return 'Ausgewählte entfernen ($count)';
  }

  @override
  String get leftoverBackupNote =>
      'Nur als sicher markierte Elemente sind vorausgewählt. Vor dem Entfernen werden Registrierungsschlüssel als .reg, Aufgaben als XML und Firewallregeln als JSON gesichert; Dateien und Ordner kommen in den Papierkorb.';

  @override
  String leftoverRemoved(String path) {
    return 'Reste entfernt. Sicherungen: $path';
  }

  @override
  String get leftoverRefusedInvalid =>
      'Nicht entfernt: ungültiger oder unsicherer Eintrag.';

  @override
  String get leftoverRefusedOutside =>
      'Nicht entfernt: außerhalb dessen, was ZapTweaks hier bereinigen darf.';

  @override
  String get leftoverRefusedShared =>
      'Nicht entfernt: wird von Windows oder anderen Programmen mitgenutzt.';

  @override
  String get orphanFolders => 'Verwaiste Ordner';

  @override
  String get orphanFoldersNote =>
      'Program-Files-Ordner, auf die kein installiertes Programm verweist. Ein portables Tool oder Treiberpaket kann genauso aussehen, daher ist nichts ausgewählt: prüfe jeden Ordner zuerst.';

  @override
  String get openLocation => 'Speicherort öffnen';

  @override
  String get processesTab => 'Prozesse';

  @override
  String get searchProcesses => 'Prozesse suchen';

  @override
  String get sortMemory => 'Arbeitsspeicher';

  @override
  String get sortCpu => 'CPU';

  @override
  String get processKindWindows => 'Windows';

  @override
  String get processKindMicrosoft => 'Microsoft-App';

  @override
  String get processKindThirdParty => 'Drittanbieter';

  @override
  String get processCanClose => 'Kann beendet werden';

  @override
  String get processLeaveRunning => 'Laufen lassen';

  @override
  String get processReasonCritical =>
      'Windows braucht ihn: Beenden kann dich abmelden oder das System abstürzen lassen.';

  @override
  String get processReasonWindowsFolder =>
      'Läuft aus dem Windows-Ordner oder ist geschützt.';

  @override
  String get processReasonService =>
      'Führt einen Dienst aus: über den Tab Dienste verwalten.';

  @override
  String get processReasonSelf => 'Das ist ZapTweaks.';

  @override
  String get processReasonUserApp =>
      'Eine von dir gestartete App: Beim Beenden geht Ungespeichertes verloren.';

  @override
  String get processEnd => 'Prozess beenden';

  @override
  String processEndConfirm(String name) {
    return '$name beenden? Nicht Gespeichertes geht verloren.';
  }

  @override
  String get processEndChanged =>
      'Er war schon beendet oder seine ID gehört jetzt einem anderen Prozess: nichts wurde beendet.';

  @override
  String get processEndFailed =>
      'Windows hat das Beenden verweigert. Er läuft vielleicht als Administrator.';

  @override
  String get searchOnline => 'Online suchen';

  @override
  String get processOnlyClosable => 'Nur beendbare';

  @override
  String get processNote =>
      'Eine Momentaufnahme: CPU ist ein einzelner Messwert, zum erneuten Lesen aktualisieren. Signaturen werden geprüft, nachdem die Liste erscheint. Systemprozesse werden nie zum Beenden angeboten.';

  @override
  String get noProcessesMatch => 'Kein Prozess entspricht diesen Filtern.';

  @override
  String signedBy(String signer) {
    return 'Signiert von $signer';
  }

  @override
  String get servicesTab => 'Dienste';

  @override
  String get searchServices => 'Dienste suchen';

  @override
  String get filterOrigin => 'Herkunft';

  @override
  String get originMicrosoft => 'Microsoft';

  @override
  String get serviceCanDisable => 'Deaktivierbar';

  @override
  String get serviceDependsOnUse => 'Je nach Nutzung';

  @override
  String get serviceKeep => 'Behalten';

  @override
  String get serviceStartAutomatic => 'Automatisch';

  @override
  String get serviceStartDelayed => 'Automatisch (verzögert)';

  @override
  String get serviceStartManual => 'Manuell';

  @override
  String get serviceStartDisabled => 'Deaktiviert';

  @override
  String get serviceStartBoot => 'Systemstart';

  @override
  String get serviceRunning => 'Läuft';

  @override
  String get serviceStopped => 'Beendet';

  @override
  String get serviceSetDisabled => 'Deaktivieren';

  @override
  String get serviceSetManual => 'Auf manuell setzen';

  @override
  String get serviceSetAutomatic => 'Auf automatisch setzen';

  @override
  String serviceChangeTitle(String service) {
    return '$service ändern';
  }

  @override
  String serviceChangeConfirm(String from, String to, String reason) {
    return 'Starttyp: $from → $to.\n$reason\nGilt ab dem nächsten Start des Dienstes oder von Windows. Du kannst es direkt danach rückgängig machen.';
  }

  @override
  String serviceChanged(String service, String to) {
    return '$service ist jetzt $to.';
  }

  @override
  String get serviceUndo => 'Rückgängig';

  @override
  String get serviceNote =>
      'Änderungen fragen nach Administratorrechten und gelten ab dem nächsten Start des Dienstes oder von Windows. Dienste, die Windows braucht, werden nie angeboten; Dienste, von denen andere abhängen, lassen sich nicht deaktivieren.';

  @override
  String get noServicesMatch => 'Kein Dienst entspricht diesen Filtern.';

  @override
  String get svcReasonTelemetry =>
      'Sendet Nutzungs- und Diagnosedaten an Microsoft. Nichts, was du nutzt, hört auf zu funktionieren.';

  @override
  String get svcReasonDeviceManagement =>
      'Telemetrie und Geräteverwaltung durch Arbeit oder Schule: nur nötig, wenn eine Organisation diesen PC verwaltet.';

  @override
  String get svcReasonCrashReports =>
      'Sendet Absturzberichte an Microsoft. Abstürze werden weiterhin auf diesem PC protokolliert.';

  @override
  String get svcReasonRemoteRegistry =>
      'Erlaubt anderen Computern, die Registrierung dieses PCs über das Netzwerk zu ändern. Standardmäßig aus.';

  @override
  String get svcReasonOfflineMaps =>
      'Hält Offlinekarten der Karten-App aktuell.';

  @override
  String get svcReasonMediaSharing =>
      'Gibt die Windows-Media-Player-Bibliothek im Netzwerk frei.';

  @override
  String get svcReasonRetailDemo =>
      'Demomodus für Geschäfte. Zu Hause nie nötig.';

  @override
  String get svcReasonXbox =>
      'Ohne ihn: Xbox-App, Game Pass, Cloud-Speicherstände und Xbox-Zubehör funktionieren nicht mehr.';

  @override
  String get svcReasonPrinting =>
      'Ohne ihn: Drucken funktioniert nicht mehr, auch nicht Drucken als PDF.';

  @override
  String get svcReasonBluetooth =>
      'Ohne ihn: Bluetooth-Geräte verbinden sich nicht mehr.';

  @override
  String get svcReasonSearch =>
      'Ohne ihn: Die Suche in Start, Einstellungen und Explorer wird langsam und unvollständig.';

  @override
  String get svcReasonSysMain =>
      'Lädt oft genutzte Apps vor. Ohne ihn können Starts langsamer sein, vor allem auf Festplatten.';

  @override
  String get svcReasonTouchKeyboard =>
      'Ohne ihn: Bildschirmtastatur, Handschrift, Emoji-Panel und manche Eingabemethoden funktionieren nicht mehr.';

  @override
  String get svcReasonLocation =>
      'Ohne ihn: Apps und „Mein Gerät suchen“ können deinen Standort nicht mehr ermitteln.';

  @override
  String get svcReasonBiometrics =>
      'Ohne ihn: Anmeldung per Gesicht und Fingerabdruck mit Windows Hello funktioniert nicht mehr.';

  @override
  String get svcReasonPhone =>
      'Ohne ihn: Anrufe über Smartphone-Link funktionieren nicht mehr.';

  @override
  String get svcReasonRemoteDesktop =>
      'Ohne ihn: Remotedesktop auf diesen PC funktioniert nicht mehr.';

  @override
  String get svcReasonSmartCard =>
      'Ohne ihn: Smartcards und manche Sicherheitsschlüssel funktionieren nicht mehr.';

  @override
  String get svcReasonParental =>
      'Ohne ihn: Grenzen von Microsoft Family Safety werden nicht mehr durchgesetzt.';

  @override
  String get svcReasonNfc =>
      'Ohne ihn: NFC und kontaktloses Bezahlen funktionieren nicht mehr.';

  @override
  String get svcReasonHotspot =>
      'Ohne ihn: Mobiler Hotspot funktioniert nicht mehr.';

  @override
  String get svcReasonScanner =>
      'Ohne ihn: Scanner und manche Kameras funktionieren nicht mehr.';

  @override
  String get svcReasonCompatibility =>
      'Ohne ihn: Windows bietet keine Korrekturen mehr an, wenn ein altes Programm nicht startet.';

  @override
  String get svcReasonFax => 'Ohne ihn: Fax funktioniert nicht mehr.';

  @override
  String get svcReasonInsider =>
      'Ohne ihn: Windows-Insider-Vorabversionen kommen nicht mehr an.';

  @override
  String get svcReasonUpdates =>
      'Windows Update braucht ihn: Ohne ihn kommen keine Sicherheitsupdates mehr an.';

  @override
  String get svcReasonSecurity =>
      'Schützt diesen PC (Virenschutz, Firewall, Sicherheitsstatus).';

  @override
  String get svcReasonWindowsCore =>
      'Windows braucht ihn für Ton, Netzwerk, Protokolle oder Grundfunktionen.';

  @override
  String get svcReasonNotReviewed =>
      'Teil von Windows und nicht geprüft: so lassen.';

  @override
  String get svcReasonDriverService =>
      'Mit einem Treiber installiert: so lassen, außer du weißt, was er tut.';

  @override
  String get svcReasonMicrosoftApp =>
      'Gehört zu einer Microsoft-App: Ohne ihn kann diese App nicht mehr funktionieren oder sich aktualisieren.';

  @override
  String get svcReasonThirdParty =>
      'Mit einem anderen Programm installiert: Ohne ihn kann es nicht mehr funktionieren oder sich aktualisieren.';

  @override
  String get serviceStartTypeAction => 'Start ändern';

  @override
  String get presetsTab => 'Voreinstellungen';

  @override
  String get presetDebloatName => 'Nur Debloat';

  @override
  String get presetDebloatSummary =>
      'Entfernt vorinstallierte Microsoft-Apps, die kaum jemand nutzt. Sonst ändert sich nichts.';

  @override
  String get presetCleanName => 'Sauber';

  @override
  String get presetCleanSummary =>
      'Debloat plus Telemetrie- und ungenutzte Dienste aus sowie Apps, die grundlos mit Windows starten.';

  @override
  String get presetGamingName => 'Gaming';

  @override
  String get presetGamingSummary =>
      'Sauber plus Einstellungen fürs Spielen: keine Energiedrosselung laufender Apps, Task beenden in der Taskleiste. Xbox bleibt.';

  @override
  String get presetPrivacyName => 'Datenschutz';

  @override
  String get presetPrivacySummary =>
      'Sauber plus die Datenschutzeinstellungen aus Microsofts eigenem Leitfaden: Werbe-ID, Tracking, Vorschläge, Diagnosedaten auf das Minimum.';

  @override
  String get presetCompetitiveName => 'Competitive';

  @override
  String get presetCompetitiveSummary =>
      'Entfernt alles, was die anderen entfernen, und mehr: Apps, die viele nutzen, Xbox, Drucken, Launcher beim Start, Spielaufnahme. Dazu saubere Treiberinstallation und WinSux, von Hand.';

  @override
  String get presetAttention => 'Achtung';

  @override
  String get presetAttentionNote =>
      'Es entfernt viel, auch Dinge, die viele nutzen. Kein FPS-, Latenz- oder sonstiger Gewinn wird versprochen: Es ist eine Sammlung von Änderungen, keine gemessene Verbesserung.';

  @override
  String get presetGroupApps => 'Entfernte Apps (aktueller Benutzer)';

  @override
  String get presetGroupServices => 'Deaktivierte Dienste';

  @override
  String get presetGroupStartup => 'Deaktivierte Autostart-Einträge';

  @override
  String get presetGroupTweaks => 'Einstellungen';

  @override
  String get presetGroupThirdParty => 'Skripte und Tools von Drittanbietern';

  @override
  String get presetGroupRestart => 'Neustart';

  @override
  String get presetGroupReversible => 'Was rückgängig gemacht werden kann';

  @override
  String get presetRestartNeeded =>
      'Danach neu starten: Dienste und Autostart ändern sich beim nächsten Start.';

  @override
  String get presetRestartNone => 'Kein Neustart nötig.';

  @override
  String get presetReversibleApps =>
      'Apps: aus dem Microsoft Store neu installieren.';

  @override
  String get presetReversibleSettings =>
      'Dienste, Autostart und Einstellungen: direkt danach mit Voreinstellung rückgängig machen oder später mit dem vorher erstellten Wiederherstellungspunkt.';

  @override
  String get presetReversibleManual =>
      'Schritte von Drittanbietern führt ZapTweaks nicht aus: Zum Rückgängigmachen den Anweisungen des Autors folgen.';

  @override
  String get presetManualWhy =>
      'Von Hand: Das Skript lädt weitere Dateien herunter und führt sie aus, die sich nicht per Hash festlegen lassen; ZapTweaks führt es daher nicht aus.';

  @override
  String get presetManualDriverClean =>
      'Saubere Grafiktreiber-Installation: DDU im abgesicherten Modus, dann der neueste Treiber vom Hersteller.';

  @override
  String get presetManualWinsux =>
      'WinSux: Windows-Debloat und Einstellungen in einem Skript.';

  @override
  String get presetPreview => 'Vorschau auf diesem PC';

  @override
  String get presetPreviewLoading =>
      'Apps, Dienste, Autostart und Einstellungen werden gelesen…';

  @override
  String get presetStatusApply => 'Zu tun';

  @override
  String get presetStatusDone => 'Bereits gesetzt';

  @override
  String get presetStatusSkipped => 'Übersprungen';

  @override
  String get presetStatusManual => 'Von Hand';

  @override
  String get presetSkipNotInstalled => 'nicht installiert';

  @override
  String get presetSkipNotFound => 'nicht auf diesem PC';

  @override
  String get presetSkipUnsupported => 'hier nicht unterstützt';

  @override
  String get presetSkipDuplicate => 'Name doppelt: nur der erste wird geändert';

  @override
  String presetCounts(int apply, int done, int skipped) {
    return '$apply zu tun · $done bereits gesetzt · $skipped übersprungen';
  }

  @override
  String get presetConsent =>
      'Ich habe die ganze Liste gelesen und akzeptiere das Risiko.';

  @override
  String get presetApply => 'Voreinstellung anwenden';

  @override
  String get presetApplyNote =>
      'Zuerst wird ein Wiederherstellungspunkt erstellt; schlägt er fehl, ändert sich nichts. Administratoränderungen fragen einmal nach UAC.';

  @override
  String get presetApplying => 'Wird angewendet…';

  @override
  String presetReport(int ok, int failed) {
    return 'Fertig: $ok geändert, $failed nicht geändert.';
  }

  @override
  String get presetUndo => 'Voreinstellung rückgängig';

  @override
  String get presetUndone =>
      'Voreinstellung rückgängig gemacht. Entfernte Apps bleiben entfernt: aus dem Store neu installieren.';

  @override
  String get presetNothingToDo => 'Nichts zu tun: alles ist bereits gesetzt.';

  @override
  String get presetSaveAs => 'Als eigene Voreinstellung speichern';

  @override
  String get presetSaveNote =>
      'Speichert die noch markierten Einträge. Datei teilen zum Exportieren; Datei in den Ordner legen zum Importieren.';

  @override
  String get presetName => 'Name';

  @override
  String presetSaved(String path) {
    return 'Gespeichert: $path';
  }

  @override
  String get presetOpenFolder => 'Voreinstellungsordner öffnen';

  @override
  String get presetUserTitle => 'Meine Voreinstellungen';

  @override
  String presetInvalidFile(String file, String error) {
    return '$file nicht geladen: $error';
  }

  @override
  String get presetItemPowerThrottling =>
      'Energiedrosselung laufender Apps aus';

  @override
  String get presetItemEndTask => 'Task beenden im Taskleistenmenü';

  @override
  String get presetItemAdvertisingId => 'Werbe-ID aus';

  @override
  String get presetItemLanguageList =>
      'Websites können deine Sprachliste nicht lesen';

  @override
  String get presetItemAppLaunchTracking =>
      'Windows verfolgt gestartete Apps nicht';

  @override
  String get presetItemTailoredExperiences =>
      'Keine personalisierten Erlebnisse aus Diagnosedaten';

  @override
  String get presetItemCloudContent =>
      'Keine cloudoptimierten Inhalte (Vorschläge)';

  @override
  String get presetItemDiagnosticData => 'Diagnosedaten: nur erforderliche';

  @override
  String get presetItemLockScreenOverlay =>
      'Keine Tipps auf dem Sperrbildschirm';

  @override
  String get presetItemLockScreenFacts =>
      'Keine Fakten auf dem Sperrbildschirm';

  @override
  String get presetItemGameDvr => 'Spielaufnahme der Game Bar aus';

  @override
  String get presetSkipHasDependents =>
      'Andere Dienste hängen davon ab, daher lässt Windows das Deaktivieren nicht zu.';

  @override
  String get settingsGeneral => 'Allgemein';

  @override
  String get settingsModes => 'Modi';

  @override
  String get settingsMaintenance => 'Wartung';

  @override
  String get settingsAbout => 'Info';

  @override
  String get openLogFolderDescription =>
      'Sitzungsprotokolle mit jedem Befehl, den ZapTweaks ausgeführt hat.';

  @override
  String get redetectSystemStateDescription =>
      'Hardware und den Zustand jedes Tweaks erneut lesen.';

  @override
  String get profileTitle => 'Einstellungsprofil';

  @override
  String get profileDescription =>
      'ZapTweaks-Einstellungen in einer Datei speichern oder daraus laden.';

  @override
  String get resetAppSettingsDescription =>
      'Zurück zu den Standardeinstellungen von ZapTweaks. Windows wird nicht geändert.';

  @override
  String get expertModeOn => 'Ein';

  @override
  String get expertModeOff => 'Aus';
}
