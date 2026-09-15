// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Lingua';

  @override
  String get languageDescription => 'Scegli la lingua usata da ZapTweaks.';

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
  String get powerPlans => 'Piani di alimentazione';

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
      'Mostra operazioni avanzate e tool esterni. Le restrizioni di sicurezza restano attive.';

  @override
  String get searchOperations => 'Cerca operazioni';

  @override
  String get searchResults => 'Risultati della ricerca';

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
  String get guidedSetup => 'Setup guidato';

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
      'Registra su richiesta una traccia Windows Performance Recorder limitata a 15 secondi. Nessun monitor resta attivo.';

  @override
  String etwTraceSaved(Object path) {
    return 'Traccia salvata in $path';
  }

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
  String get renamePowerPlan => 'Rinomina piano di alimentazione';

  @override
  String get renamePowerPlanDescription =>
      'Modifica solo il nome visualizzato del piano selezionato e conserva quello originale per il rollback.';

  @override
  String get rename => 'Rinomina';

  @override
  String get firmwareTemperatures => 'Zone termiche firmware';

  @override
  String get firmwareTemperaturesDescription =>
      'Legge una volta le zone termiche ACPI. Disponibilità e significato dei sensori dipendono dal firmware; i valori non sono indicati come temperature CPU o GPU.';

  @override
  String get noThermalSensors => 'Questo PC non espone zone termiche ACPI.';

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
  String get searchApps => 'Cerca app';

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
}
