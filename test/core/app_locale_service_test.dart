import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/app_locale_service.dart';
import 'package:script_utility/l10n/app_localizations.dart';

void main() {
  test('supports exactly the seven requested locale codes', () {
    expect(AppLocaleService.supportedCodes, <String>[
      'en',
      'it',
      'de',
      'es',
      'fr',
      'ru',
      'zh',
    ]);
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      unorderedEquals(AppLocaleService.supportedCodes),
    );
  });

  test(
    'translates navigation categories without changing their internal ids',
    () {
      expect(
        AppLocaleService.category('it', 'Power & CPU'),
        'Alimentazione e CPU',
      );
      expect(AppLocaleService.category('zh-CN', 'Tools'), '工具');
      expect(AppLocaleService.category('en', 'Gaming'), 'Gaming');
    },
  );

  test('normalizes Windows locale names and falls back to English', () {
    expect(AppLocaleService.normalize('it-IT'), 'it');
    expect(AppLocaleService.normalize('de_DE'), 'de');
    expect(AppLocaleService.normalize('zh-CN'), 'zh');
    expect(AppLocaleService.normalize('pt-BR'), 'en');
    expect(AppLocaleService.normalize(null), 'en');
  });
}
