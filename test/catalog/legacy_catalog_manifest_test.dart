import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';

void main() {
  test('legacy manifest freezes all 346 catalog entries', () {
    final file = File('assets/catalog/legacy_catalog.json');
    expect(file.existsSync(), isTrue);

    final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final entries = (root['entries'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final ids = entries.map((entry) => entry['id'] as String).toList();
    final dispositions = entries
        .map((entry) => entry['disposition'] as String)
        .toList();

    expect(entries, hasLength(346));
    expect(ids.toSet(), hasLength(346));
    expect(
      entries.every((entry) => (entry['destination'] as String).isNotEmpty),
      isTrue,
    );
    expect(
      entries.every((entry) => (entry['disposition'] as String).isNotEmpty),
      isTrue,
    );
    expect(dispositions.where((value) => value == 'external'), hasLength(78));
    expect(
      entries.where(
        (entry) => (entry['title'] as String).contains('Script Variant'),
      ),
      hasLength(37),
    );

    final aliases = entries.where((entry) => entry['disposition'] == 'alias');
    expect(aliases, hasLength(23));
    expect(
      aliases.every((entry) => (entry['aliasTarget'] as String).isNotEmpty),
      isTrue,
    );

    final catalogIds = TweakCatalogService()
        .buildCatalog()
        .map((entry) => entry.id)
        .toSet();
    expect(catalogIds, ids.toSet());
  });

  test('legacy aliases are complete and acyclic', () {
    final root =
        jsonDecode(
              File('assets/catalog/legacy_catalog.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final entries = (root['entries'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final aliases = <String, String>{
      for (final entry in entries.where(
        (entry) => entry['disposition'] == 'alias',
      ))
        entry['id'] as String: entry['aliasTarget'] as String,
    };

    for (final start in aliases.keys) {
      final visited = <String>{};
      String? current = start;
      while (current != null && aliases.containsKey(current)) {
        expect(visited.add(current), isTrue, reason: 'Alias cycle at $start');
        current = aliases[current];
      }
    }
  });
}
