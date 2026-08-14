import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/models/tweak_descriptor.dart';
import 'package:script_utility/core/services/tweak_text_localizer.dart';

void main() {
  test(
    'uses translated copy where available and preserves technical fallback',
    () {
      const descriptor = TweakDescriptor(
        id: 'gaming_amd_gpu_extreme_profile',
        title: 'AMD GPU Extreme Profile',
        description: 'English fallback.',
        category: 'Gaming',
        isAggressive: true,
        systemKey: 'x',
      );

      final italian = TweakTextLocalizer.resolve(descriptor, 'it');
      final english = TweakTextLocalizer.resolve(descriptor, 'en');

      expect(italian.title, 'Profilo GPU AMD estremo');
      expect(italian.details, contains('punto di ripristino'));
      expect(english.title, 'AMD GPU Extreme Profile');
    },
  );
}
