class SystemMetricsSnapshot {
  const SystemMetricsSnapshot({
    required this.timestamp,
    required this.cpuUsagePercent,
    required this.memoryUsagePercent,
    required this.memoryUsedBytes,
    required this.memoryTotalBytes,
  });

  static const SystemMetricsSnapshot empty = SystemMetricsSnapshot(
    timestamp: null,
    cpuUsagePercent: 0,
    memoryUsagePercent: 0,
    memoryUsedBytes: 0,
    memoryTotalBytes: 0,
  );

  final DateTime? timestamp;
  final double cpuUsagePercent;
  final double memoryUsagePercent;
  final int memoryUsedBytes;
  final int memoryTotalBytes;

  double get memoryUsedGb => memoryUsedBytes / _bytesInGb;
  double get memoryTotalGb => memoryTotalBytes / _bytesInGb;

  String get cpuLabel => '${cpuUsagePercent.toStringAsFixed(1)}%';

  String get memoryPercentLabel => '${memoryUsagePercent.toStringAsFixed(1)}%';

  String get memoryDetailLabel {
    if (memoryTotalBytes <= 0) {
      return '${memoryUsedGb.toStringAsFixed(1)} GB used';
    }

    return '${memoryUsedGb.toStringAsFixed(1)} / ${memoryTotalGb.toStringAsFixed(1)} GB';
  }

  static const double _bytesInGb = 1024 * 1024 * 1024;
}
