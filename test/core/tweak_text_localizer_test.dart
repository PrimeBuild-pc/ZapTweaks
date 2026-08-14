import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/models/tweak_descriptor.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
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

  test('translates every catalog entry into every supported language', () {
    final catalog = TweakCatalogService().buildCatalog();

    for (final locale in <String>['it', 'de', 'es', 'fr', 'ru', 'zh']) {
      for (final descriptor in catalog) {
        expect(
          TweakTextLocalizer.hasTranslation(descriptor, locale),
          isTrue,
          reason: '${descriptor.id} is missing $locale copy',
        );
      }
    }
  });

  test('translates reference subtitles and generated service subtitles', () {
    const network = TweakDescriptor(
      id: 'network_llmnr_off',
      title: 'LLMNR Off',
      description: 'English fallback.',
      category: 'Networking',
      isAggressive: true,
      systemKey: 'x',
    );
    const service = TweakDescriptor(
      id: 'service_diagtrack_off',
      title: 'Connected User Experiences and Telemetry Off',
      description: 'English fallback.',
      category: 'Services',
      isAggressive: true,
      systemKey: 'x',
    );

    expect(
      TweakTextLocalizer.resolve(network, 'it').description,
      'Disattiva la risoluzione legacy dei nomi tramite multicast locale.',
    );
    expect(
      TweakTextLocalizer.resolve(service, 'it').description,
      isNot('English fallback.'),
    );
  });
}
