import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/service_inventory.dart';
import 'package:script_utility/features/apps/domain/service_safety_policy.dart';

ServiceVerdict _classify(String name, {String? path, String? company}) =>
    classifyService(
      name: name,
      binaryPath: path,
      company: company,
      systemRoot: r'C:\Windows',
    );

void main() {
  test('curated services carry their class and what stops working', () {
    expect(_classify('DiagTrack').safety, ServiceSafety.canDisable);
    expect(_classify('diagtrack').reason, ServiceReason.telemetry);
    final spooler = _classify('Spooler');
    expect(spooler.safety, ServiceSafety.dependsOnUse);
    expect(spooler.reason, ServiceReason.printing);
    expect(_classify('wuauserv').safety, ServiceSafety.keep);
  });

  test('Defender lives outside the Windows folder and is still kept', () {
    final verdict = _classify(
      'WinDefend',
      path:
          r'C:\ProgramData\Microsoft\Windows Defender\platform\4.18\MsMpEng.exe',
      company: 'Microsoft Corporation',
    );
    expect(verdict.safety, ServiceSafety.keep);
  });

  test('unlisted Windows services are kept as not reviewed', () {
    final verdict = _classify(
      'Appinfo',
      path: r'C:\WINDOWS\system32\svchost.exe',
      company: 'Microsoft Corporation',
    );
    expect(verdict.safety, ServiceSafety.keep);
    expect(verdict.reason, ServiceReason.notReviewed);
  });

  test('driver services in the Windows folder are kept', () {
    final verdict = _classify(
      'AMD External Events Utility',
      path: r'C:\WINDOWS\System32\DriverStore\FileRepository\u0\atiesrxx.exe',
      company: 'AMD',
    );
    expect(verdict.safety, ServiceSafety.keep);
    expect(verdict.reason, ServiceReason.driverService);
  });

  test('services of installed programs depend on use', () {
    final third = _classify(
      'MullvadVPN',
      path: r'C:\Program Files\Mullvad VPN\resources\mullvad-daemon.exe',
      company: 'Mullvad VPN AB',
    );
    expect(third.safety, ServiceSafety.dependsOnUse);
    expect(third.reason, ServiceReason.thirdParty);
    final office = _classify(
      'ClickToRunSvc',
      path: r'C:\Program Files\Common Files\microsoft shared\ClickToRun\x.exe',
      company: 'Microsoft Corporation',
    );
    expect(office.reason, ServiceReason.microsoftApp);
  });

  test('missing, unexpanded or kernel-style paths are treated as Windows', () {
    expect(_classify('Unknown').safety, ServiceSafety.keep);
    for (final path in <String>[
      r'%SystemRoot%\System32\svchost.exe -k netsvcs',
      r'\SystemRoot\System32\drivers\x.sys',
      r'system32\x.exe',
    ]) {
      expect(_classify('Unknown', path: path).safety, ServiceSafety.keep);
    }
  });

  test('the operation allowlist holds only changeable curated names', () {
    expect(changeableCuratedServices, contains('DiagTrack'));
    expect(changeableCuratedServices, contains('Spooler'));
    expect(changeableCuratedServices, isNot(contains('wuauserv')));
  });

  test('parses the service inventory', () {
    final services = parseServiceInventory(
      '{"Services":[{"Name":"Spooler","DisplayName":"Print Spooler","Description":"Queues print jobs",'
      '"StartMode":"Auto","Delayed":false,"Running":true,"Path":"C:\\\\WINDOWS\\\\System32\\\\spoolsv.exe","Company":"Microsoft Corporation","Dependents":2},'
      '{"Name":"x"},'
      '{"Name":"Foo","DisplayName":"Foo","Description":null,"StartMode":"Manual","Delayed":false,"Running":false,"Path":null,"Company":null},'
      '{"Name":"AvSvc","StartMode":"Auto","Path":"C:\\\\Program Files\\\\AV Co\\\\Engine\\\\svc.exe"}],'
      '"Security":["windowsdefender://","C:\\\\Program Files\\\\AV Co\\\\UI\\\\av.exe"]}',
    );
    expect(services.map((s) => s.name), ['Spooler', 'Foo', 'AvSvc']);
    expect(services.first.startType, 2);
    expect(services.first.running, isTrue);
    expect(services[1].startType, 3);
    expect(services[1].path, isNull);
    expect(services.first.dependents, 2);
    expect(services[1].dependents, 0);
    expect(services.map((s) => s.securityProduct), [false, false, true]);
  });

  test('services of Security Center products are kept', () {
    const products = <String>[
      'windowsdefender://',
      r'"C:\Program Files\Avast Software\Avast\wsc_proxy.exe"',
      r'C:\Program Files\Common Files\McAfee\Platform\McUICnt.exe',
      r'D:\SecureCo\bin\agent.exe',
      r'C:\Program Files\loose.exe',
      r'C:\edr.exe',
    ];
    for (final path in <String>[
      r'C:\Program Files\Avast Software\Avast\AvastSvc.exe',
      r'C:\PROGRAM FILES\AVAST SOFTWARE\Browser\update.exe',
      r'C:\Program Files\Common Files\McAfee\SystemCore\mfemms.exe',
      r'D:\SecureCo\bin\svc.exe',
    ]) {
      expect(isSecurityProductPath(path, products), isTrue, reason: path);
    }
    // Shared folders and drive roots never widen to everything inside.
    for (final path in <String>[
      r'C:\Program Files\Mullvad VPN\mullvad-daemon.exe',
      r'C:\Program Files\Common Files\Other\svc.exe',
      r'C:\Other\svc.exe',
      r'D:\SecureCo\other\svc.exe',
      '',
    ]) {
      expect(isSecurityProductPath(path, products), isFalse, reason: path);
    }
    expect(isSecurityProductPath(null, products), isFalse);

    final verdict = classifyService(
      name: 'AvastSvc',
      binaryPath: r'C:\Program Files\Avast Software\Avast\AvastSvc.exe',
      company: 'Gen Digital Inc.',
      systemRoot: r'C:\Windows',
      securityProduct: true,
    );
    expect(verdict.safety, ServiceSafety.keep);
    expect(verdict.reason, ServiceReason.security);
    // The curated list still wins.
    expect(
      classifyService(
        name: 'Spooler',
        binaryPath: null,
        company: null,
        systemRoot: r'C:\Windows',
        securityProduct: true,
      ).safety,
      ServiceSafety.dependsOnUse,
    );
  });
}
