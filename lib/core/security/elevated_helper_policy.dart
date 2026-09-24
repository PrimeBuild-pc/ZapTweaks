import 'dart:typed_data';

import '../operations/operation.dart';

class HelperOperationRule {
  const HelperOperationRule({
    this.parameters = const <String, Type>{},
    this.targetPattern,
  });

  final Map<String, Type> parameters;
  final RegExp? targetPattern;
}

class ElevatedHelperPolicy {
  ElevatedHelperPolicy(Map<String, HelperOperationRule> rules)
    : _rules = Map.unmodifiable(rules);

  static const Set<String> forbiddenParameterNames = <String>{
    'command',
    'executable',
    'script',
    'shell',
  };

  final Map<String, HelperOperationRule> _rules;

  void validate({
    required String operationId,
    required String nonce,
    required String? target,
    required JsonMap parameters,
  }) {
    if (nonce.length < 32) throw StateError('Invalid helper nonce.');
    final rule = _rules[operationId];
    if (rule == null) throw StateError('Operation is not helper-allowlisted.');
    if (target != null &&
        (rule.targetPattern == null || !rule.targetPattern!.hasMatch(target))) {
      throw StateError('Invalid operation target.');
    }
    for (final entry in parameters.entries) {
      if (forbiddenParameterNames.contains(entry.key.toLowerCase())) {
        throw StateError('Arbitrary execution parameters are forbidden.');
      }
      final type = rule.parameters[entry.key];
      if (type == null || !_matchesType(entry.value, type)) {
        throw StateError('Invalid helper parameter: ${entry.key}.');
      }
    }
    final missing = rule.parameters.keys.where(
      (name) => !parameters.containsKey(name),
    );
    if (missing.isNotEmpty) {
      throw StateError('Missing helper parameter: ${missing.first}.');
    }
  }

  static bool _matchesType(Object? value, Type type) {
    if (type == bool) return value is bool;
    if (type == int) return value is int;
    if (type == String) return value is String;
    if (type == Uint8List) return value is Uint8List;
    if (type == List<String>) {
      return value is List && value.every((item) => item is String);
    }
    return false;
  }
}
