// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get externalDownload => 'Download esterno';

  @override
  String get appRequirements => 'Requisiti';

  @override
  String get appWarnings => 'Avvertenze';

  @override
  String get metricUnavailable => 'N/D';

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Lingua';

  @override
  String get languageDescription => 'Scegli la lingua usata da ZapTweaks.';

  @override
  String get appearance => 'Aspetto';

  @override
  String get appearanceDescription =>
      'Segui Windows oppure usa un tema chiaro o scuro fisso per l\'app.';

  @override
  String get themeSystem => 'Predefinito Windows';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settings => 'Impostazioni';

  @override
  String get startWithWindows => 'Avvia con Windows';

  @override
  String get startWithWindowsDescription =>
      'Avvia ZapTweaks dopo l’accesso a Windows.';

  @override
  String get openLogFolder => 'Apri cartella log';

  @override
  String get redetectSystemState => 'Rileva di nuovo lo stato del sistema';

  @override
  String get exportProfile => 'Esporta profilo';

  @override
  String get importProfile => 'Importa profilo';

  @override
  String get resetAppSettings => 'Reimposta impostazioni app';

  @override
  String get updates => 'Aggiornamenti';

  @override
  String get automaticUpdateNotifications =>
      'Notifiche di aggiornamento automatiche';

  @override
  String get automaticUpdateDescription =>
      'Controlla all’avvio e mostra un indicatore. Gli aggiornamenti non vengono mai installati automaticamente.';

  @override
  String get checking => 'Controllo in corso...';

  @override
  String get checkNow => 'Controlla ora';

  @override
  String get viewRelease => 'Visualizza release';

  @override
  String get updateNow => 'Aggiorna ora';

  @override
  String get applicationVersion => 'Versione dell’applicazione';

  @override
  String get dryRunMode => 'Modalità simulazione';

  @override
  String get dryRunDescription => 'Simula i comandi senza modificare Windows.';

  @override
  String get done => 'Completato';

  @override
  String get operationFailed => 'Operazione non riuscita';

  @override
  String get updateAvailable => 'È disponibile un aggiornamento';

  @override
  String get updateAvailableDescription =>
      'Puoi consultare le note di rilascio o installarlo direttamente.';

  @override
  String get updateAvailableShort => 'Aggiornamento disponibile';

  @override
  String get checkingForUpdates => 'Controllo degli aggiornamenti';

  @override
  String get contactingReleaseServer => 'Contatto con il server di rilascio...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version è disponibile';
  }

  @override
  String installedVersion(Object version) {
    return 'Versione installata: $version';
  }

  @override
  String get releaseNotesOnGitHub =>
      'Le note sulla versione sono disponibili su GitHub.';

  @override
  String get later => 'Più tardi';

  @override
  String get failed => 'Fallito';

  @override
  String get downloadingUpdate => 'Download dell\'aggiornamento';

  @override
  String get downloadingUpdateDescription =>
      'Download e preparazione del programma di installazione in corso...';

  @override
  String get adminPrivilegesRequired =>
      'Sono richiesti i privilegi di amministratore';

  @override
  String get adminRequiredBanner =>
      'Chiudi l\'app e avvia ZapTweaks con \"Esegui come amministratore\". Senza elevazione, le modifiche al sistema non possono essere applicate in modo sicuro.';

  @override
  String get cancel => 'Annulla';

  @override
  String get createRestorePoint => 'Crea punto di ripristino';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks necessita delle autorizzazioni di amministratore per applicare le impostazioni di sistema.\n\nChiudi l\'app, fai clic con il pulsante destro del mouse sull\'eseguibile e seleziona \"Esegui come amministratore\".';

  @override
  String get understood => 'Capito';

  @override
  String aboutVersion(Object version) {
    return 'Versione: v$version';
  }

  @override
  String get author => 'Autore: PrimeBuild';

  @override
  String get aboutDescription =>
      'Compagno di ottimizzazione avanzato per flussi di lavoro di diagnostica, hardware e giochi Windows più approfonditi.';

  @override
  String year(Object year) {
    return 'Anno: $year';
  }

  @override
  String get close => 'Chiudi';

  @override
  String get github => 'GitHub';

  @override
  String get discord => 'Discord';

  @override
  String get homeAndStats => 'Home e statistiche';

  @override
  String get cpuUsage => 'Utilizzo della CPU';

  @override
  String get cpuUsageDescription =>
      'Utilizzo in tempo reale dai contatori di Windows';

  @override
  String get gpuUsage => 'Utilizzo della GPU';

  @override
  String get gpuUsageDescription => 'Utilizzo del motore in tempo reale';

  @override
  String get vramUsage => 'Utilizzo della VRAM';

  @override
  String get memoryUsage => 'Utilizzo della memoria';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get installedRam => 'RAM installata';

  @override
  String get networkAdapters => 'Adattatori di rete';

  @override
  String get noConnectedAdapters => 'Nessun adattatore collegato rilevato';

  @override
  String get audioDevices => 'Dispositivi audio';

  @override
  String get noAudioDevices => 'Nessun dispositivo audio rilevato';

  @override
  String get noTweaksAvailable =>
      'Non sono disponibili modifiche per la configurazione hardware.';

  @override
  String get detectedHardware => 'Hardware rilevato';

  @override
  String get gpuUnknown => 'GPU: sconosciuta';

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
  String get enableAllVisible => 'Abilita tutte le voci visibili';

  @override
  String get disableAllVisible => 'Disabilita tutte le voci visibili';

  @override
  String get restartNow => 'Riavvia ora';

  @override
  String get restartRequired => 'È necessario riavviare';

  @override
  String get restartRequiredDescription =>
      'Per applicare completamente una o più modifiche è necessario il riavvio del sistema.';

  @override
  String get advancedActionsIncluded => 'Azioni avanzate incluse';

  @override
  String get advancedActionsDescription =>
      'Strumenti esterni, azioni di avvio e utilità basate su script sono raggruppati qui per flussi di lavoro di diagnostica e manutenzione rapidi.';

  @override
  String get aggressiveTweakWarning =>
      'Modifica aggressiva. Un punto di ripristino è consigliato.';

  @override
  String get networkReconnectWarning =>
      'Potrebbe essere necessaria la riconnessione dell\'adattatore di rete o il riavvio del sistema.';

  @override
  String get actionWarning => 'Avviso di azione';

  @override
  String get unknownError => 'Errore sconosciuto.';

  @override
  String get presets => 'Preimpostazioni';

  @override
  String get presetFailed => 'La preimpostazione non è riuscita';

  @override
  String get safetyWarning => 'Avviso di sicurezza';

  @override
  String get unavailable => 'Non disponibile';

  @override
  String get powerPlans => 'Power Settings Explorer';

  @override
  String get powerPlansDescription =>
      'Importa e attiva un piano in bundle. ZapTweaks ricorda il precedente piano attivo per il ripristino.';

  @override
  String get noPowerPlans =>
      'Non è stato trovato alcun piano di alimentazione incluso.';

  @override
  String get working => 'Operazione in corso...';

  @override
  String get importAndActivate => 'Importa e attiva';

  @override
  String get restorePreviousPlan => 'Ripristina il piano precedente';

  @override
  String get ran => 'Eseguito';

  @override
  String get gpuDrivers => 'Driver GPU';

  @override
  String get noGpuDrivers => 'Nessun driver GPU rilevato';

  @override
  String get chipsetDrivers => 'Driver chipset';

  @override
  String get noChipsetDrivers => 'Nessun driver chipset rilevato';

  @override
  String get monitors => 'Monitor';

  @override
  String get noMonitors => 'Nessun monitor rilevato';

  @override
  String get mice => 'Mouse';

  @override
  String get noMice => 'Nessun mouse rilevato';

  @override
  String get keyboards => 'Tastiere';

  @override
  String get noKeyboards => 'Nessuna tastiera rilevata';

  @override
  String get restorePointPromptTitle => 'Creare un punto di ripristino?';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks può creare un punto di ripristino di Windows prima di modificare le impostazioni di sistema. È facoltativo: se lo salti la modifica viene applicata comunque. La richiesta compare una sola volta per sessione.';

  @override
  String get skip => 'Salta';

  @override
  String get continueAction => 'Continua';

  @override
  String get tweaksSectionHeader => 'TWEAK';

  @override
  String get startingUp => 'Avvio di ZapTweaks';

  @override
  String get expertMode => 'Modalità esperto';

  @override
  String get expertModeDescription =>
      'Mostra operazioni avanzate e tool esterni solo dopo consenso manuale esplicito. È disattivata per impostazione predefinita; le restrizioni di sicurezza restano attive.';

  @override
  String get searchOperations => 'Cerca operazioni';

  @override
  String get searchResults => 'Risultati della ricerca';

  @override
  String get searchSections => 'Sezioni e strumenti integrati';

  @override
  String get searchApps => 'Cerca app';

  @override
  String get searchCatalog => 'Operazioni e strumenti esterni';

  @override
  String get searchOpenResult => 'Apri';

  @override
  String get searchExpertRequired => 'Abilita la modalità Esperto per aprire';

  @override
  String get noSearchResults =>
      'Nessuna sezione, app, operazione o strumento corrispondente';

  @override
  String get operationTaskbarEndTaskTitle => 'Termina attività dalla barra';

  @override
  String get operationTaskbarEndTaskDescription =>
      'Mostra Termina attività nei menu contestuali delle app sulla barra delle applicazioni.';

  @override
  String get appStore => 'Store delle app';

  @override
  String get appManagement => 'App installate';

  @override
  String get windowsAppTools => 'Strumenti app Windows';

  @override
  String get optionalFeatures => 'Funzionalità facoltative';

  @override
  String get searchOptionalFeatures => 'Cerca funzionalità facoltative';

  @override
  String get scanOptionalFeatures => 'Analizza funzionalità (UAC)';

  @override
  String get optionalFeaturesUacNotice =>
      'L’inventario e ogni modifica passano attraverso l’helper con allowlist. La scansione non applica modifiche.';

  @override
  String get confirmOptionalFeatureChange => 'Conferma modifica funzionalità';

  @override
  String confirmOptionalFeatureChangeMessage(Object name, Object action) {
    return 'Funzionalità: $name\nAzione: $action\n\nWindows potrebbe richiedere un riavvio. Lo stato di attivazione precedente viene acquisito prima della modifica.';
  }

  @override
  String get enable => 'Attiva';

  @override
  String get disable => 'Disattiva';

  @override
  String get enabled => 'Attiva';

  @override
  String get disabled => 'Disattivata';

  @override
  String get enablePending => 'Attivazione in attesa di riavvio';

  @override
  String get disablePending => 'Disattivazione in attesa di riavvio';

  @override
  String get startupApps => 'App di avvio';

  @override
  String get searchStartupApps => 'Cerca app di avvio';

  @override
  String get openStartupSettings => 'Apri Impostazioni di avvio';

  @override
  String get openTaskManagerStartup => 'Apri Avvio in Gestione attività';

  @override
  String get startupInventoryNotice =>
      'Inventario di sola lettura. Usa Impostazioni di Windows o Gestione attività per modificare una voce.';

  @override
  String get guidedSetup => 'Configurazione guidata';

  @override
  String get wizardInventory => 'Inventario';

  @override
  String get wizardBaseline => 'Baseline';

  @override
  String get wizardWindowsUpdate => 'Windows Update';

  @override
  String get wizardDrivers => 'Controllo driver';

  @override
  String get wizardApplications => 'Applicazioni';

  @override
  String get wizardDebloat => 'Debloat selettivo';

  @override
  String get wizardPrivacyInterface => 'Privacy e interfaccia';

  @override
  String get wizardPreview => 'Anteprima piano';

  @override
  String get wizardApply => 'Applicazione';

  @override
  String get wizardReport => 'Report finale';

  @override
  String get wizardInventoryDescription =>
      'Legge hardware, pacchetti winget installati e dispositivi presenti prima di effettuare scelte.';

  @override
  String get runInventory => 'Esegui inventario';

  @override
  String inventorySummary(Object apps, Object devices) {
    return 'Rilevati $apps pacchetti winget e $devices dispositivi presenti.';
  }

  @override
  String get wizardUpdateNotice =>
      'Controlla Windows Update prima di modificare driver e app. ZapTweaks non installa aggiornamenti automaticamente.';

  @override
  String get openWindowsUpdate => 'Apri Windows Update';

  @override
  String get updatesReviewed => 'Ho controllato Windows Update';

  @override
  String driverInventorySummary(Object devices, Object missing) {
    return 'Dispositivi presenti: $devices\nDispositivi senza INF associato: $missing';
  }

  @override
  String get wizardDebloatNotice =>
      'Nessuna scelta di debloat è implicita. Qui sono selezionabili solo pacchetti AppX dell’utente corrente con fonte di ripristino verificata; le altre rimozioni restano in App → App installate con anteprima separata.';

  @override
  String get wizardPrivacyNotice =>
      'Le impostazioni di privacy e interfaccia restano invariate, salvo le selezioni esplicite qui sotto.';

  @override
  String get noAppsSelected =>
      'Nessuna operation selezionata. Il wizard non applicherà modifiche.';

  @override
  String planContains(Object count) {
    return 'Il piano contiene $count operation esplicite:';
  }

  @override
  String readyToApply(Object count) {
    return 'Pronto ad applicare $count operation sulle app. Ogni pacchetto viene verificato al termine di winget.';
  }

  @override
  String get noPlanReport => 'Terminato senza applicare un piano.';

  @override
  String get planStatus => 'Stato piano';

  @override
  String get applyPlan => 'Applica piano';

  @override
  String get back => 'Indietro';

  @override
  String get finish => 'Fine';

  @override
  String get recovery => 'Ripristino';

  @override
  String get diagnosticTools => 'Strumenti diagnostici';

  @override
  String get repairComponentStore => 'Ripara l\'archivio componenti di Windows';

  @override
  String get repairComponentStoreDescription =>
      'Esegue DISM RestoreHealth e poi una verifica ScanHealth separata. Può richiedere molto tempo.';

  @override
  String get repairSystemFiles => 'Ripara i file di sistema protetti';

  @override
  String get repairSystemFilesDescription =>
      'Esegue scansione e riparazione SFC, seguite da una verifica separata.';

  @override
  String get confirmSystemRepair => 'Conferma riparazione Windows';

  @override
  String get systemRepairWarning =>
      'La riparazione può sostituire componenti Windows danneggiati e non può essere annullata da ZapTweaks. Non spegnere il PC durante l\'esecuzione.';

  @override
  String get systemRepairVerified =>
      'Riparazione completata e verifica superata.';

  @override
  String get runRepair => 'Esegui riparazione';

  @override
  String get operationCompleted => 'Operazione completata';

  @override
  String get captureEtwTrace => 'Acquisisci traccia prestazioni';

  @override
  String get captureEtwTraceDescription =>
      'Registra su richiesta una traccia Windows Performance Recorder limitata e produce un report diagnostico DPC/ISR. Nessun monitor resta attivo.';

  @override
  String get dpcLatencyAnalyzer => 'Analizzatore latenza DPC / ISR';

  @override
  String get dpcLatencyAnalyzerDescription =>
      'Acquisisce ETW su richiesta e mostra attività DPC, ISR, hard fault e context switch, distribuzione per processore, moduli kernel osservati e provider ETW.';

  @override
  String get diagnosticNotCausality =>
      'Segnale diagnostico, non un verdetto sulla latenza';

  @override
  String get diagnosticNotCausalityDescription =>
      'Conteggi e moduli osservati aiutano l’indagine ma non provano che un driver causi latenza. Conferma con tracce A/B/A ripetibili e WPA o strumenti del produttore.';

  @override
  String get startDpcCapture => 'Avvia acquisizione';

  @override
  String get openTraceFolder => 'Apri cartella tracce';

  @override
  String captureInProgress(int seconds) {
    return 'Acquisizione per $seconds secondi… mantieni attivo il carico di lavoro.';
  }

  @override
  String get traceDuration => 'Durata osservata';

  @override
  String get hardFaults => 'Hard fault';

  @override
  String get contextSwitches => 'Context switch';

  @override
  String get totalEvents => 'Eventi ETW totali';

  @override
  String get kernelModulesObserved =>
      'Moduli kernel osservati negli eventi DPC/ISR';

  @override
  String get noKernelModulesObserved =>
      'Gli eventi esportati non espongono nomi di moduli kernel. Apri l’ETL in WPA per l’analisi con simboli.';

  @override
  String get dpcIsrByProcessor => 'Eventi DPC/ISR per processore logico';

  @override
  String get noProcessorDistribution =>
      'Gli ID processore non erano presenti negli eventi esportati.';

  @override
  String get topEtwProviders => 'Provider ETW principali';

  @override
  String get noProviderData => 'Nessun dato provider disponibile.';

  @override
  String etwTraceSaved(Object path) {
    return 'Traccia salvata in $path';
  }

  @override
  String get cleanupDiagnosticTraces => 'Elimina tracce diagnostiche';

  @override
  String get cleanupDiagnosticTracesDescription =>
      'Analizza solo le tracce di ZapTweaks, mostra il numero esatto di file e byte e le elimina dopo conferma.';

  @override
  String cleanupTracePreview(int count, int bytes) {
    return 'Eliminare $count file di traccia ZapTweaks ($bytes byte)? L\'operazione non può essere annullata.';
  }

  @override
  String get cleanupTracesCompleted =>
      'Le tracce diagnostiche mostrate nell\'anteprima sono state eliminate e verificate come assenti.';

  @override
  String get noDiagnosticTraces =>
      'Nessuna traccia diagnostica di ZapTweaks trovata.';

  @override
  String get hardwareMonitor => 'Monitor hardware';

  @override
  String get dedicatedVramUsage => 'Memoria GPU dedicata in uso';

  @override
  String get dedicatedVramUsageDescription =>
      'Acquisisce una singola lettura dai contatori prestazioni GPU di Windows. Al termine non resta attivo nulla.';

  @override
  String vramUsageValue(Object megabytes) {
    return '$megabytes MB';
  }

  @override
  String get captureNow => 'Acquisisci ora';

  @override
  String get tweaks => 'Ottimizzazioni';

  @override
  String get searchPowerPlans => 'Cerca piani di alimentazione';

  @override
  String get activePowerPlan => 'Attivo';

  @override
  String get activate => 'Attiva';

  @override
  String get details => 'Dettagli';

  @override
  String get compare => 'Confronta';

  @override
  String get noPowerDifferences =>
      'Non sono state trovate differenze nei valori AC/DC.';

  @override
  String get importPowerPlan => 'Importa .pow';

  @override
  String get importPowerPlanDescription =>
      'Importa un piano locale dopo staging limitato e verificato tramite hash.';

  @override
  String get exportActivePowerPlan => 'Esporta piano attivo';

  @override
  String get restoreDefaultPowerSchemes => 'Ripristina predefiniti Windows';

  @override
  String get restoreDefaultPowerSchemesDescription =>
      'Esporta e verifica tramite hash ogni piano corrente prima di ripristinare i predefiniti Windows.';

  @override
  String get restoreDefaultPowerSchemesWarning =>
      'Sostituire tutti i piani correnti con quelli predefiniti di Windows? ZapTweaks esporterà prima ogni piano per il rollback esatto.';

  @override
  String get interruptConfiguration => 'MSI Utility v3 e affinità interrupt';

  @override
  String get interruptConfigurationDescription =>
      'Controlli avanzati con capability gate per MSI e affinità interrupt del gruppo 0, limitati ai dispositivi display, rete, media, controller host USB e audio HD presenti. Nessun valore viene consigliato automaticamente.';

  @override
  String get configureMsi => 'Configura MSI';

  @override
  String get enableMsi => 'Abilita interrupt message-signaled';

  @override
  String get configureInterruptAffinity => 'Configura affinità';

  @override
  String get interruptChangeWarning =>
      'Una policy interrupt non valida può rendere il dispositivo indisponibile fino al rollback o al riavvio. ZapTweaks convalida i limiti hardware e salva i valori correnti esatti.';

  @override
  String get affinityMaskHint => 'Maschera esadecimale gruppo 0, ad esempio 3';

  @override
  String get invalidAffinityMask =>
      'Inserisci una maschera esadecimale canonica non nulla di massimo 64 bit.';

  @override
  String msiRange(int maximum) {
    return 'Il numero di messaggi deve essere compreso tra 1 e $maximum.';
  }

  @override
  String get noCompatibleInterruptDevices =>
      'Nessun dispositivo PCI display, rete, media, controller host USB o audio HD presente espone capability interrupt compatibili.';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return 'Hardware: Line $line · MSI $msi · MSI-X $msix · messaggi massimi $maximum';
  }

  @override
  String get messageNumberLimit => 'Limite numero messaggi';

  @override
  String get interruptPriority => 'Policy priorità interrupt';

  @override
  String get interruptPriorityDefault => 'Non definita / predefinita driver';

  @override
  String get interruptPriorityLow => 'Bassa';

  @override
  String get interruptPriorityNormal => 'Normale';

  @override
  String get interruptPriorityHigh => 'Alta';

  @override
  String get interruptPolicy => 'Policy affinità processori';

  @override
  String get interruptPolicyDefault => 'Predefinita macchina';

  @override
  String get interruptPolicyAllClose => 'Tutti i processori vicini';

  @override
  String get interruptPolicyOneClose => 'Un processore vicino';

  @override
  String get interruptPolicyAllProcessors => 'Tutti i processori';

  @override
  String get interruptPolicySpecified => 'Processori specificati (gruppo 0)';

  @override
  String get interruptPolicySpread => 'Distribuisci messaggi tra i processori';

  @override
  String get selectLogicalProcessors =>
      'Seleziona processori logici nel gruppo 0';

  @override
  String get affinitySelectAll => 'Tutti i processori logici';

  @override
  String get affinityClear => 'Deseleziona';

  @override
  String get affinityPhysicalCores => 'Un thread per core fisico';

  @override
  String get affinityPerformanceCores => 'Performance core';

  @override
  String get affinityEfficiencyCores => 'Efficiency core';

  @override
  String get affinityParked => 'parcheggiato';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'Nodo NUMA $index';
  }

  @override
  String get compatibleDevices => 'Dispositivi compatibili';

  @override
  String get msiEnabledDevices => 'MSI attualmente attivo';

  @override
  String get logicalProcessors => 'Processori logici';

  @override
  String get searchDevices => 'Cerca dispositivi, Instance ID o INF driver';

  @override
  String get driverUnknown => 'INF driver non disponibile';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return 'Attuale: $mode · messaggi $messages · priorità $priority · policy $policy · maschera $mask';
  }

  @override
  String get renamePowerPlan => 'Rinomina piano di alimentazione';

  @override
  String get renamePowerPlanDescription =>
      'Modifica solo il nome visualizzato del piano selezionato e conserva quello originale per il rollback.';

  @override
  String get rename => 'Rinomina';

  @override
  String get duplicate => 'Duplica';

  @override
  String get duplicatePowerPlan => 'Duplica piano di alimentazione';

  @override
  String get duplicatePowerPlanDescription =>
      'Crea e verifica una copia PowrProf. Il rollback è best effort perché Windows assegna il GUID durante la creazione.';

  @override
  String get apply => 'Applica';

  @override
  String get edit => 'Modifica';

  @override
  String powerValueRange(int maximum) {
    return 'I valori devono essere compresi tra 0 e $maximum.';
  }

  @override
  String get powerSettingConfigure =>
      'Configura qualsiasi power setting con limiti noti';

  @override
  String get powerSettingConfigureDescription =>
      'Modifica un setting esposto da PowrProf solo quando Windows fornisce minimo, massimo e incremento live.';

  @override
  String get searchPowerSettings => 'Cerca setting, descrizioni, gruppi o GUID';

  @override
  String get allPowerSubgroups => 'Tutti i gruppi power setting';

  @override
  String powerSettingCount(int count) {
    return '$count setting';
  }

  @override
  String powerSettingOptions(int count) {
    return '$count opzioni definite da Windows';
  }

  @override
  String get backToPowerPlans => 'Torna ai piani di alimentazione';

  @override
  String get powerPlanEditorHint =>
      'Duplica un piano per creare il tuo profilo personalizzato, quindi apri Dettagli e modifica uno per uno i setting AC/DC nascosti.';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Intervallo $minimum–$maximum, incremento $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows non ha esposto valori o limiti di modifica sicuri per questo setting.';

  @override
  String get delete => 'Elimina';

  @override
  String get deletePowerPlan => 'Elimina piano di alimentazione';

  @override
  String get deletePowerPlanDescription =>
      'Esporta il piano inattivo selezionato prima di eliminarlo e conserva il backup per il rollback esatto.';

  @override
  String deletePowerPlanWarning(Object name) {
    return 'Eliminare $name? ZapTweaks esporterà prima una copia di ripristino.';
  }

  @override
  String get firmwareTemperatures => 'Zone termiche firmware';

  @override
  String get firmwareTemperaturesDescription =>
      'Legge una volta le zone termiche ACPI. Disponibilità e significato dei sensori dipendono dal firmware; i valori non sono indicati come temperature CPU o GPU.';

  @override
  String get noThermalSensors => 'Questo PC non espone zone termiche ACPI.';

  @override
  String get cpuFrequency => 'Clock CPU e core parking';

  @override
  String get cpuFrequencyDescription =>
      'Legge una volta i contatori di prestazione del processore di Windows. Il clock effettivo è il clock base × % Prestazioni processore, la stessa formula di Gestione attività. Serve a verificare piano energetico, boost e core parking. Sola lettura.';

  @override
  String cpuEffectiveClock(Object mhz, Object nominal) {
    return '$mhz MHz effettivi · base $nominal MHz';
  }

  @override
  String cpuParkedCount(Object parked, Object total) {
    return '$parked processori logici su $total parcheggiati';
  }

  @override
  String get cpuParked => 'parcheggiato';

  @override
  String get cpuFrequencySource =>
      'Fonte: contatori di prestazione Processor Information (Win32_PerfFormattedData_Counters_ProcessorInformation), un campione mediato sull\'ultimo intervallo del contatore. Non è il clock di picco. I valori per core usano un solo clock nominale, quindi sui CPU ibridi i core efficienti risultano più alti.';

  @override
  String get driverInventory => 'Inventario Driver Store';

  @override
  String get installLocalDriver => 'Installa un pacchetto driver locale';

  @override
  String get installLocalDriverDescription =>
      'Verifica un INF locale, il catalogo firmato e la compatibilità hardware prima dell\'installazione.';

  @override
  String get selectDevice => 'Seleziona un dispositivo presente';

  @override
  String get localInfPath => 'Percorso assoluto del file .inf locale';

  @override
  String get verifyDriverPackage => 'Verifica pacchetto';

  @override
  String verifiedDriverPublisher(Object publisher, Object sha256) {
    return 'Autore verificato: $publisher\nSHA-256 INF: $sha256';
  }

  @override
  String get confirmLocalDriverInstall =>
      'Conferma installazione driver locale';

  @override
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  ) {
    return 'Dispositivo: $device\nAutore firmato: $publisher\nSHA-256 INF: $sha256\n\nWindows potrebbe cambiare il driver attivo e richiedere un riavvio. Il rollback è best effort.';
  }

  @override
  String get driverTools => 'Flussi assistiti';

  @override
  String get temporaryDriverUpdatesPause =>
      'Escludi temporaneamente i driver dagli aggiornamenti qualitativi di Windows';

  @override
  String get temporaryDriverUpdatesPauseDescription =>
      'Usa la policy documentata di Windows Update per 7 o 30 giorni. ZapTweaks registra il valore precedente esatto e mostra un promemoria alla scadenza; il ripristino richiede la tua conferma.';

  @override
  String get driverUpdatePolicy => 'Policy driver di Windows Update';

  @override
  String get driverUpdatePolicyDescription =>
      'Esclude i driver dei dispositivi dagli aggiornamenti qualitativi di Windows per 7 giorni, 30 giorni o finché non ripristini esplicitamente la policy precedente esatta.';

  @override
  String get disableUntilRestored => 'Disabilita fino al ripristino';

  @override
  String get driverUpdatePausePermanent =>
      'Gli aggiornamenti driver restano esclusi finché non ripristini la policy precedente.';

  @override
  String get driverUpdatePauseActive =>
      'Sospensione aggiornamenti driver attiva';

  @override
  String get driverUpdatePauseExpired =>
      'Sospensione scaduta — ripristina la policy precedente';

  @override
  String driverUpdatePauseUntil(Object date) {
    return 'Scadenza prevista: $date';
  }

  @override
  String get pauseSevenDays => 'Sospendi per 7 giorni';

  @override
  String get pauseThirtyDays => 'Sospendi per 30 giorni';

  @override
  String get restoreDriverUpdates => 'Ripristina policy precedente';

  @override
  String get assistedDriverFlows => 'Flussi driver verificati e assistiti';

  @override
  String get assistedDriverFlowsDescription =>
      'ZapTweaks apre solo fonti dei produttori e superfici Windows. Non esegue script remoti mutabili, non aggiorna firmware e non rimuove componenti driver di nascosto.';

  @override
  String get amdDriverFlow => 'Driver e software AMD';

  @override
  String get amdDriverFlowDescription =>
      'Apre il selettore driver ufficiale AMD. Verifica il prodotto rilevato prima del download.';

  @override
  String get nvidiaDriverFlow => 'Driver NVIDIA';

  @override
  String get nvidiaDriverFlowDescription =>
      'Apre la ricerca manuale ufficiale NVIDIA. L\'installazione pulita resta una scelta esplicita nell\'installer del produttore.';

  @override
  String get intelDriverFlow => 'Intel Driver & Support Assistant';

  @override
  String get intelDriverFlowDescription =>
      'Apre il flusso ufficiale Intel di rilevamento e supporto.';

  @override
  String get windowsOptionalDrivers =>
      'Aggiornamenti driver facoltativi di Windows';

  @override
  String get windowsOptionalDriversDescription =>
      'Rivedi gli aggiornamenti driver facoltativi nelle Impostazioni di Windows; nulla viene selezionato automaticamente.';

  @override
  String get deviceManager => 'Gestione dispositivi';

  @override
  String get deviceManagerDescription =>
      'Ispeziona dispositivi, codici di stato, driver attivi e opzioni di rollback manuale.';

  @override
  String get openOfficialSource => 'Apri fonte ufficiale';

  @override
  String get openWindowsPanel => 'Apri pannello Windows';

  @override
  String get searchDrivers => 'Cerca nel Driver Store';

  @override
  String get driverStoreSafetyNotice =>
      'Qui si possono rimuovere solo pacchetti di terze parti firmati e non associati. ZapTweaks esporta e verifica gli hash prima della rimozione; il ripristino è best effort perché Windows può assegnare un nome pubblicato diverso.';

  @override
  String get signed => 'Firmato';

  @override
  String get unsigned => 'Non firmato';

  @override
  String get driverInUse => 'In uso';

  @override
  String get driverUnbound => 'Non associato';

  @override
  String get exportAndRemove => 'Esporta e rimuovi';

  @override
  String get confirmDriverRemoval => 'Conferma rimozione dal Driver Store';

  @override
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  ) {
    return 'Nome pubblicato: $published\nINF originale: $inf\nAutore: $publisher\nVersione: $version\n\nZapTweaks esporterà il pacchetto e ne verificherà gli hash prima della rimozione. Potrebbe essere necessario un riavvio; il ripristino è best effort.';
  }

  @override
  String get searchInstalledApps => 'Cerca nelle app installate';

  @override
  String get scanAllUsers => 'Analizza tutti gli utenti (UAC)';

  @override
  String get systemScopesComplete =>
      'Sono inclusi gli scope AppX per tutti gli utenti e provisioned.';

  @override
  String get systemScopesIncomplete =>
      'Solo inventario utente corrente e winget. Analizza tutti gli utenti per includere gli scope AppX di sistema.';

  @override
  String get currentUser => 'Utente corrente';

  @override
  String get allUsers => 'Tutti gli utenti';

  @override
  String get provisioned => 'Provisioned';

  @override
  String get confirmAppxRemoval => 'Conferma rimozione AppX';

  @override
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  ) {
    return 'App: $name\nIdentità: $id\nScope: $scope\nRipristino: $recovery\n\nVerrà rimosso solo lo scope indicato. Questa operazione non dispone di rollback esatto.';
  }

  @override
  String get reinstallable => 'Fonte di ripristino verificata disponibile';

  @override
  String get notReinstallable => 'Nessuna fonte di ripristino verificata';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String get installedOnly => 'Solo installate';

  @override
  String get refreshInventory => 'Aggiorna inventario';

  @override
  String get install => 'Installa';

  @override
  String get uninstall => 'Disinstalla';

  @override
  String get uninstallSelected => 'Disinstalla selezionate';

  @override
  String get openOfficialPage => 'Apri pagina ufficiale';

  @override
  String get installed => 'Installata';

  @override
  String get notInstalled => 'Non installata';

  @override
  String get appInventoryUnavailable =>
      'Il rilevamento delle app installate non è disponibile.';

  @override
  String get confirmBulkUninstall => 'Conferma disinstallazione multipla';

  @override
  String confirmBulkUninstallMessage(Object apps) {
    return 'Le seguenti app verranno disinstallate:\n\n$apps';
  }

  @override
  String get appCatalogSources =>
      'Catalogo unificato da revisioni bloccate di CTT WinUtil, candidati Winhance clean-room, TweakHub e fonti ufficiali richieste.';

  @override
  String get tcpOptimizer => 'TCP Optimizer';

  @override
  String get tcpOptimizerDescription =>
      'Ispeziona e configura i template TCP di Windows, gli offload globali, il QoS per applicazione e diagnostiche di rete ripetibili.';

  @override
  String get tcpNoRecommendation =>
      'Nessun valore viene consigliato automaticamente. Il read-back o un singolo test di rete non dimostrano un beneficio prestazionale.';

  @override
  String get tcpLiveState => 'Stato TCP live';

  @override
  String get tcpTemplates => 'Template TCP';

  @override
  String get tcpGlobal => 'Offload TCP globali';

  @override
  String get tcpAutotuning => 'Autotuning della finestra di ricezione';

  @override
  String get tcpHeuristics => 'Euristiche di scaling della finestra';

  @override
  String get tcpEcn => 'Capacità ECN';

  @override
  String get tcpCongestion => 'Controllo della congestione';

  @override
  String get tcpRsc => 'Receive segment coalescing (RSC)';

  @override
  String get tcpRss => 'Receive-side scaling (RSS) globale';

  @override
  String get tcpConfigure => 'Configura';

  @override
  String get tcpChangePreview => 'Anteprima modifica TCP';

  @override
  String get tcpCurrentValue => 'Valore attuale';

  @override
  String get tcpNewValue => 'Nuovo valore';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks acquisirà lo snapshot esatto del valore corrente, applicherà con una sola richiesta UAC, eseguirà il read-back, registrerà l\'operazione e manterrà il rollback esatto.';

  @override
  String get tcpUnsupported => 'Non esposto da questa build di Windows';

  @override
  String get tcpAdapterRss => 'Apri i controlli RSS per adattatore';

  @override
  String get rssAdapterState => 'Stato RSS per adattatore';

  @override
  String get rssEnabled => 'RSS abilitato';

  @override
  String get rssProfile => 'Profilo RSS';

  @override
  String get rssQueuesProcessors => 'Code/processori';

  @override
  String get tcpSettingOperationTitle => 'Configura impostazione TCP';

  @override
  String get tcpSettingOperationDescription =>
      'Modifica un solo valore capability-gated di un template TCP o offload globale di Windows con rollback esatto.';

  @override
  String get qosPolicies => 'Policy QoS per applicazione';

  @override
  String get qosDescription =>
      'Crea policy QoS persistenti ed esplicite per un eseguibile. Le policy esistenti non create da ZapTweaks restano in sola lettura.';

  @override
  String get qosCreate => 'Crea policy';

  @override
  String get qosEdit => 'Modifica';

  @override
  String get qosDelete => 'Elimina';

  @override
  String get qosName => 'Nome policy';

  @override
  String get qosAppPath => 'Percorso eseguibile';

  @override
  String get qosProtocol => 'Protocollo';

  @override
  String get qosSourcePort => 'Porta sorgente (facoltativa)';

  @override
  String get qosDestinationPort => 'Porta destinazione (facoltativa)';

  @override
  String get qosDscp => 'DSCP 0–63 (facoltativo)';

  @override
  String get qosThrottleMbps => 'Limite Mbit/s (facoltativo)';

  @override
  String get qosOwnedOnly =>
      'I nomi devono iniziare con “ZapTweaks - ”. Viene modificata solo la policy selezionata; le altre policy QoS non vengono mai cancellate.';

  @override
  String get qosDeleteConfirm =>
      'Eliminare la policy QoS selezionata? Il suo stato esatto viene salvato nel journal ZapTweaks per il rollback.';

  @override
  String get qosReadOnly => 'Sola lettura';

  @override
  String get qosPolicyOperationTitle => 'Configura QoS per applicazione';

  @override
  String get qosPolicyOperationDescription =>
      'Crea, modifica o rimuove una sola policy QoS persistente e validata per applicazione con rollback esatto.';

  @override
  String get networkDiagnostics => 'Diagnostica prima/dopo';

  @override
  String get networkDiagnosticsDescription =>
      'Misura latenza di connessione TCP, jitter, perdita e throughput download HTTPS con limiti definiti. I risultati sono evidenza diagnostica, non un consiglio.';

  @override
  String get diagnosticEndpoint => 'URL diretto HTTPS del file di test';

  @override
  String get diagnosticNetworkCost =>
      'Il test scarica al massimo 10 MiB dall\'endpoint inserito. Non è integrato alcun endpoint di terze parti.';

  @override
  String get diagnosticBaseline => 'Esegui baseline';

  @override
  String get diagnosticComparison => 'Esegui confronto';

  @override
  String get diagnosticCancel => 'Annulla misurazione';

  @override
  String get diagnosticLatency => 'Latenza';

  @override
  String get diagnosticJitter => 'Jitter';

  @override
  String get diagnosticPacketLoss => 'Perdita pacchetti';

  @override
  String get diagnosticThroughput => 'Throughput';

  @override
  String get diagnosticRawSamples => 'Campioni latenza grezzi';

  @override
  String get diagnosticDownloadedBytes => 'Byte scaricati';

  @override
  String get diagnosticDifference => 'Differenza B − A';

  @override
  String get tcpAttribution =>
      'Ispirato a WINSPAR — powplowdevs (revisione bloccata)';

  @override
  String get openRecoveryHistory => 'Apri ripristino e journal';

  @override
  String get manualRestoreTitle => 'Ripristina impostazioni manuali originali';

  @override
  String get manualRestoreWarning =>
      'Ripristina gli originali registrati, non valori predefiniti. Le impostazioni modificate nel frattempo non vengono sovrascritte. Quelle ad alto rischio richiedono Expert e UAC. Controlla il journal dopo il ripristino; restano validi gli avvisi su riavvio o disconnessione.';

  @override
  String get cleanupUserTemp => 'Pulizia UserTemp';

  @override
  String get cleanupUserTempDescription =>
      'Esamina e scegli file precisi nella cartella Temp dell\'utente corrente. Nessuna preselezione, eliminazione forzata o rimozione di cartelle.';

  @override
  String get cleanupSelectFiles => 'Anteprima e selezione file';

  @override
  String get cleanupShaderCache => 'Pulizia della cache shader GPU';

  @override
  String get cleanupShaderCacheDescription =>
      'Mostra in anteprima le cache shader DirectX, AMD, NVIDIA e Intel dell\'utente corrente cartella per cartella, ed elimina esattamente i file trovati dall\'anteprima. Il driver le ricrea, quindi il primo avvio di ogni gioco può avere qualche scatto. Chiudi prima i giochi. Non reversibile.';

  @override
  String get cleanupShaderCacheNone =>
      'Nessun file di cache shader GPU trovato.';

  @override
  String get cleanupShaderCacheCompleted =>
      'I file di cache shader mostrati nell\'anteprima sono stati eliminati e ne è stata verificata l\'assenza.';

  @override
  String get cleanupPreview => 'Anteprima';

  @override
  String get cleanupUserTempNone => 'Nessun file UserTemp trovato.';

  @override
  String get cleanupPermanentWarning =>
      'Eliminazione permanente. Nessun rollback o aggiramento di permessi/blocchi. Chiudi prima le applicazioni. In caso di errore, alcuni file potrebbero essere già stati eliminati.';

  @override
  String get cleanupUserTempSelectionHint =>
      'Nessun file selezionato. Scegli solo file riconosciuti; i file creati dopo l\'anteprima sono esclusi.';

  @override
  String cleanupPreviewCount(int count, int bytes) {
    return '$count file, $bytes byte';
  }

  @override
  String get cleanupRecycleUnavailable =>
      'Pulizia del Cestino non disponibile: non è possibile mostrare ed eliminare in sicurezza singoli elementi con identità esatta. Nessuna azione svuota tutto.';

  @override
  String get cleanupCrashReports => 'Dump di crash e segnalazioni errori';

  @override
  String get cleanupCrashReportsDescription =>
      'Cancella i dump di crash dei tuoi programmi (%LOCALAPPDATA%\\CrashDumps) e l\'archivio e la coda di Segnalazione errori Windows del tuo utente. Utile dopo molti crash di un gioco o di un\'app. I minidump di sistema (schermate blu) non vengono toccati.';

  @override
  String get cleanupCrashReportsNone =>
      'Nessun dump di crash o segnalazione errori da cancellare.';

  @override
  String get cleanupCrashReportsCompleted =>
      'Dump di crash e segnalazioni errori cancellati.';

  @override
  String get cleanupBrowserCache => 'Cache dei browser';

  @override
  String get cleanupBrowserCacheDescription =>
      'Cancella le cache su disco di Chrome, Edge, Brave (tutti i profili) e Firefox. Cookie, cronologia, password ed estensioni non vengono toccati; le pagine si caricano un po\' più lentamente la prima volta.';

  @override
  String get cleanupBrowserCacheNone =>
      'Nessun file di cache dei browser da cancellare.';

  @override
  String get cleanupBrowserCacheCompleted => 'Cache dei browser cancellate.';

  @override
  String cleanupBrowserRunning(String browsers) {
    return 'Prima chiudi $browsers (anche dall\'area di notifica: Edge e Chrome possono restare attivi in background).';
  }

  @override
  String thermalZoneLimited(String percent) {
    return 'il firmware limita la CPU al $percent%';
  }

  @override
  String get thermalSourceCounters =>
      'Fonte: contatori Windows \"Thermal Zone Information\" (zone ACPI definite dal firmware, senza diritti di amministratore). Una zona è un sensore scelto dal produttore: spesso non è il die della CPU.';

  @override
  String get thermalSourceAcpi =>
      'Fonte: MSAcpi_ThermalZoneTemperature (zone ACPI definite dal firmware). Una zona è un sensore scelto dal produttore: spesso non è il die della CPU.';

  @override
  String get thermalSourceNone =>
      'Il firmware di questo PC non espone zone termiche ACPI (capita spesso sulle schede desktop). Meglio non mostrare nulla che un valore non misurato.';

  @override
  String get srumTab => 'Cronologia app';

  @override
  String get srumTitle => 'Cronologia app (SRUM)';

  @override
  String get srumDescription =>
      'Uso di rete, CPU e disco di ogni programma negli ultimi 30 giorni, come lo registra Windows (System Resource Usage Monitor). Sola lettura: viene letta una copia shadow del database, poi cancellata. Servono i diritti di amministratore.';

  @override
  String get srumRead => 'Leggi cronologia';

  @override
  String get srumNotCollectingTitle =>
      'Windows non sta registrando la cronologia delle app';

  @override
  String srumNotCollecting(String status, String startType, String date) {
    return 'Il Servizio criteri di diagnostica, che registra questa cronologia, è $status ($startType). I dati si fermano al $date.';
  }

  @override
  String get srumNoData => 'Nessun utilizzo registrato negli ultimi 30 giorni.';

  @override
  String get srumNetwork => 'Rete (inviati / ricevuti)';

  @override
  String get srumCpu =>
      'Tempo CPU (quota su tutti i programmi; parte usata in background)';

  @override
  String srumCpuShare(String share, String background) {
    return '$share% · $background% in background';
  }

  @override
  String get srumUnattributed => 'Non attribuito a un programma';

  @override
  String srumSource(String first, String last) {
    return 'Fonte: C:\\Windows\\System32\\sru\\SRUDB.dat, dati dal $first al $last. Windows li scrive circa una volta all\'ora.';
  }

  @override
  String get manualControls => 'Controlli manuali';

  @override
  String upToDate(String version) {
    return 'Stai usando l’ultima versione ($version).';
  }

  @override
  String get startCapture => 'Avvia acquisizione';

  @override
  String get batteryHealth => 'Salute della batteria';

  @override
  String get batteryHealthDescription =>
      'Capacità che la batteria trattiene ancora rispetto a quella di progetto. Sola lettura.';

  @override
  String get batteryGood => 'Buona';

  @override
  String get batteryFair => 'Usurata';

  @override
  String get batteryPoor => 'Da sostituire presto';

  @override
  String get notAvailable => 'Non disponibile';

  @override
  String get batteryDesigned => 'Capacità di progetto';

  @override
  String get batteryFullCharge => 'Capacità a carica completa';

  @override
  String get batteryWear => 'Usura';

  @override
  String get batteryCycles => 'Cicli di carica';

  @override
  String get batteryCharge => 'Carica attuale';

  @override
  String get batteryOnAc => 'Collegata alla corrente';

  @override
  String get batteryOnBattery => 'A batteria';

  @override
  String get batterySourceWmi =>
      'Fonte: root\\wmi BatteryStaticData, BatteryFullChargedCapacity, BatteryCycleCount e BatteryStatus, come riportati dal firmware della batteria.';

  @override
  String get batterySourceReport =>
      'Fonte: powercfg /batteryreport (XML temporaneo, eliminato dopo la lettura), come riportato dal firmware della batteria.';

  @override
  String get appTypeSystem => 'Sistema';

  @override
  String get appTypeUser => 'Utente';

  @override
  String get appTypeStore => 'Store';

  @override
  String get appSafetyRemovable => 'Si può togliere';

  @override
  String get appSafetyCheckFirst => 'Controlla prima';

  @override
  String get appSafetyKeep => 'Tienila';

  @override
  String get appReasonSystemComponent =>
      'Componente nascosto di Windows o del produttore.';

  @override
  String get appReasonProtected => 'Il suo installer ne vieta la rimozione.';

  @override
  String get appReasonUpdate =>
      'Aggiornamento di un altro programma: togli quello.';

  @override
  String get appReasonWindowsPart =>
      'Parte di Windows o framework usato da altre app.';

  @override
  String get appReasonSharedDependency =>
      'Usata da altre app (runtime, driver o pannello del produttore).';

  @override
  String get appReasonOptionalFeature =>
      'Funzione opzionale di Windows: leggi cosa smette di funzionare.';

  @override
  String get appReasonMissingUninstaller =>
      'Nessun disinstallatore registrato.';

  @override
  String get appReasonUserInstalled =>
      'Installata da te o dal produttore del PC; nient\'altro dipende da lei.';

  @override
  String get appLabelMissingUninstaller => 'Senza disinstallatore';

  @override
  String get appLabelProtected => 'Protetta';

  @override
  String get appLabelSystemComponent => 'Componente di sistema';

  @override
  String get appLabelUpdate => 'Aggiornamento';

  @override
  String get filterAll => 'Tutte';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterSafety => 'Sicurezza';

  @override
  String get filterSource => 'Fonte';

  @override
  String get sourceWholePc => 'Tutto il PC';

  @override
  String get sortBy => 'Ordina';

  @override
  String get sortSize => 'Dimensione';

  @override
  String get sortName => 'Nome';

  @override
  String get sortDate => 'Data di installazione';

  @override
  String appsShown(int count) {
    return '$count app';
  }

  @override
  String selectionSummary(int count, String size) {
    return '$count selezionate · $size';
  }

  @override
  String selectionUnknownSizes(int count) {
    return '$count con dimensione sconosciuta';
  }

  @override
  String get appsSource =>
      'Fonte: chiavi Uninstall del registro (HKLM 64/32 bit, HKCU), Get-AppxPackage, winget export per gli id di reinstallazione. Dimensione: EstimatedSize, altrimenti la cartella di installazione.';

  @override
  String get noAppsMatch => 'Nessuna app corrisponde ai filtri.';

  @override
  String reinstallableVia(String id) {
    return 'Reinstallazione: winget $id';
  }

  @override
  String get uninstallQueueTitle => 'Coda di disinstallazione';

  @override
  String get uninstallModeSilent => 'Silenziosa';

  @override
  String get uninstallModeWindowed => 'Apre la sua finestra';

  @override
  String get uninstallManualNoUninstaller =>
      'A mano: nessun disinstallatore registrato.';

  @override
  String get uninstallManualUnsafe =>
      'A mano: il comando registrato avvia una shell o uno script, quindi ZapTweaks non lo esegue.';

  @override
  String get uninstallManualNotFound =>
      'A mano: il file del disinstallatore non esiste.';

  @override
  String uninstallRunningWarning(String processes) {
    return 'Ancora in esecuzione dalla sua cartella: $processes. Chiudilo prima.';
  }

  @override
  String get uninstallSimulate =>
      'Simulazione: prepara e mostra la coda, senza disinstallare nulla';

  @override
  String get uninstallRestorePointNote =>
      'Prima viene creato un punto di ripristino. Prima le disinstallazioni con finestra, una alla volta; poi quelle silenziose.';

  @override
  String get uninstallStart => 'Avvia la disinstallazione';

  @override
  String get restorePointCreating => 'Creazione del punto di ripristino…';

  @override
  String get restorePointFailed =>
      'Il punto di ripristino non è stato creato. La Protezione sistema potrebbe essere spenta. Non è stato modificato nulla.';

  @override
  String get restorePointEnableAndRetry =>
      'Attiva la Protezione sistema e riprova';

  @override
  String get queueWaiting => 'In attesa';

  @override
  String get queueRunning => 'In corso';

  @override
  String get queueDone => 'Fatta';

  @override
  String get queueFailed => 'Fallita';

  @override
  String get queueSkipped => 'Saltata';

  @override
  String get queueSkip => 'Salta';

  @override
  String get queueStop => 'Ferma dopo quella in corso';

  @override
  String get queueSimulated => 'Simulazione: non è stato disinstallato nulla.';

  @override
  String get uninstallStoreAppsHint =>
      'Le app dello Store selezionate si tolgono dal menu Disinstalla della loro riga.';

  @override
  String get leftoverSearch => 'Cerca residui';

  @override
  String get leftoverTitle => 'Residui';

  @override
  String get leftoverGood => 'Sicuro';

  @override
  String get leftoverMedium => 'Probabile';

  @override
  String get leftoverLow => 'Incerto';

  @override
  String get leftoverKindFolder => 'Cartella';

  @override
  String get leftoverKindShortcut => 'Collegamento';

  @override
  String get leftoverKindRegistry => 'Chiave di registro';

  @override
  String get leftoverKindRun => 'Voce di avvio';

  @override
  String get leftoverKindTask => 'Attività pianificata';

  @override
  String get leftoverKindFirewall => 'Regola firewall';

  @override
  String get leftoverNone => 'Nessun residuo trovato.';

  @override
  String leftoverRemoveSelected(int count) {
    return 'Rimuovi selezionati ($count)';
  }

  @override
  String get leftoverBackupNote =>
      'Sono selezionati in partenza solo gli elementi Sicuri. Prima della rimozione le chiavi di registro vengono esportate in .reg, le attività in XML e le regole firewall in JSON; file e cartelle vanno nel Cestino.';

  @override
  String leftoverRemoved(String path) {
    return 'Residui rimossi. Backup in: $path';
  }

  @override
  String get leftoverRefusedInvalid =>
      'Non rimosso: voce non valida o non sicura.';

  @override
  String get leftoverRefusedOutside =>
      'Non rimosso: fuori dalle posizioni che ZapTweaks può pulire qui.';

  @override
  String get leftoverRefusedShared =>
      'Non rimosso: in comune con Windows o altri programmi.';

  @override
  String get orphanFolders => 'Cartelle orfane';

  @override
  String get orphanFoldersNote =>
      'Cartelle in Program Files a cui nessun programma installato fa riferimento. Uno strumento portatile o un kit di driver può sembrare uguale, quindi nulla è selezionato: controlla ognuna prima.';

  @override
  String get openLocation => 'Apri posizione';

  @override
  String get processesTab => 'Processi';

  @override
  String get searchProcesses => 'Cerca processi';

  @override
  String get sortMemory => 'Memoria';

  @override
  String get sortCpu => 'CPU';

  @override
  String get processKindWindows => 'Windows';

  @override
  String get processKindMicrosoft => 'App Microsoft';

  @override
  String get processKindThirdParty => 'Terze parti';

  @override
  String get processCanClose => 'Si può chiudere';

  @override
  String get processLeaveRunning => 'Lascialo attivo';

  @override
  String get processReasonCritical =>
      'Serve a Windows: chiuderlo può disconnetterti o bloccare il sistema.';

  @override
  String get processReasonWindowsFolder =>
      'Parte dalla cartella di Windows o è protetto.';

  @override
  String get processReasonService =>
      'Fa girare un servizio: si gestisce dalla scheda Servizi.';

  @override
  String get processReasonSelf => 'È ZapTweaks.';

  @override
  String get processReasonUserApp =>
      'Un\'app avviata da te: chiudendola perdi il lavoro non salvato.';

  @override
  String get processEnd => 'Termina processo';

  @override
  String processEndConfirm(String name) {
    return 'Terminare $name? Quello che non è salvato va perso.';
  }

  @override
  String get processEndChanged =>
      'Era già chiuso, o il suo ID ora è di un altro processo: non è stato terminato nulla.';

  @override
  String get processEndFailed =>
      'Windows ha rifiutato di terminarlo. Potrebbe girare come amministratore.';

  @override
  String get searchOnline => 'Cerca online';

  @override
  String get processOnlyClosable => 'Solo quelli chiudibili';

  @override
  String get processNote =>
      'Un\'istantanea: la CPU è un solo campione, aggiorna per rileggerla. Le firme vengono verificate dopo che la lista appare. I processi di sistema non vengono mai proposti per la chiusura.';

  @override
  String get noProcessesMatch => 'Nessun processo corrisponde a questi filtri.';

  @override
  String signedBy(String signer) {
    return 'Firmato da $signer';
  }

  @override
  String get servicesTab => 'Servizi';

  @override
  String get searchServices => 'Cerca servizi';

  @override
  String get filterOrigin => 'Origine';

  @override
  String get originMicrosoft => 'Microsoft';

  @override
  String get serviceCanDisable => 'Si può disattivare';

  @override
  String get serviceDependsOnUse => 'Dipende dall\'uso';

  @override
  String get serviceKeep => 'Tienilo';

  @override
  String get serviceStartAutomatic => 'Automatico';

  @override
  String get serviceStartDelayed => 'Automatico (ritardato)';

  @override
  String get serviceStartManual => 'Manuale';

  @override
  String get serviceStartDisabled => 'Disattivato';

  @override
  String get serviceStartBoot => 'Avvio sistema';

  @override
  String get serviceRunning => 'In esecuzione';

  @override
  String get serviceStopped => 'Fermo';

  @override
  String get serviceSetDisabled => 'Disattiva';

  @override
  String get serviceSetManual => 'Imposta su manuale';

  @override
  String get serviceSetAutomatic => 'Imposta su automatico';

  @override
  String serviceChangeTitle(String service) {
    return 'Modifica $service';
  }

  @override
  String serviceChangeConfirm(String from, String to, String reason) {
    return 'Tipo di avvio: $from → $to.\n$reason\nVale dal prossimo avvio del servizio o di Windows. Puoi annullarlo subito dopo.';
  }

  @override
  String serviceChanged(String service, String to) {
    return '$service ora è $to.';
  }

  @override
  String get serviceUndo => 'Annulla modifica';

  @override
  String get serviceNote =>
      'Le modifiche chiedono i diritti di amministratore e valgono dal prossimo avvio del servizio o di Windows. I servizi che servono a Windows non vengono mai proposti; disattivare un servizio da cui altri dipendono viene rifiutato.';

  @override
  String get noServicesMatch => 'Nessun servizio corrisponde a questi filtri.';

  @override
  String get svcReasonTelemetry =>
      'Invia dati di utilizzo e diagnostica a Microsoft. Non smette di funzionare nulla di ciò che usi.';

  @override
  String get svcReasonDeviceManagement =>
      'Telemetria e gestione dei dispositivi di lavoro o scuola: serve solo se un\'organizzazione gestisce questo PC.';

  @override
  String get svcReasonCrashReports =>
      'Invia i rapporti sugli arresti anomali a Microsoft. Gli arresti restano registrati su questo PC.';

  @override
  String get svcReasonRemoteRegistry =>
      'Permette ad altri computer di modificare il registro di questo PC in rete. Spento di serie.';

  @override
  String get svcReasonOfflineMaps =>
      'Aggiorna le mappe offline dell\'app Mappe.';

  @override
  String get svcReasonMediaSharing =>
      'Condivide in rete la raccolta di Windows Media Player.';

  @override
  String get svcReasonRetailDemo =>
      'Modalità demo per i negozi. A casa non serve mai.';

  @override
  String get svcReasonXbox =>
      'Senza: app Xbox, Game Pass, salvataggi nel cloud e accessori Xbox smettono di funzionare.';

  @override
  String get svcReasonPrinting =>
      'Senza: la stampa smette di funzionare, compresa la stampa in PDF.';

  @override
  String get svcReasonBluetooth =>
      'Senza: i dispositivi Bluetooth non si collegano più.';

  @override
  String get svcReasonSearch =>
      'Senza: la ricerca in Start, Impostazioni ed Esplora file diventa lenta e incompleta.';

  @override
  String get svcReasonSysMain =>
      'Precarica le app che usi spesso. Senza, gli avvii possono essere più lenti, soprattutto su dischi meccanici.';

  @override
  String get svcReasonTouchKeyboard =>
      'Senza: tastiera virtuale, scrittura a mano, pannello emoji e alcuni metodi di input smettono di funzionare.';

  @override
  String get svcReasonLocation =>
      'Senza: le app e Trova il mio dispositivo non possono più rilevare la posizione.';

  @override
  String get svcReasonBiometrics =>
      'Senza: l\'accesso con volto e impronta di Windows Hello smette di funzionare.';

  @override
  String get svcReasonPhone =>
      'Senza: le chiamate tramite Collegamento al telefono smettono di funzionare.';

  @override
  String get svcReasonRemoteDesktop =>
      'Senza: il Desktop remoto verso questo PC smette di funzionare.';

  @override
  String get svcReasonSmartCard =>
      'Senza: smart card e alcune chiavi di sicurezza smettono di funzionare.';

  @override
  String get svcReasonParental =>
      'Senza: i limiti di Microsoft Family Safety non vengono più applicati.';

  @override
  String get svcReasonNfc =>
      'Senza: NFC e pagamenti contactless smettono di funzionare.';

  @override
  String get svcReasonHotspot =>
      'Senza: l\'hotspot mobile smette di funzionare.';

  @override
  String get svcReasonScanner =>
      'Senza: scanner e alcune fotocamere smettono di funzionare.';

  @override
  String get svcReasonCompatibility =>
      'Senza: Windows non propone più correzioni quando un vecchio programma non parte.';

  @override
  String get svcReasonFax => 'Senza: il fax smette di funzionare.';

  @override
  String get svcReasonInsider =>
      'Senza: le build di anteprima di Windows Insider non arrivano più.';

  @override
  String get svcReasonUpdates =>
      'Serve a Windows Update: senza, le correzioni di sicurezza non arrivano più.';

  @override
  String get svcReasonSecurity =>
      'Protegge questo PC (antivirus, firewall, stato della sicurezza).';

  @override
  String get svcReasonWindowsCore =>
      'Serve a Windows per audio, rete, registri o funzioni di base del sistema.';

  @override
  String get svcReasonNotReviewed =>
      'Parte di Windows e non verificato: lascialo com\'è.';

  @override
  String get svcReasonDriverService =>
      'Installato con un driver: lascialo, a meno che tu non sappia cosa fa.';

  @override
  String get svcReasonMicrosoftApp =>
      'Appartiene a un\'app Microsoft: senza, quell\'app può smettere di funzionare o di aggiornarsi.';

  @override
  String get svcReasonThirdParty =>
      'Installato con un altro programma: senza, quel programma può smettere di funzionare o di aggiornarsi.';

  @override
  String get serviceStartTypeAction => 'Cambia avvio';

  @override
  String get presetsTab => 'Preset';

  @override
  String get presetDebloatName => 'Solo debloat';

  @override
  String get presetDebloatSummary =>
      'Toglie le app Microsoft preinstallate che pochi usano. Non cambia altro.';

  @override
  String get presetCleanName => 'Pulito';

  @override
  String get presetCleanSummary =>
      'Debloat più servizi di telemetria e inutilizzati spenti e app che partono con Windows senza motivo.';

  @override
  String get presetGamingName => 'Gaming';

  @override
  String get presetGamingSummary =>
      'Pulito più impostazioni per giocare: niente risparmio energetico sui processi, Termina attività nella barra. Xbox resta.';

  @override
  String get presetPrivacyName => 'Privacy';

  @override
  String get presetPrivacySummary =>
      'Pulito più le impostazioni di privacy della guida di Microsoft: ID pubblicitario, tracciamento, suggerimenti, dati di diagnostica al minimo.';

  @override
  String get presetCompetitiveName => 'Competitive';

  @override
  String get presetCompetitiveSummary =>
      'Toglie tutto quello che tolgono gli altri preset e di più: app che molti usano, Xbox, stampa, launcher all\'avvio, registrazione dei giochi. Più installazione pulita dei driver e WinSux, da fare a mano.';

  @override
  String get presetAttention => 'Attenzione';

  @override
  String get presetAttentionNote =>
      'Toglie molto, comprese cose che molti usano. Non promette FPS, latenza o altri guadagni: è un insieme di modifiche, non un miglioramento misurato.';

  @override
  String get presetGroupApps => 'App che rimuove (utente corrente)';

  @override
  String get presetGroupServices => 'Servizi che disattiva';

  @override
  String get presetGroupStartup => 'Voci di avvio che spegne';

  @override
  String get presetGroupTweaks => 'Impostazioni';

  @override
  String get presetGroupThirdParty => 'Script e strumenti di terze parti';

  @override
  String get presetGroupRestart => 'Riavvio';

  @override
  String get presetGroupReversible => 'Cosa si può annullare';

  @override
  String get presetRestartNeeded =>
      'Riavvia dopo: servizi e voci di avvio cambiano al prossimo avvio.';

  @override
  String get presetRestartNone => 'Non serve riavviare.';

  @override
  String get presetReversibleApps =>
      'App: si reinstallano dal Microsoft Store.';

  @override
  String get presetReversibleSettings =>
      'Servizi, voci di avvio e impostazioni: annullali subito con Annulla preset, o più tardi con il punto di ripristino creato prima.';

  @override
  String get presetReversibleManual =>
      'I passi di terze parti non li esegue ZapTweaks: per annullarli segui le istruzioni dell\'autore.';

  @override
  String get presetManualWhy =>
      'Da fare a mano: lo script scarica ed esegue altri file che non si possono fissare con un hash, quindi ZapTweaks non lo esegue.';

  @override
  String get presetManualDriverClean =>
      'Installazione pulita del driver video: DDU in modalità provvisoria, poi l\'ultimo driver del produttore.';

  @override
  String get presetManualWinsux =>
      'WinSux: debloat e impostazioni di Windows in un solo script.';

  @override
  String get presetPreview => 'Anteprima su questo PC';

  @override
  String get presetPreviewLoading =>
      'Leggo app, servizi, voci di avvio e impostazioni…';

  @override
  String get presetStatusApply => 'Da fare';

  @override
  String get presetStatusDone => 'Già a posto';

  @override
  String get presetStatusSkipped => 'Saltato';

  @override
  String get presetStatusManual => 'A mano';

  @override
  String get presetSkipNotInstalled => 'non installata';

  @override
  String get presetSkipNotFound => 'non presente su questo PC';

  @override
  String get presetSkipUnsupported => 'non supportata qui';

  @override
  String get presetSkipDuplicate =>
      'stesso nome due volte: cambia solo la prima';

  @override
  String presetCounts(int apply, int done, int skipped) {
    return '$apply da fare · $done già a posto · $skipped saltati';
  }

  @override
  String get presetConsent =>
      'Ho letto l\'elenco completo e accetto il rischio.';

  @override
  String get presetApply => 'Applica preset';

  @override
  String get presetApplyNote =>
      'Prima si crea un punto di ripristino; se non riesce non cambia nulla. Le modifiche da amministratore chiedono l\'UAC una volta.';

  @override
  String get presetApplying => 'Applico…';

  @override
  String presetReport(int ok, int failed) {
    return 'Fatto: $ok modificate, $failed non modificate.';
  }

  @override
  String get presetUndo => 'Annulla preset';

  @override
  String get presetUndone =>
      'Preset annullato. Le app rimosse restano rimosse: reinstallale dallo Store.';

  @override
  String get presetNothingToDo => 'Niente da fare: è già tutto a posto.';

  @override
  String get presetSaveAs => 'Salva come mio preset';

  @override
  String get presetSaveNote =>
      'Salva le voci ancora spuntate. Condividi il file per esportarlo; mettine uno nella cartella per importarlo.';

  @override
  String get presetName => 'Nome';

  @override
  String presetSaved(String path) {
    return 'Salvato: $path';
  }

  @override
  String get presetOpenFolder => 'Apri cartella preset';

  @override
  String get presetUserTitle => 'I miei preset';

  @override
  String presetInvalidFile(String file, String error) {
    return '$file non caricato: $error';
  }

  @override
  String get presetItemPowerThrottling =>
      'Risparmio energetico dei processi (Power Throttling) spento';

  @override
  String get presetItemEndTask =>
      'Termina attività nel menu della barra delle applicazioni';

  @override
  String get presetItemAdvertisingId => 'ID pubblicitario disattivato';

  @override
  String get presetItemLanguageList =>
      'I siti non leggono l\'elenco delle tue lingue';

  @override
  String get presetItemAppLaunchTracking =>
      'Windows non traccia le app che avvii';

  @override
  String get presetItemTailoredExperiences =>
      'Niente esperienze personalizzate dai dati di diagnostica';

  @override
  String get presetItemCloudContent =>
      'Niente contenuti ottimizzati dal cloud (suggerimenti)';

  @override
  String get presetItemDiagnosticData =>
      'Dati di diagnostica: solo quelli obbligatori';

  @override
  String get presetItemLockScreenOverlay =>
      'Niente suggerimenti sulla schermata di blocco';

  @override
  String get presetItemLockScreenFacts =>
      'Niente curiosità sulla schermata di blocco';

  @override
  String get presetItemGameDvr =>
      'Registrazione dei giochi di Game Bar disattivata';

  @override
  String get presetSkipHasDependents =>
      'Altri servizi dipendono da questo, quindi Windows non permette di disattivarlo.';

  @override
  String get settingsGeneral => 'Generale';

  @override
  String get settingsModes => 'Modalità';

  @override
  String get settingsMaintenance => 'Manutenzione';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get openLogFolderDescription =>
      'Log delle sessioni con ogni comando eseguito da ZapTweaks.';

  @override
  String get redetectSystemStateDescription =>
      'Rilegge l\'hardware e lo stato di ogni tweak.';

  @override
  String get profileTitle => 'Profilo impostazioni';

  @override
  String get profileDescription =>
      'Salva le preferenze di ZapTweaks in un file o caricale da un file.';

  @override
  String get resetAppSettingsDescription =>
      'Torna alle preferenze predefinite di ZapTweaks. Windows non viene modificato.';

  @override
  String get expertModeOn => 'Attivata';

  @override
  String get expertModeOff => 'Disattivata';
}
