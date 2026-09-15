import 'dart:convert';

import '../../core/services/process_runner.dart';
import 'hardware_capability_validators.dart';
import 'processor_topology.dart';

class RssAdapterState {
  const RssAdapterState({
    required this.name,
    required this.configuration,
    required this.maximumQueues,
    required this.maximumProcessors,
  });

  final String name;
  final RssConfiguration configuration;
  final int maximumQueues;
  final int maximumProcessors;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'enabled': configuration.enabled,
    'profile': configuration.profile,
    'baseGroup': configuration.baseProcessor.group,
    'baseNumber': configuration.baseProcessor.number,
    'maxGroup': configuration.maximumProcessor.group,
    'maxNumber': configuration.maximumProcessor.number,
    'processorCount': configuration.processorCount,
    'queueCount': configuration.queueCount,
    'processorArray': configuration.processorArray
        .map(
          (processor) => <String, int>{
            'group': processor.group,
            'number': processor.number,
          },
        )
        .toList(growable: false),
    'maximumQueues': maximumQueues,
    'maximumProcessors': maximumProcessors,
  };

  factory RssAdapterState.fromJson(Map<String, dynamic> json) {
    int integer(String name) {
      final value = json[name];
      if (value is! num) throw FormatException('Invalid RSS $name.');
      return value.toInt();
    }

    final processors = (json['processorArray'] as List? ?? const <Object>[])
        .map((row) {
          final value = Map<String, dynamic>.from(row as Map);
          return ProcessorAddress(
            (value['group']! as num).toInt(),
            (value['number']! as num).toInt(),
          );
        })
        .toList(growable: false);
    return RssAdapterState(
      name: json['name']! as String,
      configuration: RssConfiguration(
        enabled: json['enabled']! as bool,
        profile: json['profile']! as String,
        baseProcessor: ProcessorAddress(
          integer('baseGroup'),
          integer('baseNumber'),
        ),
        maximumProcessor: ProcessorAddress(
          integer('maxGroup'),
          integer('maxNumber'),
        ),
        processorCount: integer('processorCount'),
        queueCount: integer('queueCount'),
        processorArray: processors,
      ),
      maximumQueues: integer('maximumQueues'),
      maximumProcessors: integer('maximumProcessors'),
    );
  }
}

abstract interface class RssStore {
  Future<RssAdapterState> inspect(String adapterName);
  Future<void> write(String adapterName, RssConfiguration configuration);
  RssCapabilities capabilities(RssAdapterState state);
}

class WindowsRssService implements RssStore {
  WindowsRssService({
    ProcessRunner? processRunner,
    ProcessorTopology Function()? topology,
  }) : _processRunner = processRunner ?? ProcessRunner.shared,
       _topology = topology ?? ProcessorTopology.inspect;

  final ProcessRunner _processRunner;
  final ProcessorTopology Function() _topology;

  static String _name(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed.length > 256 ||
        trimmed.runes.any((r) => r < 32)) {
      throw ArgumentError.value(value, 'adapterName', 'Invalid adapter name.');
    }
    return base64Encode(utf8.encode(trimmed));
  }

  @override
  Future<RssAdapterState> inspect(String adapterName) async {
    final name = _name(adapterName);
    final output = await _processRunner.runPowerShellForOutput('''
\$n=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$name'))
\$r=Get-NetAdapterRss -Name \$n -ErrorAction Stop
\$processors=@(\$r.RssProcessorArray | ForEach-Object { [ordered]@{group=[int]\$_.Group;number=[int]\$_.Number} })
[ordered]@{
 name=[string]\$r.Name;enabled=[bool]\$r.Enabled;profile=[string]\$r.Profile
 baseGroup=[int]\$r.BaseProcessorGroup;baseNumber=[int]\$r.BaseProcessorNumber
 maxGroup=[int]\$r.MaxProcessorGroup;maxNumber=[int]\$r.MaxProcessorNumber
 processorCount=[int]\$r.MaxProcessors;queueCount=[int]\$r.NumberOfReceiveQueues
 processorArray=\$processors;maximumQueues=[int]\$r.NumberOfReceiveQueues
 maximumProcessors=[int]\$r.MaxProcessors
} | ConvertTo-Json -Compress -Depth 4
''');
    return RssAdapterState.fromJson(
      Map<String, dynamic>.from(jsonDecode(output) as Map),
    );
  }

  @override
  RssCapabilities capabilities(RssAdapterState state) {
    final topology = _topology();
    return RssCapabilities(
      processors: topology.addresses,
      maximumQueues: state.maximumQueues,
      maximumProcessors: state.maximumProcessors,
    );
  }

  @override
  Future<void> write(String adapterName, RssConfiguration value) async {
    final name = _name(adapterName);
    const profiles = <String>{
      'Closest',
      'ClosestStatic',
      'NUMA',
      'NUMAStatic',
      'Conservative',
    };
    if (!profiles.contains(value.profile)) {
      throw StateError('Unsupported RSS profile.');
    }
    final error = HardwareCapabilityValidators.validateRss(
      value,
      capabilities(await inspect(adapterName)),
    );
    if (error != null) throw StateError(error);
    final enabled = value.enabled ? r'$true' : r'$false';
    await _processRunner.runPowerShellForOutput('''
\$n=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$name'))
Set-NetAdapterRss -Name \$n -Enabled $enabled -Profile ${value.profile} -BaseProcessorGroup ${value.baseProcessor.group} -BaseProcessorNumber ${value.baseProcessor.number} -MaxProcessorGroup ${value.maximumProcessor.group} -MaxProcessorNumber ${value.maximumProcessor.number} -MaxProcessors ${value.processorCount} -NumberOfReceiveQueues ${value.queueCount} -ErrorAction Stop
'OK'
''');
  }
}
