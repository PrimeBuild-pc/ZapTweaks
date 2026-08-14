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
      'Modifica aggressiva. Un punto di ripristino è obbligatorio.';

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
}
