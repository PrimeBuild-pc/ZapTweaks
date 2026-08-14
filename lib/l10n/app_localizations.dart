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
  /// **'Aggressive tweak. A restore point is mandatory.'**
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
  /// **'Bundled Power Plans'**
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
