import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all legacy interactive entries have one closed execution classification', () {
    final root =
        jsonDecode(
              File(
                'assets/catalog/legacy_script_classification.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final expected = Map<String, dynamic>.from(root['invariants']! as Map);
    final entries = (root['entries']! as List).cast<Map<String, dynamic>>();
    final ids = entries.map((entry) => entry['id']! as String).toList();

    expect(entries, hasLength(expected['total']! as int));
    expect(ids.toSet(), hasLength(ids.length));
    for (final classification in <String, int>{
      'alias': expected['aliases']! as int,
      'composite': expected['composites']! as int,
      'rejected': expected['rejected']! as int,
      'externalTool': expected['externalTools']! as int,
      'procedure': expected['procedures']! as int,
    }.entries) {
      expect(
        entries.where((entry) => entry['classification'] == classification.key),
        hasLength(classification.value),
      );
    }
    expect(
      entries
          .where((entry) => entry['resource'] is String)
          .every((entry) => File(entry['resource']! as String).existsSync()),
      isTrue,
    );
    expect(
      entries.where(
        (entry) =>
            entry['classification'] != 'externalTool' &&
            entry['classification'] != 'rejected',
      ),
      hasLength(expected['actionableNonExternal']! as int),
    );
    expect(
      entries
          .where((entry) => entry['executionPolicy'] == 'redirect')
          .every((entry) => entry['replacement'] is String),
      isTrue,
    );
    expect(
      entries.where(
        (entry) => entry['executionPolicy'] == 'blockedUntilDecomposed',
      ),
      hasLength(14),
    );
  });
}
