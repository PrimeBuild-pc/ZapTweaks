import '../../models/action_tweaks.dart';
import '../../models/system_tweak.dart';

class TweakDescriptor {
  const TweakDescriptor({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.collection = 'General',
    this.isAggressive = false,
    this.restartRequired = false,
    this.requiredCpuVendor,
    this.requiredGpuVendors = const <String>{},
    this.minimumWindowsBuild,
    this.conflictingTweakIds = const <String>{},
    this.systemKey,
    this.scriptTweak,
    this.migrationDisposition = 'legacy',
    this.aliasTarget,
  });

  final String id;
  final String title;
  final String description;
  final String category;

  /// Intermediate grouping inside a sidebar category, rendered as a collapsible
  /// collection in the tweaks page.
  final String collection;
  final bool isAggressive;
  final bool restartRequired;
  final String? requiredCpuVendor;
  final Set<String> requiredGpuVendors;
  final int? minimumWindowsBuild;
  final Set<String> conflictingTweakIds;
  final String? systemKey;
  final SystemTweak? scriptTweak;
  final String migrationDisposition;
  final String? aliasTarget;

  bool get isSystemToggle => systemKey != null;
  bool get isScriptToggle => scriptTweak != null && scriptTweak!.hasState;
  bool get isScriptAction => scriptTweak != null && !scriptTweak!.hasState;
  bool get isAlias => migrationDisposition == 'alias';
  bool get isRejected => migrationDisposition == 'rejected';
  bool get isBlockedLegacyScript =>
      scriptTweak is ScriptInteractiveTweak ||
      scriptTweak is BatchScriptTweak ||
      scriptTweak is RegistryImportTweak ||
      scriptTweak is PowerShellTerminalCommandTweak ||
      scriptTweak is NvidiaProfileImportTweak ||
      scriptTweak is ExecutableLauncherTweak ||
      scriptTweak is DirectoryLauncherTweak ||
      scriptTweak is ExplorerSelectFileTweak ||
      scriptTweak?.id == 'tool_winget_interactive_uninstaller';

  TweakDescriptor copyWith({
    String? category,
    String? migrationDisposition,
    String? aliasTarget,
  }) {
    return TweakDescriptor(
      id: id,
      title: title,
      description: description,
      category: category ?? this.category,
      collection: collection,
      isAggressive: isAggressive,
      restartRequired: restartRequired,
      requiredCpuVendor: requiredCpuVendor,
      requiredGpuVendors: requiredGpuVendors,
      minimumWindowsBuild: minimumWindowsBuild,
      conflictingTweakIds: conflictingTweakIds,
      systemKey: systemKey,
      scriptTweak: scriptTweak,
      migrationDisposition: migrationDisposition ?? this.migrationDisposition,
      aliasTarget: aliasTarget ?? this.aliasTarget,
    );
  }
}
