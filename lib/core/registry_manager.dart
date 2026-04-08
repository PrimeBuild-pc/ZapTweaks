import 'services/process_runner.dart';

class RegistryException implements Exception {
  RegistryException(this.message, {this.exitCode});

  final String message;
  final int? exitCode;

  @override
  String toString() => message;
}

class RegistryManager {
  static Future<int?> readDword(String keyPath, String valueName) async {
    try {
      final result = await _runRegProcess('reg', [
        'query',
        keyPath,
        '/v',
        valueName,
      ]);

      if (result.exitCode != 0) {
        return null;
      }

      final rawValue = _extractQueryValue(
        result.stdout.toString(),
        valueName,
        r'REG_DWORD',
      );
      if (rawValue == null) {
        return null;
      }

      return _parseDword(rawValue);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> readString(String keyPath, String valueName) async {
    try {
      final result = await _runRegProcess('reg', [
        'query',
        keyPath,
        '/v',
        valueName,
      ]);

      if (result.exitCode != 0) {
        return null;
      }

      final rawValue = _extractQueryValue(
        result.stdout.toString(),
        valueName,
        r'REG_(SZ|EXPAND_SZ)',
      );
      if (rawValue == null) {
        return null;
      }

      final trimmed = rawValue.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == '(value not set)') {
        return null;
      }

      return trimmed;
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeDword(
    String keyPath,
    String valueName,
    int value,
  ) async {
    final normalizedValue = value.toUnsigned(32);
    await _runReg(<String>[
      'add',
      _quote(keyPath),
      '/v',
      _quote(valueName),
      '/t',
      'REG_DWORD',
      '/d',
      normalizedValue.toString(),
      '/f',
    ], operation: 'write REG_DWORD $keyPath/$valueName');
  }

  static Future<void> writeString(
    String keyPath,
    String valueName,
    String value,
  ) async {
    await _runReg(<String>[
      'add',
      _quote(keyPath),
      '/v',
      _quote(valueName),
      '/t',
      'REG_SZ',
      '/d',
      value,
      '/f',
    ], operation: 'write REG_SZ $keyPath/$valueName');
  }

  static Future<void> writeBinary(
    String keyPath,
    String valueName,
    String hexValue,
  ) async {
    await _runReg(<String>[
      'add',
      _quote(keyPath),
      '/v',
      _quote(valueName),
      '/t',
      'REG_BINARY',
      '/d',
      hexValue,
      '/f',
    ], operation: 'write REG_BINARY $keyPath/$valueName');
  }

  static Future<void> deleteValue(String keyPath, String valueName) async {
    await _runReg(<String>[
      'delete',
      _quote(keyPath),
      '/v',
      _quote(valueName),
      '/f',
    ], operation: 'delete value $keyPath/$valueName');
  }

  static Future<void> _runReg(
    List<String> arguments, {
    required String operation,
  }) async {
    try {
      final result = await _runRegProcess('reg.exe', arguments);
      if (result.exitCode != 0) {
        final stderr = result.stderr.toString().trim();
        final stdout = result.stdout.toString().trim();
        final details = stderr.isNotEmpty
            ? stderr
            : (stdout.isNotEmpty ? stdout : 'Unknown registry error');

        throw RegistryException(
          'Registry operation failed: $operation | $details',
          exitCode: result.exitCode,
        );
      }
    } catch (e) {
      throw RegistryException('Unable to execute reg.exe: ${e.toString()}');
    }
  }

  static Future<CommandResult> _runRegProcess(
    String executable,
    List<String> arguments, {
    bool runInShell = true,
  }) async {
    return ProcessRunner.shared.run(
      executable,
      arguments,
      runInShell: runInShell,
      timeout: const Duration(seconds: 30),
    );
  }

  static String _quote(String value) {
    final escaped = value.replaceAll('"', r'\"');
    return '"$escaped"';
  }

  static String? _extractQueryValue(
    String output,
    String valueName,
    String typePattern,
  ) {
    final exactLineRegex = RegExp(
      '^\\s*${RegExp.escape(valueName)}\\s+$typePattern\\s+(.+)\$',
      multiLine: true,
      caseSensitive: false,
    );

    final exactLineMatch = exactLineRegex.firstMatch(output);
    if (exactLineMatch != null) {
      return exactLineMatch.group(1)?.trim();
    }

    final fallbackRegex = RegExp(
      '$typePattern\\s+(.+)\$',
      multiLine: true,
      caseSensitive: false,
    );
    final fallbackMatch = fallbackRegex.firstMatch(output);
    return fallbackMatch?.group(1)?.trim();
  }

  static int? _parseDword(String rawValue) {
    final firstToken = rawValue.trim().split(RegExp(r'\s+')).first;
    final token = firstToken.toLowerCase();

    if (token.startsWith('0x')) {
      return int.tryParse(token.substring(2), radix: 16);
    }

    final decimal = int.tryParse(token);
    if (decimal != null) {
      return decimal;
    }

    final bracketedDecimal = RegExp(r'\((\d+)\)').firstMatch(rawValue);
    if (bracketedDecimal != null) {
      return int.tryParse(bracketedDecimal.group(1)!);
    }

    return null;
  }
}
