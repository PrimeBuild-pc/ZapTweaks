import 'dart:convert';

import '../../core/services/process_runner.dart';

class TcpSettingState {
  const TcpSettingState({
    required this.target,
    required this.template,
    required this.field,
    required this.value,
    required this.supportedValues,
    required this.writable,
  });

  final String target;
  final String template;
  final String field;
  final String value;
  final List<String> supportedValues;
  final bool writable;

  factory TcpSettingState.fromJson(Map<String, dynamic> json) =>
      TcpSettingState(
        target: json['target']! as String,
        template: json['template']! as String,
        field: json['field']! as String,
        value: json['value']! as String,
        supportedValues: (json['supportedValues']! as List).cast<String>(),
        writable: json['writable']! as bool,
      );
}

abstract interface class TcpOptimizerStore {
  Future<List<TcpSettingState>> inventory();
  Future<TcpSettingState> inspect(String target);
  Future<void> write(String target, String value);
}

class WindowsTcpOptimizerService implements TcpOptimizerStore {
  WindowsTcpOptimizerService({ProcessRunner? processRunner})
    : _processRunner = processRunner ?? ProcessRunner.shared;

  final ProcessRunner _processRunner;

  static final RegExp _templatePattern = RegExp(r'^[A-Za-z][A-Za-z0-9]{0,63}$');
  static const Map<String, String> _tcpProperties = <String, String>{
    'autotuning': 'AutoTuningLevelLocal',
    'heuristics': 'ScalingHeuristics',
    'ecn': 'EcnCapability',
    'congestion': 'CongestionProvider',
  };
  static const Map<String, String> _globalProperties = <String, String>{
    'rsc': 'ReceiveSegmentCoalescing',
    'rss': 'ReceiveSideScaling',
  };

  @override
  Future<List<TcpSettingState>> inventory() async {
    final output = await _processRunner.runPowerShellForOutput(r'''
$tcpCommand=Get-Command Set-NetTCPSetting -ErrorAction Stop
$offloadCommand=Get-Command Set-NetOffloadGlobalSetting -ErrorAction Stop
function EnumNames($command,$parameter) {
  $type=$command.Parameters[$parameter].ParameterType
  if(-not $type.IsEnum) { return @() }
  return @($type.GetEnumNames() | ForEach-Object { [string]$_ })
}
$fields=@(
  @{key='autotuning';property='AutoTuningLevelLocal'},
  @{key='heuristics';property='ScalingHeuristics'},
  @{key='ecn';property='EcnCapability'},
  @{key='congestion';property='CongestionProvider'}
)
$rows=@()
foreach($setting in @(Get-NetTCPSetting -ErrorAction Stop)) {
  $name=[string]$setting.SettingName
  if([string]::IsNullOrWhiteSpace($name) -or $name -eq 'Automatic') { continue }
  foreach($field in $fields) {
    $values=@(EnumNames $tcpCommand $field.property)
    $value=[string]$setting.($field.property)
    if($values.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($value)) {
      $rows += [ordered]@{
        target="template:${name}:$($field.key)";template=$name;field=$field.key
        value=$value;supportedValues=$values;writable=$name.EndsWith('Custom',[StringComparison]::Ordinal)
      }
    }
  }
}
$global=Get-NetOffloadGlobalSetting -ErrorAction Stop
foreach($field in @(
  @{key='rsc';property='ReceiveSegmentCoalescing'},
  @{key='rss';property='ReceiveSideScaling'}
)) {
  $values=@(EnumNames $offloadCommand $field.property)
  $value=[string]$global.($field.property)
  if($values.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($value)) {
    $rows += [ordered]@{
      target="global:$($field.key)";template='Global';field=$field.key
      value=$value;supportedValues=$values;writable=$true
    }
  }
}
[ordered]@{settings=$rows} | ConvertTo-Json -Compress -Depth 5
''');
    final root = Map<String, dynamic>.from(jsonDecode(output) as Map);
    return (root['settings'] as List? ?? const <Object>[])
        .map(
          (row) =>
              TcpSettingState.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<TcpSettingState> inspect(String target) async {
    _parseTarget(target);
    final matches = (await inventory()).where((item) => item.target == target);
    if (matches.length != 1) {
      throw StateError('TCP setting is not exposed by this Windows build.');
    }
    return matches.single;
  }

  @override
  Future<void> write(String target, String value) async {
    final parts = _parseTarget(target);
    final current = await inspect(target);
    if (!current.writable || !current.supportedValues.contains(value)) {
      throw StateError('Unsupported TCP setting value.');
    }
    final encodedValue = base64Encode(utf8.encode(value));
    if (parts.first == 'global') {
      final property = _globalProperties[parts[1]]!;
      final parameter = switch (property) {
        'ReceiveSegmentCoalescing' => '-ReceiveSegmentCoalescing',
        'ReceiveSideScaling' => '-ReceiveSideScaling',
        _ => throw StateError('Unsupported global TCP setting.'),
      };
      await _processRunner.runPowerShellForOutput('''
\$v=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedValue'))
Set-NetOffloadGlobalSetting $parameter \$v -ErrorAction Stop
'OK'
''');
      return;
    }

    final template = parts[1];
    final property = _tcpProperties[parts[2]]!;
    final parameter = switch (property) {
      'AutoTuningLevelLocal' => '-AutoTuningLevelLocal',
      'ScalingHeuristics' => '-ScalingHeuristics',
      'EcnCapability' => '-EcnCapability',
      'CongestionProvider' => '-CongestionProvider',
      _ => throw StateError('Unsupported TCP template setting.'),
    };
    final encodedTemplate = base64Encode(utf8.encode(template));
    await _processRunner.runPowerShellForOutput('''
\$n=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedTemplate'))
\$v=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedValue'))
Set-NetTCPSetting -SettingName \$n $parameter \$v -ErrorAction Stop
'OK'
''');
  }

  static List<String> _parseTarget(String target) {
    final parts = target.split(':');
    if (parts.length == 2 &&
        parts.first == 'global' &&
        _globalProperties.containsKey(parts[1])) {
      return parts;
    }
    if (parts.length == 3 &&
        parts.first == 'template' &&
        _templatePattern.hasMatch(parts[1]) &&
        _tcpProperties.containsKey(parts[2])) {
      return parts;
    }
    throw FormatException('Invalid TCP setting target.');
  }
}

class QosPolicy {
  const QosPolicy({
    required this.name,
    required this.appPath,
    required this.protocol,
    this.sourcePort,
    this.destinationPort,
    this.dscp,
    this.throttleBitsPerSecond,
    this.editable = true,
  });

  static const String ownedPrefix = 'ZapTweaks - ';

  final String name;
  final String appPath;
  final String protocol;
  final int? sourcePort;
  final int? destinationPort;
  final int? dscp;
  final int? throttleBitsPerSecond;
  final bool editable;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'appPath': appPath,
    'protocol': protocol,
    'sourcePort': sourcePort,
    'destinationPort': destinationPort,
    'dscp': dscp,
    'throttleBitsPerSecond': throttleBitsPerSecond,
  };

  factory QosPolicy.fromJson(Map<String, dynamic> json) => QosPolicy(
    name: json['name']! as String,
    appPath: json['appPath']! as String,
    protocol: json['protocol']! as String,
    sourcePort: (json['sourcePort'] as num?)?.toInt(),
    destinationPort: (json['destinationPort'] as num?)?.toInt(),
    dscp: (json['dscp'] as num?)?.toInt(),
    throttleBitsPerSecond: (json['throttleBitsPerSecond'] as num?)?.toInt(),
    editable: json['editable'] as bool? ?? true,
  );

  static QosPolicy validate(Map<String, dynamic> json) {
    const keys = <String>{
      'name',
      'appPath',
      'protocol',
      'sourcePort',
      'destinationPort',
      'dscp',
      'throttleBitsPerSecond',
    };
    if (json.keys.any((key) => !keys.contains(key)) ||
        !keys.every(json.containsKey)) {
      throw const FormatException('Invalid QoS policy fields.');
    }
    final policy = QosPolicy.fromJson(json);
    if (!RegExp(
      r'^ZapTweaks - [A-Za-z0-9][A-Za-z0-9 ._()\-]{0,51}$',
    ).hasMatch(policy.name)) {
      throw const FormatException(
        'QoS names must start with "ZapTweaks - " and contain safe characters.',
      );
    }
    if (policy.appPath.length > 1024 ||
        !RegExp(
          r'^[A-Za-z]:\\[^<>:"|?*\r\n]+\.exe$',
          caseSensitive: false,
        ).hasMatch(policy.appPath)) {
      throw const FormatException(
        'A full Windows executable path is required.',
      );
    }
    if (!const <String>{'TCP', 'UDP', 'Both'}.contains(policy.protocol)) {
      throw const FormatException('Invalid QoS protocol.');
    }
    for (final port in <int?>[policy.sourcePort, policy.destinationPort]) {
      if (port != null && (port < 1 || port > 65535)) {
        throw const FormatException('QoS ports must be between 1 and 65535.');
      }
    }
    if (policy.dscp != null && (policy.dscp! < 0 || policy.dscp! > 63)) {
      throw const FormatException('DSCP must be between 0 and 63.');
    }
    if (policy.throttleBitsPerSecond != null &&
        (policy.throttleBitsPerSecond! < 1 ||
            policy.throttleBitsPerSecond! > 1000000000000)) {
      throw const FormatException(
        'Throttle must be between 1 and 1,000,000,000,000 bit/s.',
      );
    }
    if (policy.dscp == null && policy.throttleBitsPerSecond == null) {
      throw const FormatException('QoS requires DSCP or a throttle rate.');
    }
    return policy;
  }
}

abstract interface class QosPolicyStore {
  Future<List<QosPolicy>> inventory();
  Future<QosPolicy?> inspect(String name);
  Future<void> write(String name, QosPolicy? policy);
}

class WindowsQosPolicyService implements QosPolicyStore {
  WindowsQosPolicyService({ProcessRunner? processRunner})
    : _processRunner = processRunner ?? ProcessRunner.shared;

  final ProcessRunner _processRunner;

  @override
  Future<List<QosPolicy>> inventory() async {
    final output = await _processRunner.runPowerShellForOutput(r'''
$rows=@()
foreach($policy in @(Get-NetQosPolicy -PolicyStore localhost -ErrorAction Stop)) {
  function NumberOrNull($value,$minimum) {
    if($null -eq $value) { return $null }
    $number=[long]$value
    if($number -lt $minimum -or $number -eq [long]::MaxValue) { return $null }
    return $number
  }
  $name=[string]$policy.Name
  $rows += [ordered]@{
    name=$name;appPath=[string]$policy.AppPathName;protocol=[string]$policy.IPProtocol
    sourcePort=NumberOrNull $policy.IPSrcPortStart 1
    destinationPort=NumberOrNull $policy.IPDstPortStart 1
    dscp=NumberOrNull $policy.DSCPValue 0
    throttleBitsPerSecond=NumberOrNull $policy.ThrottleRate 1
    editable=$name.StartsWith('ZapTweaks - ',[StringComparison]::Ordinal)
  }
}
[ordered]@{policies=$rows} | ConvertTo-Json -Compress -Depth 4
''');
    final root = Map<String, dynamic>.from(jsonDecode(output) as Map);
    return (root['policies'] as List? ?? const <Object>[])
        .map((row) => QosPolicy.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  @override
  Future<QosPolicy?> inspect(String name) async {
    _validateName(name);
    final matches = (await inventory()).where((policy) => policy.name == name);
    if (matches.length > 1) throw StateError('Duplicate QoS policy name.');
    return matches.isEmpty ? null : matches.single;
  }

  @override
  Future<void> write(String name, QosPolicy? policy) async {
    _validateName(name);
    final desired = policy == null
        ? null
        : QosPolicy.validate(Map<String, dynamic>.from(policy.toJson()));
    if (desired != null && (desired.name != name || !desired.editable)) {
      throw const FormatException('QoS policy target mismatch.');
    }
    final current = await inspect(name);
    if (current != null && !current.editable) {
      throw StateError('Only ZapTweaks-owned QoS policies can be changed.');
    }
    if (current?.toJson().toString() == desired?.toJson().toString()) return;
    final payload = base64Encode(
      utf8.encode(
        jsonEncode(<String, Object?>{
          'name': name,
          'policy': desired?.toJson(),
        }),
      ),
    );
    try {
      await _processRunner.runPowerShellForOutput('''
\$d=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$payload')) | ConvertFrom-Json
\$existing=@(Get-NetQosPolicy -PolicyStore localhost -ErrorAction Stop | Where-Object { \$_.Name -ceq \$d.name })
if(\$existing.Count -gt 1) { throw 'Duplicate QoS policy name.' }
if(\$existing.Count -eq 1) {
  Remove-NetQosPolicy -Name \$d.name -PolicyStore localhost -Confirm:\$false -ErrorAction Stop
}
if(\$null -ne \$d.policy) {
  \$p=@{Name=[string]\$d.policy.name;AppPathNameMatchCondition=[string]\$d.policy.appPath;IPProtocolMatchCondition=[string]\$d.policy.protocol;PolicyStore='localhost';ErrorAction='Stop'}
  if(\$null -ne \$d.policy.sourcePort) { \$p.IPSrcPortMatchCondition=[uint16]\$d.policy.sourcePort }
  if(\$null -ne \$d.policy.destinationPort) { \$p.IPDstPortMatchCondition=[uint16]\$d.policy.destinationPort }
  if(\$null -ne \$d.policy.dscp) { \$p.DSCPAction=[byte]\$d.policy.dscp }
  if(\$null -ne \$d.policy.throttleBitsPerSecond) { \$p.ThrottleRateActionBitsPerSecond=[uint64]\$d.policy.throttleBitsPerSecond }
  New-NetQosPolicy @p | Out-Null
}
'OK'
''');
    } catch (_) {
      if (current != null && await inspect(name) == null) {
        await write(name, current);
      }
      rethrow;
    }
  }

  static void _validateName(String name) {
    if (!RegExp(
      r'^ZapTweaks - [A-Za-z0-9][A-Za-z0-9 ._()\-]{0,51}$',
    ).hasMatch(name)) {
      throw const FormatException('Invalid ZapTweaks QoS policy name.');
    }
  }
}
