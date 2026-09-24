import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class NetworkDiagnosticResult {
  const NetworkDiagnosticResult({
    required this.capturedAt,
    required this.endpoint,
    required this.latencySamplesMs,
    required this.lostSamples,
    required this.downloadedBytes,
    required this.downloadSeconds,
  });

  final DateTime capturedAt;
  final Uri endpoint;
  final List<double> latencySamplesMs;
  final int lostSamples;
  final int downloadedBytes;
  final double downloadSeconds;

  int get sentSamples => latencySamplesMs.length + lostSamples;
  double? get latencyMs => latencySamplesMs.isEmpty
      ? null
      : latencySamplesMs.reduce((a, b) => a + b) / latencySamplesMs.length;
  double? get jitterMs {
    if (latencySamplesMs.length < 2) return null;
    var total = 0.0;
    for (var index = 1; index < latencySamplesMs.length; index++) {
      total += (latencySamplesMs[index] - latencySamplesMs[index - 1]).abs();
    }
    return total / (latencySamplesMs.length - 1);
  }

  double get packetLossPercent =>
      sentSamples == 0 ? 100 : lostSamples * 100 / sentSamples;
  double? get throughputMbps => downloadSeconds <= 0
      ? null
      : downloadedBytes * 8 / downloadSeconds / 1000000;

  Map<String, Object?> toJson() => <String, Object?>{
    'capturedAt': capturedAt.toUtc().toIso8601String(),
    'endpoint': endpoint.toString(),
    'latencySamplesMs': latencySamplesMs,
    'lostSamples': lostSamples,
    'downloadedBytes': downloadedBytes,
    'downloadSeconds': downloadSeconds,
    'latencyMs': latencyMs,
    'jitterMs': jitterMs,
    'packetLossPercent': packetLossPercent,
    'throughputMbps': throughputMbps,
  };
}

typedef LatencyProbe = Future<double?> Function(Uri endpoint, Duration timeout);

class NetworkDiagnosticsService {
  NetworkDiagnosticsService({
    http.Client Function()? clientFactory,
    LatencyProbe? latencyProbe,
  }) : _clientFactory = clientFactory ?? http.Client.new,
       _latencyProbe = latencyProbe ?? _probeTcp;

  final http.Client Function() _clientFactory;
  final LatencyProbe _latencyProbe;
  http.Client? _client;
  bool _cancelled = false;
  bool _running = false;

  void cancel() {
    _cancelled = true;
    _client?.close();
  }

  Future<NetworkDiagnosticResult> measure({
    required Uri endpoint,
    int samples = 6,
    int maximumBytes = 10 * 1024 * 1024,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_running) throw StateError('A network diagnostic is already running.');
    if (endpoint.scheme != 'https' ||
        endpoint.host.isEmpty ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.fragment.isNotEmpty) {
      throw const FormatException('A direct HTTPS endpoint is required.');
    }
    if (samples < 3 || samples > 20) {
      throw const FormatException('Sample count must be between 3 and 20.');
    }
    if (maximumBytes < 1024 || maximumBytes > 50 * 1024 * 1024) {
      throw const FormatException(
        'Download limit must be between 1 KiB and 50 MiB.',
      );
    }
    _running = true;
    _cancelled = false;
    final latencies = <double>[];
    var lost = 0;
    try {
      for (var index = 0; index < samples; index++) {
        if (_cancelled) throw StateError('Network diagnostic cancelled.');
        final latency = await _latencyProbe(
          endpoint,
          const Duration(seconds: 3),
        );
        if (latency == null) {
          lost++;
        } else {
          latencies.add(latency);
        }
      }
      if (_cancelled) throw StateError('Network diagnostic cancelled.');

      final client = _clientFactory();
      _client = client;
      final request = http.Request('GET', endpoint)
        ..followRedirects = false
        ..maxRedirects = 0
        ..headers['Range'] = 'bytes=0-${maximumBytes - 1}';
      final watch = Stopwatch()..start();
      final response = await client.send(request).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Diagnostic endpoint returned HTTP ${response.statusCode}.',
          uri: endpoint,
        );
      }
      var bytes = 0;
      await (() async {
        await for (final chunk in response.stream) {
          if (_cancelled) throw StateError('Network diagnostic cancelled.');
          bytes += chunk.length;
          if (bytes >= maximumBytes) break;
        }
      })().timeout(timeout);
      if (_cancelled) throw StateError('Network diagnostic cancelled.');
      watch.stop();
      return NetworkDiagnosticResult(
        capturedAt: DateTime.now().toUtc(),
        endpoint: endpoint,
        latencySamplesMs: List<double>.unmodifiable(latencies),
        lostSamples: lost,
        downloadedBytes: bytes > maximumBytes ? maximumBytes : bytes,
        downloadSeconds: watch.elapsedMicroseconds / 1000000,
      );
    } on TimeoutException {
      _client?.close();
      throw StateError('Network diagnostic timed out.');
    } finally {
      _client?.close();
      _client = null;
      _running = false;
    }
  }

  static Future<double?> _probeTcp(Uri endpoint, Duration timeout) async {
    final watch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        endpoint.host,
        endpoint.hasPort ? endpoint.port : 443,
        timeout: timeout,
      );
      watch.stop();
      socket.destroy();
      return watch.elapsedMicroseconds / 1000;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    }
  }
}
