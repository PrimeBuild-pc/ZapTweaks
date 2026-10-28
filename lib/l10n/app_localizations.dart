import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @externalDownload.
  ///
  /// In en, this message translates to:
  /// **'External download'**
  String get externalDownload;

  /// No description provided for @appRequirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get appRequirements;

  /// No description provided for @appWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get appWarnings;

  /// No description provided for @metricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get metricUnavailable;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ZapTweaks'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used by ZapTweaks.'**
  String get languageDescription;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow Windows or use a fixed light or dark app theme.'**
  String get appearanceDescription;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Windows default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @startWithWindows.
  ///
  /// In en, this message translates to:
  /// **'Start with Windows'**
  String get startWithWindows;

  /// No description provided for @startWithWindowsDescription.
  ///
  /// In en, this message translates to:
  /// **'Launch ZapTweaks after you sign in to Windows.'**
  String get startWithWindowsDescription;

  /// No description provided for @openLogFolder.
  ///
  /// In en, this message translates to:
  /// **'Open log folder'**
  String get openLogFolder;

  /// No description provided for @redetectSystemState.
  ///
  /// In en, this message translates to:
  /// **'Re-detect system state'**
  String get redetectSystemState;

  /// No description provided for @exportProfile.
  ///
  /// In en, this message translates to:
  /// **'Export profile'**
  String get exportProfile;

  /// No description provided for @importProfile.
  ///
  /// In en, this message translates to:
  /// **'Import profile'**
  String get importProfile;

  /// No description provided for @resetAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset app settings'**
  String get resetAppSettings;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @automaticUpdateNotifications.
  ///
  /// In en, this message translates to:
  /// **'Automatic update notifications'**
  String get automaticUpdateNotifications;

  /// No description provided for @automaticUpdateDescription.
  ///
  /// In en, this message translates to:
  /// **'Check at startup and show a notification dot. Updates are never installed automatically.'**
  String get automaticUpdateDescription;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get checkNow;

  /// No description provided for @viewRelease.
  ///
  /// In en, this message translates to:
  /// **'View release'**
  String get viewRelease;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @applicationVersion.
  ///
  /// In en, this message translates to:
  /// **'Application version'**
  String get applicationVersion;

  /// No description provided for @dryRunMode.
  ///
  /// In en, this message translates to:
  /// **'Dry-run mode'**
  String get dryRunMode;

  /// No description provided for @dryRunDescription.
  ///
  /// In en, this message translates to:
  /// **'Simulate commands without changing Windows.'**
  String get dryRunDescription;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get operationFailed;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'An update is available'**
  String get updateAvailable;

  /// No description provided for @updateAvailableDescription.
  ///
  /// In en, this message translates to:
  /// **'You can review the release notes or install it directly.'**
  String get updateAvailableDescription;

  /// No description provided for @updateAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableShort;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates'**
  String get checkingForUpdates;

  /// No description provided for @contactingReleaseServer.
  ///
  /// In en, this message translates to:
  /// **'Contacting the release server...'**
  String get contactingReleaseServer;

  /// No description provided for @updateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'ZapTweaks {version} is available'**
  String updateDialogTitle(Object version);

  /// No description provided for @installedVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed version: {version}'**
  String installedVersion(Object version);

  /// No description provided for @releaseNotesOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'Release notes are available on GitHub.'**
  String get releaseNotesOnGitHub;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update'**
  String get downloadingUpdate;

  /// No description provided for @downloadingUpdateDescription.
  ///
  /// In en, this message translates to:
  /// **'Downloading and preparing the installer...'**
  String get downloadingUpdateDescription;

  /// No description provided for @adminPrivilegesRequired.
  ///
  /// In en, this message translates to:
  /// **'Administrator privileges are required'**
  String get adminPrivilegesRequired;

  /// No description provided for @adminRequiredBanner.
  ///
  /// In en, this message translates to:
  /// **'Close the app and launch ZapTweaks with \"Run as administrator\". Without elevation, system tweaks cannot be applied safely.'**
  String get adminRequiredBanner;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createRestorePoint.
  ///
  /// In en, this message translates to:
  /// **'Create restore point'**
  String get createRestorePoint;

  /// No description provided for @adminRequiredDialog.
  ///
  /// In en, this message translates to:
  /// **'ZapTweaks needs administrator permissions to apply system settings.\n\nClose the app, right-click the executable, and select \"Run as administrator\".'**
  String get adminRequiredDialog;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: v{version}'**
  String aboutVersion(Object version);

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author: PrimeBuild'**
  String get author;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Advanced optimization companion for deeper Windows gaming, hardware, and diagnostics workflows.'**
  String get aboutDescription;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year: {year}'**
  String year(Object year);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @discord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get discord;

  /// No description provided for @homeAndStats.
  ///
  /// In en, this message translates to:
  /// **'Home & Stats'**
  String get homeAndStats;

  /// No description provided for @cpuUsage.
  ///
  /// In en, this message translates to:
  /// **'CPU Usage'**
  String get cpuUsage;

  /// No description provided for @cpuUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'Realtime utilization from Windows counters'**
  String get cpuUsageDescription;

  /// No description provided for @gpuUsage.
  ///
  /// In en, this message translates to:
  /// **'GPU Usage'**
  String get gpuUsage;

  /// No description provided for @gpuUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'Realtime engine utilization'**
  String get gpuUsageDescription;

  /// No description provided for @vramUsage.
  ///
  /// In en, this message translates to:
  /// **'VRAM Usage'**
  String get vramUsage;

  /// No description provided for @memoryUsage.
  ///
  /// In en, this message translates to:
  /// **'Memory Usage'**
  String get memoryUsage;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @installedRam.
  ///
  /// In en, this message translates to:
  /// **'Installed RAM'**
  String get installedRam;

  /// No description provided for @networkAdapters.
  ///
  /// In en, this message translates to:
  /// **'Network Adapters'**
  String get networkAdapters;

  /// No description provided for @noConnectedAdapters.
  ///
  /// In en, this message translates to:
  /// **'No connected adapters detected'**
  String get noConnectedAdapters;

  /// No description provided for @audioDevices.
  ///
  /// In en, this message translates to:
  /// **'Audio Devices'**
  String get audioDevices;

  /// No description provided for @noAudioDevices.
  ///
  /// In en, this message translates to:
  /// **'No audio devices detected'**
  String get noAudioDevices;

  /// No description provided for @noTweaksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tweaks are available for your hardware configuration.'**
  String get noTweaksAvailable;

  /// No description provided for @detectedHardware.
  ///
  /// In en, this message translates to:
  /// **'Detected hardware'**
  String get detectedHardware;

  /// No description provided for @gpuUnknown.
  ///
  /// In en, this message translates to:
  /// **'GPU: Unknown'**
  String get gpuUnknown;

  /// No description provided for @cpuValue.
  ///
  /// In en, this message translates to:
  /// **'CPU: {value}'**
  String cpuValue(Object value);

  /// No description provided for @gpuValue.
  ///
  /// In en, this message translates to:
  /// **'GPU: {value}'**
  String gpuValue(Object value);

  /// No description provided for @ramValue.
  ///
  /// In en, this message translates to:
  /// **'RAM: {value}'**
  String ramValue(Object value);

  /// No description provided for @enableAllVisible.
  ///
  /// In en, this message translates to:
  /// **'Enable all visible'**
  String get enableAllVisible;

  /// No description provided for @disableAllVisible.
  ///
  /// In en, this message translates to:
  /// **'Disable all visible'**
  String get disableAllVisible;

  /// No description provided for @restartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart now'**
  String get restartNow;

  /// No description provided for @restartRequired.
  ///
  /// In en, this message translates to:
  /// **'Restart required'**
  String get restartRequired;

  /// No description provided for @restartRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'A system restart is required to fully apply one or more changes.'**
  String get restartRequiredDescription;

  /// No description provided for @advancedActionsIncluded.
  ///
  /// In en, this message translates to:
  /// **'Advanced actions included'**
  String get advancedActionsIncluded;

  /// No description provided for @advancedActionsDescription.
  ///
  /// In en, this message translates to:
  /// **'External tools, launcher actions, and script-driven utilities are grouped here for quick diagnostics and maintenance workflows.'**
  String get advancedActionsDescription;

  /// No description provided for @aggressiveTweakWarning.
  ///
  /// In en, this message translates to:
  /// **'Aggressive tweak. A restore point is recommended.'**
  String get aggressiveTweakWarning;

  /// No description provided for @networkReconnectWarning.
  ///
  /// In en, this message translates to:
  /// **'Network adapter reconnect or system restart may be required.'**
  String get networkReconnectWarning;

  /// No description provided for @actionWarning.
  ///
  /// In en, this message translates to:
  /// **'Action warning'**
  String get actionWarning;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error.'**
  String get unknownError;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @presetFailed.
  ///
  /// In en, this message translates to:
  /// **'Preset failed'**
  String get presetFailed;

  /// No description provided for @safetyWarning.
  ///
  /// In en, this message translates to:
  /// **'Safety warning'**
  String get safetyWarning;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @powerPlans.
  ///
  /// In en, this message translates to:
  /// **'Power Settings Explorer'**
  String get powerPlans;

  /// No description provided for @powerPlansDescription.
  ///
  /// In en, this message translates to:
  /// **'Import and activate a bundled plan. ZapTweaks remembers the previous active plan for restore.'**
  String get powerPlansDescription;

  /// No description provided for @noPowerPlans.
  ///
  /// In en, this message translates to:
  /// **'No bundled power plans were found.'**
  String get noPowerPlans;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get working;

  /// No description provided for @importAndActivate.
  ///
  /// In en, this message translates to:
  /// **'Import and activate'**
  String get importAndActivate;

  /// No description provided for @restorePreviousPlan.
  ///
  /// In en, this message translates to:
  /// **'Restore previous plan'**
  String get restorePreviousPlan;

  /// No description provided for @ran.
  ///
  /// In en, this message translates to:
  /// **'Ran'**
  String get ran;

  /// No description provided for @gpuDrivers.
  ///
  /// In en, this message translates to:
  /// **'GPU Drivers'**
  String get gpuDrivers;

  /// No description provided for @noGpuDrivers.
  ///
  /// In en, this message translates to:
  /// **'No GPU drivers detected'**
  String get noGpuDrivers;

  /// No description provided for @chipsetDrivers.
  ///
  /// In en, this message translates to:
  /// **'Chipset Drivers'**
  String get chipsetDrivers;

  /// No description provided for @noChipsetDrivers.
  ///
  /// In en, this message translates to:
  /// **'No chipset drivers detected'**
  String get noChipsetDrivers;

  /// No description provided for @monitors.
  ///
  /// In en, this message translates to:
  /// **'Monitors'**
  String get monitors;

  /// No description provided for @noMonitors.
  ///
  /// In en, this message translates to:
  /// **'No monitors detected'**
  String get noMonitors;

  /// No description provided for @mice.
  ///
  /// In en, this message translates to:
  /// **'Mice'**
  String get mice;

  /// No description provided for @noMice.
  ///
  /// In en, this message translates to:
  /// **'No mice detected'**
  String get noMice;

  /// No description provided for @keyboards.
  ///
  /// In en, this message translates to:
  /// **'Keyboards'**
  String get keyboards;

  /// No description provided for @noKeyboards.
  ///
  /// In en, this message translates to:
  /// **'No keyboards detected'**
  String get noKeyboards;

  /// No description provided for @restorePointPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a restore point?'**
  String get restorePointPromptTitle;

  /// No description provided for @restorePointPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'ZapTweaks can create a Windows restore point before changing system settings. This is optional: skip it and the change is applied anyway. You are asked only once per session.'**
  String get restorePointPromptMessage;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @tweaksSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'TWEAKS'**
  String get tweaksSectionHeader;

  /// No description provided for @startingUp.
  ///
  /// In en, this message translates to:
  /// **'Starting ZapTweaks'**
  String get startingUp;

  /// No description provided for @expertMode.
  ///
  /// In en, this message translates to:
  /// **'Expert mode'**
  String get expertMode;

  /// No description provided for @expertModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Show advanced operations and external tools only after explicit manual consent. It is off by default; safety restrictions still apply.'**
  String get expertModeDescription;

  /// No description provided for @searchOperations.
  ///
  /// In en, this message translates to:
  /// **'Search operations'**
  String get searchOperations;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @searchSections.
  ///
  /// In en, this message translates to:
  /// **'Sections and integrated tools'**
  String get searchSections;

  /// No description provided for @searchApps.
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get searchApps;

  /// No description provided for @searchCatalog.
  ///
  /// In en, this message translates to:
  /// **'Operations and external tools'**
  String get searchCatalog;

  /// No description provided for @searchOpenResult.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get searchOpenResult;

  /// No description provided for @searchExpertRequired.
  ///
  /// In en, this message translates to:
  /// **'Enable Expert mode to open'**
  String get searchExpertRequired;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching sections, apps, operations, or tools.'**
  String get noSearchResults;

  /// No description provided for @operationTaskbarEndTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Taskbar End task'**
  String get operationTaskbarEndTaskTitle;

  /// No description provided for @operationTaskbarEndTaskDescription.
  ///
  /// In en, this message translates to:
  /// **'Show End task in taskbar app context menus.'**
  String get operationTaskbarEndTaskDescription;

  /// No description provided for @appStore.
  ///
  /// In en, this message translates to:
  /// **'App store'**
  String get appStore;

  /// No description provided for @appManagement.
  ///
  /// In en, this message translates to:
  /// **'Installed apps'**
  String get appManagement;

  /// No description provided for @windowsAppTools.
  ///
  /// In en, this message translates to:
  /// **'Windows app tools'**
  String get windowsAppTools;

  /// No description provided for @optionalFeatures.
  ///
  /// In en, this message translates to:
  /// **'Optional features'**
  String get optionalFeatures;

  /// No description provided for @searchOptionalFeatures.
  ///
  /// In en, this message translates to:
  /// **'Search optional features'**
  String get searchOptionalFeatures;

  /// No description provided for @scanOptionalFeatures.
  ///
  /// In en, this message translates to:
  /// **'Scan features (UAC)'**
  String get scanOptionalFeatures;

  /// No description provided for @optionalFeaturesUacNotice.
  ///
  /// In en, this message translates to:
  /// **'Feature inventory and each change run through the allowlisted helper. No change occurs during scanning.'**
  String get optionalFeaturesUacNotice;

  /// No description provided for @confirmOptionalFeatureChange.
  ///
  /// In en, this message translates to:
  /// **'Confirm optional feature change'**
  String get confirmOptionalFeatureChange;

  /// No description provided for @confirmOptionalFeatureChangeMessage.
  ///
  /// In en, this message translates to:
  /// **'Feature: {name}\nAction: {action}\n\nWindows may require a restart. The previous enabled state is captured before the change.'**
  String confirmOptionalFeatureChangeMessage(Object name, Object action);

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @enablePending.
  ///
  /// In en, this message translates to:
  /// **'Enable pending restart'**
  String get enablePending;

  /// No description provided for @disablePending.
  ///
  /// In en, this message translates to:
  /// **'Disable pending restart'**
  String get disablePending;

  /// No description provided for @startupApps.
  ///
  /// In en, this message translates to:
  /// **'Startup apps'**
  String get startupApps;

  /// No description provided for @searchStartupApps.
  ///
  /// In en, this message translates to:
  /// **'Search startup apps'**
  String get searchStartupApps;

  /// No description provided for @openStartupSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Startup Settings'**
  String get openStartupSettings;

  /// No description provided for @openTaskManagerStartup.
  ///
  /// In en, this message translates to:
  /// **'Open Task Manager Startup'**
  String get openTaskManagerStartup;

  /// No description provided for @startupInventoryNotice.
  ///
  /// In en, this message translates to:
  /// **'Read-only startup inventory. Use Windows Settings or Task Manager to change an entry.'**
  String get startupInventoryNotice;

  /// No description provided for @guidedSetup.
  ///
  /// In en, this message translates to:
  /// **'Guided setup'**
  String get guidedSetup;

  /// No description provided for @wizardInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get wizardInventory;

  /// No description provided for @wizardBaseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get wizardBaseline;

  /// No description provided for @wizardWindowsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Windows Update'**
  String get wizardWindowsUpdate;

  /// No description provided for @wizardDrivers.
  ///
  /// In en, this message translates to:
  /// **'Driver check'**
  String get wizardDrivers;

  /// No description provided for @wizardApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get wizardApplications;

  /// No description provided for @wizardDebloat.
  ///
  /// In en, this message translates to:
  /// **'Selective debloat'**
  String get wizardDebloat;

  /// No description provided for @wizardPrivacyInterface.
  ///
  /// In en, this message translates to:
  /// **'Privacy and interface'**
  String get wizardPrivacyInterface;

  /// No description provided for @wizardPreview.
  ///
  /// In en, this message translates to:
  /// **'Plan preview'**
  String get wizardPreview;

  /// No description provided for @wizardApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get wizardApply;

  /// No description provided for @wizardReport.
  ///
  /// In en, this message translates to:
  /// **'Final report'**
  String get wizardReport;

  /// No description provided for @wizardInventoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Read hardware, installed winget packages, and present devices before making choices.'**
  String get wizardInventoryDescription;

  /// No description provided for @runInventory.
  ///
  /// In en, this message translates to:
  /// **'Run inventory'**
  String get runInventory;

  /// No description provided for @inventorySummary.
  ///
  /// In en, this message translates to:
  /// **'Detected {apps} winget packages and {devices} present devices.'**
  String inventorySummary(Object apps, Object devices);

  /// No description provided for @wizardUpdateNotice.
  ///
  /// In en, this message translates to:
  /// **'Review Windows Update before driver and app changes. ZapTweaks does not install updates automatically.'**
  String get wizardUpdateNotice;

  /// No description provided for @openWindowsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Open Windows Update'**
  String get openWindowsUpdate;

  /// No description provided for @updatesReviewed.
  ///
  /// In en, this message translates to:
  /// **'I reviewed Windows Update'**
  String get updatesReviewed;

  /// No description provided for @driverInventorySummary.
  ///
  /// In en, this message translates to:
  /// **'Present devices: {devices}\nDevices without a bound INF: {missing}'**
  String driverInventorySummary(Object devices, Object missing);

  /// No description provided for @wizardDebloatNotice.
  ///
  /// In en, this message translates to:
  /// **'No debloat choice is implicit. Only current-user AppX packages with a verified restore source can be selected here; other removals remain available from App → Installed apps with a separate preview.'**
  String get wizardDebloatNotice;

  /// No description provided for @wizardPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Privacy and interface settings remain unchanged unless selected explicitly below.'**
  String get wizardPrivacyNotice;

  /// No description provided for @noAppsSelected.
  ///
  /// In en, this message translates to:
  /// **'No operations selected. The wizard will make no changes.'**
  String get noAppsSelected;

  /// No description provided for @planContains.
  ///
  /// In en, this message translates to:
  /// **'The plan contains {count} explicit operation(s):'**
  String planContains(Object count);

  /// No description provided for @readyToApply.
  ///
  /// In en, this message translates to:
  /// **'Ready to apply {count} app operation(s). Each package is verified after winget completes.'**
  String readyToApply(Object count);

  /// No description provided for @noPlanReport.
  ///
  /// In en, this message translates to:
  /// **'Finished without applying a plan.'**
  String get noPlanReport;

  /// No description provided for @planStatus.
  ///
  /// In en, this message translates to:
  /// **'Plan status'**
  String get planStatus;

  /// No description provided for @applyPlan.
  ///
  /// In en, this message translates to:
  /// **'Apply plan'**
  String get applyPlan;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recovery;

  /// No description provided for @diagnosticTools.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic tools'**
  String get diagnosticTools;

  /// No description provided for @repairComponentStore.
  ///
  /// In en, this message translates to:
  /// **'Repair Windows component store'**
  String get repairComponentStore;

  /// No description provided for @repairComponentStoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Runs DISM RestoreHealth, then a separate ScanHealth verification. This can take a long time.'**
  String get repairComponentStoreDescription;

  /// No description provided for @repairSystemFiles.
  ///
  /// In en, this message translates to:
  /// **'Repair protected system files'**
  String get repairSystemFiles;

  /// No description provided for @repairSystemFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Runs SFC scan and repair, then a separate verification pass.'**
  String get repairSystemFilesDescription;

  /// No description provided for @confirmSystemRepair.
  ///
  /// In en, this message translates to:
  /// **'Confirm Windows repair'**
  String get confirmSystemRepair;

  /// No description provided for @systemRepairWarning.
  ///
  /// In en, this message translates to:
  /// **'The repair may replace corrupted Windows components and cannot be rolled back by ZapTweaks. Do not turn off the PC while it runs.'**
  String get systemRepairWarning;

  /// No description provided for @systemRepairVerified.
  ///
  /// In en, this message translates to:
  /// **'Repair completed and the verification pass succeeded.'**
  String get systemRepairVerified;

  /// No description provided for @runRepair.
  ///
  /// In en, this message translates to:
  /// **'Run repair'**
  String get runRepair;

  /// No description provided for @operationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Operation completed'**
  String get operationCompleted;

  /// No description provided for @captureEtwTrace.
  ///
  /// In en, this message translates to:
  /// **'Capture performance trace'**
  String get captureEtwTrace;

  /// No description provided for @captureEtwTraceDescription.
  ///
  /// In en, this message translates to:
  /// **'Records a bounded Windows Performance Recorder trace and produces a DPC/ISR diagnostic report on demand. No monitor remains active.'**
  String get captureEtwTraceDescription;

  /// No description provided for @dpcLatencyAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'DPC / ISR latency analyzer'**
  String get dpcLatencyAnalyzer;

  /// No description provided for @dpcLatencyAnalyzerDescription.
  ///
  /// In en, this message translates to:
  /// **'Captures ETW on demand and reports DPC, ISR, hard-fault and context-switch activity, per-processor distribution, observed kernel-module names and ETW providers.'**
  String get dpcLatencyAnalyzerDescription;

  /// No description provided for @diagnosticNotCausality.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic signal, not a latency verdict'**
  String get diagnosticNotCausality;

  /// No description provided for @diagnosticNotCausalityDescription.
  ///
  /// In en, this message translates to:
  /// **'Counts and observed module names help narrow an investigation but do not prove that a driver caused latency. Confirm with repeatable A/B/A traces and WPA or vendor tooling.'**
  String get diagnosticNotCausalityDescription;

  /// No description provided for @startDpcCapture.
  ///
  /// In en, this message translates to:
  /// **'Start capture'**
  String get startDpcCapture;

  /// No description provided for @openTraceFolder.
  ///
  /// In en, this message translates to:
  /// **'Open trace folder'**
  String get openTraceFolder;

  /// No description provided for @captureInProgress.
  ///
  /// In en, this message translates to:
  /// **'Capturing for {seconds} seconds… keep the workload running.'**
  String captureInProgress(int seconds);

  /// No description provided for @traceDuration.
  ///
  /// In en, this message translates to:
  /// **'Observed duration'**
  String get traceDuration;

  /// No description provided for @hardFaults.
  ///
  /// In en, this message translates to:
  /// **'Hard faults'**
  String get hardFaults;

  /// No description provided for @contextSwitches.
  ///
  /// In en, this message translates to:
  /// **'Context switches'**
  String get contextSwitches;

  /// No description provided for @totalEvents.
  ///
  /// In en, this message translates to:
  /// **'Total ETW events'**
  String get totalEvents;

  /// No description provided for @kernelModulesObserved.
  ///
  /// In en, this message translates to:
  /// **'Kernel modules observed in DPC/ISR events'**
  String get kernelModulesObserved;

  /// No description provided for @noKernelModulesObserved.
  ///
  /// In en, this message translates to:
  /// **'The exported events did not expose kernel module names. Open the ETL in WPA for symbol-aware analysis.'**
  String get noKernelModulesObserved;

  /// No description provided for @dpcIsrByProcessor.
  ///
  /// In en, this message translates to:
  /// **'DPC/ISR events by logical processor'**
  String get dpcIsrByProcessor;

  /// No description provided for @noProcessorDistribution.
  ///
  /// In en, this message translates to:
  /// **'Processor IDs were not present in the exported events.'**
  String get noProcessorDistribution;

  /// No description provided for @topEtwProviders.
  ///
  /// In en, this message translates to:
  /// **'Top ETW providers'**
  String get topEtwProviders;

  /// No description provided for @noProviderData.
  ///
  /// In en, this message translates to:
  /// **'No provider data was available.'**
  String get noProviderData;

  /// No description provided for @etwTraceSaved.
  ///
  /// In en, this message translates to:
  /// **'Trace saved to {path}'**
  String etwTraceSaved(Object path);

  /// No description provided for @cleanupDiagnosticTraces.
  ///
  /// In en, this message translates to:
  /// **'Delete diagnostic traces'**
  String get cleanupDiagnosticTraces;

  /// No description provided for @cleanupDiagnosticTracesDescription.
  ///
  /// In en, this message translates to:
  /// **'Scans only ZapTweaks trace files, shows the exact file count and byte total, then deletes them after confirmation.'**
  String get cleanupDiagnosticTracesDescription;

  /// No description provided for @cleanupTracePreview.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} ZapTweaks trace files ({bytes} bytes)? This cannot be undone.'**
  String cleanupTracePreview(int count, int bytes);

  /// No description provided for @cleanupTracesCompleted.
  ///
  /// In en, this message translates to:
  /// **'The previewed diagnostic traces were deleted and verified absent.'**
  String get cleanupTracesCompleted;

  /// No description provided for @noDiagnosticTraces.
  ///
  /// In en, this message translates to:
  /// **'No ZapTweaks diagnostic traces were found.'**
  String get noDiagnosticTraces;

  /// No description provided for @hardwareMonitor.
  ///
  /// In en, this message translates to:
  /// **'Hardware monitor'**
  String get hardwareMonitor;

  /// No description provided for @dedicatedVramUsage.
  ///
  /// In en, this message translates to:
  /// **'Dedicated GPU memory in use'**
  String get dedicatedVramUsage;

  /// No description provided for @dedicatedVramUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'Takes one Windows GPU performance-counter snapshot. Nothing keeps running afterward.'**
  String get dedicatedVramUsageDescription;

  /// No description provided for @vramUsageValue.
  ///
  /// In en, this message translates to:
  /// **'{megabytes} MB'**
  String vramUsageValue(Object megabytes);

  /// No description provided for @captureNow.
  ///
  /// In en, this message translates to:
  /// **'Capture now'**
  String get captureNow;

  /// No description provided for @tweaks.
  ///
  /// In en, this message translates to:
  /// **'Tweaks'**
  String get tweaks;

  /// No description provided for @searchPowerPlans.
  ///
  /// In en, this message translates to:
  /// **'Search power plans'**
  String get searchPowerPlans;

  /// No description provided for @activePowerPlan.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activePowerPlan;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @noPowerDifferences.
  ///
  /// In en, this message translates to:
  /// **'No AC/DC value differences were found.'**
  String get noPowerDifferences;

  /// No description provided for @importPowerPlan.
  ///
  /// In en, this message translates to:
  /// **'Import .pow'**
  String get importPowerPlan;

  /// No description provided for @importPowerPlanDescription.
  ///
  /// In en, this message translates to:
  /// **'Imports one locally selected power plan after bounded, hash-verified staging.'**
  String get importPowerPlanDescription;

  /// No description provided for @exportActivePowerPlan.
  ///
  /// In en, this message translates to:
  /// **'Export active plan'**
  String get exportActivePowerPlan;

  /// No description provided for @restoreDefaultPowerSchemes.
  ///
  /// In en, this message translates to:
  /// **'Restore Windows defaults'**
  String get restoreDefaultPowerSchemes;

  /// No description provided for @restoreDefaultPowerSchemesDescription.
  ///
  /// In en, this message translates to:
  /// **'Exports and hashes every current scheme before asking Windows to restore its defaults.'**
  String get restoreDefaultPowerSchemesDescription;

  /// No description provided for @restoreDefaultPowerSchemesWarning.
  ///
  /// In en, this message translates to:
  /// **'Replace all current power schemes with Windows defaults? ZapTweaks will first export every scheme for exact rollback.'**
  String get restoreDefaultPowerSchemesWarning;

  /// No description provided for @interruptConfiguration.
  ///
  /// In en, this message translates to:
  /// **'MSI Utility v3 & Interrupt Affinity'**
  String get interruptConfiguration;

  /// No description provided for @interruptConfigurationDescription.
  ///
  /// In en, this message translates to:
  /// **'Advanced, capability-gated MSI and group-0 interrupt-affinity controls for present display, network, media, USB host, and HD audio devices. No value is recommended automatically.'**
  String get interruptConfigurationDescription;

  /// No description provided for @configureMsi.
  ///
  /// In en, this message translates to:
  /// **'Configure MSI'**
  String get configureMsi;

  /// No description provided for @enableMsi.
  ///
  /// In en, this message translates to:
  /// **'Enable message-signaled interrupts'**
  String get enableMsi;

  /// No description provided for @configureInterruptAffinity.
  ///
  /// In en, this message translates to:
  /// **'Configure affinity'**
  String get configureInterruptAffinity;

  /// No description provided for @interruptChangeWarning.
  ///
  /// In en, this message translates to:
  /// **'An invalid interrupt policy can make the device unavailable until rollback or reboot. ZapTweaks validates hardware limits and snapshots the exact current values.'**
  String get interruptChangeWarning;

  /// No description provided for @affinityMaskHint.
  ///
  /// In en, this message translates to:
  /// **'Group-0 hexadecimal mask, for example 3'**
  String get affinityMaskHint;

  /// No description provided for @invalidAffinityMask.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-zero canonical hexadecimal mask of at most 64 bits.'**
  String get invalidAffinityMask;

  /// No description provided for @msiRange.
  ///
  /// In en, this message translates to:
  /// **'Message count must be between 1 and {maximum}.'**
  String msiRange(int maximum);

  /// No description provided for @noCompatibleInterruptDevices.
  ///
  /// In en, this message translates to:
  /// **'No present display, network, media, USB host, or HD audio PCI device exposes compatible interrupt capabilities.'**
  String get noCompatibleInterruptDevices;

  /// No description provided for @interruptCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Hardware: Line {line} · MSI {msi} · MSI-X {msix} · maximum messages {maximum}'**
  String interruptCapabilities(
    Object line,
    Object msi,
    Object msix,
    int maximum,
  );

  /// No description provided for @messageNumberLimit.
  ///
  /// In en, this message translates to:
  /// **'Message number limit'**
  String get messageNumberLimit;

  /// No description provided for @interruptPriority.
  ///
  /// In en, this message translates to:
  /// **'Interrupt priority policy'**
  String get interruptPriority;

  /// No description provided for @interruptPriorityDefault.
  ///
  /// In en, this message translates to:
  /// **'Undefined / driver default'**
  String get interruptPriorityDefault;

  /// No description provided for @interruptPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get interruptPriorityLow;

  /// No description provided for @interruptPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get interruptPriorityNormal;

  /// No description provided for @interruptPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get interruptPriorityHigh;

  /// No description provided for @interruptPolicy.
  ///
  /// In en, this message translates to:
  /// **'Processor affinity policy'**
  String get interruptPolicy;

  /// No description provided for @interruptPolicyDefault.
  ///
  /// In en, this message translates to:
  /// **'Machine default'**
  String get interruptPolicyDefault;

  /// No description provided for @interruptPolicyAllClose.
  ///
  /// In en, this message translates to:
  /// **'All close processors'**
  String get interruptPolicyAllClose;

  /// No description provided for @interruptPolicyOneClose.
  ///
  /// In en, this message translates to:
  /// **'One close processor'**
  String get interruptPolicyOneClose;

  /// No description provided for @interruptPolicyAllProcessors.
  ///
  /// In en, this message translates to:
  /// **'All processors'**
  String get interruptPolicyAllProcessors;

  /// No description provided for @interruptPolicySpecified.
  ///
  /// In en, this message translates to:
  /// **'Specified processors (group 0)'**
  String get interruptPolicySpecified;

  /// No description provided for @interruptPolicySpread.
  ///
  /// In en, this message translates to:
  /// **'Spread messages across processors'**
  String get interruptPolicySpread;

  /// No description provided for @selectLogicalProcessors.
  ///
  /// In en, this message translates to:
  /// **'Select logical processors in processor group 0'**
  String get selectLogicalProcessors;

  /// No description provided for @affinitySelectAll.
  ///
  /// In en, this message translates to:
  /// **'All logical processors'**
  String get affinitySelectAll;

  /// No description provided for @affinityClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get affinityClear;

  /// No description provided for @affinityPhysicalCores.
  ///
  /// In en, this message translates to:
  /// **'One thread per physical core'**
  String get affinityPhysicalCores;

  /// No description provided for @affinityPerformanceCores.
  ///
  /// In en, this message translates to:
  /// **'Performance cores'**
  String get affinityPerformanceCores;

  /// No description provided for @affinityEfficiencyCores.
  ///
  /// In en, this message translates to:
  /// **'Efficiency cores'**
  String get affinityEfficiencyCores;

  /// No description provided for @affinityParked.
  ///
  /// In en, this message translates to:
  /// **'parked'**
  String get affinityParked;

  /// No description provided for @affinityLlcGroup.
  ///
  /// In en, this message translates to:
  /// **'LLC / CCD {index}'**
  String affinityLlcGroup(int index);

  /// No description provided for @affinityNumaNode.
  ///
  /// In en, this message translates to:
  /// **'NUMA node {index}'**
  String affinityNumaNode(int index);

  /// No description provided for @compatibleDevices.
  ///
  /// In en, this message translates to:
  /// **'Compatible devices'**
  String get compatibleDevices;

  /// No description provided for @msiEnabledDevices.
  ///
  /// In en, this message translates to:
  /// **'MSI currently enabled'**
  String get msiEnabledDevices;

  /// No description provided for @logicalProcessors.
  ///
  /// In en, this message translates to:
  /// **'Logical processors'**
  String get logicalProcessors;

  /// No description provided for @searchDevices.
  ///
  /// In en, this message translates to:
  /// **'Search devices, instance IDs, or driver INF'**
  String get searchDevices;

  /// No description provided for @driverUnknown.
  ///
  /// In en, this message translates to:
  /// **'Driver INF unavailable'**
  String get driverUnknown;

  /// No description provided for @currentInterruptConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Current: {mode} · messages {messages} · priority {priority} · policy {policy} · mask {mask}'**
  String currentInterruptConfiguration(
    Object mode,
    Object messages,
    Object priority,
    Object policy,
    Object mask,
  );

  /// No description provided for @renamePowerPlan.
  ///
  /// In en, this message translates to:
  /// **'Rename power plan'**
  String get renamePowerPlan;

  /// No description provided for @renamePowerPlanDescription.
  ///
  /// In en, this message translates to:
  /// **'Changes only the selected plan\'s display name and preserves the original name for rollback.'**
  String get renamePowerPlanDescription;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @duplicatePowerPlan.
  ///
  /// In en, this message translates to:
  /// **'Duplicate power plan'**
  String get duplicatePowerPlan;

  /// No description provided for @duplicatePowerPlanDescription.
  ///
  /// In en, this message translates to:
  /// **'Creates and verifies a PowrProf copy. Rollback is best effort because Windows assigns its GUID during creation.'**
  String get duplicatePowerPlanDescription;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @powerValueRange.
  ///
  /// In en, this message translates to:
  /// **'Values must be between 0 and {maximum}.'**
  String powerValueRange(int maximum);

  /// No description provided for @powerSettingConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure any bounded power setting'**
  String get powerSettingConfigure;

  /// No description provided for @powerSettingConfigureDescription.
  ///
  /// In en, this message translates to:
  /// **'Edits a setting exposed by PowrProf only when Windows provides live minimum, maximum, and increment metadata.'**
  String get powerSettingConfigureDescription;

  /// No description provided for @searchPowerSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings, descriptions, subgroups, or GUIDs'**
  String get searchPowerSettings;

  /// No description provided for @allPowerSubgroups.
  ///
  /// In en, this message translates to:
  /// **'All power-setting groups'**
  String get allPowerSubgroups;

  /// No description provided for @powerSettingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} settings'**
  String powerSettingCount(int count);

  /// No description provided for @powerSettingOptions.
  ///
  /// In en, this message translates to:
  /// **'{count} Windows-defined options'**
  String powerSettingOptions(int count);

  /// No description provided for @backToPowerPlans.
  ///
  /// In en, this message translates to:
  /// **'Back to power plans'**
  String get backToPowerPlans;

  /// No description provided for @powerPlanEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Duplicate a plan to create your custom profile, then open Details and edit its hidden AC/DC settings one by one.'**
  String get powerPlanEditorHint;

  /// No description provided for @powerSettingRange.
  ///
  /// In en, this message translates to:
  /// **'Range {minimum}–{maximum}, step {increment}'**
  String powerSettingRange(Object minimum, Object maximum, Object increment);

  /// No description provided for @powerSettingBoundsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Windows did not expose safe values or bounds for this setting.'**
  String get powerSettingBoundsUnavailable;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePowerPlan.
  ///
  /// In en, this message translates to:
  /// **'Delete power plan'**
  String get deletePowerPlan;

  /// No description provided for @deletePowerPlanDescription.
  ///
  /// In en, this message translates to:
  /// **'Exports the selected inactive plan before deleting it and preserves the backup for exact rollback.'**
  String get deletePowerPlanDescription;

  /// No description provided for @deletePowerPlanWarning.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? ZapTweaks will export a recovery copy first.'**
  String deletePowerPlanWarning(Object name);

  /// No description provided for @firmwareTemperatures.
  ///
  /// In en, this message translates to:
  /// **'Firmware thermal zones'**
  String get firmwareTemperatures;

  /// No description provided for @firmwareTemperaturesDescription.
  ///
  /// In en, this message translates to:
  /// **'Reads ACPI thermal zones once. Availability and sensor meaning depend on the PC firmware; values are not labeled as CPU or GPU temperatures.'**
  String get firmwareTemperaturesDescription;

  /// No description provided for @noThermalSensors.
  ///
  /// In en, this message translates to:
  /// **'No ACPI thermal zones were exposed by this PC.'**
  String get noThermalSensors;

  /// No description provided for @cpuFrequency.
  ///
  /// In en, this message translates to:
  /// **'CPU clock and core parking'**
  String get cpuFrequency;

  /// No description provided for @cpuFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Takes one sample of the Windows processor performance counters. The effective clock is the base clock × % Processor Performance, the same formula as Task Manager. Use it to check power plan, boost and core parking changes. Read-only.'**
  String get cpuFrequencyDescription;

  /// No description provided for @cpuEffectiveClock.
  ///
  /// In en, this message translates to:
  /// **'{mhz} MHz effective · base {nominal} MHz'**
  String cpuEffectiveClock(Object mhz, Object nominal);

  /// No description provided for @cpuParkedCount.
  ///
  /// In en, this message translates to:
  /// **'{parked} of {total} logical processors parked'**
  String cpuParkedCount(Object parked, Object total);

  /// No description provided for @cpuParked.
  ///
  /// In en, this message translates to:
  /// **'parked'**
  String get cpuParked;

  /// No description provided for @cpuFrequencySource.
  ///
  /// In en, this message translates to:
  /// **'Source: Processor Information performance counters (Win32_PerfFormattedData_Counters_ProcessorInformation), one sample averaged over the last counter interval. Not a peak clock. Per-core values use one nominal clock, so efficiency cores of hybrid CPUs read high.'**
  String get cpuFrequencySource;

  /// No description provided for @driverInventory.
  ///
  /// In en, this message translates to:
  /// **'Driver Store inventory'**
  String get driverInventory;

  /// No description provided for @installLocalDriver.
  ///
  /// In en, this message translates to:
  /// **'Install a local driver package'**
  String get installLocalDriver;

  /// No description provided for @installLocalDriverDescription.
  ///
  /// In en, this message translates to:
  /// **'Verify a local INF, its signed catalog, and hardware compatibility before installation.'**
  String get installLocalDriverDescription;

  /// No description provided for @selectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select a present device'**
  String get selectDevice;

  /// No description provided for @localInfPath.
  ///
  /// In en, this message translates to:
  /// **'Absolute path to the local .inf file'**
  String get localInfPath;

  /// No description provided for @verifyDriverPackage.
  ///
  /// In en, this message translates to:
  /// **'Verify package'**
  String get verifyDriverPackage;

  /// No description provided for @verifiedDriverPublisher.
  ///
  /// In en, this message translates to:
  /// **'Verified publisher: {publisher}\nINF SHA-256: {sha256}'**
  String verifiedDriverPublisher(Object publisher, Object sha256);

  /// No description provided for @confirmLocalDriverInstall.
  ///
  /// In en, this message translates to:
  /// **'Confirm local driver installation'**
  String get confirmLocalDriverInstall;

  /// No description provided for @confirmLocalDriverInstallMessage.
  ///
  /// In en, this message translates to:
  /// **'Device: {device}\nSigned publisher: {publisher}\nINF SHA-256: {sha256}\n\nWindows may change the active driver and require a restart. Rollback is best effort.'**
  String confirmLocalDriverInstallMessage(
    Object device,
    Object publisher,
    Object sha256,
  );

  /// No description provided for @driverTools.
  ///
  /// In en, this message translates to:
  /// **'Assisted flows'**
  String get driverTools;

  /// No description provided for @temporaryDriverUpdatesPause.
  ///
  /// In en, this message translates to:
  /// **'Temporarily exclude drivers from Windows quality updates'**
  String get temporaryDriverUpdatesPause;

  /// No description provided for @temporaryDriverUpdatesPauseDescription.
  ///
  /// In en, this message translates to:
  /// **'Uses the documented Windows Update policy for 7 or 30 days. ZapTweaks records the exact previous value and shows a reminder when the pause expires; restoration requires your confirmation.'**
  String get temporaryDriverUpdatesPauseDescription;

  /// No description provided for @driverUpdatePolicy.
  ///
  /// In en, this message translates to:
  /// **'Windows Update driver policy'**
  String get driverUpdatePolicy;

  /// No description provided for @driverUpdatePolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'Exclude device drivers from Windows quality updates for 7 days, 30 days, or until you explicitly restore the exact previous policy.'**
  String get driverUpdatePolicyDescription;

  /// No description provided for @disableUntilRestored.
  ///
  /// In en, this message translates to:
  /// **'Disable until restored'**
  String get disableUntilRestored;

  /// No description provided for @driverUpdatePausePermanent.
  ///
  /// In en, this message translates to:
  /// **'Driver updates remain excluded until you restore the previous policy.'**
  String get driverUpdatePausePermanent;

  /// No description provided for @driverUpdatePauseActive.
  ///
  /// In en, this message translates to:
  /// **'Driver update pause active'**
  String get driverUpdatePauseActive;

  /// No description provided for @driverUpdatePauseExpired.
  ///
  /// In en, this message translates to:
  /// **'Driver update pause expired — restore the previous policy'**
  String get driverUpdatePauseExpired;

  /// No description provided for @driverUpdatePauseUntil.
  ///
  /// In en, this message translates to:
  /// **'Scheduled expiration: {date}'**
  String driverUpdatePauseUntil(Object date);

  /// No description provided for @pauseSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Pause for 7 days'**
  String get pauseSevenDays;

  /// No description provided for @pauseThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'Pause for 30 days'**
  String get pauseThirtyDays;

  /// No description provided for @restoreDriverUpdates.
  ///
  /// In en, this message translates to:
  /// **'Restore previous policy'**
  String get restoreDriverUpdates;

  /// No description provided for @assistedDriverFlows.
  ///
  /// In en, this message translates to:
  /// **'Verified and assisted driver flows'**
  String get assistedDriverFlows;

  /// No description provided for @assistedDriverFlowsDescription.
  ///
  /// In en, this message translates to:
  /// **'ZapTweaks opens only vendor-owned sources and Windows surfaces. It does not run mutable remote scripts, flash firmware, or silently remove driver components.'**
  String get assistedDriverFlowsDescription;

  /// No description provided for @amdDriverFlow.
  ///
  /// In en, this message translates to:
  /// **'AMD drivers and software'**
  String get amdDriverFlow;

  /// No description provided for @amdDriverFlowDescription.
  ///
  /// In en, this message translates to:
  /// **'Open AMD\'s official driver selector. Verify the detected product before downloading.'**
  String get amdDriverFlowDescription;

  /// No description provided for @nvidiaDriverFlow.
  ///
  /// In en, this message translates to:
  /// **'NVIDIA drivers'**
  String get nvidiaDriverFlow;

  /// No description provided for @nvidiaDriverFlowDescription.
  ///
  /// In en, this message translates to:
  /// **'Open NVIDIA\'s official manual driver search. Clean installation remains an explicit vendor-installer choice.'**
  String get nvidiaDriverFlowDescription;

  /// No description provided for @intelDriverFlow.
  ///
  /// In en, this message translates to:
  /// **'Intel Driver & Support Assistant'**
  String get intelDriverFlow;

  /// No description provided for @intelDriverFlowDescription.
  ///
  /// In en, this message translates to:
  /// **'Open Intel\'s official detection and support flow.'**
  String get intelDriverFlowDescription;

  /// No description provided for @windowsOptionalDrivers.
  ///
  /// In en, this message translates to:
  /// **'Windows optional driver updates'**
  String get windowsOptionalDrivers;

  /// No description provided for @windowsOptionalDriversDescription.
  ///
  /// In en, this message translates to:
  /// **'Review optional driver updates in Windows Settings; nothing is selected automatically.'**
  String get windowsOptionalDriversDescription;

  /// No description provided for @deviceManager.
  ///
  /// In en, this message translates to:
  /// **'Device Manager'**
  String get deviceManager;

  /// No description provided for @deviceManagerDescription.
  ///
  /// In en, this message translates to:
  /// **'Inspect devices, status codes, active drivers, and manual rollback options.'**
  String get deviceManagerDescription;

  /// No description provided for @openOfficialSource.
  ///
  /// In en, this message translates to:
  /// **'Open official source'**
  String get openOfficialSource;

  /// No description provided for @openWindowsPanel.
  ///
  /// In en, this message translates to:
  /// **'Open Windows panel'**
  String get openWindowsPanel;

  /// No description provided for @searchDrivers.
  ///
  /// In en, this message translates to:
  /// **'Search Driver Store'**
  String get searchDrivers;

  /// No description provided for @driverStoreSafetyNotice.
  ///
  /// In en, this message translates to:
  /// **'Only signed, unbound third-party packages can be removed here. ZapTweaks exports and hashes the package first; restoration is best effort because Windows may assign a different published name.'**
  String get driverStoreSafetyNotice;

  /// No description provided for @signed.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get signed;

  /// No description provided for @unsigned.
  ///
  /// In en, this message translates to:
  /// **'Unsigned'**
  String get unsigned;

  /// No description provided for @driverInUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get driverInUse;

  /// No description provided for @driverUnbound.
  ///
  /// In en, this message translates to:
  /// **'Unbound'**
  String get driverUnbound;

  /// No description provided for @exportAndRemove.
  ///
  /// In en, this message translates to:
  /// **'Export and remove'**
  String get exportAndRemove;

  /// No description provided for @confirmDriverRemoval.
  ///
  /// In en, this message translates to:
  /// **'Confirm Driver Store removal'**
  String get confirmDriverRemoval;

  /// No description provided for @confirmDriverRemovalMessage.
  ///
  /// In en, this message translates to:
  /// **'Published name: {published}\nOriginal INF: {inf}\nPublisher: {publisher}\nVersion: {version}\n\nZapTweaks will export and hash the package before removal. A restart may be required; restoration is best effort.'**
  String confirmDriverRemovalMessage(
    Object published,
    Object inf,
    Object publisher,
    Object version,
  );

  /// No description provided for @searchInstalledApps.
  ///
  /// In en, this message translates to:
  /// **'Search installed apps'**
  String get searchInstalledApps;

  /// No description provided for @scanAllUsers.
  ///
  /// In en, this message translates to:
  /// **'Scan all users (UAC)'**
  String get scanAllUsers;

  /// No description provided for @systemScopesComplete.
  ///
  /// In en, this message translates to:
  /// **'All-user and provisioned AppX scopes are included.'**
  String get systemScopesComplete;

  /// No description provided for @systemScopesIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Current-user and winget inventory only. Scan all users to include system AppX scopes.'**
  String get systemScopesIncomplete;

  /// No description provided for @currentUser.
  ///
  /// In en, this message translates to:
  /// **'Current user'**
  String get currentUser;

  /// No description provided for @allUsers.
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get allUsers;

  /// No description provided for @provisioned.
  ///
  /// In en, this message translates to:
  /// **'Provisioned'**
  String get provisioned;

  /// No description provided for @confirmAppxRemoval.
  ///
  /// In en, this message translates to:
  /// **'Confirm AppX removal'**
  String get confirmAppxRemoval;

  /// No description provided for @confirmAppxRemovalMessage.
  ///
  /// In en, this message translates to:
  /// **'App: {name}\nIdentity: {id}\nScope: {scope}\nRecovery: {recovery}\n\nOnly the listed scope will be removed. This operation has no exact rollback.'**
  String confirmAppxRemovalMessage(
    Object name,
    Object id,
    Object scope,
    Object recovery,
  );

  /// No description provided for @reinstallable.
  ///
  /// In en, this message translates to:
  /// **'Verified restore source available'**
  String get reinstallable;

  /// No description provided for @notReinstallable.
  ///
  /// In en, this message translates to:
  /// **'No verified restore source'**
  String get notReinstallable;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @installedOnly.
  ///
  /// In en, this message translates to:
  /// **'Installed only'**
  String get installedOnly;

  /// No description provided for @refreshInventory.
  ///
  /// In en, this message translates to:
  /// **'Refresh inventory'**
  String get refreshInventory;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @uninstallSelected.
  ///
  /// In en, this message translates to:
  /// **'Uninstall selected'**
  String get uninstallSelected;

  /// No description provided for @openOfficialPage.
  ///
  /// In en, this message translates to:
  /// **'Open official page'**
  String get openOfficialPage;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @notInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get notInstalled;

  /// No description provided for @appInventoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Installed-app detection is unavailable.'**
  String get appInventoryUnavailable;

  /// No description provided for @confirmBulkUninstall.
  ///
  /// In en, this message translates to:
  /// **'Confirm bulk uninstall'**
  String get confirmBulkUninstall;

  /// No description provided for @confirmBulkUninstallMessage.
  ///
  /// In en, this message translates to:
  /// **'The following apps will be uninstalled:\n\n{apps}'**
  String confirmBulkUninstallMessage(Object apps);

  /// No description provided for @appCatalogSources.
  ///
  /// In en, this message translates to:
  /// **'Catalog merged from pinned CTT WinUtil, clean-room Winhance candidates, TweakHub, and requested official sources.'**
  String get appCatalogSources;

  /// No description provided for @tcpOptimizer.
  ///
  /// In en, this message translates to:
  /// **'TCP Optimizer'**
  String get tcpOptimizer;

  /// No description provided for @tcpOptimizerDescription.
  ///
  /// In en, this message translates to:
  /// **'Inspect and configure Windows TCP templates, global offloads, per-application QoS, and repeatable network diagnostics.'**
  String get tcpOptimizerDescription;

  /// No description provided for @tcpNoRecommendation.
  ///
  /// In en, this message translates to:
  /// **'No value is recommended automatically. A read-back or one network test does not prove a performance benefit.'**
  String get tcpNoRecommendation;

  /// No description provided for @tcpLiveState.
  ///
  /// In en, this message translates to:
  /// **'Live TCP state'**
  String get tcpLiveState;

  /// No description provided for @tcpTemplates.
  ///
  /// In en, this message translates to:
  /// **'TCP templates'**
  String get tcpTemplates;

  /// No description provided for @tcpGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global TCP offloads'**
  String get tcpGlobal;

  /// No description provided for @tcpAutotuning.
  ///
  /// In en, this message translates to:
  /// **'Receive-window autotuning'**
  String get tcpAutotuning;

  /// No description provided for @tcpHeuristics.
  ///
  /// In en, this message translates to:
  /// **'Window-scaling heuristics'**
  String get tcpHeuristics;

  /// No description provided for @tcpEcn.
  ///
  /// In en, this message translates to:
  /// **'ECN capability'**
  String get tcpEcn;

  /// No description provided for @tcpCongestion.
  ///
  /// In en, this message translates to:
  /// **'Congestion control'**
  String get tcpCongestion;

  /// No description provided for @tcpRsc.
  ///
  /// In en, this message translates to:
  /// **'Receive segment coalescing (RSC)'**
  String get tcpRsc;

  /// No description provided for @tcpRss.
  ///
  /// In en, this message translates to:
  /// **'Global receive-side scaling (RSS)'**
  String get tcpRss;

  /// No description provided for @tcpConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get tcpConfigure;

  /// No description provided for @tcpChangePreview.
  ///
  /// In en, this message translates to:
  /// **'TCP change preview'**
  String get tcpChangePreview;

  /// No description provided for @tcpCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Current value'**
  String get tcpCurrentValue;

  /// No description provided for @tcpNewValue.
  ///
  /// In en, this message translates to:
  /// **'New value'**
  String get tcpNewValue;

  /// No description provided for @tcpExactRollbackNotice.
  ///
  /// In en, this message translates to:
  /// **'ZapTweaks will snapshot the exact current value, apply with one UAC request, read it back, journal it, and preserve exact rollback.'**
  String get tcpExactRollbackNotice;

  /// No description provided for @tcpUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Not exposed by this Windows build'**
  String get tcpUnsupported;

  /// No description provided for @tcpAdapterRss.
  ///
  /// In en, this message translates to:
  /// **'Open per-adapter RSS controls'**
  String get tcpAdapterRss;

  /// No description provided for @rssAdapterState.
  ///
  /// In en, this message translates to:
  /// **'Per-adapter RSS state'**
  String get rssAdapterState;

  /// No description provided for @rssEnabled.
  ///
  /// In en, this message translates to:
  /// **'RSS enabled'**
  String get rssEnabled;

  /// No description provided for @rssProfile.
  ///
  /// In en, this message translates to:
  /// **'RSS profile'**
  String get rssProfile;

  /// No description provided for @rssQueuesProcessors.
  ///
  /// In en, this message translates to:
  /// **'Queues/processors'**
  String get rssQueuesProcessors;

  /// No description provided for @tcpSettingOperationTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure TCP setting'**
  String get tcpSettingOperationTitle;

  /// No description provided for @tcpSettingOperationDescription.
  ///
  /// In en, this message translates to:
  /// **'Changes one capability-gated Windows TCP template or global offload value with exact rollback.'**
  String get tcpSettingOperationDescription;

  /// No description provided for @qosPolicies.
  ///
  /// In en, this message translates to:
  /// **'Application QoS policies'**
  String get qosPolicies;

  /// No description provided for @qosDescription.
  ///
  /// In en, this message translates to:
  /// **'Create explicit persistent QoS policies for one executable. Existing non-ZapTweaks policies remain read-only.'**
  String get qosDescription;

  /// No description provided for @qosCreate.
  ///
  /// In en, this message translates to:
  /// **'Create policy'**
  String get qosCreate;

  /// No description provided for @qosEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get qosEdit;

  /// No description provided for @qosDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get qosDelete;

  /// No description provided for @qosName.
  ///
  /// In en, this message translates to:
  /// **'Policy name'**
  String get qosName;

  /// No description provided for @qosAppPath.
  ///
  /// In en, this message translates to:
  /// **'Executable path'**
  String get qosAppPath;

  /// No description provided for @qosProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get qosProtocol;

  /// No description provided for @qosSourcePort.
  ///
  /// In en, this message translates to:
  /// **'Source port (optional)'**
  String get qosSourcePort;

  /// No description provided for @qosDestinationPort.
  ///
  /// In en, this message translates to:
  /// **'Destination port (optional)'**
  String get qosDestinationPort;

  /// No description provided for @qosDscp.
  ///
  /// In en, this message translates to:
  /// **'DSCP 0–63 (optional)'**
  String get qosDscp;

  /// No description provided for @qosThrottleMbps.
  ///
  /// In en, this message translates to:
  /// **'Throttle Mbit/s (optional)'**
  String get qosThrottleMbps;

  /// No description provided for @qosOwnedOnly.
  ///
  /// In en, this message translates to:
  /// **'Names must start with “ZapTweaks - ”. Only the selected policy is changed; unrelated QoS policies are never cleared.'**
  String get qosOwnedOnly;

  /// No description provided for @qosDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the selected QoS policy? Its exact state is stored in the ZapTweaks journal for rollback.'**
  String get qosDeleteConfirm;

  /// No description provided for @qosReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get qosReadOnly;

  /// No description provided for @qosPolicyOperationTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure application QoS'**
  String get qosPolicyOperationTitle;

  /// No description provided for @qosPolicyOperationDescription.
  ///
  /// In en, this message translates to:
  /// **'Creates, edits, or removes one validated persistent per-application QoS policy with exact rollback.'**
  String get qosPolicyOperationDescription;

  /// No description provided for @networkDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Before/after diagnostics'**
  String get networkDiagnostics;

  /// No description provided for @networkDiagnosticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Measure bounded TCP connection latency, jitter, loss, and HTTPS download throughput. Results are diagnostic evidence, not a recommendation.'**
  String get networkDiagnosticsDescription;

  /// No description provided for @diagnosticEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Direct HTTPS test-file URL'**
  String get diagnosticEndpoint;

  /// No description provided for @diagnosticNetworkCost.
  ///
  /// In en, this message translates to:
  /// **'The test downloads at most 10 MiB from the endpoint you enter. No third-party endpoint is built in.'**
  String get diagnosticNetworkCost;

  /// No description provided for @diagnosticBaseline.
  ///
  /// In en, this message translates to:
  /// **'Run baseline'**
  String get diagnosticBaseline;

  /// No description provided for @diagnosticComparison.
  ///
  /// In en, this message translates to:
  /// **'Run comparison'**
  String get diagnosticComparison;

  /// No description provided for @diagnosticCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel measurement'**
  String get diagnosticCancel;

  /// No description provided for @diagnosticLatency.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get diagnosticLatency;

  /// No description provided for @diagnosticJitter.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get diagnosticJitter;

  /// No description provided for @diagnosticPacketLoss.
  ///
  /// In en, this message translates to:
  /// **'Packet loss'**
  String get diagnosticPacketLoss;

  /// No description provided for @diagnosticThroughput.
  ///
  /// In en, this message translates to:
  /// **'Throughput'**
  String get diagnosticThroughput;

  /// No description provided for @diagnosticRawSamples.
  ///
  /// In en, this message translates to:
  /// **'Raw latency samples'**
  String get diagnosticRawSamples;

  /// No description provided for @diagnosticDownloadedBytes.
  ///
  /// In en, this message translates to:
  /// **'Downloaded bytes'**
  String get diagnosticDownloadedBytes;

  /// No description provided for @diagnosticDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference B − A'**
  String get diagnosticDifference;

  /// No description provided for @tcpAttribution.
  ///
  /// In en, this message translates to:
  /// **'Inspired by WINSPAR — powplowdevs (frozen revision)'**
  String get tcpAttribution;

  /// No description provided for @openRecoveryHistory.
  ///
  /// In en, this message translates to:
  /// **'Open recovery and journal'**
  String get openRecoveryHistory;

  /// No description provided for @manualRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore original manual settings'**
  String get manualRestoreTitle;

  /// No description provided for @manualRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Restore the recorded originals, not defaults. Changed settings are not overwritten. High-risk settings require Expert mode and UAC. Review the journal after restoration; restart or sign-out requirements still apply.'**
  String get manualRestoreWarning;

  /// No description provided for @cleanupUserTemp.
  ///
  /// In en, this message translates to:
  /// **'UserTemp cleanup'**
  String get cleanupUserTemp;

  /// No description provided for @cleanupUserTempDescription.
  ///
  /// In en, this message translates to:
  /// **'Review and select exact files in the current user\'s Temp directory. No automatic selection, forced deletion or directory removal.'**
  String get cleanupUserTempDescription;

  /// No description provided for @cleanupSelectFiles.
  ///
  /// In en, this message translates to:
  /// **'Preview and select files'**
  String get cleanupSelectFiles;

  /// No description provided for @cleanupShaderCache.
  ///
  /// In en, this message translates to:
  /// **'GPU shader cache cleanup'**
  String get cleanupShaderCache;

  /// No description provided for @cleanupShaderCacheDescription.
  ///
  /// In en, this message translates to:
  /// **'Previews the DirectX, AMD, NVIDIA and Intel shader caches of the current user, folder by folder, and deletes exactly the files found by that preview. The driver rebuilds them, so the first launch of each game can stutter. Close games first. Not reversible.'**
  String get cleanupShaderCacheDescription;

  /// No description provided for @cleanupShaderCacheNone.
  ///
  /// In en, this message translates to:
  /// **'No GPU shader cache files were found.'**
  String get cleanupShaderCacheNone;

  /// No description provided for @cleanupShaderCacheCompleted.
  ///
  /// In en, this message translates to:
  /// **'The previewed shader cache files were deleted and verified absent.'**
  String get cleanupShaderCacheCompleted;

  /// No description provided for @cleanupPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get cleanupPreview;

  /// No description provided for @cleanupUserTempNone.
  ///
  /// In en, this message translates to:
  /// **'No UserTemp files found.'**
  String get cleanupUserTempNone;

  /// No description provided for @cleanupPermanentWarning.
  ///
  /// In en, this message translates to:
  /// **'Permanent deletion. No rollback or permission/lock override. Close applications first. If deletion fails, earlier files may already have been removed.'**
  String get cleanupPermanentWarning;

  /// No description provided for @cleanupUserTempSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing is selected. Select only files you recognize; files created after this preview are excluded.'**
  String get cleanupUserTempSelectionHint;

  /// No description provided for @cleanupPreviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files, {bytes} bytes'**
  String cleanupPreviewCount(int count, int bytes);

  /// No description provided for @cleanupRecycleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin cleanup is unavailable: exact item identities cannot be previewed and deleted safely. No empty-all action is performed.'**
  String get cleanupRecycleUnavailable;

  /// No description provided for @cleanupCrashReports.
  ///
  /// In en, this message translates to:
  /// **'Crash dumps and error reports'**
  String get cleanupCrashReports;

  /// No description provided for @cleanupCrashReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Deletes the crash dumps of your programs (%LOCALAPPDATA%\\CrashDumps) and your Windows Error Reporting archive and queue. Useful after a game or app crashed many times. System minidumps (blue screens) are not touched.'**
  String get cleanupCrashReportsDescription;

  /// No description provided for @cleanupCrashReportsNone.
  ///
  /// In en, this message translates to:
  /// **'No crash dumps or error reports to delete.'**
  String get cleanupCrashReportsNone;

  /// No description provided for @cleanupCrashReportsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Crash dumps and error reports deleted.'**
  String get cleanupCrashReportsCompleted;

  /// No description provided for @cleanupBrowserCache.
  ///
  /// In en, this message translates to:
  /// **'Browser caches'**
  String get cleanupBrowserCache;

  /// No description provided for @cleanupBrowserCacheDescription.
  ///
  /// In en, this message translates to:
  /// **'Deletes the disk caches of Chrome, Edge, Brave (every profile) and Firefox. Cookies, history, passwords and extensions are not touched; pages load a little slower the first time.'**
  String get cleanupBrowserCacheDescription;

  /// No description provided for @cleanupBrowserCacheNone.
  ///
  /// In en, this message translates to:
  /// **'No browser cache files to delete.'**
  String get cleanupBrowserCacheNone;

  /// No description provided for @cleanupBrowserCacheCompleted.
  ///
  /// In en, this message translates to:
  /// **'Browser caches deleted.'**
  String get cleanupBrowserCacheCompleted;

  /// No description provided for @cleanupBrowserRunning.
  ///
  /// In en, this message translates to:
  /// **'Close {browsers} first (also from the system tray: Edge and Chrome can keep running in the background).'**
  String cleanupBrowserRunning(String browsers);

  /// No description provided for @thermalZoneLimited.
  ///
  /// In en, this message translates to:
  /// **'firmware limits the CPU to {percent}%'**
  String thermalZoneLimited(String percent);

  /// No description provided for @thermalSourceCounters.
  ///
  /// In en, this message translates to:
  /// **'Source: Windows \"Thermal Zone Information\" counters (ACPI zones defined by the firmware, no administrator rights needed). A zone is a sensor the manufacturer chose; it is often not the CPU die.'**
  String get thermalSourceCounters;

  /// No description provided for @thermalSourceAcpi.
  ///
  /// In en, this message translates to:
  /// **'Source: MSAcpi_ThermalZoneTemperature (ACPI zones defined by the firmware). A zone is a sensor the manufacturer chose; it is often not the CPU die.'**
  String get thermalSourceAcpi;

  /// No description provided for @thermalSourceNone.
  ///
  /// In en, this message translates to:
  /// **'The firmware of this PC exposes no ACPI thermal zone (common on desktop boards). Nothing is shown rather than a value that was not measured.'**
  String get thermalSourceNone;

  /// No description provided for @srumTab.
  ///
  /// In en, this message translates to:
  /// **'App history'**
  String get srumTab;

  /// No description provided for @srumTitle.
  ///
  /// In en, this message translates to:
  /// **'App history (SRUM)'**
  String get srumTitle;

  /// No description provided for @srumDescription.
  ///
  /// In en, this message translates to:
  /// **'Network, CPU and disk use of every program in the last 30 days, as recorded by Windows (System Resource Usage Monitor). Read-only: ZapTweaks reads a shadow copy of the database and deletes it afterwards. Needs administrator rights.'**
  String get srumDescription;

  /// No description provided for @srumRead.
  ///
  /// In en, this message translates to:
  /// **'Read history'**
  String get srumRead;

  /// No description provided for @srumNotCollectingTitle.
  ///
  /// In en, this message translates to:
  /// **'Windows is not recording app history'**
  String get srumNotCollectingTitle;

  /// No description provided for @srumNotCollecting.
  ///
  /// In en, this message translates to:
  /// **'The Diagnostic Policy Service, which records this history, is {status} ({startType}). The data ends on {date}.'**
  String srumNotCollecting(String status, String startType, String date);

  /// No description provided for @srumNoData.
  ///
  /// In en, this message translates to:
  /// **'No usage recorded in the last 30 days.'**
  String get srumNoData;

  /// No description provided for @srumNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network (sent / received)'**
  String get srumNetwork;

  /// No description provided for @srumCpu.
  ///
  /// In en, this message translates to:
  /// **'CPU time (share of all programs; part used in the background)'**
  String get srumCpu;

  /// No description provided for @srumCpuShare.
  ///
  /// In en, this message translates to:
  /// **'{share}% · {background}% background'**
  String srumCpuShare(String share, String background);

  /// No description provided for @srumUnattributed.
  ///
  /// In en, this message translates to:
  /// **'Not attributed to a program'**
  String get srumUnattributed;

  /// No description provided for @srumSource.
  ///
  /// In en, this message translates to:
  /// **'Source: C:\\Windows\\System32\\sru\\SRUDB.dat, records from {first} to {last}. Windows writes them about once an hour.'**
  String srumSource(String first, String last);

  /// No description provided for @manualControls.
  ///
  /// In en, this message translates to:
  /// **'Manual controls'**
  String get manualControls;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You are running the latest version ({version}).'**
  String upToDate(String version);

  /// No description provided for @startCapture.
  ///
  /// In en, this message translates to:
  /// **'Start capture'**
  String get startCapture;

  /// No description provided for @batteryHealth.
  ///
  /// In en, this message translates to:
  /// **'Battery health'**
  String get batteryHealth;

  /// No description provided for @batteryHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'Capacity the battery still holds compared with its design. Read-only.'**
  String get batteryHealthDescription;

  /// No description provided for @batteryGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get batteryGood;

  /// No description provided for @batteryFair.
  ///
  /// In en, this message translates to:
  /// **'Worn'**
  String get batteryFair;

  /// No description provided for @batteryPoor.
  ///
  /// In en, this message translates to:
  /// **'Replace soon'**
  String get batteryPoor;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @batteryDesigned.
  ///
  /// In en, this message translates to:
  /// **'Design capacity'**
  String get batteryDesigned;

  /// No description provided for @batteryFullCharge.
  ///
  /// In en, this message translates to:
  /// **'Full charge capacity'**
  String get batteryFullCharge;

  /// No description provided for @batteryWear.
  ///
  /// In en, this message translates to:
  /// **'Wear'**
  String get batteryWear;

  /// No description provided for @batteryCycles.
  ///
  /// In en, this message translates to:
  /// **'Charge cycles'**
  String get batteryCycles;

  /// No description provided for @batteryCharge.
  ///
  /// In en, this message translates to:
  /// **'Current charge'**
  String get batteryCharge;

  /// No description provided for @batteryOnAc.
  ///
  /// In en, this message translates to:
  /// **'Plugged in'**
  String get batteryOnAc;

  /// No description provided for @batteryOnBattery.
  ///
  /// In en, this message translates to:
  /// **'On battery'**
  String get batteryOnBattery;

  /// No description provided for @batterySourceWmi.
  ///
  /// In en, this message translates to:
  /// **'Source: root\\wmi BatteryStaticData, BatteryFullChargedCapacity, BatteryCycleCount and BatteryStatus, as reported by the battery firmware.'**
  String get batterySourceWmi;

  /// No description provided for @batterySourceReport.
  ///
  /// In en, this message translates to:
  /// **'Source: powercfg /batteryreport (temporary XML, deleted after reading), as reported by the battery firmware.'**
  String get batterySourceReport;

  /// No description provided for @appTypeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appTypeSystem;

  /// No description provided for @appTypeUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get appTypeUser;

  /// No description provided for @appTypeStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get appTypeStore;

  /// No description provided for @appSafetyRemovable.
  ///
  /// In en, this message translates to:
  /// **'Can remove'**
  String get appSafetyRemovable;

  /// No description provided for @appSafetyCheckFirst.
  ///
  /// In en, this message translates to:
  /// **'Check first'**
  String get appSafetyCheckFirst;

  /// No description provided for @appSafetyKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get appSafetyKeep;

  /// No description provided for @appReasonSystemComponent.
  ///
  /// In en, this message translates to:
  /// **'Hidden Windows or vendor component.'**
  String get appReasonSystemComponent;

  /// No description provided for @appReasonProtected.
  ///
  /// In en, this message translates to:
  /// **'Its installer forbids removal.'**
  String get appReasonProtected;

  /// No description provided for @appReasonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update of another program: remove that program instead.'**
  String get appReasonUpdate;

  /// No description provided for @appReasonWindowsPart.
  ///
  /// In en, this message translates to:
  /// **'Part of Windows or a framework other apps need.'**
  String get appReasonWindowsPart;

  /// No description provided for @appReasonSharedDependency.
  ///
  /// In en, this message translates to:
  /// **'Used by other apps (runtime, driver or vendor panel).'**
  String get appReasonSharedDependency;

  /// No description provided for @appReasonOptionalFeature.
  ///
  /// In en, this message translates to:
  /// **'Optional Windows feature: read what stops working.'**
  String get appReasonOptionalFeature;

  /// No description provided for @appReasonMissingUninstaller.
  ///
  /// In en, this message translates to:
  /// **'No uninstaller registered.'**
  String get appReasonMissingUninstaller;

  /// No description provided for @appReasonUserInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed by you or the PC maker; nothing else depends on it.'**
  String get appReasonUserInstalled;

  /// No description provided for @appLabelMissingUninstaller.
  ///
  /// In en, this message translates to:
  /// **'No uninstaller'**
  String get appLabelMissingUninstaller;

  /// No description provided for @appLabelProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get appLabelProtected;

  /// No description provided for @appLabelSystemComponent.
  ///
  /// In en, this message translates to:
  /// **'System component'**
  String get appLabelSystemComponent;

  /// No description provided for @appLabelUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get appLabelUpdate;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get filterSafety;

  /// No description provided for @filterSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get filterSource;

  /// No description provided for @sourceWholePc.
  ///
  /// In en, this message translates to:
  /// **'Whole PC'**
  String get sourceWholePc;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sortSize;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortDate.
  ///
  /// In en, this message translates to:
  /// **'Install date'**
  String get sortDate;

  /// No description provided for @appsShown.
  ///
  /// In en, this message translates to:
  /// **'{count} apps'**
  String appsShown(int count);

  /// No description provided for @selectionSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} selected · {size}'**
  String selectionSummary(int count, String size);

  /// No description provided for @selectionUnknownSizes.
  ///
  /// In en, this message translates to:
  /// **'{count} with unknown size'**
  String selectionUnknownSizes(int count);

  /// No description provided for @appsSource.
  ///
  /// In en, this message translates to:
  /// **'Source: Uninstall registry keys (HKLM 64/32-bit, HKCU), Get-AppxPackage, winget export for reinstall ids. Size: EstimatedSize, otherwise the install folder.'**
  String get appsSource;

  /// No description provided for @noAppsMatch.
  ///
  /// In en, this message translates to:
  /// **'No app matches these filters.'**
  String get noAppsMatch;

  /// No description provided for @reinstallableVia.
  ///
  /// In en, this message translates to:
  /// **'Reinstall: winget {id}'**
  String reinstallableVia(String id);

  /// No description provided for @uninstallQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Uninstall queue'**
  String get uninstallQueueTitle;

  /// No description provided for @uninstallModeSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get uninstallModeSilent;

  /// No description provided for @uninstallModeWindowed.
  ///
  /// In en, this message translates to:
  /// **'Opens its window'**
  String get uninstallModeWindowed;

  /// No description provided for @uninstallManualNoUninstaller.
  ///
  /// In en, this message translates to:
  /// **'Manual: no uninstaller registered.'**
  String get uninstallManualNoUninstaller;

  /// No description provided for @uninstallManualUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Manual: the registered command runs a shell or script, so ZapTweaks does not start it.'**
  String get uninstallManualUnsafe;

  /// No description provided for @uninstallManualNotFound.
  ///
  /// In en, this message translates to:
  /// **'Manual: the uninstaller file is missing.'**
  String get uninstallManualNotFound;

  /// No description provided for @uninstallRunningWarning.
  ///
  /// In en, this message translates to:
  /// **'Still running from its folder: {processes}. Close it first.'**
  String uninstallRunningWarning(String processes);

  /// No description provided for @uninstallSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulation: plan and show the queue, uninstall nothing'**
  String get uninstallSimulate;

  /// No description provided for @uninstallRestorePointNote.
  ///
  /// In en, this message translates to:
  /// **'A restore point is created first. Programs that open a window run first, one at a time; silent ones follow.'**
  String get uninstallRestorePointNote;

  /// No description provided for @uninstallStart.
  ///
  /// In en, this message translates to:
  /// **'Start uninstalling'**
  String get uninstallStart;

  /// No description provided for @restorePointCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating restore point…'**
  String get restorePointCreating;

  /// No description provided for @restorePointFailed.
  ///
  /// In en, this message translates to:
  /// **'The restore point was not created. System Protection may be off. Nothing has been changed.'**
  String get restorePointFailed;

  /// No description provided for @restorePointEnableAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Turn on System Protection and retry'**
  String get restorePointEnableAndRetry;

  /// No description provided for @queueWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get queueWaiting;

  /// No description provided for @queueRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get queueRunning;

  /// No description provided for @queueDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get queueDone;

  /// No description provided for @queueFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get queueFailed;

  /// No description provided for @queueSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get queueSkipped;

  /// No description provided for @queueSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get queueSkip;

  /// No description provided for @queueStop.
  ///
  /// In en, this message translates to:
  /// **'Stop after the current one'**
  String get queueStop;

  /// No description provided for @queueSimulated.
  ///
  /// In en, this message translates to:
  /// **'Simulation: nothing was uninstalled.'**
  String get queueSimulated;

  /// No description provided for @uninstallStoreAppsHint.
  ///
  /// In en, this message translates to:
  /// **'Store apps in the selection use the Uninstall menu on their row.'**
  String get uninstallStoreAppsHint;

  /// No description provided for @leftoverSearch.
  ///
  /// In en, this message translates to:
  /// **'Look for leftovers'**
  String get leftoverSearch;

  /// No description provided for @leftoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Leftovers'**
  String get leftoverTitle;

  /// No description provided for @leftoverGood.
  ///
  /// In en, this message translates to:
  /// **'Sure'**
  String get leftoverGood;

  /// No description provided for @leftoverMedium.
  ///
  /// In en, this message translates to:
  /// **'Likely'**
  String get leftoverMedium;

  /// No description provided for @leftoverLow.
  ///
  /// In en, this message translates to:
  /// **'Uncertain'**
  String get leftoverLow;

  /// No description provided for @leftoverKindFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get leftoverKindFolder;

  /// No description provided for @leftoverKindShortcut.
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get leftoverKindShortcut;

  /// No description provided for @leftoverKindRegistry.
  ///
  /// In en, this message translates to:
  /// **'Registry key'**
  String get leftoverKindRegistry;

  /// No description provided for @leftoverKindRun.
  ///
  /// In en, this message translates to:
  /// **'Startup entry'**
  String get leftoverKindRun;

  /// No description provided for @leftoverKindTask.
  ///
  /// In en, this message translates to:
  /// **'Scheduled task'**
  String get leftoverKindTask;

  /// No description provided for @leftoverKindFirewall.
  ///
  /// In en, this message translates to:
  /// **'Firewall rule'**
  String get leftoverKindFirewall;

  /// No description provided for @leftoverNone.
  ///
  /// In en, this message translates to:
  /// **'No leftovers found.'**
  String get leftoverNone;

  /// No description provided for @leftoverRemoveSelected.
  ///
  /// In en, this message translates to:
  /// **'Remove selected ({count})'**
  String leftoverRemoveSelected(int count);

  /// No description provided for @leftoverBackupNote.
  ///
  /// In en, this message translates to:
  /// **'Only items marked Sure start selected. Before removal, registry keys are exported to .reg, tasks to XML and firewall rules to JSON; files and folders go to the Recycle Bin.'**
  String get leftoverBackupNote;

  /// No description provided for @leftoverRemoved.
  ///
  /// In en, this message translates to:
  /// **'Leftovers removed. Backups: {path}'**
  String leftoverRemoved(String path);

  /// No description provided for @leftoverRefusedInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not removed: malformed or unsafe entry.'**
  String get leftoverRefusedInvalid;

  /// No description provided for @leftoverRefusedOutside.
  ///
  /// In en, this message translates to:
  /// **'Not removed: outside what ZapTweaks may clean here.'**
  String get leftoverRefusedOutside;

  /// No description provided for @leftoverRefusedShared.
  ///
  /// In en, this message translates to:
  /// **'Not removed: shared with Windows or other programs.'**
  String get leftoverRefusedShared;

  /// No description provided for @orphanFolders.
  ///
  /// In en, this message translates to:
  /// **'Orphan folders'**
  String get orphanFolders;

  /// No description provided for @orphanFoldersNote.
  ///
  /// In en, this message translates to:
  /// **'Program Files folders that no installed program points to. A portable tool or a driver kit can look the same, so nothing is selected: check each one first.'**
  String get orphanFoldersNote;

  /// No description provided for @openLocation.
  ///
  /// In en, this message translates to:
  /// **'Open location'**
  String get openLocation;

  /// No description provided for @processesTab.
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get processesTab;

  /// No description provided for @searchProcesses.
  ///
  /// In en, this message translates to:
  /// **'Search processes'**
  String get searchProcesses;

  /// No description provided for @sortMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get sortMemory;

  /// No description provided for @sortCpu.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get sortCpu;

  /// No description provided for @processKindWindows.
  ///
  /// In en, this message translates to:
  /// **'Windows'**
  String get processKindWindows;

  /// No description provided for @processKindMicrosoft.
  ///
  /// In en, this message translates to:
  /// **'Microsoft app'**
  String get processKindMicrosoft;

  /// No description provided for @processKindThirdParty.
  ///
  /// In en, this message translates to:
  /// **'Third party'**
  String get processKindThirdParty;

  /// No description provided for @processCanClose.
  ///
  /// In en, this message translates to:
  /// **'Can close'**
  String get processCanClose;

  /// No description provided for @processLeaveRunning.
  ///
  /// In en, this message translates to:
  /// **'Leave running'**
  String get processLeaveRunning;

  /// No description provided for @processReasonCritical.
  ///
  /// In en, this message translates to:
  /// **'Windows needs it: closing it can sign you out or crash the system.'**
  String get processReasonCritical;

  /// No description provided for @processReasonWindowsFolder.
  ///
  /// In en, this message translates to:
  /// **'Runs from the Windows folder or is protected.'**
  String get processReasonWindowsFolder;

  /// No description provided for @processReasonService.
  ///
  /// In en, this message translates to:
  /// **'Runs a service: manage it from the Services tab.'**
  String get processReasonService;

  /// No description provided for @processReasonSelf.
  ///
  /// In en, this message translates to:
  /// **'This is ZapTweaks.'**
  String get processReasonSelf;

  /// No description provided for @processReasonUserApp.
  ///
  /// In en, this message translates to:
  /// **'An app you started: closing it loses unsaved work.'**
  String get processReasonUserApp;

  /// No description provided for @processEnd.
  ///
  /// In en, this message translates to:
  /// **'End process'**
  String get processEnd;

  /// No description provided for @processEndConfirm.
  ///
  /// In en, this message translates to:
  /// **'End {name}? Anything unsaved in it is lost.'**
  String processEndConfirm(String name);

  /// No description provided for @processEndChanged.
  ///
  /// In en, this message translates to:
  /// **'It had already closed, or its ID now belongs to another process: nothing was ended.'**
  String get processEndChanged;

  /// No description provided for @processEndFailed.
  ///
  /// In en, this message translates to:
  /// **'Windows refused to end it. It may run as administrator.'**
  String get processEndFailed;

  /// No description provided for @searchOnline.
  ///
  /// In en, this message translates to:
  /// **'Search online'**
  String get searchOnline;

  /// No description provided for @processOnlyClosable.
  ///
  /// In en, this message translates to:
  /// **'Only ones you can close'**
  String get processOnlyClosable;

  /// No description provided for @processNote.
  ///
  /// In en, this message translates to:
  /// **'A snapshot: CPU is a single sample, refresh to read it again. Signatures are checked after the list appears. System processes are never offered for closing.'**
  String get processNote;

  /// No description provided for @noProcessesMatch.
  ///
  /// In en, this message translates to:
  /// **'No process matches these filters.'**
  String get noProcessesMatch;

  /// No description provided for @signedBy.
  ///
  /// In en, this message translates to:
  /// **'Signed by {signer}'**
  String signedBy(String signer);

  /// No description provided for @servicesTab.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTab;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get searchServices;

  /// No description provided for @filterOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get filterOrigin;

  /// No description provided for @originMicrosoft.
  ///
  /// In en, this message translates to:
  /// **'Microsoft'**
  String get originMicrosoft;

  /// No description provided for @serviceCanDisable.
  ///
  /// In en, this message translates to:
  /// **'Can disable'**
  String get serviceCanDisable;

  /// No description provided for @serviceDependsOnUse.
  ///
  /// In en, this message translates to:
  /// **'Depends on use'**
  String get serviceDependsOnUse;

  /// No description provided for @serviceKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get serviceKeep;

  /// No description provided for @serviceStartAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get serviceStartAutomatic;

  /// No description provided for @serviceStartDelayed.
  ///
  /// In en, this message translates to:
  /// **'Automatic (delayed)'**
  String get serviceStartDelayed;

  /// No description provided for @serviceStartManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get serviceStartManual;

  /// No description provided for @serviceStartDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get serviceStartDisabled;

  /// No description provided for @serviceStartBoot.
  ///
  /// In en, this message translates to:
  /// **'Boot'**
  String get serviceStartBoot;

  /// No description provided for @serviceRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get serviceRunning;

  /// No description provided for @serviceStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get serviceStopped;

  /// No description provided for @serviceSetDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get serviceSetDisabled;

  /// No description provided for @serviceSetManual.
  ///
  /// In en, this message translates to:
  /// **'Set to manual'**
  String get serviceSetManual;

  /// No description provided for @serviceSetAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Set to automatic'**
  String get serviceSetAutomatic;

  /// No description provided for @serviceChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change {service}'**
  String serviceChangeTitle(String service);

  /// No description provided for @serviceChangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start type: {from} → {to}.\n{reason}\nIt applies the next time the service or Windows starts. You can undo it right after.'**
  String serviceChangeConfirm(String from, String to, String reason);

  /// No description provided for @serviceChanged.
  ///
  /// In en, this message translates to:
  /// **'{service} is now {to}.'**
  String serviceChanged(String service, String to);

  /// No description provided for @serviceUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get serviceUndo;

  /// No description provided for @serviceNote.
  ///
  /// In en, this message translates to:
  /// **'Changes ask for administrator rights and take effect at the next start of the service or of Windows. Services Windows needs are never offered; disabling a service that others depend on is refused.'**
  String get serviceNote;

  /// No description provided for @noServicesMatch.
  ///
  /// In en, this message translates to:
  /// **'No service matches these filters.'**
  String get noServicesMatch;

  /// No description provided for @svcReasonTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Sends usage and diagnostic data to Microsoft. Nothing you use stops working.'**
  String get svcReasonTelemetry;

  /// No description provided for @svcReasonDeviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Telemetry and work or school device management: only needed if an organization manages this PC.'**
  String get svcReasonDeviceManagement;

  /// No description provided for @svcReasonCrashReports.
  ///
  /// In en, this message translates to:
  /// **'Sends crash reports to Microsoft. Crashes are still logged on this PC.'**
  String get svcReasonCrashReports;

  /// No description provided for @svcReasonRemoteRegistry.
  ///
  /// In en, this message translates to:
  /// **'Lets other computers edit this PC\'s registry over the network. Off by default.'**
  String get svcReasonRemoteRegistry;

  /// No description provided for @svcReasonOfflineMaps.
  ///
  /// In en, this message translates to:
  /// **'Keeps offline maps up to date for the Maps app.'**
  String get svcReasonOfflineMaps;

  /// No description provided for @svcReasonMediaSharing.
  ///
  /// In en, this message translates to:
  /// **'Shares the Windows Media Player library on the network.'**
  String get svcReasonMediaSharing;

  /// No description provided for @svcReasonRetailDemo.
  ///
  /// In en, this message translates to:
  /// **'Shop demo mode. Never needed at home.'**
  String get svcReasonRetailDemo;

  /// No description provided for @svcReasonXbox.
  ///
  /// In en, this message translates to:
  /// **'Without it: Xbox app, Game Pass, cloud saves and Xbox accessories stop working.'**
  String get svcReasonXbox;

  /// No description provided for @svcReasonPrinting.
  ///
  /// In en, this message translates to:
  /// **'Without it: printing stops working, Print to PDF included.'**
  String get svcReasonPrinting;

  /// No description provided for @svcReasonBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Without it: Bluetooth devices stop connecting.'**
  String get svcReasonBluetooth;

  /// No description provided for @svcReasonSearch.
  ///
  /// In en, this message translates to:
  /// **'Without it: search in Start, Settings and File Explorer gets slow and incomplete.'**
  String get svcReasonSearch;

  /// No description provided for @svcReasonSysMain.
  ///
  /// In en, this message translates to:
  /// **'Preloads apps you use often. Without it launches can be slower, mostly on hard disks.'**
  String get svcReasonSysMain;

  /// No description provided for @svcReasonTouchKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Without it: touch keyboard, handwriting, the emoji panel and some input methods stop working.'**
  String get svcReasonTouchKeyboard;

  /// No description provided for @svcReasonLocation.
  ///
  /// In en, this message translates to:
  /// **'Without it: apps and Find my device can no longer get your location.'**
  String get svcReasonLocation;

  /// No description provided for @svcReasonBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Without it: Windows Hello face and fingerprint sign-in stop working.'**
  String get svcReasonBiometrics;

  /// No description provided for @svcReasonPhone.
  ///
  /// In en, this message translates to:
  /// **'Without it: calls through Phone Link stop working.'**
  String get svcReasonPhone;

  /// No description provided for @svcReasonRemoteDesktop.
  ///
  /// In en, this message translates to:
  /// **'Without it: Remote Desktop into this PC stops working.'**
  String get svcReasonRemoteDesktop;

  /// No description provided for @svcReasonSmartCard.
  ///
  /// In en, this message translates to:
  /// **'Without it: smart cards and some security keys stop working.'**
  String get svcReasonSmartCard;

  /// No description provided for @svcReasonParental.
  ///
  /// In en, this message translates to:
  /// **'Without it: Microsoft Family Safety limits are no longer enforced.'**
  String get svcReasonParental;

  /// No description provided for @svcReasonNfc.
  ///
  /// In en, this message translates to:
  /// **'Without it: NFC and tap-to-pay stop working.'**
  String get svcReasonNfc;

  /// No description provided for @svcReasonHotspot.
  ///
  /// In en, this message translates to:
  /// **'Without it: Mobile hotspot stops working.'**
  String get svcReasonHotspot;

  /// No description provided for @svcReasonScanner.
  ///
  /// In en, this message translates to:
  /// **'Without it: scanners and some cameras stop working.'**
  String get svcReasonScanner;

  /// No description provided for @svcReasonCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Without it: Windows no longer offers fixes when an old program fails to run.'**
  String get svcReasonCompatibility;

  /// No description provided for @svcReasonFax.
  ///
  /// In en, this message translates to:
  /// **'Without it: fax stops working.'**
  String get svcReasonFax;

  /// No description provided for @svcReasonInsider.
  ///
  /// In en, this message translates to:
  /// **'Without it: Windows Insider preview builds stop arriving.'**
  String get svcReasonInsider;

  /// No description provided for @svcReasonUpdates.
  ///
  /// In en, this message translates to:
  /// **'Windows Update needs it: without it security fixes stop arriving.'**
  String get svcReasonUpdates;

  /// No description provided for @svcReasonSecurity.
  ///
  /// In en, this message translates to:
  /// **'Protects this PC (antivirus, firewall, security status).'**
  String get svcReasonSecurity;

  /// No description provided for @svcReasonWindowsCore.
  ///
  /// In en, this message translates to:
  /// **'Windows needs it for sound, network, logs or basic system functions.'**
  String get svcReasonWindowsCore;

  /// No description provided for @svcReasonNotReviewed.
  ///
  /// In en, this message translates to:
  /// **'Part of Windows and not reviewed: leave it as it is.'**
  String get svcReasonNotReviewed;

  /// No description provided for @svcReasonDriverService.
  ///
  /// In en, this message translates to:
  /// **'Installed with a driver: leave it unless you know what it does.'**
  String get svcReasonDriverService;

  /// No description provided for @svcReasonMicrosoftApp.
  ///
  /// In en, this message translates to:
  /// **'Belongs to a Microsoft app: without it that app may stop working or updating.'**
  String get svcReasonMicrosoftApp;

  /// No description provided for @svcReasonThirdParty.
  ///
  /// In en, this message translates to:
  /// **'Installed with another program: without it that program may stop working or updating.'**
  String get svcReasonThirdParty;

  /// No description provided for @serviceStartTypeAction.
  ///
  /// In en, this message translates to:
  /// **'Change startup'**
  String get serviceStartTypeAction;

  /// No description provided for @presetsTab.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetsTab;

  /// No description provided for @presetDebloatName.
  ///
  /// In en, this message translates to:
  /// **'Debloat only'**
  String get presetDebloatName;

  /// No description provided for @presetDebloatSummary.
  ///
  /// In en, this message translates to:
  /// **'Removes preinstalled Microsoft apps few people use. Nothing else changes.'**
  String get presetDebloatSummary;

  /// No description provided for @presetCleanName.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get presetCleanName;

  /// No description provided for @presetCleanSummary.
  ///
  /// In en, this message translates to:
  /// **'Debloat, plus telemetry and unused services off and apps that start with Windows for no reason.'**
  String get presetCleanSummary;

  /// No description provided for @presetGamingName.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get presetGamingName;

  /// No description provided for @presetGamingSummary.
  ///
  /// In en, this message translates to:
  /// **'Clean, plus settings for playing: no power throttling of running apps, End task in the taskbar. Xbox stays.'**
  String get presetGamingSummary;

  /// No description provided for @presetPrivacyName.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get presetPrivacyName;

  /// No description provided for @presetPrivacySummary.
  ///
  /// In en, this message translates to:
  /// **'Clean, plus the privacy settings from Microsoft\'s own guide: advertising ID, tracking, suggestions, diagnostic data to the minimum.'**
  String get presetPrivacySummary;

  /// No description provided for @presetCompetitiveName.
  ///
  /// In en, this message translates to:
  /// **'Competitive'**
  String get presetCompetitiveName;

  /// No description provided for @presetCompetitiveSummary.
  ///
  /// In en, this message translates to:
  /// **'Removes everything the other presets remove and more: apps many people use, Xbox, printing, launchers at startup, game recording. Plus a clean driver install and WinSux, done by hand.'**
  String get presetCompetitiveSummary;

  /// No description provided for @presetAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get presetAttention;

  /// No description provided for @presetAttentionNote.
  ///
  /// In en, this message translates to:
  /// **'It removes a lot, including things many people use. No FPS, latency or other gain is promised: it is a set of changes, not a measured improvement.'**
  String get presetAttentionNote;

  /// No description provided for @presetGroupApps.
  ///
  /// In en, this message translates to:
  /// **'Apps it removes (current user)'**
  String get presetGroupApps;

  /// No description provided for @presetGroupServices.
  ///
  /// In en, this message translates to:
  /// **'Services it turns off'**
  String get presetGroupServices;

  /// No description provided for @presetGroupStartup.
  ///
  /// In en, this message translates to:
  /// **'Startup entries it turns off'**
  String get presetGroupStartup;

  /// No description provided for @presetGroupTweaks.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get presetGroupTweaks;

  /// No description provided for @presetGroupThirdParty.
  ///
  /// In en, this message translates to:
  /// **'Third-party scripts and tools'**
  String get presetGroupThirdParty;

  /// No description provided for @presetGroupRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get presetGroupRestart;

  /// No description provided for @presetGroupReversible.
  ///
  /// In en, this message translates to:
  /// **'What can be undone'**
  String get presetGroupReversible;

  /// No description provided for @presetRestartNeeded.
  ///
  /// In en, this message translates to:
  /// **'Restart afterwards: services and startup entries change at the next start.'**
  String get presetRestartNeeded;

  /// No description provided for @presetRestartNone.
  ///
  /// In en, this message translates to:
  /// **'No restart needed.'**
  String get presetRestartNone;

  /// No description provided for @presetReversibleApps.
  ///
  /// In en, this message translates to:
  /// **'Apps: reinstall them from the Microsoft Store.'**
  String get presetReversibleApps;

  /// No description provided for @presetReversibleSettings.
  ///
  /// In en, this message translates to:
  /// **'Services, startup entries and settings: undo them right after with Undo preset, or later with the restore point created first.'**
  String get presetReversibleSettings;

  /// No description provided for @presetReversibleManual.
  ///
  /// In en, this message translates to:
  /// **'Third-party steps are not run by ZapTweaks: follow the author\'s own instructions to undo them.'**
  String get presetReversibleManual;

  /// No description provided for @presetManualWhy.
  ///
  /// In en, this message translates to:
  /// **'Done by hand: the script downloads and runs other files that cannot be pinned to a hash, so ZapTweaks does not run it.'**
  String get presetManualWhy;

  /// No description provided for @presetManualDriverClean.
  ///
  /// In en, this message translates to:
  /// **'Clean graphics driver install: DDU in Safe Mode, then the latest driver from the vendor.'**
  String get presetManualDriverClean;

  /// No description provided for @presetManualWinsux.
  ///
  /// In en, this message translates to:
  /// **'WinSux: Windows debloat and settings in one script.'**
  String get presetManualWinsux;

  /// No description provided for @presetPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview on this PC'**
  String get presetPreview;

  /// No description provided for @presetPreviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Reading apps, services, startup entries and settings…'**
  String get presetPreviewLoading;

  /// No description provided for @presetStatusApply.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get presetStatusApply;

  /// No description provided for @presetStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Already set'**
  String get presetStatusDone;

  /// No description provided for @presetStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get presetStatusSkipped;

  /// No description provided for @presetStatusManual.
  ///
  /// In en, this message translates to:
  /// **'By hand'**
  String get presetStatusManual;

  /// No description provided for @presetSkipNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'not installed'**
  String get presetSkipNotInstalled;

  /// No description provided for @presetSkipNotFound.
  ///
  /// In en, this message translates to:
  /// **'not on this PC'**
  String get presetSkipNotFound;

  /// No description provided for @presetSkipUnsupported.
  ///
  /// In en, this message translates to:
  /// **'not supported here'**
  String get presetSkipUnsupported;

  /// No description provided for @presetSkipDuplicate.
  ///
  /// In en, this message translates to:
  /// **'same name twice: only the first is changed'**
  String get presetSkipDuplicate;

  /// No description provided for @presetCounts.
  ///
  /// In en, this message translates to:
  /// **'{apply} to do · {done} already set · {skipped} skipped'**
  String presetCounts(int apply, int done, int skipped);

  /// No description provided for @presetConsent.
  ///
  /// In en, this message translates to:
  /// **'I have read the full list and accept the risk.'**
  String get presetConsent;

  /// No description provided for @presetApply.
  ///
  /// In en, this message translates to:
  /// **'Apply preset'**
  String get presetApply;

  /// No description provided for @presetApplyNote.
  ///
  /// In en, this message translates to:
  /// **'A restore point is created first; if it fails nothing changes. Administrator changes ask for UAC once.'**
  String get presetApplyNote;

  /// No description provided for @presetApplying.
  ///
  /// In en, this message translates to:
  /// **'Applying…'**
  String get presetApplying;

  /// No description provided for @presetReport.
  ///
  /// In en, this message translates to:
  /// **'Done: {ok} changed, {failed} not changed.'**
  String presetReport(int ok, int failed);

  /// No description provided for @presetUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo preset'**
  String get presetUndo;

  /// No description provided for @presetUndone.
  ///
  /// In en, this message translates to:
  /// **'Preset undone. Removed apps stay removed: reinstall them from the Store.'**
  String get presetUndone;

  /// No description provided for @presetNothingToDo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do: everything is already set.'**
  String get presetNothingToDo;

  /// No description provided for @presetSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Save as my preset'**
  String get presetSaveAs;

  /// No description provided for @presetSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Saves the items still ticked. Share the file to export it; put a file in the folder to import it.'**
  String get presetSaveNote;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get presetName;

  /// No description provided for @presetSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String presetSaved(String path);

  /// No description provided for @presetOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Open presets folder'**
  String get presetOpenFolder;

  /// No description provided for @presetUserTitle.
  ///
  /// In en, this message translates to:
  /// **'My presets'**
  String get presetUserTitle;

  /// No description provided for @presetInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'{file} not loaded: {error}'**
  String presetInvalidFile(String file, String error);

  /// No description provided for @presetItemPowerThrottling.
  ///
  /// In en, this message translates to:
  /// **'Power throttling of running apps off'**
  String get presetItemPowerThrottling;

  /// No description provided for @presetItemEndTask.
  ///
  /// In en, this message translates to:
  /// **'End task in the taskbar menu'**
  String get presetItemEndTask;

  /// No description provided for @presetItemAdvertisingId.
  ///
  /// In en, this message translates to:
  /// **'Advertising ID off'**
  String get presetItemAdvertisingId;

  /// No description provided for @presetItemLanguageList.
  ///
  /// In en, this message translates to:
  /// **'Websites can\'t read your language list'**
  String get presetItemLanguageList;

  /// No description provided for @presetItemAppLaunchTracking.
  ///
  /// In en, this message translates to:
  /// **'Windows doesn\'t track the apps you start'**
  String get presetItemAppLaunchTracking;

  /// No description provided for @presetItemTailoredExperiences.
  ///
  /// In en, this message translates to:
  /// **'No tailored experiences from diagnostic data'**
  String get presetItemTailoredExperiences;

  /// No description provided for @presetItemCloudContent.
  ///
  /// In en, this message translates to:
  /// **'No cloud-optimized content (suggestions)'**
  String get presetItemCloudContent;

  /// No description provided for @presetItemDiagnosticData.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic data: required only'**
  String get presetItemDiagnosticData;

  /// No description provided for @presetItemLockScreenOverlay.
  ///
  /// In en, this message translates to:
  /// **'No tips over the lock screen'**
  String get presetItemLockScreenOverlay;

  /// No description provided for @presetItemLockScreenFacts.
  ///
  /// In en, this message translates to:
  /// **'No fun facts on the lock screen'**
  String get presetItemLockScreenFacts;

  /// No description provided for @presetItemGameDvr.
  ///
  /// In en, this message translates to:
  /// **'Game Bar game recording off'**
  String get presetItemGameDvr;

  /// No description provided for @presetSkipHasDependents.
  ///
  /// In en, this message translates to:
  /// **'Other services depend on it, so Windows does not allow disabling it.'**
  String get presetSkipHasDependents;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsModes.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get settingsModes;

  /// No description provided for @settingsMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get settingsMaintenance;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @openLogFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'Session logs with every command ZapTweaks ran.'**
  String get openLogFolderDescription;

  /// No description provided for @redetectSystemStateDescription.
  ///
  /// In en, this message translates to:
  /// **'Read the hardware and the state of every tweak again.'**
  String get redetectSystemStateDescription;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings profile'**
  String get profileTitle;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Save ZapTweaks preferences to a file or load them from one.'**
  String get profileDescription;

  /// No description provided for @resetAppSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Back to default ZapTweaks preferences. Windows is not changed.'**
  String get resetAppSettingsDescription;

  /// No description provided for @expertModeOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get expertModeOn;

  /// No description provided for @expertModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get expertModeOff;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
