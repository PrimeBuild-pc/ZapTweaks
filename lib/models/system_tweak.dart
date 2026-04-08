enum TweakUiType { toggle, launcher, interactiveScript }

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
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final TweakUiType type;
  final String actionLabel;
  final bool isAggressive;
  bool isApplied;

  bool get hasState => type == TweakUiType.toggle;

  Future<void> runAction() async {
    await onApply();
  }

  Future<void> onApply();
  Future<void> onRevert();
  Future<bool> checkState();
}

abstract class ActionSystemTweak extends SystemTweak {
  ActionSystemTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.type,
    super.actionLabel,
    super.isAggressive,
  });

  @override
  Future<void> onRevert() async {}

  @override
  Future<bool> checkState() async => false;
}
