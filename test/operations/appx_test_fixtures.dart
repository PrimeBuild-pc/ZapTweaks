import 'package:script_utility/features/apps/domain/appx_candidate_policy.dart';

const feedbackHub = 'Microsoft.WindowsFeedbackHub';

Map<String, dynamic> appxMetadata({String name = feedbackHub}) {
  final candidate = appxCandidatePolicy[name];
  final publisherId = candidate?.publisherId ?? '8wekyb3d8bbwe';
  return <String, dynamic>{
    'Name': name,
    'DisplayName': name,
    'Version': '1.0.0.0',
    'Publisher': candidate?.publisher ?? microsoftAppxPublisher,
    'PublisherId': publisherId,
    'PackageFullName': '${name}_1.0.0.0_x64__$publisherId',
    'PackageFamilyName': '${name}_$publisherId',
    'IsFramework': false,
    'IsResourcePackage': false,
    'NonRemovable': false,
    'IsPartiallyStaged': false,
    'IsDevelopmentMode': false,
    'SignatureKind': 'Store',
    'Status': 'Ok',
    'DependenciesComplete': true,
    'Dependencies': <Map<String, dynamic>>[],
    'CurrentUser': true,
    'AllUsers': false,
    'Provisioned': false,
  };
}

Map<String, dynamic> appxInventory({
  List<Map<String, dynamic>>? installed,
  bool system = false,
  List<Map<String, dynamic>> provisioned = const [],
}) => <String, dynamic>{
  'InstalledComplete': true,
  'AllUsersComplete': system,
  'ProvisionedComplete': system,
  'Installed': installed ?? <Map<String, dynamic>>[appxMetadata()],
  'Provisioned': provisioned,
};

Map<String, dynamic> appxProvision(Map<String, dynamic> app) =>
    <String, dynamic>{
      'DisplayName': app['Name'],
      'PackageName': app['PackageFullName'],
      'Version': app['Version'],
    };
