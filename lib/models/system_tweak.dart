/// UI rendering modes supported by tweak descriptors.
enum TweakUiType { toggle, launcher, interactiveScript }

/// Base contract for all tweak definitions used by the catalog.
abstract class SystemTweak {
  SystemTweak({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isApplied = false,
    this.type = TweakUiType.toggle,
    this.actionLabel = 'Run',
    this.isAggressive = false,
    this.warningMessage,
    this.requiredCpuVendor,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final TweakUiType type;
  final String actionLabel;
  final bool isAggressive;
  final String? warningMessage;
  final String? requiredCpuVendor;
  bool isApplied;

  bool get hasState => type == TweakUiType.toggle;

  Future<void> runAction() async {
    await onApply();
  }

  Future<void> onApply();
  Future<void> onRevert();
  Future<bool> checkState();
}

/// Base type for one-shot or launcher tweaks without persisted toggle state.
abstract class ActionSystemTweak extends SystemTweak {
  ActionSystemTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.type,
    super.actionLabel,
    super.isAggressive,
    super.warningMessage,
    super.requiredCpuVendor,
  });

  @override
  Future<void> onRevert() async {}

  @override
  Future<bool> checkState() async => false;
}
