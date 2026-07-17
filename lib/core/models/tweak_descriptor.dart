import '../../models/system_tweak.dart';

class TweakDescriptor {
  const TweakDescriptor({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isAggressive = false,
    this.restartRequired = false,
    this.requiredCpuVendor,
    this.requiredGpuVendors = const <String>{},
    this.minimumWindowsBuild,
    this.conflictingTweakIds = const <String>{},
    this.systemKey,
    this.scriptTweak,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final bool isAggressive;
  final bool restartRequired;
  final String? requiredCpuVendor;
  final Set<String> requiredGpuVendors;
  final int? minimumWindowsBuild;
  final Set<String> conflictingTweakIds;
  final String? systemKey;
  final SystemTweak? scriptTweak;

  bool get isSystemToggle => systemKey != null;
  bool get isScriptToggle => scriptTweak != null && scriptTweak!.hasState;
  bool get isScriptAction => scriptTweak != null && !scriptTweak!.hasState;
}
