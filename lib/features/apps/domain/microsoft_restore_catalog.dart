class MicrosoftRestoreIdentity {
  const MicrosoftRestoreIdentity({
    required this.name,
    required this.packageId,
    required this.source,
  });

  final String name;
  final String packageId;
  final String source;
}

const Map<String, MicrosoftRestoreIdentity> microsoftRestoreCatalog =
    <String, MicrosoftRestoreIdentity>{
      'Microsoft.WindowsStore': MicrosoftRestoreIdentity(
        name: 'Microsoft Store',
        packageId: '9WZDNCRFJBMP',
        source: 'msstore',
      ),
      'Microsoft.StickyNotes': MicrosoftRestoreIdentity(
        name: 'Sticky Notes',
        packageId: '9NBLGGH4QGHW',
        source: 'msstore',
      ),
      'Microsoft.WindowsAlarms': MicrosoftRestoreIdentity(
        name: 'Clock',
        packageId: '9WZDNCRFJ3PR',
        source: 'msstore',
      ),
      'Microsoft.WindowsFeedbackHub': MicrosoftRestoreIdentity(
        name: 'Feedback Hub',
        packageId: '9NBLGGH4R32N',
        source: 'msstore',
      ),
      'Microsoft.Todos': MicrosoftRestoreIdentity(
        name: 'Microsoft To Do',
        packageId: '9NBLGGH5R558',
        source: 'msstore',
      ),
      'Microsoft.YourPhone': MicrosoftRestoreIdentity(
        name: 'Phone Link',
        packageId: '9NMPJ99VJBWV',
        source: 'msstore',
      ),
      'Microsoft.OneDrive': MicrosoftRestoreIdentity(
        name: 'OneDrive',
        packageId: 'Microsoft.OneDrive',
        source: 'winget',
      ),
      'Microsoft.GamingApp': MicrosoftRestoreIdentity(
        name: 'Xbox App',
        packageId: '9MV0B5HZVK9Z',
        source: 'msstore',
      ),
      'Microsoft.XboxGamingOverlay': MicrosoftRestoreIdentity(
        name: 'Xbox Game Bar',
        packageId: '9NZKPSTSNW4P',
        source: 'msstore',
      ),
      'Microsoft.XboxIdentityProvider': MicrosoftRestoreIdentity(
        name: 'Xbox Identity Provider',
        packageId: '9WZDNCRD1HKW',
        source: 'msstore',
      ),
      'Clipchamp.Clipchamp': MicrosoftRestoreIdentity(
        name: 'Clipchamp',
        packageId: '9P1J8S7CCWWT',
        source: 'msstore',
      ),
      'Microsoft.Family': MicrosoftRestoreIdentity(
        name: 'Microsoft Family',
        packageId: '9PDJDJS743XF',
        source: 'msstore',
      ),
      'Microsoft.QuickAssist': MicrosoftRestoreIdentity(
        name: 'Quick Assist',
        packageId: '9P7BP5VNWKX5',
        source: 'msstore',
      ),
      'Microsoft.PowerAutomateDesktop': MicrosoftRestoreIdentity(
        name: 'Power Automate',
        packageId: '9NFTCH6J7FHV',
        source: 'msstore',
      ),
      'Microsoft.DevHome': MicrosoftRestoreIdentity(
        name: 'Windows Advanced Settings',
        packageId: '9N8MHTPHNGVV',
        source: 'msstore',
      ),
      'Microsoft.MicrosoftOfficeHub': MicrosoftRestoreIdentity(
        name: 'Microsoft 365 Copilot',
        packageId: '9WZDNCRD29V9',
        source: 'msstore',
      ),
      'Microsoft.OutlookForWindows': MicrosoftRestoreIdentity(
        name: 'Outlook (new)',
        packageId: '9NRX63209R7B',
        source: 'msstore',
      ),
    };
