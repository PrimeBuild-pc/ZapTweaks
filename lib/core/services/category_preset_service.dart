import '../models/tweak_descriptor.dart';

class CategoryPresetService {
  static const String defaultPreset = 'Default';
  static const String safePreset = 'Safe';
  static const String aggressivePreset = 'Aggressive';

  List<String> availablePresetsForCategory(String category) {
    if (category == 'Home') {
      return const <String>[defaultPreset];
    }

    return const <String>[defaultPreset, safePreset, aggressivePreset];
  }

  bool shouldEnable({
    required String category,
    required String preset,
    required TweakDescriptor descriptor,
  }) {
    switch (preset) {
      case safePreset:
        return !descriptor.isAggressive;
      case aggressivePreset:
        return true;
      case defaultPreset:
      default:
        return false;
    }
  }
}
