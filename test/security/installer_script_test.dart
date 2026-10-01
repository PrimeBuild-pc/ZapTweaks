import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'bootstrap verifies official identity, SHA-256 and size before launch',
    () async {
      final dir = await Directory.systemTemp.createTemp('bootstrap-test-');
      addTearDown(() => dir.delete(recursive: true));
      final script = File(
        'scripts/installer-latest.ps1',
      ).absolute.path.replaceAll("'", "''");
      for (final mode in [
        'valid',
        'badHash',
        'badSize',
        'badUrl',
        'noDigest',
      ]) {
        final asset = <String, Object>{
          'name': 'ZapTweaks_Setup_v9.9.9.exe',
          'browser_download_url': mode == 'badUrl'
              ? 'https://evil.example/setup.exe'
              : 'https://github.com/PrimeBuild-pc/ZapTweaks/releases/download/v9.9.9/ZapTweaks_Setup_v9.9.9.exe',
          'size': mode == 'badSize' ? 4 : 3,
          if (mode != 'noDigest')
            'digest':
                'sha256:${sha256.convert(mode == 'badHash' ? [4, 5, 6] : [1, 2, 3])}',
        };
        final payload = base64Encode(
          utf8.encode(
            jsonEncode({
              'tag_name': 'v9.9.9',
              'draft': false,
              'prerelease': false,
              'assets': [asset],
            }),
          ),
        );
        final wrapper =
            '''
\$global:launches = 0
function Invoke-RestMethod { param(\$Uri, \$Headers)
  if (\$Uri -ne 'https://api.github.com/repos/PrimeBuild-pc/ZapTweaks/releases/latest') { throw 'Unexpected endpoint' }
  [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$payload')) | ConvertFrom-Json
}
function Invoke-WebRequest { param(\$Uri, \$OutFile, [switch]\$UseBasicParsing, \$TimeoutSec)
  [IO.File]::WriteAllBytes(\$OutFile, [byte[]](1,2,3))
}
function icacls.exe { \$global:LASTEXITCODE = 0 }
function Get-FileHash { throw 'Hash cmdlet intentionally unavailable; use .NET SHA256' }
function Start-Process { param(\$FilePath, [switch]\$Wait) \$global:launches++ }
try { . '$script' } catch { Write-Output "GUARDED: \$_" }
Write-Output "LAUNCHES=\$global:launches"
''';
        final encoded = ByteData(wrapper.codeUnits.length * 2);
        for (var i = 0; i < wrapper.codeUnits.length; i++) {
          encoded.setUint16(i * 2, wrapper.codeUnits[i], Endian.little);
        }
        final result = await Process.run(
          'powershell',
          [
            '-NoProfile',
            '-EncodedCommand',
            base64Encode(encoded.buffer.asUint8List()),
          ],
          environment: {'LOCALAPPDATA': dir.path},
        ).timeout(const Duration(seconds: 20));
        expect(result.exitCode, 0, reason: '${result.stderr}');
        expect(
          result.stdout.toString(),
          contains('LAUNCHES=${mode == 'valid' ? 1 : 0}'),
          reason: mode,
        );
        if (mode == 'valid') {
          expect(result.stdout.toString(), isNot(contains('GUARDED:')));
        } else {
          expect(result.stdout.toString(), contains('GUARDED:'));
        }
      }
    },
    skip: !Platform.isWindows,
  );
}
