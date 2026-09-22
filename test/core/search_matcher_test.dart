import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/search/search_matcher.dart';

void main() {
  test('search matches fragments, multiple terms, and small typing errors', () {
    expect(SearchMatcher.matches('bench', 'BenchMate benchmark'), isTrue);
    expect(SearchMatcher.matches('msi v3', 'MSI Utility v3'), isTrue);
    expect(
      SearchMatcher.matches(
        'Mozilla.Firefox',
        'Firefox app_mozilla_firefox Mozilla.Firefox Browsers Mozilla',
      ),
      isTrue,
    );
    expect(
      SearchMatcher.matches('powre settings', 'Power Settings Explorer'),
      isTrue,
    );
    expect(
      SearchMatcher.matches('unrelated', 'Power Settings Explorer'),
      isFalse,
    );
  });
}
