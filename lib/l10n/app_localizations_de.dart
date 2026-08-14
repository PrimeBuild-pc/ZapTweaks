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
      'Aggressiver Tweak. Ein Wiederherstellungspunkt ist obligatorisch.';

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
}
