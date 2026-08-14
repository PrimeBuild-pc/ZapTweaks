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
}
