import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/presets/application/user_presets.dart';
import 'package:script_utility/features/presets/domain/preset_catalog.dart';

void main() {
  test('round trip keeps the name and the chosen items', () {
    final json = encodeUserPreset('My setup', const [
      'app:Microsoft.BingNews',
      'service:DiagTrack',
      'manual:winsux',
    ]);
    final preset = decodeUserPreset(json);
    expect(preset.name, 'My setup');
    expect(preset.builtIn, isFalse);
    expect(preset.items.map((i) => i.key), [
      'app:Microsoft.BingNews',
      'service:DiagTrack',
      'manual:winsux',
    ]);
    expect(preset.attention, isTrue, reason: 'WinSux is Competitive-only');
    expect(
      decodeUserPreset(
        encodeUserPreset('light', const ['app:Microsoft.BingNews']),
      ).attention,
      isFalse,
    );
  });

  test('a preset with Competitive-only items asks for attention', () {
    final preset = decodeUserPreset(
      encodeUserPreset('x', const ['service:Spooler']),
    );
    expect(preset.attention, isTrue);
  });

  group('rejected on import', () {
    String doc(Object? items, {Object? name = 'n', Object? format}) =>
        jsonEncode(<String, Object?>{
          'format': format ?? 'zaptweaks.preset',
          'version': 1,
          'name': name,
          'items': items,
        });

    final cases = <String, String>{
      'not JSON': '{',
      'wrong format': doc(const ['app:Microsoft.BingNews'], format: 'other'),
      'unknown item': doc(const ['app:Evil.App']),
      'script smuggled as item': doc(const ['script:iwr x | iex']),
      'arbitrary link': doc(const ['manual:https://evil.example']),
      'items not a list': doc('app:Microsoft.BingNews'),
      'empty': doc(const <String>[]),
      'duplicate': doc(const [
        'app:Microsoft.BingNews',
        'app:Microsoft.BingNews',
      ]),
      'empty name': doc(const ['app:Microsoft.BingNews'], name: ' '),
      'long name': doc(const ['app:Microsoft.BingNews'], name: 'x' * 61),
      'control char': doc(const ['app:Microsoft.BingNews'], name: 'a\u0007'),
      'too large': 'x' * (maxUserPresetBytes + 1),
    };
    cases.forEach((label, json) {
      test(label, () {
        expect(() => decodeUserPreset(json), throwsFormatException);
      });
    });
  });

  test('saved files are listed; bad ones carry their error', () {
    final dir = Directory.systemTemp.createTempSync('zt_presets');
    addTearDown(() => dir.deleteSync(recursive: true));
    final saved = saveUserPreset(dir, 'Gaming: mine/1', const [
      'tweak:power_throttling_off',
    ]);
    expect(saved.parent.path, dir.path, reason: 'no path escape from name');
    File('${dir.path}${Platform.pathSeparator}bad.json').writeAsStringSync('{');
    final loaded = loadUserPresets(dir);
    expect(loaded, hasLength(2));
    expect(
      loaded.where((e) => e.preset != null).single.preset!.name,
      'Gaming: mine/1',
    );
    expect(loaded.where((e) => e.error != null), hasLength(1));
  });

  test('every built-in item key is importable', () {
    for (final item in builtInPresets.expand((p) => p.items)) {
      expect(presetItemsByKey[item.key], isNotNull);
    }
  });
}
