import 'dart:ffi';

final int Function() _getTickCount64 = DynamicLibrary.open(
  'kernel32.dll',
).lookupFunction<Uint64 Function(), int Function()>('GetTickCount64');

bool windowsRebootedSince(DateTime timestamp) {
  final bootedAt = DateTime.now().toUtc().subtract(
    Duration(milliseconds: _getTickCount64()),
  );
  return bootedAt.isAfter(timestamp.toUtc());
}
