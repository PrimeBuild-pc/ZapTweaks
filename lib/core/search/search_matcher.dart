class SearchMatcher {
  const SearchMatcher._();

  static bool matches(String query, String text) {
    final needle = _normalize(query);
    final haystack = _normalize(text);
    if (needle.isEmpty || haystack.contains(needle)) return needle.isNotEmpty;

    final words = haystack.split(' ').where((word) => word.isNotEmpty).toList();
    return needle
        .split(' ')
        .where((term) => term.isNotEmpty)
        .every(
          (term) => words.any(
            (word) =>
                word.startsWith(term) ||
                term.startsWith(word) ||
                _distance(term, word) <= (term.length >= 5 ? 2 : 1),
          ),
        );
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  static int _distance(String left, String right) {
    if (left == right) return 0;
    if (left.isEmpty) return right.length;
    if (right.isEmpty) return left.length;
    final previous = List<int>.generate(right.length + 1, (index) => index);
    for (var row = 1; row <= left.length; row++) {
      var diagonal = previous[0];
      previous[0] = row;
      for (var column = 1; column <= right.length; column++) {
        final above = previous[column];
        previous[column] = <int>[
          above + 1,
          previous[column - 1] + 1,
          diagonal +
              (left.codeUnitAt(row - 1) == right.codeUnitAt(column - 1)
                  ? 0
                  : 1),
        ].reduce((a, b) => a < b ? a : b);
        diagonal = above;
      }
    }
    return previous.last;
  }
}
