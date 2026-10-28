import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/core/services/tweak_text_localizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('only ZapTweaks, ThreadPilot and LightCrosshair are by PrimeBuild', () {
    final catalog =
        jsonDecode(File('assets/catalog/app_catalog.json').readAsStringSync())
            as Map<String, dynamic>;
    final ownApps = <String>[
      for (final app in catalog['apps'] as List)
        if ((app as Map)['author'] == 'PrimeBuild') app['name'] as String,
    ]..sort();

    expect(ownApps, <String>['LightCrosshair', 'ThreadPilot', 'ZapTweaks']);
  });

  test('native tweaks carry no author; third-party text names none', () {
    final catalog = TweakCatalogService().buildCatalog();
    final byAuthor = RegExp(
      r'\b(by|di|von|par|de|от) (Fr33thy|Fr33hty|zoicware|Sapphire|kubaam)\b|Fr33thy 的',
    );

    for (final descriptor in catalog) {
      if (descriptor.isSystemToggle) {
        expect(descriptor.scriptTweak?.author, isNull, reason: descriptor.id);
      }
      for (final locale in <String>['en', 'it', 'de', 'es', 'fr', 'ru', 'zh']) {
        final text = TweakTextLocalizer.resolve(descriptor, locale);
        expect(
          byAuthor.hasMatch('${text.title} ${text.description}'),
          isFalse,
          reason: '${descriptor.id} [$locale]',
        );
      }
    }
  });

  test('Fr33thy and zoicware entries keep their author as a field', () {
    final authors = <String, String?>{
      for (final d in TweakCatalogService().buildCatalog())
        d.id: d.scriptTweak?.author,
    };

    expect(authors['check_ram_check'], 'Fr33thy');
    expect(authors['tool_winsux_debloat'], 'Fr33thy');
    expect(authors['tool_zoicware_zturbo'], 'zoicware');
    expect(authors['tool_ctt_winutil'], 'Chris Titus Tech');
  });
}
