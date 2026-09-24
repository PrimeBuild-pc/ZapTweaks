enum WindowsOptionalFeatureState {
  enabled,
  disabled,
  enablePending,
  disablePending,
  unknown,
}

class WindowsOptionalFeature {
  const WindowsOptionalFeature({required this.name, required this.state});

  final String name;
  final WindowsOptionalFeatureState state;

  bool? get enabled => switch (state) {
    WindowsOptionalFeatureState.enabled => true,
    WindowsOptionalFeatureState.disabled => false,
    _ => null,
  };

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'state': state.name,
  };

  factory WindowsOptionalFeature.fromJson(Map<String, dynamic> json) =>
      WindowsOptionalFeature(
        name: json['name']! as String,
        state: WindowsOptionalFeatureState.values.byName(
          json['state']! as String,
        ),
      );
}
