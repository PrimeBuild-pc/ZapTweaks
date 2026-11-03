import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Game folders that ZapTweaks excluded from Defender. Kept locally because
/// Defender shows its exclusion list only to administrators; it drives the
/// "Remove" list and the reminder shown while at least one exists.
class DefenderExclusionRecords {
  DefenderExclusionRecords(this.file);

  static final instance = DefenderExclusionRecords(
    File(
      p.join(
        Platform.environment['APPDATA'] ?? Directory.systemTemp.path,
        'ZapTweaks',
        'defender-exclusions.json',
      ),
    ),
  );

  final File file;
  final ValueNotifier<List<String>> paths = ValueNotifier(const <String>[]);

  Future<void> load() async {
    try {
      final json = jsonDecode(await file.readAsString());
      paths.value = json is List
          ? List.unmodifiable(json.whereType<String>())
          : const <String>[];
    } catch (_) {
      paths.value = const <String>[];
    }
  }

  Future<void> add(String path) => _save(<String>[
    ...paths.value.where((item) => !p.windows.equals(item, path)),
    path,
  ]);

  Future<void> remove(String path) => _save(
    paths.value.where((item) => !p.windows.equals(item, path)).toList(),
  );

  Future<void> _save(List<String> next) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(next));
    paths.value = List.unmodifiable(next);
  }
}
