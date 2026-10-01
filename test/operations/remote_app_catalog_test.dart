import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:script_utility/features/apps/application/app_store_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'remote catalog updates all consumers and persists a validated offline cache',
    () async {
      final dir = await Directory.systemTemp.createTemp('catalog-test-');
      addTearDown(() => dir.delete(recursive: true));
      final cache = File('${dir.path}/catalog.json');
      final payload =
          jsonDecode(
                await rootBundle.loadString('assets/catalog/app_catalog.json'),
              )
              as Map<String, dynamic>;
      (payload['apps'] as List).add({
        'id': 'app_test_new',
        'name': 'New remote tool',
        'category': 'GPU & Display',
        'wingetId': null,
        'url': 'https://github.com/example/tool/releases',
        'author': 'example',
        'sources': ['Direct request'],
      });
      final catalog = await AppStoreCatalog.load(
        bundle: rootBundle,
        client: MockClient((request) async {
          expect(request.url.scheme, 'https');
          expect(request.url.host, 'raw.githubusercontent.com');
          expect(request.followRedirects, isFalse);
          return http.Response(jsonEncode(payload), 200);
        }),
        cacheFile: cache,
      );
      expect(catalog.apps.last.name, 'New remote tool');
      expect(await cache.exists(), isTrue);
      final offline = await AppStoreCatalog.load(
        bundle: rootBundle,
        client: MockClient((_) async => throw const SocketException('offline')),
        cacheFile: cache,
      );
      expect(offline.apps.last.name, 'New remote tool');
      for (final mutation in <void Function(Map<String, dynamic>)>[
        (row) => row['url'] = 'file:///C:/malicious.exe',
        (row) => row['command'] = 'powershell bad',
        (row) => row['wingetId'] = 'Vendor.Tool; bad',
        (row) => row['wingetId'] = '--ignore-security-hash',
        (row) => row['name'] = 'NV-UV-Play',
        (row) => row['url'] = 'https://user:pass@example.test/tool',
        (row) => row['name'] = 'New remote tool\u0000',
      ]) {
        final bad = jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
        mutation((bad['apps'] as List).last as Map<String, dynamic>);
        final fallback = await AppStoreCatalog.load(
          bundle: rootBundle,
          client: MockClient((_) async => http.Response(jsonEncode(bad), 200)),
          cacheFile: cache,
        );
        expect(fallback.apps.last.name, 'New remote tool');
        expect(jsonDecode(await cache.readAsString()), payload);
      }
      for (final bad in [
        {...payload, 'schemaVersion': 999},
        {...payload, 'command': 'powershell bad'},
      ]) {
        final fallback = await AppStoreCatalog.load(
          bundle: rootBundle,
          client: MockClient((_) async => http.Response(jsonEncode(bad), 200)),
          cacheFile: cache,
        );
        expect(fallback.apps.last.name, 'New remote tool');
        expect(jsonDecode(await cache.readAsString()), payload);
      }
      await cache.writeAsString('{"schemaVersion":999}');
      final bundled = await AppStoreCatalog.load(
        bundle: rootBundle,
        client: MockClient((_) async => http.Response('invalid', 200)),
        cacheFile: cache,
      );
      expect(bundled.apps, hasLength(465));
    },
  );
}
