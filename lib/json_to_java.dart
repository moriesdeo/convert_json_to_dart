String jsonToJava(String className, Map<String, dynamic> json, {bool useDummyDefaults = false}) {
  final buffer = StringBuffer();
  buffer.writeln('public class $className {');

  // Generate class properties with appropriate default values
  json.forEach((key, value) {
    final type = _getJavaType(value, capitalize(_convertToCamelCase(key)));
    final defaultValue = useDummyDefaults ? ' = ${_getDefaultValueForJavaType(type)};' : ';';
    buffer.writeln('  private $type ${_convertToCamelCase(key)}$defaultValue');
  });

  buffer.writeln();

  // Generate getters and setters
  json.forEach((key, value) {
    final type = _getJavaType(value, capitalize(_convertToCamelCase(key)));
    final camelCaseKey = _convertToCamelCase(key);
    buffer.writeln('  public $type get${capitalize(camelCaseKey)}() {');
    buffer.writeln('    return $camelCaseKey;');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  public void set${capitalize(camelCaseKey)}($type $camelCaseKey) {');
    buffer.writeln('    this.$camelCaseKey = $camelCaseKey;');
    buffer.writeln('  }');
    buffer.writeln();
  });

  buffer.writeln('}');

  // Recursive generation of nested classes
  json.forEach((key, value) {
    final type = _getJavaType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      if (value is List && value.isNotEmpty && value.first is Map) {
        buffer.writeln(jsonToJava(itemType, (value.first as Map).cast<String, dynamic>(), useDummyDefaults: useDummyDefaults));
      }
    } else if (!_isPrimitiveJavaType(type)) {
      if (value is Map) {
        buffer.writeln(jsonToJava(type, value.cast<String, dynamic>(), useDummyDefaults: useDummyDefaults));
      }
    }
  });

  return buffer.toString();
}

String _getJavaType(dynamic value, String key) {
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'boolean';
  if (value is List && value.isNotEmpty) {
    final firstElement = value.first;
    if (firstElement is Map<String, dynamic>) {
      return 'List<${capitalize(key)}>';
    }
    return 'List<${_getJavaType(firstElement, key)}>';
  }
  if (value is Map<String, dynamic>) return capitalize(key);
  return 'String';
}

String _getDefaultValueForJavaType(String type) {
  // Set dummy default values based on Java types
  switch (type) {
    case 'int':
      return '0';
    case 'double':
      return '0.0';
    case 'boolean':
      return 'false';
    case 'String':
      return '""';
    default:
      if (type.startsWith('List<')) return 'new ArrayList<>()';
      return 'null';
  }
}

bool _isPrimitiveJavaType(String type) {
  return type == 'String' || type == 'int' || type == 'double' || type == 'boolean';
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _convertToCamelCase(String s) {
  final parts = s.split('_');
  return parts[0] + parts.skip(1).map(capitalize).join();
}
