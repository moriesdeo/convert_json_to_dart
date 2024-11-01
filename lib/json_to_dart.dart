String jsonToDart(String className, Map<String, dynamic> json,
    {bool nullable = false, bool defaultValue = false}) {
  final buffer = StringBuffer();
  buffer.writeln('class $className {');

  // Generate class properties with appropriate default values
  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    final nullableType = nullable ? '$type?' : type;
    buffer.writeln('  final $nullableType ${_convertToCamelCase(key)};');
  });

  buffer.writeln();
  buffer.writeln('  $className({');
  json.forEach((key, value) {
    final propertyName = _convertToCamelCase(key);
    final defaultVal = defaultValue ? _getDefaultValue(value) : 'null';
    buffer.writeln(
        nullable || defaultValue
            ? '    this.$propertyName = $defaultVal,'
            : '    required this.$propertyName,'
    );
  });
  buffer.writeln('  });');
  buffer.writeln();

  // Factory constructor for JSON deserialization
  buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
  buffer.writeln('    return $className(');
  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    final propertyName = _convertToCamelCase(key);
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      final defaultList = nullable ? 'null' : '[]';
      if (_isPrimitiveType(itemType)) {
        buffer.writeln(
            '      $propertyName: json[\'$key\'] != null ? List<$itemType>.from(json[\'$key\']) : $defaultList,');
      } else {
        buffer.writeln(
            '      $propertyName: json[\'$key\'] != null ? (json[\'$key\'] as List).map((item) => $itemType.fromJson(item)).toList() : $defaultList,');
      }
    } else if (!_isPrimitiveType(type)) {
      buffer.writeln(
          '      $propertyName: json[\'$key\'] != null ? $type.fromJson(json[\'$key\']) : ${nullable ? 'null' : '$type()'},');
    } else {
      buffer.writeln('      $propertyName: json[\'$key\']${nullable ? '' : ' ?? ${_getDefaultValue(value)}'},');
    }
  });
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();

  // Method for JSON serialization
  buffer.writeln('  Map<String, dynamic> toJson() {');
  buffer.writeln('    return {');
  json.forEach((key, value) {
    final propertyName = _convertToCamelCase(key);
    final type = _getType(value, capitalize(propertyName));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      if (_isPrimitiveType(itemType)) {
        buffer.writeln('      \'$key\': $propertyName,');
      } else {
        buffer.writeln(
            '      \'$key\': $propertyName?.map((item) => item.toJson()).toList(),');
      }
    } else if (!_isPrimitiveType(type)) {
      buffer.writeln('      \'$key\': $propertyName?.toJson(),');
    } else {
      buffer.writeln('      \'$key\': $propertyName,');
    }
  });
  buffer.writeln('    };');
  buffer.writeln('  }');
  buffer.writeln('}');

  // Recursive generation of nested classes
  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    if (type.startsWith('List<')) {
      final itemType = type.substring(5, type.length - 1);
      if (value is List && value.isNotEmpty && value.first is Map) {
        buffer.writeln(jsonToDart(itemType,
            (value.first as Map).cast<String, dynamic>(),
            nullable: nullable, defaultValue: defaultValue));
      }
    } else if (!_isPrimitiveType(type)) {
      if (value is Map) {
        buffer.writeln(jsonToDart(
            type, value.cast<String, dynamic>(),
            nullable: nullable, defaultValue: defaultValue));
      }
    }
  });

  return buffer.toString();
}

String _getDefaultValue(dynamic value) {
  if (value is int) return '0';
  if (value is double) return '0.0';
  if (value is bool) return 'false';
  if (value is String) return "''";
  if (value is List) return '[]';
  return 'null';
}

bool _isPrimitiveType(String type) {
  return type == 'String' || type == 'int' || type == 'double' || type == 'bool';
}

String _getType(dynamic value, String className) {
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is String) return 'String';
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>';
    final itemType = _getType(value.first, className);
    return 'List<$itemType>';
  }
  if (value is Map) return className;
  return 'dynamic';
}

String capitalize(String input) => input.isEmpty ? input : input[0].toUpperCase() + input.substring(1);

String _convertToCamelCase(String input) {
  if (input.isEmpty) return input;
  final parts = input.split(RegExp(r'[_\s]+'));
  return parts[0] + parts.skip(1).map(capitalize).join('');
}
