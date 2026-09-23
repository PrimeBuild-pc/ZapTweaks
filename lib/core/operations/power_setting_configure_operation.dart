import '../../platform/windows/power_scheme_service.dart';
import 'operation.dart';

class PowerSettingConfigureOperation implements OperationDefinition {
  PowerSettingConfigureOperation(this.schemes);

  final PowerSchemeAdministration schemes;
  final Map<String, PowerSettingInfo> _cache = <String, PowerSettingInfo>{};

  ({String subgroupId, String settingId, PowerSettingInfo info}) _setting(
    OperationRequest request,
  ) {
    final schemeId = request.target;
    final subgroupId = request.parameters['subgroupId'];
    final settingId = request.parameters['settingId'];
    if (schemeId == null ||
        !_guid.hasMatch(_canonical(schemeId)) ||
        request.parameters.length != 2 ||
        subgroupId is! String ||
        settingId is! String ||
        !_guid.hasMatch(_canonical(subgroupId)) ||
        !_guid.hasMatch(_canonical(settingId))) {
      throw const FormatException(
        'Canonical scheme, subgroup, and setting GUIDs are required.',
      );
    }
    final normalizedSubgroup = _canonical(subgroupId);
    final normalizedSetting = _canonical(settingId);
    final key = '$schemeId/$normalizedSubgroup/$normalizedSetting';
    final info = _cache.putIfAbsent(
      key,
      () => schemes.enumerateSettings(schemeId).singleWhere(
        (item) =>
            _canonical(item.subgroupId) == normalizedSubgroup &&
            _canonical(item.settingId) == normalizedSetting,
        orElse: () => throw const FormatException(
          'The power setting is not present in this scheme.',
        ),
      ),
    );
    if (info.minimum == null || info.maximum == null) {
      throw const FormatException(
        'Windows did not expose safe bounds for this setting.',
      );
    }
    return (
      subgroupId: normalizedSubgroup,
      settingId: normalizedSetting,
      info: info,
    );
  }

  PowerSettingValue _desired(OperationRequest request, PowerSettingInfo info) {
    final value = request.desiredValue;
    if (value is! Map || value['ac'] is! int || value['dc'] is! int) {
      throw const FormatException('AC and DC integer values are required.');
    }
    final desired = PowerSettingValue(
      ac: value['ac']! as int,
      dc: value['dc']! as int,
    );
    for (final candidate in <int>[desired.ac, desired.dc]) {
      if (candidate < info.minimum! || candidate > info.maximum!) {
        throw FormatException(
          'Value must be between ${info.minimum} and ${info.maximum}.',
        );
      }
      if (info.possibleValues.isNotEmpty &&
          !info.possibleValues.containsKey(candidate)) {
        throw const FormatException(
          'Value is not exposed by Windows for this setting.',
        );
      }
      final increment = info.increment;
      if (increment != null &&
          increment > 0 &&
          (candidate - info.minimum!) % increment != 0) {
        throw FormatException('Value must use increments of $increment.');
      }
    }
    return desired;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      final setting = _setting(request);
      _desired(request, setting.info);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final setting = _setting(request);
      final value = schemes.readSetting(
        request.target!,
        setting.subgroupId,
        setting.settingId,
      );
      return OperationState(
        OperationStateKind.configured,
        value: <String, int>{'ac': value.ac, 'dc': value.dc},
      );
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final setting = _setting(request);
    final value = schemes.readSetting(
      request.target!,
      setting.subgroupId,
      setting.settingId,
    );
    return OperationSnapshot(
      type: 'powerSettingConfigure',
      data: <String, Object?>{
        'schemeId': request.target!,
        'subgroupId': setting.subgroupId,
        'settingId': setting.settingId,
        'activeSchemeId': schemes.activeSchemeId,
        'ac': value.ac,
        'dc': value.dc,
      },
      expectedAfterRollback: OperationState(
        OperationStateKind.configured,
        value: <String, int>{'ac': value.ac, 'dc': value.dc},
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final setting = _setting(request);
    schemes.writeSetting(
      request.target!,
      setting.subgroupId,
      setting.settingId,
      _desired(request, setting.info),
    );
    if (schemes.activeSchemeId == request.target) {
      schemes.setActiveScheme(request.target!);
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'powerSettingConfigure' ||
        snapshot.data['schemeId'] != request.target ||
        snapshot.data['subgroupId'] !=
            _canonical(request.parameters['subgroupId']! as String) ||
        snapshot.data['settingId'] !=
            _canonical(request.parameters['settingId']! as String) ||
        snapshot.data['ac'] is! int ||
        snapshot.data['dc'] is! int ||
        snapshot.data['activeSchemeId'] is! String) {
      throw StateError('Invalid power setting snapshot.');
    }
    schemes.writeSetting(
      request.target!,
      snapshot.data['subgroupId']! as String,
      snapshot.data['settingId']! as String,
      PowerSettingValue(
        ac: snapshot.data['ac']! as int,
        dc: snapshot.data['dc']! as int,
      ),
    );
    schemes.setActiveScheme(snapshot.data['activeSchemeId']! as String);
  }

  static String _canonical(String value) =>
      value.trim().toLowerCase().replaceAll('{', '').replaceAll('}', '');

  static final RegExp _guid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  @override
  String get id => 'power.setting.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'powerSettingConfigure';
  @override
  String get descriptionKey => 'powerSettingConfigureDescription';
  @override
  String get domain => 'power';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.unverified;
  @override
  String? get evidenceBinaryVersion => null;
  @override
  String? get evidenceSha256 => null;
  @override
  List<String> get supportedEditions => const <String>['Home', 'Pro'];
  @override
  List<String> get supportedArchitectures => const <String>['x64'];
  @override
  List<String> get technicalSources => const <String>[
    'https://learn.microsoft.com/windows/win32/power/power-management-functions',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
