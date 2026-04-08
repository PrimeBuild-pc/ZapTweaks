class SystemMetricsSnapshot {
  const SystemMetricsSnapshot({
    required this.timestamp,
    required this.cpuUsagePercent,
    required this.gpuUsagePercent,
    required this.memoryUsagePercent,
    required this.memoryUsedBytes,
    required this.memoryTotalBytes,
    required this.vramUsagePercent,
    required this.vramUsedBytes,
    required this.vramTotalBytes,
  });

  static const SystemMetricsSnapshot empty = SystemMetricsSnapshot(
    timestamp: null,
    cpuUsagePercent: 0,
    gpuUsagePercent: 0,
    memoryUsagePercent: 0,
    memoryUsedBytes: 0,
    memoryTotalBytes: 0,
    vramUsagePercent: 0,
    vramUsedBytes: 0,
    vramTotalBytes: 0,
  );

  final DateTime? timestamp;
  final double cpuUsagePercent;
  final double gpuUsagePercent;
  final double memoryUsagePercent;
  final int memoryUsedBytes;
  final int memoryTotalBytes;
  final double vramUsagePercent;
  final int vramUsedBytes;
  final int vramTotalBytes;

  double get memoryUsedGb => memoryUsedBytes / _bytesInGb;
  double get memoryTotalGb => memoryTotalBytes / _bytesInGb;
  double get vramUsedGb => vramUsedBytes / _bytesInGb;
  double get vramTotalGb => vramTotalBytes / _bytesInGb;

  String get cpuLabel => '${cpuUsagePercent.toStringAsFixed(1)}%';

  String get gpuLabel => '${gpuUsagePercent.toStringAsFixed(1)}%';

  String get memoryPercentLabel => '${memoryUsagePercent.toStringAsFixed(1)}%';

  String get vramPercentLabel => '${vramUsagePercent.toStringAsFixed(1)}%';

  String get memoryDetailLabel {
    if (memoryTotalBytes <= 0) {
      return '${memoryUsedGb.toStringAsFixed(1)} GB used';
    }

    return '${memoryUsedGb.toStringAsFixed(1)} / ${memoryTotalGb.toStringAsFixed(1)} GB';
  }

  String get vramDetailLabel {
    if (vramTotalBytes <= 0) {
      return '${vramUsedGb.toStringAsFixed(1)} GB used';
    }

    return '${vramUsedGb.toStringAsFixed(1)} / ${vramTotalGb.toStringAsFixed(1)} GB';
  }

  static const double _bytesInGb = 1024 * 1024 * 1024;
}
