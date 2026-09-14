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
  String get powerPlans => 'Piani di alimentazione in bundle';

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
