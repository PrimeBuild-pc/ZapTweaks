import 'microsoft_restore_catalog.dart';

enum AppxCandidateGroup {
  lowRisk,
  optional,
  legacyInventoryOnly;

  String get label => switch (this) {
    lowRisk => 'Low risk · optional app',
    optional => 'Medium risk · optional functionality',
    legacyInventoryOnly => 'Legacy · inventory only',
  };
}

class AppxCandidate {
  const AppxCandidate(
    this.name,
    this.group,
    this.consequence, {
    this.storeId,
    this.publisherId = '8wekyb3d8bbwe',
    this.publisher = microsoftAppxPublisher,
  });

  final String name;
  final AppxCandidateGroup group;
  final String consequence;
  final String? storeId;
  final String publisherId;
  final String publisher;

  bool get removable => group != AppxCandidateGroup.legacyInventoryOnly;
  MicrosoftRestoreIdentity? get restore => storeId == null
      ? null
      : MicrosoftRestoreIdentity(
          name: name,
          packageId: storeId!,
          source: 'msstore',
        );
}

const microsoftAppxPublisher =
    'CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US';
const microsoftWindowsAppxPublisher =
    'CN=Microsoft Windows, O=Microsoft Corporation, L=Redmond, S=Washington, C=US';

// This is an exact opt-in removal policy, not the legacy restore allowlist.
const appxCandidatePolicy = <String, AppxCandidate>{
  'Microsoft.WindowsFeedbackHub': AppxCandidate(
    'Feedback Hub',
    AppxCandidateGroup.lowRisk,
    'Feedback reporting',
    storeId: '9NBLGGH4R32N',
  ),
  'Microsoft.GetHelp': AppxCandidate(
    'Get Help',
    AppxCandidateGroup.lowRisk,
    'Windows support app',
    storeId: '9PKDZBMV1H3T',
  ),
  'Microsoft.Getstarted': AppxCandidate(
    'Tips',
    AppxCandidateGroup.lowRisk,
    'Windows tips; retired app, restore may be unavailable',
  ),
  'Microsoft.BingNews': AppxCandidate(
    'News',
    AppxCandidateGroup.lowRisk,
    'News feed',
    storeId: '9WZDNCRFHVFW',
  ),
  'Microsoft.BingWeather': AppxCandidate(
    'Weather',
    AppxCandidateGroup.lowRisk,
    'Weather forecasts',
    storeId: '9WZDNCRFJ3Q2',
  ),
  'Microsoft.MicrosoftSolitaireCollection': AppxCandidate(
    'Solitaire',
    AppxCandidateGroup.lowRisk,
    'Solitaire games',
    storeId: '9WZDNCRFHWD2',
  ),
  'Microsoft.ZuneVideo': AppxCandidate(
    'Movies & TV',
    AppxCandidateGroup.lowRisk,
    'Video playback and purchased media access',
    storeId: '9WZDNCRFJ3P2',
  ),
  'Clipchamp.Clipchamp': AppxCandidate(
    'Clipchamp',
    AppxCandidateGroup.optional,
    'Video editing',
    storeId: '9P1J8S7CCWWT',
    publisherId: 'yxz26nhyzhsrt',
    publisher: 'CN=66816457-FB4B-4A1F-BFA2-323D5F933E5E',
  ),
  'Microsoft.OutlookForWindows': AppxCandidate(
    'Outlook (new)',
    AppxCandidateGroup.optional,
    'Mail, calendar and local app settings',
    storeId: '9NRX63209R7B',
  ),
  'Microsoft.MicrosoftOfficeHub': AppxCandidate(
    'Microsoft 365',
    AppxCandidateGroup.optional,
    'Microsoft 365 entry points',
    storeId: '9WZDNCRD29V9',
  ),
  'MSTeams': AppxCandidate(
    'Microsoft Teams',
    AppxCandidateGroup.optional,
    'Teams chat and meetings',
    storeId: 'XP8BT8DW290MPQ',
  ),
  'Microsoft.Todos': AppxCandidate(
    'Microsoft To Do',
    AppxCandidateGroup.optional,
    'Tasks and unsynced local data',
    storeId: '9NBLGGH5R558',
  ),
  'Microsoft.MicrosoftStickyNotes': AppxCandidate(
    'Sticky Notes',
    AppxCandidateGroup.optional,
    'Notes and unsynced local data',
    storeId: '9NBLGGH4QGHW',
  ),
  'Microsoft.WindowsAlarms': AppxCandidate(
    'Clock',
    AppxCandidateGroup.optional,
    'Alarms, timers and focus sessions',
    storeId: '9WZDNCRFJ3PR',
  ),
  'Microsoft.WindowsSoundRecorder': AppxCandidate(
    'Sound Recorder',
    AppxCandidateGroup.optional,
    'Audio recording',
    storeId: '9WZDNCRFHWKN',
  ),
  'Microsoft.Paint': AppxCandidate(
    'Paint',
    AppxCandidateGroup.optional,
    'Image editing',
    storeId: '9PCFS5B6T72H',
  ),
  'Microsoft.WindowsNotepad': AppxCandidate(
    'Notepad',
    AppxCandidateGroup.optional,
    'Text editing and unsaved sessions',
    storeId: '9MSMLRH6LZF3',
  ),
  'Microsoft.ScreenSketch': AppxCandidate(
    'Snipping Tool',
    AppxCandidateGroup.optional,
    'Screenshots and screen recording',
    storeId: '9MZ95KL8MR0L',
  ),
  'Microsoft.YourPhone': AppxCandidate(
    'Phone Link',
    AppxCandidateGroup.optional,
    'Phone integration',
    storeId: '9NMPJ99VJBWV',
  ),
  'MicrosoftWindows.CrossDevice': AppxCandidate(
    'Cross Device Experience Host',
    AppxCandidateGroup.optional,
    'Cross-device and phone integration',
    storeId: '9NTXGKQ8P7N0',
    publisherId: 'cw5n1h2txyewy',
    publisher: microsoftWindowsAppxPublisher,
  ),
  'Microsoft.Windows.DevHome': AppxCandidate(
    'Dev Home',
    AppxCandidateGroup.optional,
    'Developer workspace; retired app, restore may be unavailable',
    storeId: '9N8MHTPHNGVV',
  ),
  'Microsoft.PowerAutomateDesktop': AppxCandidate(
    'Power Automate',
    AppxCandidateGroup.optional,
    'Desktop automation flows',
    storeId: '9NFTCH6J7FHV',
  ),
  'MicrosoftCorporationII.QuickAssist': AppxCandidate(
    'Quick Assist',
    AppxCandidateGroup.optional,
    'Remote assistance',
    storeId: '9P7BP5VNWKX5',
  ),
  'Microsoft.WindowsMaps': AppxCandidate(
    'Maps',
    AppxCandidateGroup.optional,
    'Offline maps; retired app, restore may be unavailable',
  ),
  'Microsoft.Office.OneNote': AppxCandidate(
    'OneNote for Windows',
    AppxCandidateGroup.optional,
    'Notebooks and unsynced local data; retired app',
  ),
  'Microsoft.GamingApp': AppxCandidate(
    'Xbox App',
    AppxCandidateGroup.optional,
    'Xbox and Game Pass access',
    storeId: '9MV0B5HZVK9Z',
  ),
  'Microsoft.XboxGamingOverlay': AppxCandidate(
    'Xbox Game Bar',
    AppxCandidateGroup.optional,
    'Game capture and overlay',
    storeId: '9NZKPSTSNW4P',
  ),
  'Microsoft.DevHome': AppxCandidate(
    'Legacy Dev Home identity',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only; not the Microsoft.Windows.DevHome package',
  ),
  'Microsoft.BingFinance': AppxCandidate(
    'Money (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.BingSports': AppxCandidate(
    'Sports (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.BingTravel': AppxCandidate(
    'Travel (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.People': AppxCandidate(
    'People (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.WindowsCommunicationsApps': AppxCandidate(
    'Mail and Calendar (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.SkypeApp': AppxCandidate(
    'Skype (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.3DBuilder': AppxCandidate(
    '3D Builder (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.Microsoft3DViewer': AppxCandidate(
    '3D Viewer (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
  'Microsoft.MixedReality.Portal': AppxCandidate(
    'Mixed Reality Portal (legacy)',
    AppxCandidateGroup.legacyInventoryOnly,
    'Inventory only',
  ),
};

/// Exact publisher and complete protection metadata are required for every target.
bool isRemovableAppxMetadata(Map<String, dynamic> row) {
  final candidate = appxCandidatePolicy[row['Name']];
  if (candidate == null || !candidate.removable) return false;
  final name = row['Name'] as String;
  final fullName = row['PackageFullName'];
  final version = row['Version'];
  return version is String &&
      RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$').hasMatch(version) &&
      row['Publisher'] == candidate.publisher &&
      row['PublisherId'] == candidate.publisherId &&
      row['PackageFamilyName'] == '${name}_${candidate.publisherId}' &&
      fullName is String &&
      RegExp(
        '^${RegExp.escape(name)}_${RegExp.escape(version)}_(x64|x86|arm64|neutral)_[A-Za-z0-9.~-]*_${candidate.publisherId}\$',
      ).hasMatch(fullName) &&
      row['IsFramework'] == false &&
      row['IsResourcePackage'] == false &&
      row['NonRemovable'] == false &&
      row['IsPartiallyStaged'] == false &&
      row['IsDevelopmentMode'] == false &&
      const <String>{'Store', 'System'}.contains(row['SignatureKind']) &&
      row['Status'] == 'Ok' &&
      hasCompleteAppxDependencies(row);
}

bool hasCompleteAppxDependencies(Map<String, dynamic> row) =>
    row['Name'] is String &&
    (row['Name'] as String).isNotEmpty &&
    row['PackageFullName'] is String &&
    (row['PackageFullName'] as String).isNotEmpty &&
    row['DependenciesComplete'] == true &&
    row['Dependencies'] is List &&
    (row['Dependencies'] as List).every(
      (dependency) =>
          dependency is Map &&
          dependency['Name'] is String &&
          (dependency['Name'] as String).isNotEmpty &&
          dependency['PackageFullName'] is String &&
          (dependency['PackageFullName'] as String).isNotEmpty &&
          dependency['PublisherId'] is String &&
          (dependency['PublisherId'] as String).isNotEmpty,
    );

/// Fails closed if *any* inverse-dependency metadata in the affected scope is missing.
List<Map<String, dynamic>> validateAppxRemovalInventory(
  Map<String, dynamic> inventory,
  String target,
  String scope,
) {
  if (!const <String>{
    'currentUser',
    'allUsers',
    'provisioned',
    'allUsersAndProvisioned',
  }.contains(scope)) {
    throw StateError('Invalid AppX scope.');
  }
  if (appxCandidatePolicy[target]?.removable != true) {
    throw StateError('AppX identity is protected or inventory-only.');
  }
  final system = scope != 'currentUser';
  final provisioned =
      scope == 'provisioned' || scope == 'allUsersAndProvisioned';
  if (inventory['InstalledComplete'] != true ||
      (system && inventory['AllUsersComplete'] != true) ||
      (provisioned && inventory['ProvisionedComplete'] != true) ||
      inventory['Installed'] is! List ||
      (provisioned && inventory['Provisioned'] is! List)) {
    throw StateError('Incomplete AppX scope inventory.');
  }
  final installed = (inventory['Installed'] as List)
      .map((row) => Map<String, dynamic>.from(row as Map))
      .toList();
  if (installed.any((row) => !hasCompleteAppxDependencies(row))) {
    throw StateError('Incomplete AppX inverse-dependency inventory.');
  }
  final targets = installed
      .where((row) => row['Name'] == target && row['IsResourcePackage'] != true)
      .toList();
  if (targets.any((row) => !isRemovableAppxMetadata(row))) {
    throw StateError(
      'AppX publisher, identity or protection metadata mismatch.',
    );
  }
  final provisions = provisioned
      ? (inventory['Provisioned'] as List)
            .map((row) => Map<String, dynamic>.from(row as Map))
            .toList()
      : <Map<String, dynamic>>[];
  // DISM omits publisher/dependencies: require exact installed metadata, never infer from a name.
  for (final row in provisions) {
    final matches = installed.where(
      (app) =>
          app['Name'] == row['DisplayName'] &&
          app['PackageFullName'] == row['PackageName'],
    );
    if (matches.isEmpty ||
        matches.any((app) => !hasCompleteAppxDependencies(app))) {
      throw StateError('Provisioned package metadata is unavailable.');
    }
    if (row['DisplayName'] == target &&
        matches.any((app) => !isRemovableAppxMetadata(app))) {
      throw StateError('Provisioned AppX metadata mismatch.');
    }
  }
  for (final row in installed.where((row) => row['Name'] != target)) {
    if ((row['Dependencies'] as List).any(
      (dependency) =>
          dependency['Name'] == target ||
          targets.any(
            (app) => dependency['PackageFullName'] == app['PackageFullName'],
          ),
    )) {
      throw StateError('AppX is required by ${row['Name']}.');
    }
  }
  return <Map<String, dynamic>>[
    if (scope != 'provisioned') ...targets,
    ...provisions.where((row) => row['DisplayName'] == target),
  ];
}

/// Structured Windows inventory, shared by the UI and fresh operation preflight.
String appxInventoryScript({
  required bool allUsers,
  required bool provisioned,
}) =>
    '''
\$ErrorActionPreference = 'Stop'
function Read-AppxMetadata(\$p) {
  \$complete = \$null -ne \$p.PSObject.Properties['Dependencies'] -and \$null -ne \$p.Dependencies
  [pscustomobject]@{
    Name = \$p.Name; DisplayName = \$p.Name; Version = [string]\$p.Version
    Publisher = \$p.Publisher; PublisherId = \$p.PublisherId
    PackageFullName = \$p.PackageFullName; PackageFamilyName = \$p.PackageFamilyName
    IsFramework = \$p.IsFramework; IsResourcePackage = \$p.IsResourcePackage
    NonRemovable = \$p.NonRemovable; IsPartiallyStaged = \$p.IsPartiallyStaged
    IsDevelopmentMode = \$p.IsDevelopmentMode; SignatureKind = [string]\$p.SignatureKind
    Status = [string]\$p.Status; DependenciesComplete = \$complete
    Dependencies = @(\$p.Dependencies | Sort-Object PackageFullName | ForEach-Object {
      [pscustomobject]@{ Name = \$_.Name; PackageFullName = \$_.PackageFullName; PublisherId = \$_.PublisherId }
    })
    CurrentUser = \$${!allUsers}; AllUsers = \$$allUsers; Provisioned = \$false
  }
}
\$installed = @(Get-AppxPackage ${allUsers ? '-AllUsers' : ''} -PackageTypeFilter All -ErrorAction Stop | Sort-Object PackageFullName | ForEach-Object { Read-AppxMetadata \$_ })
\$provisioned = @(${provisioned ? "Get-AppxProvisionedPackage -Online -ErrorAction Stop | Sort-Object PackageName | ForEach-Object { [pscustomobject]@{ DisplayName = \$_.DisplayName; PackageName = \$_.PackageName; Version = [string]\$_.Version } }" : ''})
ConvertTo-Json -Compress -Depth 8 -InputObject ([pscustomobject]@{
  InstalledComplete = \$true; AllUsersComplete = \$$allUsers; ProvisionedComplete = \$$provisioned
  Installed = \$installed; Provisioned = \$provisioned
})
''';
