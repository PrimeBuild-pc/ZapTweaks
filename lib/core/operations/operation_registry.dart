import 'operation.dart';

class OperationRegistry {
  OperationRegistry(Iterable<OperationDefinition> definitions) {
    for (final definition in definitions) {
      if (_definitions.containsKey(definition.id)) {
        throw StateError('Duplicate operation ID: ${definition.id}');
      }
      _definitions[definition.id] = definition;
    }
    for (final definition in _definitions.values) {
      for (final alias in definition.legacyAliases) {
        if (_definitions.containsKey(alias) || _aliases.containsKey(alias)) {
          throw StateError('Duplicate operation alias: $alias');
        }
        _aliases[alias] = definition.id;
      }
    }
  }

  final Map<String, OperationDefinition> _definitions =
      <String, OperationDefinition>{};
  final Map<String, String> _aliases = <String, String>{};

  Iterable<OperationDefinition> get definitions => _definitions.values;

  OperationDefinition resolve(String idOrAlias) {
    final id = _aliases[idOrAlias] ?? idOrAlias;
    final definition = _definitions[id];
    if (definition == null) throw StateError('Unknown operation: $idOrAlias');
    return definition;
  }
}
