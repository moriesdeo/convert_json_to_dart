String jsonToDart(String className, Map<String, dynamic> json) {
  final buffer = StringBuffer();
  buffer.writeln('class $className {');

  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    buffer.writeln('  final $type ${_convertToCamelCase(key)};');
  });

  buffer.writeln();
  buffer.writeln('  $className({');
  json.forEach((key, _) {
    buffer.writeln('    required this.${_convertToCamelCase(key)},');
  });
  buffer.writeln('  });');
  buffer.writeln();
  buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) => $className(');
  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      buffer.writeln('    ${_convertToCamelCase(key)}: (json[\'$key\'] as List).map((e) => $itemType.fromJson(e)).toList(),');
    } else if (type != 'String' && type != 'int' && type != 'double' && type != 'bool') {
      buffer.writeln('    ${_convertToCamelCase(key)}: $type.fromJson(json[\'$key\']),');
    } else {
      buffer.writeln('    ${_convertToCamelCase(key)}: json[\'$key\'],');
    }
  });
  buffer.writeln('  );');
  buffer.writeln();
  buffer.writeln('  Map<String, dynamic> toJson() => {');
  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      buffer.writeln('    \'$key\': ${_convertToCamelCase(key)}.map((e) => e.toJson()).toList(),');
    } else if (type != 'String' && type != 'int' && type != 'double' && type != 'bool') {
      buffer.writeln('    \'$key\': ${_convertToCamelCase(key)}.toJson(),');
    } else {
      buffer.writeln('    \'$key\': ${_convertToCamelCase(key)},');
    }
  });
  buffer.writeln('  };');
  buffer.writeln('}');

  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      if (value is List && value.isNotEmpty && value.first is Map) {
        buffer.writeln(jsonToDart(itemType, (value.first as Map).cast<String, dynamic>()));
      }
    } else if (type != 'String' && type != 'int' && type != 'double' && type != 'bool') {
      if (value is Map) {
        buffer.writeln(jsonToDart(type, value.cast<String, dynamic>()));
      }
    }
  });

  return buffer.toString();
}

String _getType(dynamic value, String key) {
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is List && value.isNotEmpty) {
    final firstElement = value.first;
    if (firstElement is Map<String, dynamic>) {
      return 'List<${capitalize(key)}>';
    }
    return 'List<${_getType(firstElement, key)}>';
  }
  if (value is Map<String, dynamic>) return capitalize(key);
  return 'String';
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _convertToCamelCase(String s) {
  final parts = s.split('_');
  return parts[0] + parts.skip(1).map(capitalize).join();
}
