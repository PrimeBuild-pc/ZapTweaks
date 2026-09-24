import 'dart:convert';

import 'package:flutter/services.dart';

class LegacyCatalogEntry {
  const LegacyCatalogEntry({
    required this.id,
    required this.title,
    required this.destination,
    required this.disposition,
    required this.target,
    this.aliasTarget,
  });

  factory LegacyCatalogEntry.fromJson(Map<String, dynamic> json) {
    return LegacyCatalogEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      disposition: json['disposition'] as String,
      target: json['target'] as String,
      aliasTarget: json['aliasTarget'] as String?,
    );
  }

  final String id;
  final String title;
  final String destination;
  final String disposition;
  final String target;
  final String? aliasTarget;
}

class LegacyCatalogManifest {
  const LegacyCatalogManifest(this.entries);

  factory LegacyCatalogManifest.fromJson(String source) {
    final root = jsonDecode(source) as Map<String, dynamic>;
    final entries = (root['entries'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(LegacyCatalogEntry.fromJson)
        .toList(growable: false);
    return LegacyCatalogManifest(entries);
  }

  static Future<LegacyCatalogManifest> load({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(
      'assets/catalog/legacy_catalog.json',
    );
    return LegacyCatalogManifest.fromJson(source);
  }

  final List<LegacyCatalogEntry> entries;
}
