import 'app_package.dart';
import 'appx_candidate_policy.dart';

enum AppSafety { removable, checkFirst, keep }

/// One-line reason behind a verdict; the UI turns it into localized text.
enum AppSafetyReason {
  systemComponent,
  protected,
  update,
  windowsPart,
  sharedDependency,
  optionalFeature,
  missingUninstaller,
  userInstalled,
}

typedef AppVerdict = ({AppSafety safety, AppSafetyReason reason});

/// Runtimes, drivers and vendor control panels other programs rely on.
/// Curated list: add a pattern here, with a test, rather than in the UI.
final List<RegExp> sharedDependencyPatterns = <RegExp>[
  RegExp(r'Visual C\+\+ .*Redistributable', caseSensitive: false),
  RegExp(r'\.NET (Runtime|Framework|Desktop Runtime)', caseSensitive: false),
  RegExp(r'Windows Desktop Runtime', caseSensitive: false),
  RegExp(r'ASP\.NET Core', caseSensitive: false),
  RegExp(r'WebView2 Runtime', caseSensitive: false),
  RegExp(r'DirectX', caseSensitive: false),
  RegExp(r'\bDriver\b', caseSensitive: false),
  RegExp(r'Chipset', caseSensitive: false),
  RegExp(r'PhysX', caseSensitive: false),
  RegExp(
    r'Graphics Command Center|Control Panel|AMD Software',
    caseSensitive: false,
  ),
  RegExp(r'Realtek|Dolby|Nahimic|Waves MaxxAudio', caseSensitive: false),
  RegExp(
    r'Java\(TM\)|Java \d+ Update|Runtime Environment',
    caseSensitive: false,
  ),
  RegExp(
    r'Microsoft Update Health Tools|Windows SDK|Software Development Kit|'
    r'Assessment and Deployment Kit|Windows Driver Kit',
    caseSensitive: false,
  ),
];

AppVerdict classifyApp(AppPackage app) {
  final entry = app.uninstall;
  if (entry?.systemComponent == true) {
    return (safety: AppSafety.keep, reason: AppSafetyReason.systemComponent);
  }
  if (entry?.noRemove == true) {
    return (safety: AppSafety.keep, reason: AppSafetyReason.protected);
  }
  if (entry?.isUpdate == true) {
    return (safety: AppSafety.keep, reason: AppSafetyReason.update);
  }
  if (app.provider == AppProvider.appx) {
    final candidate = app.appxCandidate;
    if (candidate == null &&
        app.publisher != null &&
        !app.publisher!.contains('O=Microsoft Corporation') &&
        !app.isFramework) {
      // A third-party Store app the user installed (Spotify, WhatsApp…).
      return (
        safety: AppSafety.removable,
        reason: AppSafetyReason.userInstalled,
      );
    }
    return switch (candidate?.group) {
      AppxCandidateGroup.lowRisk when app.canRemoveAppx => (
        safety: AppSafety.removable,
        reason: AppSafetyReason.userInstalled,
      ),
      AppxCandidateGroup.optional => (
        safety: AppSafety.checkFirst,
        reason: AppSafetyReason.optionalFeature,
      ),
      _ => (safety: AppSafety.keep, reason: AppSafetyReason.windowsPart),
    };
  }
  if (sharedDependencyPatterns.any((pattern) => pattern.hasMatch(app.name))) {
    return (
      safety: AppSafety.checkFirst,
      reason: AppSafetyReason.sharedDependency,
    );
  }
  if (app.labels.contains(AppLabel.missingUninstaller)) {
    return (
      safety: AppSafety.checkFirst,
      reason: AppSafetyReason.missingUninstaller,
    );
  }
  return (safety: AppSafety.removable, reason: AppSafetyReason.userInstalled);
}
