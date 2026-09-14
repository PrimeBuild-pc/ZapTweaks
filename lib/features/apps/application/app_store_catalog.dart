import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/store_app.dart';

class AppStoreCatalog {
  const AppStoreCatalog(this.apps);

  final List<StoreApp> apps;

  static Future<AppStoreCatalog> load({AssetBundle? bundle}) async {
    final json =
        jsonDecode(
              await (bundle ?? rootBundle).loadString(
                'assets/catalog/app_catalog.json',
              ),
            )
            as Map<String, dynamic>;
    final apps = (json['apps']! as List)
        .map((row) => StoreApp.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
    return AppStoreCatalog(apps);
  }
}
