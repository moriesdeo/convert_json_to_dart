String jsonToJava(String className, Map<String, dynamic> json) {
  final buffer = StringBuffer();
  buffer.writeln('public class $className {');

  // Generate class properties
  json.forEach((key, value) {
    final type = _getJavaType(value, capitalize(_convertToCamelCase(key)));
    buffer.writeln('  private $type ${_convertToCamelCase(key)};');
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
        buffer.writeln(jsonToJava(itemType, (value.first as Map).cast<String, dynamic>()));
      }
    } else if (type != 'String' && type != 'int' && type != 'double' && type != 'boolean') {
      if (value is Map) {
        buffer.writeln(jsonToJava(type, value.cast<String, dynamic>()));
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

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _convertToCamelCase(String s) {
  final parts = s.split('_');
  return parts[0] + parts.skip(1).map(capitalize).join();
}
