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

  @override
  String get updateAvailableShort => 'Mise à jour disponible';

  @override
  String get checkingForUpdates => 'Vérification des mises à jour';

  @override
  String get contactingReleaseServer => 'Contacter le serveur de version...';

  @override
  String updateDialogTitle(Object version) {
    return 'ZapTweaks $version est disponible';
  }

  @override
  String installedVersion(Object version) {
    return 'Version installée : $version';
  }

  @override
  String get releaseNotesOnGitHub =>
      'Les notes de version sont disponibles sur GitHub.';

  @override
  String get later => 'Plus tard';

  @override
  String get failed => 'Échec';

  @override
  String get downloadingUpdate => 'Téléchargement de la mise à jour';

  @override
  String get downloadingUpdateDescription =>
      'Téléchargement et préparation du programme d\'installation...';

  @override
  String get adminPrivilegesRequired =>
      'Les privilèges d\'administrateur sont requis';

  @override
  String get adminRequiredBanner =>
      'Fermez l\'application et lancez ZapTweaks avec \"Exécuter en tant qu\'administrateur\". Sans élévation, les modifications du système ne peuvent pas être appliquées en toute sécurité.';

  @override
  String get cancel => 'Annuler';

  @override
  String get createRestorePoint => 'Créer un point de restauration';

  @override
  String get adminRequiredDialog =>
      'ZapTweaks a besoin des autorisations d\'administrateur pour appliquer les paramètres système.\n\nFermez l\'application, cliquez avec le bouton droit sur l\'exécutable et sélectionnez « Exécuter en tant qu\'administrateur ».';

  @override
  String get understood => 'Compris';

  @override
  String aboutVersion(Object version) {
    return 'Version : v$version';
  }

  @override
  String get author => 'Auteur : PrimeBuild';

  @override
  String get aboutDescription =>
      'Compagnon d\'optimisation avancé pour des flux de travail de jeu, de matériel et de diagnostic Windows plus approfondis.';

  @override
  String year(Object year) {
    return 'Année : $year';
  }

  @override
  String get close => 'Fermer';

  @override
  String get github => 'GitHub';

  @override
  String get discord => 'Discorde';

  @override
  String get homeAndStats => 'Accueil et statistiques';

  @override
  String get cpuUsage => 'Utilisation du processeur';

  @override
  String get cpuUsageDescription =>
      'Utilisation en temps réel à partir des compteurs Windows';

  @override
  String get gpuUsage => 'Utilisation du GPU';

  @override
  String get gpuUsageDescription => 'Utilisation du moteur en temps réel';

  @override
  String get vramUsage => 'Utilisation de la VRAM';

  @override
  String get memoryUsage => 'Utilisation de la mémoire';

  @override
  String get unknown => 'Inconnu';

  @override
  String get installedRam => 'RAM installée';

  @override
  String get networkAdapters => 'Adaptateurs réseau';

  @override
  String get noConnectedAdapters => 'Aucun adaptateur connecté détecté';

  @override
  String get audioDevices => 'Appareils audio';

  @override
  String get noAudioDevices => 'Aucun périphérique audio détecté';

  @override
  String get noTweaksAvailable =>
      'Aucun réglage n\'est disponible pour votre configuration matérielle.';

  @override
  String get detectedHardware => 'Matériel détecté';

  @override
  String get gpuUnknown => 'GPU : Inconnu';

  @override
  String cpuValue(Object value) {
    return 'Processeur : $value';
  }

  @override
  String gpuValue(Object value) {
    return 'GPU : $value';
  }

  @override
  String ramValue(Object value) {
    return 'RAM : $value';
  }

  @override
  String get enableAllVisible => 'Activer tout ce qui est visible';

  @override
  String get disableAllVisible => 'Désactiver tout ce qui est visible';

  @override
  String get restartNow => 'Redémarrer maintenant';

  @override
  String get restartRequired => 'Redémarrage requis';

  @override
  String get restartRequiredDescription =>
      'Un redémarrage du système est nécessaire pour appliquer complètement une ou plusieurs modifications.';

  @override
  String get advancedActionsIncluded => 'Actions avancées incluses';

  @override
  String get advancedActionsDescription =>
      'Les outils externes, les actions de lancement et les utilitaires basés sur des scripts sont regroupés ici pour des diagnostics rapides et des flux de travail de maintenance.';

  @override
  String get aggressiveTweakWarning =>
      'Ajustement agressif. Un point de restauration est obligatoire.';

  @override
  String get networkReconnectWarning =>
      'Une reconnexion de la carte réseau ou un redémarrage du système peuvent être nécessaires.';

  @override
  String get actionWarning => 'Avertissement d\'action';

  @override
  String get unknownError => 'Erreur inconnue.';

  @override
  String get presets => 'Préréglages';

  @override
  String get presetFailed => 'Échec du préréglage';

  @override
  String get safetyWarning => 'Avertissement de sécurité';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get powerPlans => 'Forfaits d’alimentation groupés';

  @override
  String get powerPlansDescription =>
      'Importez et activez un forfait groupé. ZapTweaks se souvient du plan actif précédent pour la restauration.';

  @override
  String get noPowerPlans =>
      'Aucun plan d\'alimentation groupé n\'a été trouvé.';

  @override
  String get working => 'Travailler...';

  @override
  String get importAndActivate => 'Importer et activer';

  @override
  String get restorePreviousPlan => 'Restaurer le plan précédent';

  @override
  String get ran => 'Couru';

  @override
  String get gpuDrivers => 'Pilotes GPU';

  @override
  String get noGpuDrivers => 'Aucun pilote GPU détecté';

  @override
  String get chipsetDrivers => 'Pilotes de chipset';

  @override
  String get noChipsetDrivers => 'Aucun pilote de chipset détecté';

  @override
  String get monitors => 'Moniteurs';

  @override
  String get noMonitors => 'Aucun moniteur détecté';

  @override
  String get mice => 'Souris';

  @override
  String get noMice => 'Aucune souris détectée';

  @override
  String get keyboards => 'Claviers';

  @override
  String get noKeyboards => 'Aucun clavier détecté';
}
