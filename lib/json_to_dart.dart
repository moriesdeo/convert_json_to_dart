String jsonToDart(String className, Map<String, dynamic> json,
    {bool nullable = false, bool defaultValue = false}) {
  final buffer = StringBuffer();
  buffer.writeln('class $className {');

  // Generate class properties
  json.forEach((key, value) {
    final type = _getType(value, capitalize(_convertToCamelCase(key)));
    final nullableType = nullable ? '$type?' : type;
    buffer.writeln('  final $nullableType ${_convertToCamelCase(key)};');
  });

  buffer.writeln();
  buffer.writeln('  $className({');
  json.forEach((key, value) {
    final propertyName = _convertToCamelCase(key);
    if (defaultValue) {
      buffer.writeln('    this.$propertyName = ${_getDefaultValue(value)},');
    } else {
      buffer.writeln(
          nullable ? '    this.$propertyName,' : '    required this.$propertyName,');
    }
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
      if (itemType == 'String' ||
          itemType == 'int' ||
          itemType == 'double' ||
          itemType == 'bool') {
        buffer.writeln(
            '      $propertyName: json[\'$key\'] != null ? List<$itemType>.from(json[\'$key\']) : ${nullable ? 'null' : '[]'},');
      } else {
        buffer.writeln(
            '      $propertyName: json[\'$key\'] != null ? (json[\'$key\'] as List).map((item) => $itemType.fromJson(item)).toList() : ${nullable ? 'null' : '[]'},');
      }
    } else if (type != 'String' &&
        type != 'int' &&
        type != 'double' &&
        type != 'bool') {
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
      if (itemType == 'String' ||
          itemType == 'int' ||
          itemType == 'double' ||
          itemType == 'bool') {
        buffer.writeln('      \'$key\': $propertyName,');
      } else {
        buffer.writeln(
            '      \'$key\': $propertyName?.map((item) => item.toJson()).toList(),');
      }
    } else if (type != 'String' &&
        type != 'int' &&
        type != 'double' &&
        type != 'bool') {
      buffer.writeln('      \'$key\': $propertyName?.toJson(),');
    } else {
      buffer.writeln('      \'$key\': $propertyName,');
    }
  });
  buffer.writeln('    };');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();

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
    } else if (type != 'String' &&
        type != 'int' &&
        type != 'double' &&
        type != 'bool') {
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
  if (value is int) {
    return '0';
  } else if (value is double) {
    return '0.0';
  } else if (value is bool) {
    return 'false';
  } else if (value is String) {
    return "''";
  } else if (value is List) {
    return '[]';
  } else {
    return 'null';
  }
}

String _getType(dynamic value, String className) {
  if (value is int) {
    return 'int';
  } else if (value is double) {
    return 'double';
  } else if (value is bool) {
    return 'bool';
  } else if (value is String) {
    return 'String';
  } else if (value is List) {
    if (value.isEmpty) {
      return 'List<dynamic>';
    } else {
      final itemType = _getType(value.first, className);
      return 'List<$itemType>';
    }
  } else if (value is Map) {
    return className;
  } else {
    return 'dynamic';
  }
}

String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

String _convertToCamelCase(String input) {
  if (input.isEmpty) return input;

  // Split the string by underscores or spaces
  final parts = input.split(RegExp(r'[_\s]+'));

  // Convert the first part to lowercase and capitalize the rest
  final camelCase = parts.asMap().entries.map((entry) {
    if (entry.key == 0) {
      return entry.value.toLowerCase();
    } else {
      return capitalize(entry.value);
    }
  }).join('');

  return camelCase;
}