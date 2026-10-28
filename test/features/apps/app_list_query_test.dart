import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/app_list_query.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';
import 'package:script_utility/features/apps/domain/app_safety_policy.dart';

AppPackage _app(
  String name, {
  AppProvider provider = AppProvider.win32,
  int? size,
  DateTime? date,
  bool system = false,
  String hive = 'HKLM',
  String? publisher,
}) => AppPackage(
  provider: provider,
  packageId: provider == AppProvider.appx ? name : '$hive\\64\\$name',
  name: name,
  version: null,
  publisher: publisher,
  scopes: const {AppInstallScope.allUsers},
  source: 'x',
  reinstallable: false,
  sizeBytes: size,
  installDate: date,
  uninstall: provider == AppProvider.win32
      ? UninstallEntry(
          hive: hive,
          view: '64',
          key: name,
          uninstallString: 'u.exe',
          systemComponent: system,
        )
      : null,
);

final _apps = <AppPackage>[
  _app('Zeta', size: 100, date: DateTime(2024)),
  _app('alpha', size: 5000, date: DateTime(2026), publisher: 'Contoso'),
  _app('Runtime', system: true),
  _app('Microsoft.WindowsFeedbackHub', provider: AppProvider.appx, size: 10),
  _app('Per user', hive: 'HKCU', size: 50),
];

List<String> _names(AppListQuery query) =>
    query.apply(_apps).map((app) => app.name).toList();

void main() {
  test('type: Store for AppX, System for kept Win32, User otherwise', () {
    expect(appTypeOf(_apps[0]), AppType.user);
    expect(appTypeOf(_apps[2]), AppType.system);
    expect(appTypeOf(_apps[3]), AppType.store);
  });

  test('size sort puts biggest first and unknown sizes last', () {
    expect(_names(const AppListQuery()), [
      'alpha',
      'Zeta',
      'Per user',
      'Microsoft.WindowsFeedbackHub',
      'Runtime',
    ]);
  });

  test('name sort ignores case; date sort is newest first, unknown last', () {
    expect(_names(const AppListQuery(sort: AppSort.name)).take(3), [
      'alpha',
      'Microsoft.WindowsFeedbackHub',
      'Per user',
    ]);
    expect(_names(const AppListQuery(sort: AppSort.date)).take(2), [
      'alpha',
      'Zeta',
    ]);
  });

  test('filters combine with search on name and publisher', () {
    expect(_names(const AppListQuery(type: AppType.store)), [
      'Microsoft.WindowsFeedbackHub',
    ]);
    expect(
      _names(const AppListQuery(safety: AppSafety.keep)),
      ['Microsoft.WindowsFeedbackHub', 'Runtime'],
      reason: 'an AppX without removal metadata is kept',
    );
    expect(_names(const AppListQuery(source: AppSource.currentUser)), [
      'Per user',
    ]);
    expect(_names(const AppListQuery(search: 'contoso')), ['alpha']);
  });

  test('selection total adds known sizes and counts unknown ones', () {
    final total = selectionSize([_apps[0], _apps[1], _apps[2]]);
    expect(total.bytes, 5100);
    expect(total.unknown, 1);
  });
}
