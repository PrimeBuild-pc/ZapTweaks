import 'dart:convert';
import 'dart:io';

import 'package:script_utility/platform/windows/tcp_optimizer_service.dart';

Future<void> main() async {
  final tcp = await WindowsTcpOptimizerService().inventory();
  final qos = await WindowsQosPolicyService().inventory();
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'tcp': tcp
          .map(
            (item) => <String, Object?>{
              'target': item.target,
              'value': item.value,
              'supportedValues': item.supportedValues,
              'writable': item.writable,
            },
          )
          .toList(growable: false),
      'qos': qos.map((item) => item.toJson()).toList(growable: false),
    }),
  );
}
