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
}
