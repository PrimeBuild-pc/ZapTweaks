import 'dart:convert';
import 'dart:io';

import '../domain/preset_catalog.dart';

/// A user preset is a name plus a subset of the built-in items, by key.
/// Nothing else is accepted, so an imported file can never add a script,
/// a link or a service ZapTweaks has not reviewed.
const maxUserPresetBytes = 64 * 1024;
const _format = 'zaptweaks.preset';

final Map<String, PresetItem> presetItemsByKey = <String, PresetItem>{
  for (final item in builtInPresets.expand((preset) => preset.items))
    item.key: item,
};

/// Items only the Competitive preset carries: a user preset using any of
/// them gets the same visible warning and consent.
final Set<String> _attentionKeys = () {
  final lighter = <String>{
    for (final preset in builtInPresets.where((p) => !p.attention))
      ...preset.items.map((i) => i.key),
  };
  return <String>{
    for (final preset in builtInPresets.where((p) => p.attention))
      ...preset.items.map((i) => i.key).where((k) => !lighter.contains(k)),
  };
}();

String encodeUserPreset(String name, Iterable<String> keys) =>
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'format': _format,
      'version': 1,
      'name': name,
      'items': keys.toList(),
    });

Preset decodeUserPreset(String json) {
  if (json.length > maxUserPresetBytes) {
    throw const FormatException('Preset file is too large.');
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    throw const FormatException('Not a JSON file.');
  }
  if (decoded is! Map ||
      decoded['format'] != _format ||
      decoded['version'] != 1) {
    throw const FormatException('Not a ZapTweaks preset (version 1).');
  }
  final name = decoded['name'];
  if (name is! String ||
      name.trim().isEmpty ||
      name.length > 60 ||
      name.runes.any((r) => r < 0x20 || r == 0x7f)) {
    throw const FormatException('Invalid preset name.');
  }
  final keys = decoded['items'];
  if (keys is! List || keys.isEmpty || keys.length > presetItemsByKey.length) {
    throw const FormatException('Invalid item list.');
  }
  final items = <PresetItem>[];
  final seen = <String>{};
  for (final key in keys) {
    final item = key is String ? presetItemsByKey[key] : null;
    if (item == null) throw FormatException('Unknown item: $key');
    if (!seen.add(key as String)) throw FormatException('Duplicate: $key');
    items.add(item);
  }
  return Preset(
    'user',
    items,
    name: name.trim(),
    attention: seen.any(_attentionKeys.contains),
  );
}

/// `Documents\ZapTweaks\Presets`: save there, share the file, drop files
/// in to import. [documents] is the real Documents folder (it may be on
/// OneDrive). shortcut: no file dialog (no picker dependency); add one
/// if people ask for import from anywhere.
Directory userPresetFolder(
  Map<String, String> environment, {
  String? documents,
}) => Directory(
  <String>[
    documents ??
        <String>[
          environment['USERPROFILE'] ?? '.',
          'Documents',
        ].join(Platform.pathSeparator),
    'ZapTweaks',
    'Presets',
  ].join(Platform.pathSeparator),
);

File saveUserPreset(Directory folder, String name, Iterable<String> keys) {
  final json = encodeUserPreset(name, keys);
  decodeUserPreset(json); // Never write what import would refuse.
  folder.createSync(recursive: true);
  final base = name.replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '_').trim();
  final file = File(
    '${folder.path}${Platform.pathSeparator}${base.isEmpty ? 'preset' : base}.json',
  );
  file.writeAsStringSync(json);
  return file;
}

List<({File file, Preset? preset, String? error})> loadUserPresets(
  Directory folder,
) {
  if (!folder.existsSync()) {
    return const <({File file, Preset? preset, String? error})>[];
  }
  final files =
      folder
          .listSync(followLinks: false)
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return <({File file, Preset? preset, String? error})>[
    for (final file in files)
      () {
        try {
          if (file.lengthSync() > maxUserPresetBytes) {
            throw const FormatException('Preset file is too large.');
          }
          return (
            file: file,
            preset: decodeUserPreset(file.readAsStringSync()),
            error: null,
          );
        } on FormatException catch (error) {
          return (file: file, preset: null, error: error.message);
        } on FileSystemException catch (error) {
          return (file: file, preset: null, error: error.message);
        }
      }(),
  ];
}
