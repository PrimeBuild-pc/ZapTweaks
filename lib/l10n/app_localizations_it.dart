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
}
