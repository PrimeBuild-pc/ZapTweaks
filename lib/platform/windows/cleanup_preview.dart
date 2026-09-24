import 'dart:io';

class CleanupCandidate {
  const CleanupCandidate({
    required this.path,
    required this.category,
    required this.size,
    required this.reason,
  });

  final String path;
  final String category;
  final int size;
  final String reason;
}

class CleanupPreview {
  const CleanupPreview(this.candidates);

  final List<CleanupCandidate> candidates;
  int get totalBytes => candidates.fold(0, (sum, item) => sum + item.size);
}

class CleanupScanner {
  const CleanupScanner();

  Future<CleanupPreview> scanDirectory(
    Directory directory, {
    required String category,
    required String reason,
  }) async {
    if (!await directory.exists()) return const CleanupPreview([]);
    final candidates = <CleanupCandidate>[];
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      try {
        candidates.add(
          CleanupCandidate(
            path: entity.path,
            category: category,
            size: await entity.length(),
            reason: reason,
          ),
        );
      } on FileSystemException {
        // A locked or vanished file is omitted rather than forced.
      }
    }
    return CleanupPreview(candidates);
  }
}
