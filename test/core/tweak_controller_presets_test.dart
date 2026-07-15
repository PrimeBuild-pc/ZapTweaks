import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/models/tweak_descriptor.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';

void main() {
  test('presets remain available for non-Home categories', () {
    expect(
      TweakController.availablePresetsForCategory('Gaming'),
      const <String>['Default', 'Safe', 'Aggressive'],
    );
    expect(TweakController.availablePresetsForCategory('Tools'), const <String>[
      'Default',
      'Safe',
      'Aggressive',
    ]);
    expect(TweakController.availablePresetsForCategory('Home'), const <String>[
      'Default',
    ]);
  });

  test('safe preset skips aggressive toggles', () {
    const aggressiveDescriptor = TweakDescriptor(
      id: 'x',
      title: 'x',
      description: 'x',
      category: 'Gaming',
      isAggressive: true,
      systemKey: 'x',
    );
    const regularDescriptor = TweakDescriptor(
      id: 'y',
      title: 'y',
      description: 'y',
      category: 'Gaming',
      systemKey: 'y',
    );

    expect(
      TweakController.shouldEnablePreset(
        TweakController.safePreset,
        aggressiveDescriptor,
      ),
      isFalse,
    );
    expect(
      TweakController.shouldEnablePreset(
        TweakController.safePreset,
        regularDescriptor,
      ),
      isTrue,
    );
  });
}
