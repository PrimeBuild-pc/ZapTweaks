import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:script_utility/platform/windows/network_diagnostics_service.dart';

class _StreamingClient extends http.BaseClient {
  final controller = StreamController<List<int>>();
  final started = Completer<void>();
  bool closed = false;
  http.BaseRequest? request;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    if (!started.isCompleted) started.complete();
    return http.StreamedResponse(controller.stream, 200);
  }

  @override
  void close() {
    closed = true;
    if (!controller.isClosed) controller.close();
  }
}

class _HangingClient extends http.BaseClient {
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Completer<http.StreamedResponse>().future;
  @override
  void close() => closed = true;
}

void main() {
  Future<double?> probe(Uri endpoint, Duration timeout) async => 4.0;

  test('diagnostics require a user-supplied direct HTTPS endpoint', () async {
    final service = NetworkDiagnosticsService(latencyProbe: probe);
    await expectLater(
      service.measure(endpoint: Uri.parse('http://example.test/file')),
      throwsFormatException,
    );
    await expectLater(
      service.measure(endpoint: Uri.parse('https://user@example.test/file')),
      throwsFormatException,
    );
  });

  test('diagnostic cancellation closes the active download', () async {
    final client = _StreamingClient();
    final service = NetworkDiagnosticsService(
      clientFactory: () => client,
      latencyProbe: probe,
    );
    final result = service.measure(
      endpoint: Uri.parse('https://example.test/file'),
      samples: 3,
    );
    await client.started.future;
    expect(client.request!.followRedirects, isFalse);
    expect(client.request!.headers['Range'], 'bytes=0-${10 * 1024 * 1024 - 1}');

    service.cancel();

    await expectLater(result, throwsA(isA<StateError>()));
    expect(client.closed, isTrue);
  });

  test('diagnostic timeout closes the active client', () async {
    final client = _HangingClient();
    final service = NetworkDiagnosticsService(
      clientFactory: () => client,
      latencyProbe: probe,
    );

    await expectLater(
      service.measure(
        endpoint: Uri.parse('https://example.test/file'),
        samples: 3,
        timeout: const Duration(milliseconds: 10),
      ),
      throwsA(isA<StateError>()),
    );
    expect(client.closed, isTrue);
  });
}
