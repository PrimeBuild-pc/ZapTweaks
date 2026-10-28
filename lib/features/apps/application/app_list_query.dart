import '../domain/app_package.dart';
import '../domain/app_safety_policy.dart';

enum AppType { system, user, store }

/// Where the entry was read: machine-wide registry, current user, or Store.
enum AppSource { allUsers, currentUser, store }

enum AppSort { size, name, date }

AppType appTypeOf(AppPackage app) => app.provider == AppProvider.appx
    ? AppType.store
    : classifyApp(app).safety == AppSafety.keep
    ? AppType.system
    : AppType.user;

AppSource appSourceOf(AppPackage app) => app.provider == AppProvider.appx
    ? AppSource.store
    : app.uninstall?.hive == 'HKCU'
    ? AppSource.currentUser
    : AppSource.allUsers;

/// Search, filters and sort of the installed-apps list. Null filter = all.
class AppListQuery {
  const AppListQuery({
    this.search = '',
    this.type,
    this.safety,
    this.source,
    this.sort = AppSort.size,
  });

  final String search;
  final AppType? type;
  final AppSafety? safety;
  final AppSource? source;
  final AppSort sort;

  List<AppPackage> apply(Iterable<AppPackage> apps) {
    final needle = search.trim().toLowerCase();
    final result = apps.where((app) {
      if (type != null && appTypeOf(app) != type) return false;
      if (safety != null && classifyApp(app).safety != safety) return false;
      if (source != null && appSourceOf(app) != source) return false;
      return needle.isEmpty ||
          app.name.toLowerCase().contains(needle) ||
          app.packageId.toLowerCase().contains(needle) ||
          (app.publisher?.toLowerCase().contains(needle) ?? false);
    }).toList();
    int byName(AppPackage a, AppPackage b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
    // Unknown values sort last in every direction.
    int desc<T extends Comparable<T>>(T? a, T? b) =>
        a == null ? (b == null ? 0 : 1) : (b == null ? -1 : b.compareTo(a));
    result.sort(
      (a, b) => switch (sort) {
        AppSort.name => byName(a, b),
        AppSort.size => _then(desc(a.sizeBytes, b.sizeBytes), byName(a, b)),
        AppSort.date => _then(desc(a.installDate, b.installDate), byName(a, b)),
      },
    );
    return result;
  }

  static int _then(int first, int second) => first != 0 ? first : second;

  AppListQuery copyWith({
    String? search,
    AppType? Function()? type,
    AppSafety? Function()? safety,
    AppSource? Function()? source,
    AppSort? sort,
  }) => AppListQuery(
    search: search ?? this.search,
    type: type == null ? this.type : type(),
    safety: safety == null ? this.safety : safety(),
    source: source == null ? this.source : source(),
    sort: sort ?? this.sort,
  );
}

/// Known bytes of a selection plus how many apps have no known size.
({int bytes, int unknown}) selectionSize(Iterable<AppPackage> apps) => (
  bytes: apps.fold(0, (sum, app) => sum + (app.sizeBytes ?? 0)),
  unknown: apps.where((app) => app.sizeBytes == null).length,
);
