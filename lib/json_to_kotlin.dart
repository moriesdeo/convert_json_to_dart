String jsonToKotlin(String className, Map<String, dynamic> json) {
  final buffer = StringBuffer();
  buffer.writeln('data class $className(');

  // Generate class properties
  json.forEach((key, value) {
    final type = _getKotlinType(value, capitalize(_convertToCamelCase(key)));
    buffer.writeln('    val ${_convertToCamelCase(key)}: $type,');
  });
  buffer.writeln(') {');
  buffer.writeln();

  // Factory method for JSON deserialization
  buffer.writeln('    companion object {');
  buffer.writeln('        fun fromJson(json: Map<String, Any?>): $className {');
  buffer.writeln('            return $className(');
  json.forEach((key, value) {
    final type = _getKotlinType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      if (_isPrimitiveType(itemType)) {
        buffer
            .writeln('                ${_convertToCamelCase(key)} = (json["$key"] as List<*>).map { it as $itemType }.toList(),');
      } else {
        buffer.writeln(
            '                ${_convertToCamelCase(key)} = (json["$key"] as List<*>).map { $itemType.fromJson(it as Map<String, Any?>) }.toList(),');
      }
    } else if (!_isPrimitiveType(type)) {
      buffer.writeln('                ${_convertToCamelCase(key)} = $type.fromJson(json["$key"] as Map<String, Any?>),');
    } else {
      buffer.writeln('                ${_convertToCamelCase(key)} = json["$key"] as $type,');
    }
  });
  buffer.writeln('            )');
  buffer.writeln('        }');
  buffer.writeln('    }');
  buffer.writeln();

  // Method for JSON serialization
  buffer.writeln('    fun toJson(): Map<String, Any?> {');
  buffer.writeln('        return mapOf(');
  json.forEach((key, value) {
    final type = _getKotlinType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      buffer.writeln('            "$key" to ${_convertToCamelCase(key)}.map { it.toJson() },');
    } else if (!_isPrimitiveType(type)) {
      buffer.writeln('            "$key" to ${_convertToCamelCase(key)}.toJson(),');
    } else {
      buffer.writeln('            "$key" to ${_convertToCamelCase(key)},');
    }
  });
  buffer.writeln('        )');
  buffer.writeln('    }');
  buffer.writeln('}');
  buffer.writeln();

  // Recursive generation of nested classes
  json.forEach((key, value) {
    final type = _getKotlinType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      if (value is List && value.isNotEmpty && value.first is Map) {
        buffer.writeln(jsonToKotlin(itemType, (value.first as Map).cast<String, dynamic>()));
      }
    } else if (!_isPrimitiveType(type)) {
      if (value is Map) {
        buffer.writeln(jsonToKotlin(type, value.cast<String, dynamic>()));
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

bool _isPrimitiveType(String type) {
  return type == 'String' || type == 'Int' || type == 'Double' || type == 'Boolean';
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _convertToCamelCase(String s) {
  final parts = s.split('_');
  return parts[0] + parts.skip(1).map(capitalize).join();
}
