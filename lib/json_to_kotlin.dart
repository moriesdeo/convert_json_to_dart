String jsonToKotlin(String className, Map<String, dynamic> json, {bool useDummyDefaults = false}) {
  final buffer = StringBuffer();
  buffer.writeln('@Serializable');
  buffer.writeln('data class $className(');

  // Generate class properties with appropriate default values
  json.forEach((key, value) {
    final type = _getKotlinType(value, capitalize(_convertToCamelCase(key)));
    final defaultValue = useDummyDefaults ? _getDefaultValueForType(type) : 'null';
    buffer.writeln('    val ${_convertToCamelCase(key)}: $type? = $defaultValue,');
  });
  buffer.writeln(')');

  // Recursive generation of nested classes
  json.forEach((key, value) {
    final type = _getKotlinType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      if (value is List && value.isNotEmpty && value.first is Map) {
        buffer.writeln('\n' + jsonToKotlin(itemType, (value.first as Map).cast<String, dynamic>(), useDummyDefaults: useDummyDefaults));
      }
    } else if (!_isPrimitiveType(type)) {
      if (value is Map) {
        buffer.writeln('\n' + jsonToKotlin(type, value.cast<String, dynamic>(), useDummyDefaults: useDummyDefaults));
      }
    }
  });

  return buffer.toString();
}

String _getKotlinType(dynamic value, String key) {
  if (value is int) return 'Int';
  if (value is double) return 'Double';
  if (value is bool) return 'Boolean';
  if (value is List && value.isNotEmpty) {
    final firstElement = value.first;
    if (firstElement is Map<String, dynamic>) {
      return 'List<${capitalize(key)}>';
    }
    return 'List<${_getKotlinType(firstElement, key)}>';
  }
  if (value is Map<String, dynamic>) return capitalize(key);
  return 'String';
}

String _getDefaultValueForType(String type) {
  // Set dummy default values according to Kotlin types
  switch (type) {
    case 'Int':
      return '0';
    case 'Double':
      return '0.0';
    case 'Boolean':
      return 'false';
    case 'String':
      return '""';
    default:
      if (type.startsWith('List<')) return 'emptyList()';
      return 'null';
  }
}

bool _isPrimitiveType(String type) {
  return type == 'String' || type == 'Int' || type == 'Double' || type == 'Boolean';
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _convertToCamelCase(String s) {
  final parts = s.split('_');
  return parts[0] + parts.skip(1).map(capitalize).join();
}
