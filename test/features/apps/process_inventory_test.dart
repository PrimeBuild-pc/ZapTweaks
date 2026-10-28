import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/process_inventory.dart';

ProcessEntry _p(
  String name, {
  String? path,
  String? company,
  int session = 1,
  int pid = 100,
}) => ProcessEntry(
  pid: pid,
  name: name,
  path: path,
  description: null,
  company: company,
  memoryBytes: 1000,
  cpuPercent: 0,
  sessionId: session,
);

ProcessVerdict _classify(ProcessEntry entry) =>
    classifyProcess(entry, systemRoot: r'C:\Windows', selfPid: 1);

void main() {
  test('critical system processes are Windows and never offered', () {
    for (final name in [
      'csrss',
      'lsass',
      'winlogon',
      'svchost',
      'dwm',
      'System',
      'Registry',
      'smss',
      'wininit',
      'services',
    ]) {
      final verdict = _classify(_p(name, path: null, session: 0));
      expect(verdict.kind, ProcessKind.windows, reason: name);
      expect(verdict.canClose, isFalse, reason: name);
    }
  });

  test('anything run from the Windows folder is Windows and not offered', () {
    final verdict = _classify(
      _p(
        'notepad',
        path: r'C:\Windows\System32\notepad.exe',
        company: 'Microsoft Corporation',
      ),
    );
    expect(verdict.kind, ProcessKind.windows);
    expect(verdict.canClose, isFalse);
  });

  test('Microsoft apps outside Windows can be closed', () {
    final verdict = _classify(
      _p(
        'msedge',
        path: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
        company: 'Microsoft Corporation',
      ),
    );
    expect(verdict.kind, ProcessKind.microsoftApp);
    expect(verdict.canClose, isTrue);
  });

  test(
    'third-party user processes can be closed; services in session 0 cannot',
    () {
      final app = _classify(
        _p(
          'Discord',
          path: r'C:\Users\Me\AppData\Local\Discord\app-1\Discord.exe',
          company: 'Discord Inc.',
        ),
      );
      expect(app.kind, ProcessKind.thirdParty);
      expect(app.canClose, isTrue);

      final service = _classify(
        _p(
          'vmware-authd',
          path: r'C:\Program Files (x86)\VMware\vmware-authd.exe',
          company: 'VMware, Inc.',
          session: 0,
        ),
      );
      expect(service.kind, ProcessKind.thirdParty);
      expect(service.canClose, isFalse);
      expect(service.reason, ProcessReason.service);
    },
  );

  test('ZapTweaks itself is never offered', () {
    final verdict = classifyProcess(
      _p(
        'ZapTweaks',
        path: r'C:\Program Files\ZapTweaks\ZapTweaks.exe',
        pid: 1,
      ),
      systemRoot: r'C:\Windows',
      selfPid: 1,
    );
    expect(verdict.canClose, isFalse);
  });

  test('parses the inventory JSON and skips malformed rows', () {
    final entries = parseProcessInventory(
      '[{"Id":4,"Name":"System","Path":null,"Description":null,"Company":null,"WorkingSet":1024,"Cpu":0.5,"SessionId":0},'
      '{"Id":"x"},'
      '{"Id":8812,"Name":"Discord","Path":"C:\\\\D\\\\Discord.exe","Description":"Discord","Company":"Discord Inc.","WorkingSet":2048,"Cpu":3.25,"SessionId":1}]',
    );
    expect(entries.map((e) => e.name), ['System', 'Discord']);
    expect(entries.last.cpuPercent, 3.25);
    expect(entries.last.memoryBytes, 2048);
    expect(entries.first.path, isNull);
  });

  test('a valid signer outranks the self-reported company', () {
    final fake = _p(
      'updater',
      path: r'C:\Users\Me\AppData\Local\x\updater.exe',
      company: 'Microsoft Corporation',
    ).withSigner('Evil Corp');
    expect(_classify(fake).kind, ProcessKind.thirdParty);
  });

  test('ending a process checks the PID still has the same name', () {
    final script = endProcessScript(8812, "it's.exe");
    expect(script, contains('Get-Process -Id 8812'));
    expect(script, isNot(contains("it's")), reason: 'name travels as base64');
    expect(script, contains('.Kill()'));
  });

  test('search URL encodes the process name', () {
    expect(
      processSearchUri('Some App & co').toString(),
      'https://duckduckgo.com/?q=%22Some+App+%26+co%22+process',
    );
  });
}
