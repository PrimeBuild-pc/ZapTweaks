/// Safety class for Windows services, from one curated list with reasons.
enum ServiceSafety { canDisable, dependsOnUse, keep }

/// What the service does, or what stops working without it.
enum ServiceReason {
  telemetry,
  deviceManagement,
  crashReports,
  remoteRegistry,
  offlineMaps,
  mediaSharing,
  retailDemo,
  xbox,
  printing,
  bluetooth,
  search,
  sysMain,
  touchKeyboard,
  location,
  biometrics,
  phone,
  remoteDesktop,
  smartCard,
  parental,
  nfc,
  hotspot,
  scanner,
  compatibility,
  fax,
  insider,
  updates,
  security,
  windowsCore,
  notReviewed,
  driverService,
  microsoftApp,
  thirdParty,
}

typedef ServiceVerdict = ({ServiceSafety safety, ServiceReason reason});

typedef _Curated = ({String name, ServiceSafety safety, ServiceReason reason});

const _can = ServiceSafety.canDisable;
const _use = ServiceSafety.dependsOnUse;
const _keep = ServiceSafety.keep;

/// Windows 11 services reviewed by hand. Anything else in the Windows folder
/// is kept; services of installed programs depend on use.
const List<_Curated> _curated = <_Curated>[
  (name: 'DiagTrack', safety: _can, reason: ServiceReason.telemetry),
  (
    name: 'dmwappushservice',
    safety: _can,
    reason: ServiceReason.deviceManagement,
  ),
  (name: 'WerSvc', safety: _can, reason: ServiceReason.crashReports),
  (name: 'RemoteRegistry', safety: _can, reason: ServiceReason.remoteRegistry),
  (name: 'MapsBroker', safety: _can, reason: ServiceReason.offlineMaps),
  (name: 'WMPNetworkSvc', safety: _can, reason: ServiceReason.mediaSharing),
  (name: 'RetailDemo', safety: _can, reason: ServiceReason.retailDemo),
  (name: 'XblAuthManager', safety: _use, reason: ServiceReason.xbox),
  (name: 'XblGameSave', safety: _use, reason: ServiceReason.xbox),
  (name: 'XboxNetApiSvc', safety: _use, reason: ServiceReason.xbox),
  (name: 'XboxGipSvc', safety: _use, reason: ServiceReason.xbox),
  (name: 'Spooler', safety: _use, reason: ServiceReason.printing),
  (name: 'bthserv', safety: _use, reason: ServiceReason.bluetooth),
  (name: 'WSearch', safety: _use, reason: ServiceReason.search),
  (name: 'SysMain', safety: _use, reason: ServiceReason.sysMain),
  (
    name: 'TabletInputService',
    safety: _use,
    reason: ServiceReason.touchKeyboard,
  ),
  (name: 'lfsvc', safety: _use, reason: ServiceReason.location),
  (name: 'WbioSrvc', safety: _use, reason: ServiceReason.biometrics),
  (name: 'PhoneSvc', safety: _use, reason: ServiceReason.phone),
  (name: 'TermService', safety: _use, reason: ServiceReason.remoteDesktop),
  (name: 'SCardSvr', safety: _use, reason: ServiceReason.smartCard),
  (name: 'WpcMonSvc', safety: _use, reason: ServiceReason.parental),
  (name: 'SEMgrSvc', safety: _use, reason: ServiceReason.nfc),
  (name: 'icssvc', safety: _use, reason: ServiceReason.hotspot),
  (name: 'stisvc', safety: _use, reason: ServiceReason.scanner),
  (name: 'PcaSvc', safety: _use, reason: ServiceReason.compatibility),
  (name: 'Fax', safety: _use, reason: ServiceReason.fax),
  (name: 'wisvc', safety: _use, reason: ServiceReason.insider),
  (name: 'wuauserv', safety: _keep, reason: ServiceReason.updates),
  (name: 'UsoSvc', safety: _keep, reason: ServiceReason.updates),
  (name: 'BITS', safety: _keep, reason: ServiceReason.updates),
  (name: 'WaaSMedicSvc', safety: _keep, reason: ServiceReason.updates),
  (name: 'TrustedInstaller', safety: _keep, reason: ServiceReason.updates),
  // Defender runs from ProgramData, outside the Windows folder.
  (name: 'WinDefend', safety: _keep, reason: ServiceReason.security),
  (name: 'WdNisSvc', safety: _keep, reason: ServiceReason.security),
  (name: 'Sense', safety: _keep, reason: ServiceReason.security),
  (name: 'MDCoreSvc', safety: _keep, reason: ServiceReason.security),
  (name: 'mpssvc', safety: _keep, reason: ServiceReason.security),
  (name: 'BFE', safety: _keep, reason: ServiceReason.security),
  (
    name: 'SecurityHealthService',
    safety: _keep,
    reason: ServiceReason.security,
  ),
  (name: 'wscsvc', safety: _keep, reason: ServiceReason.security),
  (name: 'Audiosrv', safety: _keep, reason: ServiceReason.windowsCore),
  (
    name: 'AudioEndpointBuilder',
    safety: _keep,
    reason: ServiceReason.windowsCore,
  ),
  (name: 'Dnscache', safety: _keep, reason: ServiceReason.windowsCore),
  (name: 'Dhcp', safety: _keep, reason: ServiceReason.windowsCore),
  (name: 'EventLog', safety: _keep, reason: ServiceReason.windowsCore),
  (name: 'Schedule', safety: _keep, reason: ServiceReason.windowsCore),
  (name: 'Winmgmt', safety: _keep, reason: ServiceReason.windowsCore),
  (name: 'CryptSvc', safety: _keep, reason: ServiceReason.windowsCore),
  (name: 'RpcSs', safety: _keep, reason: ServiceReason.windowsCore),
];

final Map<String, _Curated> _byName = <String, _Curated>{
  for (final entry in _curated) entry.name.toLowerCase(): entry,
};

/// Curated names ZapTweaks may change (the operation allowlist).
final Set<String> changeableCuratedServices = <String>{
  for (final entry in _curated)
    if (entry.safety != ServiceSafety.keep) entry.name,
};

ServiceVerdict classifyService({
  required String name,
  required String? binaryPath,
  required String? company,
  required String systemRoot,
  bool securityProduct = false,
}) {
  final curated = _byName[name.toLowerCase()];
  if (curated != null) return (safety: curated.safety, reason: curated.reason);
  if (securityProduct) {
    return (safety: ServiceSafety.keep, reason: ServiceReason.security);
  }
  final microsoft = (company ?? '').toLowerCase().contains('microsoft');
  // Callers expand %VAR% first; anything not an absolute X:\ path
  // (\SystemRoot\…, relative, unexpanded) counts as Windows.
  final path = binaryPath?.replaceAll('"', '').trim().toLowerCase() ?? '';
  if (!RegExp(r'^[a-z]:\\').hasMatch(path) ||
      path.startsWith('${systemRoot.toLowerCase()}\\')) {
    return (
      safety: ServiceSafety.keep,
      reason: microsoft || company == null
          ? ServiceReason.notReviewed
          : ServiceReason.driverService,
    );
  }
  return (
    safety: ServiceSafety.dependsOnUse,
    reason: microsoft ? ServiceReason.microsoftApp : ServiceReason.thirdParty,
  );
}

/// True when [servicePath] sits in the vendor folder of an executable that
/// Windows Security Center lists (antivirus, antispyware, firewall).
// shortcut: same vendor folder only (not ProgramData or the other Program
// Files), widen if a product's services live elsewhere.
bool isSecurityProductPath(String? servicePath, Iterable<String> productExes) {
  final path = servicePath?.replaceAll('"', '').trim().toLowerCase() ?? '';
  if (path.isEmpty) return false;
  return productExes
      .map(_vendorRoot)
      .any((root) => root != null && path.startsWith(root));
}

/// `x:\program files\<vendor>\` (one level deeper under Common Files),
/// else the executable's own folder; null for drive roots, shared folders
/// and non-file paths such as `windowsdefender://`.
String? _vendorRoot(String exe) {
  final parts = exe.replaceAll('"', '').trim().toLowerCase().split(r'\');
  if (parts.length < 3 || !RegExp(r'^[a-z]:$').hasMatch(parts.first)) {
    return null;
  }
  final dirs = parts.sublist(0, parts.length - 1);
  const shared = <String>{
    'program files',
    'program files (x86)',
    'programdata',
  };
  var depth = shared.contains(dirs[1]) ? 3 : dirs.length;
  if (depth == 3 && dirs.length > 2 && dirs[2] == 'common files') depth = 4;
  if (dirs.length < depth) return null;
  return '${dirs.take(depth).join(r'\')}\\';
}
