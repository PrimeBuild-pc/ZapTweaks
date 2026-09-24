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
  /// **'Show advanced operations and external tools. Safety restrictions still apply.'**
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
