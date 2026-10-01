import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../domain/store_app.dart';

class AppStoreCatalog {
  const AppStoreCatalog(this.apps);

  final List<StoreApp> apps;
  static const remoteUrl =
      'https://raw.githubusercontent.com/PrimeBuild-pc/ZapTweaks/main/assets/catalog/app_catalog.json';
  static const _maxBytes = 2 * 1024 * 1024;
  static Future<AppStoreCatalog>? _session;
  static bool _loadingSession = false;

  /// One catalog per session, shared by search, setup and the app store.
  /// Supplying only an asset bundle keeps offline tests deterministic.
  static Future<AppStoreCatalog> load({
    AssetBundle? bundle,
    http.Client? client,
    File? cacheFile,
    bool refresh = false,
  }) {
    if (bundle != null || client != null || cacheFile != null) {
      return _load(
        bundle ?? rootBundle,
        client,
        cacheFile,
        remote: client != null,
      );
    }
    if (refresh && !_loadingSession) _session = null;
    if (_session != null) return _session!;
    _loadingSession = true;
    return _session = _load(
      rootBundle,
      null,
      File(
        path.join(
          Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path,
          'ZapTweaks',
          'app_catalog.json',
        ),
      ),
      remote: true,
    ).whenComplete(() => _loadingSession = false);
  }

  static Future<AppStoreCatalog> _load(
    AssetBundle bundle,
    http.Client? client,
    File? cache, {
    required bool remote,
  }) async {
    var fallback = _parse(
      await bundle.loadString('assets/catalog/app_catalog.json'),
    );
    if (!remote) return fallback;
    if (cache != null) {
      try {
        if (await cache.length() <= _maxBytes) {
          fallback = _parse(await cache.readAsString());
        }
      } catch (_) {
        /* Missing or invalid cache: keep bundled catalog. */
      }
    }
    final ownedClient = client == null;
    client ??= http.Client();
    try {
      final text = await (() async {
        final request = http.Request('GET', Uri.parse(remoteUrl))
          ..followRedirects = false;
        final response = await client!.send(request);
        if (response.statusCode != 200 ||
            (response.contentLength ?? 0) > _maxBytes) {
          throw const FormatException('Invalid remote catalog response.');
        }
        final bytes = <int>[];
        await for (final chunk in response.stream) {
          if (bytes.length + chunk.length > _maxBytes) {
            throw const FormatException('Catalog too large.');
          }
          bytes.addAll(chunk);
        }
        return utf8.decode(bytes);
      })().timeout(const Duration(seconds: 5));
      final catalog = _parse(text);
      if (cache != null) {
        try {
          await cache.parent.create(recursive: true);
          final temp = File('${cache.path}.tmp');
          await temp.writeAsString(text, flush: true);
          await temp.rename(cache.path);
        } catch (_) {
          /* A cache write failure must not hide valid catalog data. */
        }
      }
      return catalog;
    } catch (_) {
      return fallback;
    } finally {
      if (ownedClient) client.close();
    }
  }

  static AppStoreCatalog _parse(String text) {
    if (utf8.encode(text).length > _maxBytes) {
      throw const FormatException('Catalog too large.');
    }
    final json = jsonDecode(text);
    if (json is! Map ||
        json['schemaVersion'] != 1 ||
        json['apps'] is! List ||
        json.keys.any(
          (key) => !{'schemaVersion', 'generatedFrom', 'apps'}.contains(key),
        )) {
      throw const FormatException('Unsupported catalog schema.');
    }
    final rows = json['apps'] as List;
    if (rows.isEmpty || rows.length > 2000) {
      throw const FormatException('Invalid catalog size.');
    }
    final ids = <String>{},
        names = <String>{},
        packages = <String>{},
        repositories = <String>{};
    final apps = <StoreApp>[];
    const allowed = {
      'id',
      'name',
      'category',
      'wingetId',
      'url',
      'author',
      'sources',
      'description',
      'requirements',
      'warnings',
    };
    for (final row in rows) {
      if (row is! Map || row.keys.any((key) => !allowed.contains(key))) {
        throw const FormatException('Catalog entries are metadata only.');
      }
      final data = Map<String, dynamic>.from(row);
      for (final key in ['id', 'name', 'category', 'author']) {
        _text(data[key], max: 200);
      }
      if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(data['id'] as String) ||
          !ids.add(data['id'] as String) ||
          !names.add(
            (data['name'] as String).trim().toLowerCase().replaceAll(
              RegExp(r'\s+'),
              ' ',
            ),
          )) {
        throw const FormatException('Duplicate or invalid app identity.');
      }
      final winget = data['wingetId'];
      if (winget != null &&
          (winget is! String ||
              !RegExp(
                r'^(?:msstore:)?[A-Za-z0-9][A-Za-z0-9._+-]{0,199}$',
              ).hasMatch(winget) ||
              !packages.add(winget.toLowerCase()))) {
        throw const FormatException('Duplicate or invalid package identity.');
      }
      if (data['url'] != null) {
        _text(data['url'], max: 2048);
        final url = Uri.parse(data['url'] as String);
        if (url.scheme != 'https' ||
            url.host.isEmpty ||
            url.userInfo.isNotEmpty ||
            url.port != 443) {
          throw const FormatException('Catalog links must use HTTPS.');
        }
        if (url.host.toLowerCase() == 'github.com') {
          if (url.pathSegments.length < 2 ||
              !repositories.add(
                url.pathSegments.take(2).join('/').toLowerCase(),
              )) {
            throw const FormatException(
              'Duplicate or invalid GitHub repository.',
            );
          }
        }
      } else if (winget == null) {
        throw const FormatException('App has no source.');
      }
      _texts(data['sources'], required: true);
      if (data['description'] != null) _text(data['description'], max: 2000);
      for (final key in ['requirements', 'warnings']) {
        if (data[key] != null) _texts(data[key]);
      }
      apps.add(StoreApp.fromJson(data));
    }
    return AppStoreCatalog(List.unmodifiable(apps));
  }

  static void _text(Object? value, {required int max}) {
    if (value is! String ||
        value.trim().isEmpty ||
        value.length > max ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(value)) {
      throw const FormatException('Invalid catalog text.');
    }
  }

  static void _texts(Object? value, {bool required = false}) {
    if (value is! List || value.length > 20 || (required && value.isEmpty)) {
      throw const FormatException('Invalid catalog text list.');
    }
    for (final item in value) {
      _text(item, max: 2000);
    }
  }
}
