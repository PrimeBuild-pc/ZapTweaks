// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get externalDownload => 'Téléchargement externe';

  @override
  String get appRequirements => 'Configuration requise';

  @override
  String get appWarnings => 'Avertissements';

  @override
  String get metricUnavailable => 'N/D';

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Langue';

  @override
  String get languageDescription =>
      'Choisissez la langue utilisée par ZapTweaks.';

  @override
  String get appearance => 'Apparence';

  @override
  String get appearanceDescription =>
      'Suivre Windows ou utiliser un thème d\'application fixe, clair ou sombre.';

  @override
  String get themeSystem => 'Par défaut de Windows';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

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
      'Ajustement agressif. Un point de restauration est recommandé.';

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

  @override
  String get restorePointPromptTitle => 'Créer un point de restauration ?';

  @override
  String get restorePointPromptMessage =>
      'ZapTweaks peut créer un point de restauration Windows avant de modifier les paramètres système. C\'est facultatif : si vous passez, la modification est appliquée quand même. La question n\'est posée qu\'une fois par session.';

  @override
  String get skip => 'Passer';

  @override
  String get continueAction => 'Continuer';

  @override
  String get tweaksSectionHeader => 'RÉGLAGES';

  @override
  String get startingUp => 'Démarrage de ZapTweaks';

  @override
  String get expertMode => 'Mode expert';

  @override
  String get expertModeDescription =>
      'Afficher les opérations avancées et les outils externes uniquement après un consentement manuel explicite. Désactivé par défaut ; les restrictions de sécurité restent en vigueur.';

  @override
  String get searchOperations => 'Rechercher des opérations';

  @override
  String get searchResults => 'Résultats de recherche';

  @override
  String get searchSections => 'Sections et outils intégrés';

  @override
  String get searchApps => 'Rechercher des applications';

  @override
  String get searchCatalog => 'Opérations et outils externes';

  @override
  String get searchOpenResult => 'Ouvrir';

  @override
  String get searchExpertRequired => 'Activez le mode expert pour ouvrir';

  @override
  String get noSearchResults =>
      'Aucune section, application, opération ou outil correspondant.';

  @override
  String get operationTaskbarEndTaskTitle =>
      'Fin de tâche dans la barre des tâches';

  @override
  String get operationTaskbarEndTaskDescription =>
      'Afficher Fin de tâche dans le menu contextuel des applications de la barre des tâches.';

  @override
  String get appStore => 'Boutique d\'applications';

  @override
  String get appManagement => 'Applications installées';

  @override
  String get windowsAppTools => 'Outils d\'applications Windows';

  @override
  String get optionalFeatures => 'Fonctionnalités facultatives';

  @override
  String get searchOptionalFeatures =>
      'Rechercher des fonctionnalités facultatives';

  @override
  String get scanOptionalFeatures => 'Analyser les fonctionnalités (UAC)';

  @override
  String get optionalFeaturesUacNotice =>
      'L\'inventaire des fonctionnalités et chaque modification passent par l\'assistant autorisé. L\'analyse ne modifie rien.';

  @override
  String get confirmOptionalFeatureChange =>
      'Confirmer la modification de la fonctionnalité facultative';

  @override
  String confirmOptionalFeatureChangeMessage(Object name, Object action) {
    return 'Fonctionnalité : $name\nAction : $action\n\nWindows peut demander un redémarrage. L\'état précédent est enregistré avant la modification.';
  }

  @override
  String get enable => 'Activer';

  @override
  String get disable => 'Désactiver';

  @override
  String get enabled => 'Activée';

  @override
  String get disabled => 'Désactivée';

  @override
  String get enablePending => 'Activation au redémarrage';

  @override
  String get disablePending => 'Désactivation au redémarrage';

  @override
  String get startupApps => 'Applications au démarrage';

  @override
  String get searchStartupApps => 'Rechercher des applications au démarrage';

  @override
  String get openStartupSettings => 'Ouvrir les paramètres de démarrage';

  @override
  String get openTaskManagerStartup =>
      'Ouvrir Démarrage dans le Gestionnaire des tâches';

  @override
  String get startupInventoryNotice =>
      'Inventaire du démarrage en lecture seule. Utilisez les Paramètres Windows ou le Gestionnaire des tâches pour modifier une entrée.';

  @override
  String get guidedSetup => 'Configuration guidée';

  @override
  String get wizardInventory => 'Inventaire';

  @override
  String get wizardBaseline => 'Point de départ';

  @override
  String get wizardWindowsUpdate => 'Windows Update';

  @override
  String get wizardDrivers => 'Contrôle des pilotes';

  @override
  String get wizardApplications => 'Applications';

  @override
  String get wizardDebloat => 'Allègement sélectif';

  @override
  String get wizardPrivacyInterface => 'Confidentialité et interface';

  @override
  String get wizardPreview => 'Aperçu du plan';

  @override
  String get wizardApply => 'Appliquer';

  @override
  String get wizardReport => 'Rapport final';

  @override
  String get wizardInventoryDescription =>
      'Lire le matériel, les paquets winget installés et les périphériques présents avant de faire des choix.';

  @override
  String get runInventory => 'Lancer l\'inventaire';

  @override
  String inventorySummary(Object apps, Object devices) {
    return '$apps paquets winget et $devices périphériques présents détectés.';
  }

  @override
  String get wizardUpdateNotice =>
      'Vérifiez Windows Update avant de modifier pilotes et applications. ZapTweaks n\'installe pas de mises à jour automatiquement.';

  @override
  String get openWindowsUpdate => 'Ouvrir Windows Update';

  @override
  String get updatesReviewed => 'J\'ai vérifié Windows Update';

  @override
  String driverInventorySummary(Object devices, Object missing) {
    return 'Périphériques présents : $devices\nPériphériques sans INF associé : $missing';
  }

  @override
  String get wizardDebloatNotice =>
      'Aucun allègement n\'est implicite. Seuls les paquets AppX de l\'utilisateur actuel avec une source de restauration vérifiée peuvent être choisis ici ; les autres suppressions restent disponibles dans App → Applications installées, avec leur propre aperçu.';

  @override
  String get wizardPrivacyNotice =>
      'Les paramètres de confidentialité et d\'interface restent inchangés sauf s\'ils sont choisis explicitement ci-dessous.';

  @override
  String get noAppsSelected =>
      'Aucune opération choisie. L\'assistant ne fera aucune modification.';

  @override
  String planContains(Object count) {
    return 'Le plan contient $count opération(s) explicite(s) :';
  }

  @override
  String readyToApply(Object count) {
    return 'Prêt à appliquer $count opération(s) d\'application. Chaque paquet est vérifié une fois winget terminé.';
  }

  @override
  String get noPlanReport => 'Terminé sans appliquer de plan.';

  @override
  String get planStatus => 'État du plan';

  @override
  String get applyPlan => 'Appliquer le plan';

  @override
  String get back => 'Retour';

  @override
  String get finish => 'Terminer';

  @override
  String get recovery => 'Récupération';

  @override
  String get diagnosticTools => 'Outils de diagnostic';

  @override
  String get repairComponentStore => 'Réparer le magasin de composants Windows';

  @override
  String get repairComponentStoreDescription =>
      'Exécute DISM RestoreHealth puis une vérification ScanHealth distincte. Cela peut être long.';

  @override
  String get repairSystemFiles => 'Réparer les fichiers système protégés';

  @override
  String get repairSystemFilesDescription =>
      'Exécute une analyse et réparation SFC puis une passe de vérification distincte.';

  @override
  String get confirmSystemRepair => 'Confirmer la réparation de Windows';

  @override
  String get systemRepairWarning =>
      'La réparation peut remplacer des composants Windows endommagés et ZapTweaks ne peut pas l\'annuler. N\'éteignez pas le PC pendant l\'opération.';

  @override
  String get systemRepairVerified =>
      'Réparation terminée et vérification réussie.';

  @override
  String get runRepair => 'Réparer';

  @override
  String get operationCompleted => 'Opération terminée';

  @override
  String get captureEtwTrace => 'Capturer une trace de performances';

  @override
  String get captureEtwTraceDescription =>
      'Enregistre une trace Windows Performance Recorder limitée et produit à la demande un rapport de diagnostic DPC/ISR. Aucune surveillance ne reste active.';

  @override
  String get dpcLatencyAnalyzer => 'Analyseur de latence DPC / ISR';

  @override
  String get dpcLatencyAnalyzerDescription =>
      'Capture ETW à la demande et indique l\'activité DPC, ISR, des défauts de page matériels et des changements de contexte, la répartition par processeur, les modules noyau observés et les fournisseurs ETW.';

  @override
  String get diagnosticNotCausality =>
      'Signal de diagnostic, pas un verdict de latence';

  @override
  String get diagnosticNotCausalityDescription =>
      'Les comptages et les noms de modules observés aident à cibler une analyse mais ne prouvent pas qu\'un pilote cause la latence. Confirmez avec des traces A/B/A reproductibles et WPA ou les outils du fabricant.';

  @override
  String get startDpcCapture => 'Démarrer la capture';

  @override
  String get openTraceFolder => 'Ouvrir le dossier des traces';

  @override
  String captureInProgress(int seconds) {
    return 'Capture pendant $seconds secondes… laissez la charge tourner.';
  }

  @override
  String get traceDuration => 'Durée observée';

  @override
  String get hardFaults => 'Défauts de page matériels';

  @override
  String get contextSwitches => 'Changements de contexte';

  @override
  String get totalEvents => 'Total des événements ETW';

  @override
  String get kernelModulesObserved =>
      'Modules noyau observés dans les événements DPC/ISR';

  @override
  String get noKernelModulesObserved =>
      'Les événements exportés ne contenaient pas de noms de modules noyau. Ouvrez l\'ETL dans WPA pour une analyse avec symboles.';

  @override
  String get dpcIsrByProcessor => 'Événements DPC/ISR par processeur logique';

  @override
  String get noProcessorDistribution =>
      'Les événements exportés ne contenaient pas d\'ID de processeur.';

  @override
  String get topEtwProviders => 'Principaux fournisseurs ETW';

  @override
  String get noProviderData => 'Aucune donnée de fournisseur disponible.';

  @override
  String etwTraceSaved(Object path) {
    return 'Trace enregistrée dans $path';
  }

  @override
  String get cleanupDiagnosticTraces => 'Supprimer les traces de diagnostic';

  @override
  String get cleanupDiagnosticTracesDescription =>
      'Recherche uniquement les fichiers de trace de ZapTweaks, affiche le nombre exact de fichiers et la taille totale, puis les supprime après confirmation.';

  @override
  String cleanupTracePreview(int count, int bytes) {
    return 'Supprimer $count fichiers de trace ZapTweaks ($bytes octets) ? Action irréversible.';
  }

  @override
  String get cleanupTracesCompleted =>
      'Les traces affichées ont été supprimées et leur absence vérifiée.';

  @override
  String get noDiagnosticTraces =>
      'Aucune trace de diagnostic ZapTweaks trouvée.';

  @override
  String get hardwareMonitor => 'Moniteur matériel';

  @override
  String get dedicatedVramUsage => 'Mémoire GPU dédiée utilisée';

  @override
  String get dedicatedVramUsageDescription =>
      'Prend une seule mesure des compteurs de performances GPU de Windows. Rien ne continue à tourner ensuite.';

  @override
  String vramUsageValue(Object megabytes) {
    return '$megabytes Mo';
  }

  @override
  String get captureNow => 'Mesurer maintenant';

  @override
  String get tweaks => 'Réglages';

  @override
  String get searchPowerPlans =>
      'Rechercher des modes de gestion de l\'alimentation';

  @override
  String get activePowerPlan => 'Actif';

  @override
  String get activate => 'Activer';

  @override
  String get details => 'Détails';

  @override
  String get compare => 'Comparer';

  @override
  String get noPowerDifferences =>
      'Aucune différence entre les valeurs sur secteur et sur batterie.';

  @override
  String get importPowerPlan => 'Importer un .pow';

  @override
  String get importPowerPlanDescription =>
      'Importe un mode d\'alimentation choisi localement après une préparation limitée et vérifiée par hachage.';

  @override
  String get exportActivePowerPlan => 'Exporter le mode actif';

  @override
  String get restoreDefaultPowerSchemes => 'Restaurer les valeurs de Windows';

  @override
  String get restoreDefaultPowerSchemesDescription =>
      'Exporte et hache chaque mode actuel avant de demander à Windows de restaurer ses valeurs par défaut.';

  @override
  String get restoreDefaultPowerSchemesWarning =>
      'Remplacer tous les modes d\'alimentation actuels par ceux de Windows ? ZapTweaks exportera d\'abord chaque mode pour une annulation exacte.';

  @override
  String get interruptConfiguration =>
      'MSI Utility v3 et affinité des interruptions';

  @override
  String get interruptConfigurationDescription =>
      'Réglages avancés MSI et d\'affinité des interruptions du groupe 0, selon les capacités, pour les périphériques d\'affichage, réseau, multimédia, hôte USB et audio HD présents. Aucune valeur n\'est recommandée automatiquement.';

  @override
  String get configureMsi => 'Configurer MSI';

  @override
  String get enableMsi => 'Activer les interruptions signalées par message';

  @override
  String get configureInterruptAffinity => 'Configurer l\'affinité';

  @override
  String get interruptChangeWarning =>
      'Une stratégie d\'interruption non valide peut rendre le périphérique inutilisable jusqu\'à l\'annulation ou au redémarrage. ZapTweaks vérifie les limites matérielles et enregistre les valeurs actuelles exactes.';

  @override
  String get affinityMaskHint =>
      'Masque hexadécimal du groupe 0, par exemple 3';

  @override
  String get invalidAffinityMask =>
      'Saisissez un masque hexadécimal canonique non nul de 64 bits au maximum.';

  @override
  String msiRange(int maximum) {
    return 'Le nombre de messages doit être compris entre 1 et $maximum.';
  }

  @override
  String get noCompatibleInterruptDevices =>
      'Aucun périphérique PCI d\'affichage, réseau, multimédia, hôte USB ou audio HD présent n\'offre de capacités d\'interruption compatibles.';

  @override
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  ) {
    return 'Matériel : Line $line · MSI $msi · MSI-X $msix · messages maximum $maximum';
  }

  @override
  String get messageNumberLimit => 'Limite du nombre de messages';

  @override
  String get interruptPriority => 'Stratégie de priorité d\'interruption';

  @override
  String get interruptPriorityDefault => 'Non définie / valeur du pilote';

  @override
  String get interruptPriorityLow => 'Basse';

  @override
  String get interruptPriorityNormal => 'Normale';

  @override
  String get interruptPriorityHigh => 'Haute';

  @override
  String get interruptPolicy => 'Stratégie d\'affinité processeur';

  @override
  String get interruptPolicyDefault => 'Valeur par défaut de la machine';

  @override
  String get interruptPolicyAllClose => 'Tous les processeurs proches';

  @override
  String get interruptPolicyOneClose => 'Un processeur proche';

  @override
  String get interruptPolicyAllProcessors => 'Tous les processeurs';

  @override
  String get interruptPolicySpecified => 'Processeurs indiqués (groupe 0)';

  @override
  String get interruptPolicySpread =>
      'Répartir les messages sur les processeurs';

  @override
  String get selectLogicalProcessors =>
      'Choisir les processeurs logiques du groupe de processeurs 0';

  @override
  String get affinitySelectAll => 'Tous les processeurs logiques';

  @override
  String get affinityClear => 'Effacer';

  @override
  String get affinityPhysicalCores => 'Un thread par cœur physique';

  @override
  String get affinityPerformanceCores => 'Cœurs performance';

  @override
  String get affinityEfficiencyCores => 'Cœurs efficacité';

  @override
  String get affinityParked => 'parqué';

  @override
  String affinityLlcGroup(int index) {
    return 'LLC / CCD $index';
  }

  @override
  String affinityNumaNode(int index) {
    return 'Nœud NUMA $index';
  }

  @override
  String get compatibleDevices => 'Périphériques compatibles';

  @override
  String get msiEnabledDevices => 'MSI activé actuellement';

  @override
  String get logicalProcessors => 'Processeurs logiques';

  @override
  String get searchDevices =>
      'Rechercher périphériques, ID d\'instance ou INF de pilote';

  @override
  String get driverUnknown => 'INF du pilote indisponible';

  @override
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  ) {
    return 'Actuel : $mode · messages $messages · priorité $priority · stratégie $policy · masque $mask';
  }

  @override
  String get renamePowerPlan => 'Renommer le mode d\'alimentation';

  @override
  String get renamePowerPlanDescription =>
      'Modifie uniquement le nom affiché du mode choisi et conserve le nom d\'origine pour l\'annulation.';

  @override
  String get rename => 'Renommer';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get duplicatePowerPlan => 'Dupliquer le mode d\'alimentation';

  @override
  String get duplicatePowerPlanDescription =>
      'Crée et vérifie une copie PowrProf. L\'annulation se fait au mieux, car Windows attribue le GUID à la création.';

  @override
  String get apply => 'Appliquer';

  @override
  String get edit => 'Modifier';

  @override
  String powerValueRange(int maximum) {
    return 'Les valeurs doivent être comprises entre 0 et $maximum.';
  }

  @override
  String get powerSettingConfigure =>
      'Configurer tout paramètre d\'alimentation borné';

  @override
  String get powerSettingConfigureDescription =>
      'Modifie un paramètre exposé par PowrProf uniquement quand Windows fournit en direct le minimum, le maximum et le pas.';

  @override
  String get searchPowerSettings =>
      'Rechercher paramètres, descriptions, sous-groupes ou GUID';

  @override
  String get allPowerSubgroups =>
      'Tous les groupes de paramètres d\'alimentation';

  @override
  String powerSettingCount(int count) {
    return '$count paramètres';
  }

  @override
  String powerSettingOptions(int count) {
    return '$count options définies par Windows';
  }

  @override
  String get backToPowerPlans => 'Retour aux modes d\'alimentation';

  @override
  String get powerPlanEditorHint =>
      'Dupliquez un mode pour créer votre profil, puis ouvrez Détails et modifiez un par un ses paramètres cachés sur secteur et sur batterie.';

  @override
  String powerSettingRange(Object minimum, Object maximum, Object increment) {
    return 'Plage $minimum–$maximum, pas $increment';
  }

  @override
  String get powerSettingBoundsUnavailable =>
      'Windows n\'a fourni ni valeurs ni bornes sûres pour ce paramètre.';

  @override
  String get delete => 'Supprimer';

  @override
  String get deletePowerPlan => 'Supprimer le mode d\'alimentation';

  @override
  String get deletePowerPlanDescription =>
      'Exporte le mode inactif choisi avant de le supprimer et conserve la sauvegarde pour une annulation exacte.';

  @override
  String deletePowerPlanWarning(Object name) {
    return 'Supprimer $name ? ZapTweaks exportera d\'abord une copie de récupération.';
  }

  @override
  String get firmwareTemperatures => 'Zones thermiques du firmware';

  @override
  String get firmwareTemperaturesDescription =>
      'Lit une fois les zones thermiques ACPI. Leur disponibilité et la signification du capteur dépendent du firmware du PC ; les valeurs ne sont pas présentées comme températures CPU ou GPU.';

  @override
  String get noThermalSensors => 'Ce PC n\'expose aucune zone thermique ACPI.';

  @override
  String get cpuFrequency => 'Fréquence CPU et parcage des cœurs';

  @override
  String get cpuFrequencyDescription =>
      'Prend une mesure des compteurs de performances processeur de Windows. La fréquence effective est la fréquence de base × % de performance du processeur, la même formule que le Gestionnaire des tâches. Utile pour vérifier les changements de mode d\'alimentation, de boost et de parcage. Lecture seule.';

  @override
  String cpuEffectiveClock(Object mhz, Object nominal) {
    return '$mhz MHz effectifs · base $nominal MHz';
  }

  @override
  String cpuParkedCount(Object parked, Object total) {
    return '$parked processeurs logiques parqués sur $total';
  }

  @override
  String get cpuParked => 'parqué';

  @override
  String get cpuFrequencySource =>
      'Source : compteurs de performances Processor Information (Win32_PerfFormattedData_Counters_ProcessorInformation), une mesure moyennée sur le dernier intervalle du compteur. Pas une fréquence de pointe. Les valeurs par cœur utilisent une seule fréquence nominale ; les cœurs efficacité des CPU hybrides paraissent donc élevés.';

  @override
  String get driverInventory => 'Inventaire du magasin de pilotes';

  @override
  String get installLocalDriver => 'Installer un paquet de pilote local';

  @override
  String get installLocalDriverDescription =>
      'Vérifier un INF local, son catalogue signé et la compatibilité matérielle avant l\'installation.';

  @override
  String get selectDevice => 'Choisir un périphérique présent';

  @override
  String get localInfPath => 'Chemin absolu du fichier .inf local';

  @override
  String get verifyDriverPackage => 'Vérifier le paquet';

  @override
  String verifiedDriverPublisher(Object publisher, Object sha256) {
    return 'Éditeur vérifié : $publisher\nSHA-256 de l\'INF : $sha256';
  }

  @override
  String get confirmLocalDriverInstall =>
      'Confirmer l\'installation du pilote local';

  @override
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  ) {
    return 'Périphérique : $device\nÉditeur signé : $publisher\nSHA-256 de l\'INF : $sha256\n\nWindows peut changer le pilote actif et demander un redémarrage. L\'annulation se fait au mieux.';
  }

  @override
  String get driverTools => 'Parcours assistés';

  @override
  String get temporaryDriverUpdatesPause =>
      'Exclure temporairement les pilotes des mises à jour qualité de Windows';

  @override
  String get temporaryDriverUpdatesPauseDescription =>
      'Utilise la stratégie Windows Update documentée pendant 7 ou 30 jours. ZapTweaks enregistre la valeur précédente exacte et affiche un rappel à l\'expiration ; la restauration demande votre confirmation.';

  @override
  String get driverUpdatePolicy => 'Stratégie des pilotes de Windows Update';

  @override
  String get driverUpdatePolicyDescription =>
      'Exclure les pilotes de périphériques des mises à jour qualité de Windows pendant 7 jours, 30 jours ou jusqu\'à ce que vous restauriez explicitement la stratégie précédente exacte.';

  @override
  String get disableUntilRestored => 'Désactiver jusqu\'à restauration';

  @override
  String get driverUpdatePausePermanent =>
      'Les mises à jour de pilotes restent exclues jusqu\'à ce que vous restauriez la stratégie précédente.';

  @override
  String get driverUpdatePauseActive =>
      'Pause des mises à jour de pilotes active';

  @override
  String get driverUpdatePauseExpired =>
      'Pause des pilotes expirée — restaurez la stratégie précédente';

  @override
  String driverUpdatePauseUntil(Object date) {
    return 'Expiration prévue : $date';
  }

  @override
  String get pauseSevenDays => 'Suspendre 7 jours';

  @override
  String get pauseThirtyDays => 'Suspendre 30 jours';

  @override
  String get restoreDriverUpdates => 'Restaurer la stratégie précédente';

  @override
  String get assistedDriverFlows => 'Parcours de pilotes vérifiés et assistés';

  @override
  String get assistedDriverFlowsDescription =>
      'ZapTweaks n\'ouvre que les sources des fabricants et les panneaux de Windows. Il n\'exécute pas de scripts distants modifiables, ne flashe pas de firmware et ne retire pas de composants de pilote en silence.';

  @override
  String get amdDriverFlow => 'Pilotes et logiciels AMD';

  @override
  String get amdDriverFlowDescription =>
      'Ouvrir le sélecteur officiel de pilotes AMD. Vérifiez le produit détecté avant de télécharger.';

  @override
  String get nvidiaDriverFlow => 'Pilotes NVIDIA';

  @override
  String get nvidiaDriverFlowDescription =>
      'Ouvrir la recherche manuelle officielle de pilotes NVIDIA. L\'installation propre reste un choix explicite dans l\'installateur du fabricant.';

  @override
  String get intelDriverFlow => 'Intel Driver & Support Assistant';

  @override
  String get intelDriverFlowDescription =>
      'Ouvrir le parcours officiel de détection et d\'assistance d\'Intel.';

  @override
  String get windowsOptionalDrivers =>
      'Mises à jour facultatives de pilotes Windows';

  @override
  String get windowsOptionalDriversDescription =>
      'Vérifiez les mises à jour facultatives de pilotes dans les Paramètres Windows ; rien n\'est choisi automatiquement.';

  @override
  String get deviceManager => 'Gestionnaire de périphériques';

  @override
  String get deviceManagerDescription =>
      'Examiner périphériques, codes d\'état, pilotes actifs et options de restauration manuelle.';

  @override
  String get openOfficialSource => 'Ouvrir la source officielle';

  @override
  String get openWindowsPanel => 'Ouvrir le panneau Windows';

  @override
  String get searchDrivers => 'Rechercher dans le magasin de pilotes';

  @override
  String get driverStoreSafetyNotice =>
      'Seuls les paquets tiers signés et non associés peuvent être retirés ici. ZapTweaks exporte et hache d\'abord le paquet ; la restauration se fait au mieux, car Windows peut attribuer un autre nom publié.';

  @override
  String get signed => 'Signé';

  @override
  String get unsigned => 'Non signé';

  @override
  String get driverInUse => 'Utilisé';

  @override
  String get driverUnbound => 'Non associé';

  @override
  String get exportAndRemove => 'Exporter et retirer';

  @override
  String get confirmDriverRemoval =>
      'Confirmer le retrait du magasin de pilotes';

  @override
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  ) {
    return 'Nom publié : $published\nINF d\'origine : $inf\nÉditeur : $publisher\nVersion : $version\n\nZapTweaks exportera et hachera le paquet avant le retrait. Un redémarrage peut être nécessaire ; la restauration se fait au mieux.';
  }

  @override
  String get searchInstalledApps => 'Rechercher des applications installées';

  @override
  String get scanAllUsers => 'Analyser tous les utilisateurs (UAC)';

  @override
  String get systemScopesComplete =>
      'Les portées AppX de tous les utilisateurs et provisionnées sont incluses.';

  @override
  String get systemScopesIncomplete =>
      'Utilisateur actuel et inventaire winget uniquement. Analysez tous les utilisateurs pour inclure les portées AppX du système.';

  @override
  String get currentUser => 'Utilisateur actuel';

  @override
  String get allUsers => 'Tous les utilisateurs';

  @override
  String get provisioned => 'Provisionné';

  @override
  String get confirmAppxRemoval => 'Confirmer le retrait AppX';

  @override
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  ) {
    return 'Application : $name\nIdentité : $id\nPortée : $scope\nRécupération : $recovery\n\nSeule la portée indiquée sera retirée. Cette opération n\'a pas d\'annulation exacte.';
  }

  @override
  String get reinstallable => 'Source de restauration vérifiée disponible';

  @override
  String get notReinstallable => 'Aucune source de restauration vérifiée';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get installedOnly => 'Installées uniquement';

  @override
  String get refreshInventory => 'Actualiser l\'inventaire';

  @override
  String get install => 'Installer';

  @override
  String get uninstall => 'Désinstaller';

  @override
  String get uninstallSelected => 'Désinstaller la sélection';

  @override
  String get openOfficialPage => 'Ouvrir la page officielle';

  @override
  String get installed => 'Installée';

  @override
  String get notInstalled => 'Non installée';

  @override
  String get appInventoryUnavailable =>
      'La détection des applications installées n\'est pas disponible.';

  @override
  String get confirmBulkUninstall => 'Confirmer la désinstallation groupée';

  @override
  String confirmBulkUninstallMessage(Object apps) {
    return 'Les applications suivantes seront désinstallées :\n\n$apps';
  }

  @override
  String get appCatalogSources =>
      'Catalogue fusionné à partir de CTT WinUtil épinglé, de candidats clean-room de Winhance, de TweakHub et des sources officielles demandées.';

  @override
  String get tcpOptimizer => 'Optimiseur TCP';

  @override
  String get tcpOptimizerDescription =>
      'Inspectez et configurez les modèles TCP de Windows, les déchargements globaux, la QoS par application et des diagnostics réseau reproductibles.';

  @override
  String get tcpNoRecommendation =>
      'Aucune valeur n’est recommandée automatiquement. Une relecture ou un seul test réseau ne prouve pas un gain de performances.';

  @override
  String get tcpLiveState => 'État TCP actuel';

  @override
  String get tcpTemplates => 'Modèles TCP';

  @override
  String get tcpGlobal => 'Déchargements TCP globaux';

  @override
  String get tcpAutotuning => 'Réglage automatique de la fenêtre de réception';

  @override
  String get tcpHeuristics => 'Heuristique de mise à l’échelle de la fenêtre';

  @override
  String get tcpEcn => 'Prise en charge d’ECN';

  @override
  String get tcpCongestion => 'Contrôle de congestion';

  @override
  String get tcpRsc => 'Coalescence des segments reçus (RSC)';

  @override
  String get tcpRss => 'Mise à l’échelle globale côté réception (RSS)';

  @override
  String get tcpConfigure => 'Configurer';

  @override
  String get tcpChangePreview => 'Aperçu de la modification TCP';

  @override
  String get tcpCurrentValue => 'Valeur actuelle';

  @override
  String get tcpNewValue => 'Nouvelle valeur';

  @override
  String get tcpExactRollbackNotice =>
      'ZapTweaks enregistre la valeur actuelle exacte, applique la modification avec une demande UAC, la relit, la consigne et conserve une restauration exacte.';

  @override
  String get tcpUnsupported => 'Non exposé par cette version de Windows';

  @override
  String get tcpAdapterRss => 'Ouvrir les contrôles RSS par carte';

  @override
  String get rssAdapterState => 'État RSS par carte';

  @override
  String get rssEnabled => 'RSS activé';

  @override
  String get rssProfile => 'Profil RSS';

  @override
  String get rssQueuesProcessors => 'Files/processeurs';

  @override
  String get tcpSettingOperationTitle => 'Configurer le paramètre TCP';

  @override
  String get tcpSettingOperationDescription =>
      'Modifie un modèle TCP Windows ou une valeur de déchargement global pris en charge par le système, avec restauration exacte.';

  @override
  String get qosPolicies => 'Stratégies QoS des applications';

  @override
  String get qosDescription =>
      'Créez des stratégies QoS explicites et persistantes pour un exécutable. Les stratégies existantes qui ne proviennent pas de ZapTweaks restent en lecture seule.';

  @override
  String get qosCreate => 'Créer une stratégie';

  @override
  String get qosEdit => 'Modifier';

  @override
  String get qosDelete => 'Supprimer';

  @override
  String get qosName => 'Nom de la stratégie';

  @override
  String get qosAppPath => 'Chemin de l’exécutable';

  @override
  String get qosProtocol => 'Protocole';

  @override
  String get qosSourcePort => 'Port source (facultatif)';

  @override
  String get qosDestinationPort => 'Port de destination (facultatif)';

  @override
  String get qosDscp => 'DSCP 0–63 (facultatif)';

  @override
  String get qosThrottleMbps => 'Limite en Mbit/s (facultatif)';

  @override
  String get qosOwnedOnly =>
      'Les noms doivent commencer par « ZapTweaks - ». Seule la stratégie sélectionnée est modifiée ; les autres stratégies QoS ne sont jamais supprimées.';

  @override
  String get qosDeleteConfirm =>
      'Supprimer la stratégie QoS sélectionnée ? Son état exact est conservé dans le journal ZapTweaks pour permettre sa restauration.';

  @override
  String get qosReadOnly => 'Lecture seule';

  @override
  String get qosPolicyOperationTitle => 'Configurer la QoS d’application';

  @override
  String get qosPolicyOperationDescription =>
      'Crée, modifie ou supprime une stratégie QoS persistante et validée par application, avec restauration exacte.';

  @override
  String get networkDiagnostics => 'Diagnostic avant/après';

  @override
  String get networkDiagnosticsDescription =>
      'Mesurez de façon limitée la latence de connexion TCP, la gigue, la perte et le débit de téléchargement HTTPS. Les résultats sont des données de diagnostic, pas une recommandation.';

  @override
  String get diagnosticEndpoint => 'URL HTTPS directe du fichier de test';

  @override
  String get diagnosticNetworkCost =>
      'Le test télécharge au maximum 10 Mio depuis le point de terminaison saisi. Aucun point de terminaison tiers n’est intégré.';

  @override
  String get diagnosticBaseline => 'Lancer la mesure initiale';

  @override
  String get diagnosticComparison => 'Lancer la comparaison';

  @override
  String get diagnosticCancel => 'Annuler la mesure';

  @override
  String get diagnosticLatency => 'Latence';

  @override
  String get diagnosticJitter => 'Gigue';

  @override
  String get diagnosticPacketLoss => 'Perte de paquets';

  @override
  String get diagnosticThroughput => 'Débit';

  @override
  String get diagnosticRawSamples => 'Échantillons de latence bruts';

  @override
  String get diagnosticDownloadedBytes => 'Octets téléchargés';

  @override
  String get diagnosticDifference => 'Différence B − A';

  @override
  String get tcpAttribution =>
      'Inspiré de WINSPAR — powplowdevs (révision figée)';

  @override
  String get openRecoveryHistory => 'Ouvrir la restauration et le journal';

  @override
  String get manualRestoreTitle =>
      'Restaurer les paramètres manuels d\'origine';

  @override
  String get manualRestoreWarning =>
      'Restaure les originaux enregistrés, pas les valeurs par défaut. Les paramètres modifiés depuis ne sont pas écrasés. Les paramètres à haut risque exigent le mode expert et l\'UAC. Consultez le journal après la restauration ; un redémarrage ou une déconnexion peut rester nécessaire.';

  @override
  String get cleanupUserTemp => 'Nettoyage de UserTemp';

  @override
  String get cleanupUserTempDescription =>
      'Examiner et choisir des fichiers précis du dossier Temp de l\'utilisateur actuel. Pas de sélection automatique, pas de suppression forcée ni de retrait de dossier.';

  @override
  String get cleanupSelectFiles => 'Afficher et choisir les fichiers';

  @override
  String get cleanupShaderCache => 'Nettoyage du cache de shaders GPU';

  @override
  String get cleanupShaderCacheDescription =>
      'Affiche dossier par dossier les caches de shaders DirectX, AMD, NVIDIA et Intel de l\'utilisateur actuel et supprime exactement les fichiers trouvés par cet aperçu. Le pilote les reconstruit, donc le premier lancement de chaque jeu peut saccader. Fermez d\'abord les jeux. Irréversible.';

  @override
  String get cleanupShaderCacheNone =>
      'Aucun fichier de cache de shaders GPU trouvé.';

  @override
  String get cleanupShaderCacheCompleted =>
      'Les fichiers de cache affichés ont été supprimés et leur absence vérifiée.';

  @override
  String get cleanupPreview => 'Aperçu';

  @override
  String get cleanupUserTempNone => 'Aucun fichier UserTemp trouvé.';

  @override
  String get cleanupPermanentWarning =>
      'Suppression définitive. Pas d\'annulation ni de contournement des autorisations ou verrous. Fermez d\'abord les applications. Si la suppression échoue, des fichiers précédents peuvent déjà avoir été retirés.';

  @override
  String get cleanupUserTempSelectionHint =>
      'Rien n\'est sélectionné. Choisissez uniquement des fichiers que vous reconnaissez ; ceux créés après cet aperçu sont exclus.';

  @override
  String cleanupPreviewCount(int count, int bytes) {
    return '$count fichiers, $bytes octets';
  }

  @override
  String get cleanupRecycleUnavailable =>
      'Le nettoyage de la Corbeille n\'est pas disponible : les éléments exacts ne peuvent pas être affichés et supprimés en sécurité. Rien n\'est vidé en bloc.';

  @override
  String get cleanupCrashReports =>
      'Vidages sur incident et rapports d\'erreurs';

  @override
  String get cleanupCrashReportsDescription =>
      'Supprime les vidages sur incident de vos programmes (%LOCALAPPDATA%\\CrashDumps) ainsi que l\'archive et la file d\'attente du Rapport d\'erreurs Windows. Utile quand un jeu ou une application a planté de nombreuses fois. Les minidumps système (écrans bleus) ne sont pas touchés.';

  @override
  String get cleanupCrashReportsNone =>
      'Aucun vidage ni rapport d\'erreurs à supprimer.';

  @override
  String get cleanupCrashReportsCompleted =>
      'Vidages sur incident et rapports d\'erreurs supprimés.';

  @override
  String get cleanupBrowserCache => 'Caches des navigateurs';

  @override
  String get cleanupBrowserCacheDescription =>
      'Supprime les caches disque de Chrome, Edge, Brave (tous les profils) et Firefox. Cookies, historique, mots de passe et extensions ne sont pas touchés ; les pages se chargent un peu plus lentement la première fois.';

  @override
  String get cleanupBrowserCacheNone =>
      'Aucun fichier de cache de navigateur à supprimer.';

  @override
  String get cleanupBrowserCacheCompleted =>
      'Caches des navigateurs supprimés.';

  @override
  String cleanupBrowserRunning(String browsers) {
    return 'Fermez d\'abord $browsers (y compris depuis la zone de notification : Edge et Chrome peuvent rester actifs en arrière-plan).';
  }

  @override
  String thermalZoneLimited(String percent) {
    return 'le firmware limite le CPU à $percent %';
  }

  @override
  String get thermalSourceCounters =>
      'Source : compteurs Windows « Thermal Zone Information » (zones ACPI définies par le firmware, sans droits d\'administrateur). Une zone est un capteur choisi par le fabricant ; ce n\'est souvent pas la puce du CPU.';

  @override
  String get thermalSourceAcpi =>
      'Source : MSAcpi_ThermalZoneTemperature (zones ACPI définies par le firmware). Une zone est un capteur choisi par le fabricant ; ce n\'est souvent pas la puce du CPU.';

  @override
  String get thermalSourceNone =>
      'Le firmware de ce PC n\'expose aucune zone thermique ACPI (courant sur les cartes mères de bureau). Rien n\'est affiché plutôt qu\'une valeur non mesurée.';

  @override
  String get srumTab => 'Historique des applications';

  @override
  String get srumTitle => 'Historique des applications (SRUM)';

  @override
  String get srumDescription =>
      'Utilisation réseau, CPU et disque de chaque programme sur les 30 derniers jours, telle qu\'enregistrée par Windows (System Resource Usage Monitor). Lecture seule : ZapTweaks lit un cliché instantané de la base de données puis le supprime. Nécessite des droits d\'administrateur.';

  @override
  String get srumRead => 'Lire l\'historique';

  @override
  String get srumNotCollectingTitle =>
      'Windows n\'enregistre pas l\'historique des applications';

  @override
  String srumNotCollecting(String status, String startType, String date) {
    return 'Le Service de stratégie de diagnostic, qui enregistre cet historique, est $status ($startType). Les données s\'arrêtent le $date.';
  }

  @override
  String get srumNoData =>
      'Aucune utilisation enregistrée sur les 30 derniers jours.';

  @override
  String get srumNetwork => 'Réseau (envoyé / reçu)';

  @override
  String get srumCpu =>
      'Temps CPU (part de l\'ensemble des programmes ; part en arrière-plan)';

  @override
  String srumCpuShare(String share, String background) {
    return '$share % · $background % en arrière-plan';
  }

  @override
  String get srumUnattributed => 'Non attribué à un programme';

  @override
  String srumSource(String first, String last) {
    return 'Source : C:\\Windows\\System32\\sru\\SRUDB.dat, enregistrements du $first au $last. Windows les écrit environ une fois par heure.';
  }

  @override
  String get manualControls => 'Contrôles manuels';

  @override
  String upToDate(String version) {
    return 'Vous utilisez la dernière version ($version).';
  }

  @override
  String get startCapture => 'Démarrer la capture';

  @override
  String get batteryHealth => 'État de la batterie';

  @override
  String get batteryHealthDescription =>
      'Capacité que la batterie conserve encore par rapport à sa conception. Lecture seule.';

  @override
  String get batteryGood => 'Bonne';

  @override
  String get batteryFair => 'Usée';

  @override
  String get batteryPoor => 'À remplacer bientôt';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get batteryDesigned => 'Capacité nominale';

  @override
  String get batteryFullCharge => 'Capacité de charge complète';

  @override
  String get batteryWear => 'Usure';

  @override
  String get batteryCycles => 'Cycles de charge';

  @override
  String get batteryCharge => 'Charge actuelle';

  @override
  String get batteryOnAc => 'Branchée';

  @override
  String get batteryOnBattery => 'Sur batterie';

  @override
  String get batterySourceWmi =>
      'Source : root\\wmi BatteryStaticData, BatteryFullChargedCapacity, BatteryCycleCount et BatteryStatus, tels que rapportés par le firmware de la batterie.';

  @override
  String get batterySourceReport =>
      'Source : powercfg /batteryreport (XML temporaire, supprimé après lecture), tel que rapporté par le firmware de la batterie.';

  @override
  String get appTypeSystem => 'Système';

  @override
  String get appTypeUser => 'Utilisateur';

  @override
  String get appTypeStore => 'Store';

  @override
  String get appSafetyRemovable => 'Peut être retirée';

  @override
  String get appSafetyCheckFirst => 'Vérifier d’abord';

  @override
  String get appSafetyKeep => 'À garder';

  @override
  String get appReasonSystemComponent =>
      'Composant masqué de Windows ou du fabricant.';

  @override
  String get appReasonProtected => 'Son installateur interdit la suppression.';

  @override
  String get appReasonUpdate =>
      'Mise à jour d’un autre programme : retirez plutôt celui-ci.';

  @override
  String get appReasonWindowsPart =>
      'Partie de Windows ou framework utilisé par d’autres apps.';

  @override
  String get appReasonSharedDependency =>
      'Utilisée par d’autres apps (runtime, pilote ou panneau du fabricant).';

  @override
  String get appReasonOptionalFeature =>
      'Fonction facultative de Windows : lisez ce qui cesse de fonctionner.';

  @override
  String get appReasonMissingUninstaller => 'Aucun désinstalleur enregistré.';

  @override
  String get appReasonUserInstalled =>
      'Installée par vous ou le fabricant ; rien d’autre n’en dépend.';

  @override
  String get appLabelMissingUninstaller => 'Sans désinstalleur';

  @override
  String get appLabelProtected => 'Protégée';

  @override
  String get appLabelSystemComponent => 'Composant système';

  @override
  String get appLabelUpdate => 'Mise à jour';

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterType => 'Type';

  @override
  String get filterSafety => 'Sécurité';

  @override
  String get filterSource => 'Source';

  @override
  String get sourceWholePc => 'Tout le PC';

  @override
  String get sortBy => 'Trier';

  @override
  String get sortSize => 'Taille';

  @override
  String get sortName => 'Nom';

  @override
  String get sortDate => 'Date d’installation';

  @override
  String appsShown(int count) {
    return '$count apps';
  }

  @override
  String selectionSummary(int count, String size) {
    return '$count sélectionnées · $size';
  }

  @override
  String selectionUnknownSizes(int count) {
    return '$count de taille inconnue';
  }

  @override
  String get appsSource =>
      'Source : clés Uninstall du registre (HKLM 64/32 bits, HKCU), Get-AppxPackage, winget export pour les id de réinstallation. Taille : EstimatedSize, sinon le dossier d’installation.';

  @override
  String get noAppsMatch => 'Aucune app ne correspond à ces filtres.';

  @override
  String reinstallableVia(String id) {
    return 'Réinstallation : winget $id';
  }

  @override
  String get uninstallQueueTitle => 'File de désinstallation';

  @override
  String get uninstallModeSilent => 'Silencieuse';

  @override
  String get uninstallModeWindowed => 'Ouvre sa fenêtre';

  @override
  String get uninstallManualNoUninstaller =>
      'Manuel : aucun désinstalleur enregistré.';

  @override
  String get uninstallManualUnsafe =>
      'Manuel : la commande enregistrée lance un shell ou un script, ZapTweaks ne l’exécute donc pas.';

  @override
  String get uninstallManualNotFound =>
      'Manuel : le fichier du désinstalleur est introuvable.';

  @override
  String uninstallRunningWarning(String processes) {
    return 'Toujours lancé depuis son dossier : $processes. Fermez-le d’abord.';
  }

  @override
  String get uninstallSimulate =>
      'Simulation : préparer et afficher la file sans rien désinstaller';

  @override
  String get uninstallRestorePointNote =>
      'Un point de restauration est créé d’abord. Les désinstallations avec fenêtre passent en premier, une à la fois, puis les silencieuses.';

  @override
  String get uninstallStart => 'Lancer la désinstallation';

  @override
  String get restorePointCreating => 'Création du point de restauration…';

  @override
  String get restorePointFailed =>
      'Le point de restauration n’a pas été créé. La protection du système est peut-être désactivée. Rien n’a été modifié.';

  @override
  String get restorePointEnableAndRetry =>
      'Activer la protection du système et réessayer';

  @override
  String get queueWaiting => 'En attente';

  @override
  String get queueRunning => 'En cours';

  @override
  String get queueDone => 'Terminée';

  @override
  String get queueFailed => 'Échouée';

  @override
  String get queueSkipped => 'Ignorée';

  @override
  String get queueSkip => 'Ignorer';

  @override
  String get queueStop => 'Arrêter après celle en cours';

  @override
  String get queueSimulated => 'Simulation : rien n’a été désinstallé.';

  @override
  String get uninstallStoreAppsHint =>
      'Les apps du Store sélectionnées se retirent via le menu Désinstaller de leur ligne.';

  @override
  String get leftoverSearch => 'Chercher les restes';

  @override
  String get leftoverTitle => 'Restes';

  @override
  String get leftoverGood => 'Sûr';

  @override
  String get leftoverMedium => 'Probable';

  @override
  String get leftoverLow => 'Incertain';

  @override
  String get leftoverKindFolder => 'Dossier';

  @override
  String get leftoverKindShortcut => 'Raccourci';

  @override
  String get leftoverKindRegistry => 'Clé de registre';

  @override
  String get leftoverKindRun => 'Entrée de démarrage';

  @override
  String get leftoverKindTask => 'Tâche planifiée';

  @override
  String get leftoverKindFirewall => 'Règle de pare-feu';

  @override
  String get leftoverNone => 'Aucun reste trouvé.';

  @override
  String leftoverRemoveSelected(int count) {
    return 'Retirer la sélection ($count)';
  }

  @override
  String get leftoverBackupNote =>
      'Seuls les éléments Sûrs sont présélectionnés. Avant le retrait, les clés sont exportées en .reg, les tâches en XML et les règles de pare-feu en JSON ; fichiers et dossiers vont dans la Corbeille.';

  @override
  String leftoverRemoved(String path) {
    return 'Restes retirés. Sauvegardes : $path';
  }

  @override
  String get leftoverRefusedInvalid =>
      'Non retiré : entrée invalide ou risquée.';

  @override
  String get leftoverRefusedOutside =>
      'Non retiré : hors de ce que ZapTweaks peut nettoyer ici.';

  @override
  String get leftoverRefusedShared =>
      'Non retiré : partagé avec Windows ou d\'autres programmes.';

  @override
  String get orphanFolders => 'Dossiers orphelins';

  @override
  String get orphanFoldersNote =>
      'Dossiers de Program Files qu’aucun programme installé n’utilise. Un outil portable ou un kit de pilotes peut sembler identique : rien n’est sélectionné, vérifiez chacun.';

  @override
  String get openLocation => 'Ouvrir l’emplacement';

  @override
  String get processesTab => 'Processus';

  @override
  String get searchProcesses => 'Rechercher des processus';

  @override
  String get sortMemory => 'Mémoire';

  @override
  String get sortCpu => 'CPU';

  @override
  String get processKindWindows => 'Windows';

  @override
  String get processKindMicrosoft => 'Application Microsoft';

  @override
  String get processKindThirdParty => 'Tiers';

  @override
  String get processCanClose => 'Peut être fermé';

  @override
  String get processLeaveRunning => 'Laisser actif';

  @override
  String get processReasonCritical =>
      'Windows en a besoin : le fermer peut vous déconnecter ou planter le système.';

  @override
  String get processReasonWindowsFolder =>
      'S\'exécute depuis le dossier Windows ou est protégé.';

  @override
  String get processReasonService =>
      'Exécute un service : gérez-le depuis l\'onglet Services.';

  @override
  String get processReasonSelf => 'C\'est ZapTweaks.';

  @override
  String get processReasonUserApp =>
      'Une application que vous avez lancée : la fermer perd le travail non enregistré.';

  @override
  String get processEnd => 'Terminer le processus';

  @override
  String processEndConfirm(String name) {
    return 'Terminer $name ? Ce qui n\'est pas enregistré est perdu.';
  }

  @override
  String get processEndChanged =>
      'Il était déjà fermé ou son ID appartient maintenant à un autre processus : rien n\'a été terminé.';

  @override
  String get processEndFailed =>
      'Windows a refusé de le terminer. Il tourne peut-être en administrateur.';

  @override
  String get searchOnline => 'Rechercher en ligne';

  @override
  String get processOnlyClosable => 'Seulement ceux qu\'on peut fermer';

  @override
  String get processNote =>
      'Un instantané : le CPU est un seul échantillon, actualisez pour le relire. Les signatures sont vérifiées après l\'affichage de la liste. Les processus système ne sont jamais proposés à la fermeture.';

  @override
  String get noProcessesMatch => 'Aucun processus ne correspond à ces filtres.';

  @override
  String signedBy(String signer) {
    return 'Signé par $signer';
  }

  @override
  String get servicesTab => 'Services';

  @override
  String get searchServices => 'Rechercher des services';

  @override
  String get filterOrigin => 'Origine';

  @override
  String get originMicrosoft => 'Microsoft';

  @override
  String get serviceCanDisable => 'Peut être désactivé';

  @override
  String get serviceDependsOnUse => 'Selon l\'usage';

  @override
  String get serviceKeep => 'À garder';

  @override
  String get serviceStartAutomatic => 'Automatique';

  @override
  String get serviceStartDelayed => 'Automatique (différé)';

  @override
  String get serviceStartManual => 'Manuel';

  @override
  String get serviceStartDisabled => 'Désactivé';

  @override
  String get serviceStartBoot => 'Démarrage';

  @override
  String get serviceRunning => 'En cours';

  @override
  String get serviceStopped => 'Arrêté';

  @override
  String get serviceSetDisabled => 'Désactiver';

  @override
  String get serviceSetManual => 'Passer en manuel';

  @override
  String get serviceSetAutomatic => 'Passer en automatique';

  @override
  String serviceChangeTitle(String service) {
    return 'Modifier $service';
  }

  @override
  String serviceChangeConfirm(String from, String to, String reason) {
    return 'Type de démarrage : $from → $to.\n$reason\nS\'applique au prochain démarrage du service ou de Windows. Vous pouvez annuler juste après.';
  }

  @override
  String serviceChanged(String service, String to) {
    return '$service est maintenant $to.';
  }

  @override
  String get serviceUndo => 'Annuler la modification';

  @override
  String get serviceNote =>
      'Les modifications demandent les droits administrateur et s\'appliquent au prochain démarrage du service ou de Windows. Les services dont Windows a besoin ne sont jamais proposés ; désactiver un service dont d\'autres dépendent est refusé.';

  @override
  String get noServicesMatch => 'Aucun service ne correspond à ces filtres.';

  @override
  String get svcReasonTelemetry =>
      'Envoie des données d\'utilisation et de diagnostic à Microsoft. Rien de ce que vous utilisez ne cesse de fonctionner.';

  @override
  String get svcReasonDeviceManagement =>
      'Télémétrie et gestion des appareils professionnels ou scolaires : utile seulement si une organisation gère ce PC.';

  @override
  String get svcReasonCrashReports =>
      'Envoie les rapports de plantage à Microsoft. Les plantages restent journalisés sur ce PC.';

  @override
  String get svcReasonRemoteRegistry =>
      'Permet à d\'autres ordinateurs de modifier le registre de ce PC par le réseau. Désactivé par défaut.';

  @override
  String get svcReasonOfflineMaps =>
      'Met à jour les cartes hors connexion de l\'application Cartes.';

  @override
  String get svcReasonMediaSharing =>
      'Partage la bibliothèque du Lecteur Windows Media sur le réseau.';

  @override
  String get svcReasonRetailDemo =>
      'Mode démo pour les magasins. Jamais utile à la maison.';

  @override
  String get svcReasonXbox =>
      'Sans lui : l\'application Xbox, le Game Pass, les sauvegardes cloud et les accessoires Xbox cessent de fonctionner.';

  @override
  String get svcReasonPrinting =>
      'Sans lui : l\'impression ne fonctionne plus, Impression en PDF comprise.';

  @override
  String get svcReasonBluetooth =>
      'Sans lui : les appareils Bluetooth ne se connectent plus.';

  @override
  String get svcReasonSearch =>
      'Sans lui : la recherche dans Démarrer, Paramètres et l\'Explorateur devient lente et incomplète.';

  @override
  String get svcReasonSysMain =>
      'Précharge les applications utilisées souvent. Sans lui, les lancements peuvent être plus lents, surtout sur disque dur.';

  @override
  String get svcReasonTouchKeyboard =>
      'Sans lui : clavier tactile, écriture manuscrite, panneau des emojis et certaines méthodes de saisie ne fonctionnent plus.';

  @override
  String get svcReasonLocation =>
      'Sans lui : les applications et Localiser mon appareil ne peuvent plus obtenir votre position.';

  @override
  String get svcReasonBiometrics =>
      'Sans lui : la connexion par visage et empreinte de Windows Hello ne fonctionne plus.';

  @override
  String get svcReasonPhone =>
      'Sans lui : les appels via Mobile connecté ne fonctionnent plus.';

  @override
  String get svcReasonRemoteDesktop =>
      'Sans lui : le Bureau à distance vers ce PC ne fonctionne plus.';

  @override
  String get svcReasonSmartCard =>
      'Sans lui : les cartes à puce et certaines clés de sécurité ne fonctionnent plus.';

  @override
  String get svcReasonParental =>
      'Sans lui : les limites de Microsoft Family Safety ne sont plus appliquées.';

  @override
  String get svcReasonNfc =>
      'Sans lui : NFC et paiement sans contact ne fonctionnent plus.';

  @override
  String get svcReasonHotspot =>
      'Sans lui : le point d\'accès mobile ne fonctionne plus.';

  @override
  String get svcReasonScanner =>
      'Sans lui : les scanners et certains appareils photo ne fonctionnent plus.';

  @override
  String get svcReasonCompatibility =>
      'Sans lui : Windows ne propose plus de correctifs quand un ancien programme ne démarre pas.';

  @override
  String get svcReasonFax => 'Sans lui : le fax ne fonctionne plus.';

  @override
  String get svcReasonInsider =>
      'Sans lui : les builds Windows Insider n\'arrivent plus.';

  @override
  String get svcReasonUpdates =>
      'Windows Update en a besoin : sans lui, les correctifs de sécurité n\'arrivent plus.';

  @override
  String get svcReasonSecurity =>
      'Protège ce PC (antivirus, pare-feu, état de la sécurité).';

  @override
  String get svcReasonWindowsCore =>
      'Windows en a besoin pour le son, le réseau, les journaux ou les fonctions de base.';

  @override
  String get svcReasonNotReviewed =>
      'Fait partie de Windows et non vérifié : laissez-le tel quel.';

  @override
  String get svcReasonDriverService =>
      'Installé avec un pilote : laissez-le, sauf si vous savez ce qu\'il fait.';

  @override
  String get svcReasonMicrosoftApp =>
      'Appartient à une application Microsoft : sans lui, elle peut cesser de fonctionner ou de se mettre à jour.';

  @override
  String get svcReasonThirdParty =>
      'Installé avec un autre programme : sans lui, ce programme peut cesser de fonctionner ou de se mettre à jour.';

  @override
  String get serviceStartTypeAction => 'Changer le démarrage';

  @override
  String get presetsTab => 'Préréglages';

  @override
  String get presetDebloatName => 'Debloat seul';

  @override
  String get presetDebloatSummary =>
      'Supprime les applications Microsoft préinstallées peu utilisées. Rien d\'autre ne change.';

  @override
  String get presetCleanName => 'Propre';

  @override
  String get presetCleanSummary =>
      'Debloat, plus les services de télémétrie et inutilisés coupés et les applications lancées sans raison au démarrage.';

  @override
  String get presetGamingName => 'Gaming';

  @override
  String get presetGamingSummary =>
      'Propre, plus des réglages pour jouer : pas de bridage énergétique des applications, Fin de tâche dans la barre. Xbox reste.';

  @override
  String get presetPrivacyName => 'Confidentialité';

  @override
  String get presetPrivacySummary =>
      'Propre, plus les réglages de confidentialité du guide de Microsoft : ID publicitaire, suivi, suggestions, données de diagnostic au minimum.';

  @override
  String get presetCompetitiveName => 'Competitive';

  @override
  String get presetCompetitiveSummary =>
      'Retire tout ce que retirent les autres et plus : applications courantes, Xbox, impression, lanceurs au démarrage, enregistrement de jeu. Plus installation propre des pilotes et WinSux, à la main.';

  @override
  String get presetAttention => 'Attention';

  @override
  String get presetAttentionNote =>
      'Il retire beaucoup, y compris des choses très utilisées. Aucun gain de FPS, de latence ou autre n\'est promis : c\'est un ensemble de modifications, pas une amélioration mesurée.';

  @override
  String get presetGroupApps => 'Applications retirées (utilisateur actuel)';

  @override
  String get presetGroupServices => 'Services désactivés';

  @override
  String get presetGroupStartup => 'Entrées de démarrage coupées';

  @override
  String get presetGroupTweaks => 'Réglages';

  @override
  String get presetGroupThirdParty => 'Scripts et outils tiers';

  @override
  String get presetGroupRestart => 'Redémarrage';

  @override
  String get presetGroupReversible => 'Ce qui peut être annulé';

  @override
  String get presetRestartNeeded =>
      'Redémarrez ensuite : services et démarrage changent au prochain démarrage.';

  @override
  String get presetRestartNone => 'Aucun redémarrage nécessaire.';

  @override
  String get presetReversibleApps =>
      'Applications : réinstallez-les depuis le Microsoft Store.';

  @override
  String get presetReversibleSettings =>
      'Services, démarrage et réglages : annulez-les juste après avec Annuler le préréglage, ou plus tard avec le point de restauration créé avant.';

  @override
  String get presetReversibleManual =>
      'ZapTweaks n\'exécute pas les étapes tierces : pour les annuler, suivez les instructions de l\'auteur.';

  @override
  String get presetManualWhy =>
      'À la main : le script télécharge et exécute d\'autres fichiers qu\'on ne peut pas figer par un hash, donc ZapTweaks ne l\'exécute pas.';

  @override
  String get presetManualDriverClean =>
      'Installation propre du pilote graphique : DDU en mode sans échec, puis le dernier pilote du fabricant.';

  @override
  String get presetManualWinsux =>
      'WinSux : debloat et réglages de Windows en un seul script.';

  @override
  String get presetPreview => 'Aperçu sur ce PC';

  @override
  String get presetPreviewLoading =>
      'Lecture des applications, services, démarrage et réglages…';

  @override
  String get presetStatusApply => 'À faire';

  @override
  String get presetStatusDone => 'Déjà fait';

  @override
  String get presetStatusSkipped => 'Ignoré';

  @override
  String get presetStatusManual => 'À la main';

  @override
  String get presetSkipNotInstalled => 'non installée';

  @override
  String get presetSkipNotFound => 'absent de ce PC';

  @override
  String get presetSkipUnsupported => 'non pris en charge ici';

  @override
  String get presetSkipDuplicate =>
      'même nom deux fois : seule la première change';

  @override
  String presetCounts(int apply, int done, int skipped) {
    return '$apply à faire · $done déjà faits · $skipped ignorés';
  }

  @override
  String get presetConsent =>
      'J\'ai lu la liste complète et j\'accepte le risque.';

  @override
  String get presetApply => 'Appliquer le préréglage';

  @override
  String get presetApplyNote =>
      'Un point de restauration est créé d\'abord ; s\'il échoue, rien ne change. Les modifications administrateur demandent l\'UAC une fois.';

  @override
  String get presetApplying => 'Application…';

  @override
  String presetReport(int ok, int failed) {
    return 'Terminé : $ok modifiées, $failed non modifiées.';
  }

  @override
  String get presetUndo => 'Annuler le préréglage';

  @override
  String get presetUndone =>
      'Préréglage annulé. Les applications retirées le restent : réinstallez-les depuis le Store.';

  @override
  String get presetNothingToDo => 'Rien à faire : tout est déjà fait.';

  @override
  String get presetSaveAs => 'Enregistrer comme mon préréglage';

  @override
  String get presetSaveNote =>
      'Enregistre les éléments encore cochés. Partagez le fichier pour l\'exporter ; déposez-en un dans le dossier pour l\'importer.';

  @override
  String get presetName => 'Nom';

  @override
  String presetSaved(String path) {
    return 'Enregistré : $path';
  }

  @override
  String get presetOpenFolder => 'Ouvrir le dossier des préréglages';

  @override
  String get presetUserTitle => 'Mes préréglages';

  @override
  String presetInvalidFile(String file, String error) {
    return '$file non chargé : $error';
  }

  @override
  String get presetItemPowerThrottling =>
      'Bridage énergétique des applications désactivé';

  @override
  String get presetItemEndTask =>
      'Fin de tâche dans le menu de la barre des tâches';

  @override
  String get presetItemAdvertisingId => 'ID publicitaire désactivé';

  @override
  String get presetItemLanguageList =>
      'Les sites ne lisent pas votre liste de langues';

  @override
  String get presetItemAppLaunchTracking =>
      'Windows ne suit pas les applications lancées';

  @override
  String get presetItemTailoredExperiences =>
      'Pas d\'expériences personnalisées à partir des diagnostics';

  @override
  String get presetItemCloudContent =>
      'Pas de contenu optimisé par le cloud (suggestions)';

  @override
  String get presetItemDiagnosticData =>
      'Données de diagnostic : obligatoires uniquement';

  @override
  String get presetItemLockScreenOverlay =>
      'Pas d\'astuces sur l\'écran de verrouillage';

  @override
  String get presetItemLockScreenFacts =>
      'Pas d\'anecdotes sur l\'écran de verrouillage';

  @override
  String get presetItemGameDvr =>
      'Enregistrement de jeu de la Game Bar désactivé';

  @override
  String get presetSkipHasDependents =>
      'D’autres services en dépendent, Windows ne permet donc pas de le désactiver.';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsModes => 'Modes';

  @override
  String get settingsMaintenance => 'Maintenance';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get openLogFolderDescription =>
      'Journaux de session avec chaque commande exécutée par ZapTweaks.';

  @override
  String get redetectSystemStateDescription =>
      'Relit le matériel et l\'état de chaque réglage.';

  @override
  String get profileTitle => 'Profil de paramètres';

  @override
  String get profileDescription =>
      'Enregistrer les préférences de ZapTweaks dans un fichier ou les charger.';

  @override
  String get resetAppSettingsDescription =>
      'Revenir aux préférences par défaut de ZapTweaks. Windows n’est pas modifié.';

  @override
  String get expertModeOn => 'Activé';

  @override
  String get expertModeOff => 'Désactivé';
}
