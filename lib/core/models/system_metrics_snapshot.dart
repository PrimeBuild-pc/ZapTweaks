class GpuMetrics {
  const GpuMetrics({
    required this.adapterId,
    this.name,
    this.usagePercent,
    this.vramUsedBytes,
    this.vramTotalBytes,
  });
  final String adapterId;
  final String? name;
  final double? usagePercent;
  final int? vramUsedBytes;
  final int? vramTotalBytes;
  double? get vramPercent => vramUsedBytes == null || (vramTotalBytes ?? 0) <= 0
      ? null
      : vramUsedBytes! / vramTotalBytes! * 100;
}

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
    this.cpuAvailable = true,
    this.gpuAvailable = true,
    this.memoryAvailable = true,
    this.vramAvailable = true,
    this.gpus = const [],
    this.primaryGpuId,
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
    cpuAvailable: false,
    gpuAvailable: false,
    memoryAvailable: false,
    vramAvailable: false,
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
  final bool cpuAvailable, gpuAvailable, memoryAvailable, vramAvailable;
  final List<GpuMetrics> gpus;
  final String? primaryGpuId;

  double get memoryUsedGb => memoryUsedBytes / _bytesInGb;
  double get memoryTotalGb => memoryTotalBytes / _bytesInGb;
  double get vramUsedGb => vramUsedBytes / _bytesInGb;
  double get vramTotalGb => vramTotalBytes / _bytesInGb;
  String get cpuLabel =>
      cpuAvailable ? '${cpuUsagePercent.toStringAsFixed(1)}%' : 'N/A';
  String get gpuLabel =>
      gpuAvailable ? '${gpuUsagePercent.toStringAsFixed(1)}%' : 'N/A';
  String get memoryPercentLabel =>
      memoryAvailable ? '${memoryUsagePercent.toStringAsFixed(1)}%' : 'N/A';
  String get vramPercentLabel =>
      vramAvailable ? '${vramUsagePercent.toStringAsFixed(1)}%' : 'N/A';
  String get memoryDetailLabel => !memoryAvailable
      ? 'N/A'
      : '${memoryUsedGb.toStringAsFixed(1)} / ${memoryTotalGb.toStringAsFixed(1)} GB';
  String get vramDetailLabel => !vramAvailable
      ? 'N/A'
      : '${vramUsedGb.toStringAsFixed(1)} / ${vramTotalGb.toStringAsFixed(1)} GB';
  static const double _bytesInGb = 1024 * 1024 * 1024;
}
