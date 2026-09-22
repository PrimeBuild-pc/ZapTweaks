import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import '../../core/services/process_runner.dart';

class EtwDpcReport {
  const EtwDpcReport({
    required this.analysisAvailable,
    required this.totalEvents,
    required this.dpcEvents,
    required this.isrEvents,
    required this.hardFaultEvents,
    required this.contextSwitchEvents,
    required this.topProviders,
    this.message,
  });

  final bool analysisAvailable;
  final int totalEvents;
  final int dpcEvents;
  final int isrEvents;
  final int hardFaultEvents;
  final int contextSwitchEvents;
  final Map<String, int> topProviders;
  final String? message;

  Map<String, Object?> toJson() => <String, Object?>{
    'analysisAvailable': analysisAvailable,
    'totalEvents': totalEvents,
    'dpcEvents': dpcEvents,
    'isrEvents': isrEvents,
    'hardFaultEvents': hardFaultEvents,
    'contextSwitchEvents': contextSwitchEvents,
    'topProviders': topProviders,
    if (message != null) 'message': message,
    'interpretation':
        'Event counts identify trace activity only; they do not prove latency or identify a faulty driver.',
  };
}

class EtwDpcAnalyzer {
  EtwDpcAnalyzer({required this.processRunner});

  static const int _maxXmlBytes = 256 * 1024 * 1024;
  final ProcessRunner processRunner;

  Future<File> analyze(File trace) async {
    if (!await trace.exists() || await trace.length() == 0) {
      throw StateError('ETW trace is missing or empty.');
    }
    final xml = File('${trace.path}.events.xml');
    final report = File('${trace.path}.report.json');
    EtwDpcReport result;
    try {
      final conversion = await processRunner.run('tracerpt.exe', <String>[
        trace.path,
        '-of',
        'XML',
        '-o',
        xml.path,
        '-y',
      ]);
      if (!conversion.success ||
          !await xml.exists() ||
          await xml.length() == 0) {
        result = EtwDpcReport(
          analysisAvailable: false,
          totalEvents: 0,
          dpcEvents: 0,
          isrEvents: 0,
          hardFaultEvents: 0,
          contextSwitchEvents: 0,
          topProviders: const <String, int>{},
          message: conversion.details.isEmpty
              ? 'Windows tracerpt did not produce event XML.'
              : conversion.details,
        );
      } else if (await xml.length() > _maxXmlBytes) {
        result = const EtwDpcReport(
          analysisAvailable: false,
          totalEvents: 0,
          dpcEvents: 0,
          isrEvents: 0,
          hardFaultEvents: 0,
          contextSwitchEvents: 0,
          topProviders: <String, int>{},
          message: 'Converted trace exceeds the 256 MiB analysis limit.',
        );
      } else {
        result = parseXml(await xml.readAsString());
      }
    } catch (error) {
      result = EtwDpcReport(
        analysisAvailable: false,
        totalEvents: 0,
        dpcEvents: 0,
        isrEvents: 0,
        hardFaultEvents: 0,
        contextSwitchEvents: 0,
        topProviders: const <String, int>{},
        message: error.toString(),
      );
    } finally {
      if (await xml.exists()) await xml.delete();
    }
    await report.writeAsString(
      jsonEncode(<String, Object?>{
        'tracePath': trace.path,
        'traceBytes': await trace.length(),
        ...result.toJson(),
      }),
    );
    return report;
  }

  static EtwDpcReport parseXml(String source) {
    final events = XmlDocument.parse(source).descendants
        .whereType<XmlElement>()
        .where((element) => element.name.local.toLowerCase() == 'event');
    var total = 0;
    var dpc = 0;
    var isr = 0;
    var hardFault = 0;
    var contextSwitch = 0;
    final providers = <String, int>{};
    for (final event in events) {
      total++;
      final text = event.toXmlString().toLowerCase();
      if (RegExp(r'\bdpc\b').hasMatch(text)) dpc++;
      if (RegExp(r'\bisr\b|interrupt service routine').hasMatch(text)) isr++;
      if (text.contains('hardfault') || text.contains('hard fault')) {
        hardFault++;
      }
      if (text.contains('cswitch') || text.contains('context switch')) {
        contextSwitch++;
      }
      final provider = event.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local.toLowerCase() == 'provider')
          .firstOrNull;
      final name =
          provider?.getAttribute('Name') ??
          provider?.getAttribute('name') ??
          provider?.getAttribute('Guid') ??
          provider?.getAttribute('guid') ??
          'unknown';
      providers.update(name, (count) => count + 1, ifAbsent: () => 1);
    }
    final sorted = providers.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    return EtwDpcReport(
      analysisAvailable: true,
      totalEvents: total,
      dpcEvents: dpc,
      isrEvents: isr,
      hardFaultEvents: hardFault,
      contextSwitchEvents: contextSwitch,
      topProviders: <String, int>{
        for (final entry in sorted.take(10)) entry.key: entry.value,
      },
    );
  }
}
