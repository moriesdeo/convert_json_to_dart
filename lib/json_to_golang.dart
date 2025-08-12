String jsonToGolang(String structName, Map<String, dynamic> json, {bool useDummyDefaults = false}) {
  final buffer = StringBuffer();

  // Generate struct definition
  buffer.writeln('type $structName struct {');

  // Generate struct fields with JSON tags
  json.forEach((key, value) {
    final type = _getGolangType(value, capitalize(_convertToUpperCamelCase(key)));
    final fieldName = capitalize(_convertToUpperCamelCase(key));
    buffer.writeln('\t$fieldName $type `json:"$key"`');
  });

  buffer.writeln('}');

  // Generate constructor function
  buffer.writeln();
  buffer.writeln('func New$structName() *$structName {');
  buffer.writeln('\treturn &$structName{}');
  buffer.writeln('}');

  // Generate marshal/unmarshal methods if needed
  buffer.writeln();
  buffer.writeln('// MarshalJSON custom marshaler for $structName');
  buffer.writeln('func (s *$structName) MarshalJSON() ([]byte, error) {');
  buffer.writeln('\treturn json.Marshal(*s)');
  buffer.writeln('}');

  buffer.writeln();
  buffer.writeln('// UnmarshalJSON custom unmarshaler for $structName');
  buffer.writeln('func (s *$structName) UnmarshalJSON(data []byte) error {');
  buffer.writeln('\ttype alias $structName');
  buffer.writeln('\tvar a alias');
  buffer.writeln('\tif err := json.Unmarshal(data, &a); err != nil {');
  buffer.writeln('\t\treturn err');
  buffer.writeln('\t}');
  buffer.writeln('\t*s = $structName(a)');
  buffer.writeln('\treturn nil');
  buffer.writeln('}');

  // Recursive generation of nested structs
  json.forEach((key, value) {
    final type = _getGolangType(value, capitalize(_convertToUpperCamelCase(key)));
    if (type.startsWith('[]')) {
      final itemType = type.substring(2);
      if (value is List && value.isNotEmpty && value.first is Map) {
        buffer.writeln('\n' + jsonToGolang(itemType, (value.first as Map).cast<String, dynamic>(), useDummyDefaults: useDummyDefaults));
      }
    } else if (!_isPrimitiveGolangType(type)) {
      if (value is Map) {
        buffer.writeln('\n' + jsonToGolang(type, value.cast<String, dynamic>(), useDummyDefaults: useDummyDefaults));
      }
    }
  });

  return buffer.toString();
}

String _getGolangType(dynamic value, String typeName) {
  if (value is int) return 'int';
  if (value is double) return 'float64';
  if (value is bool) return 'bool';
  if (value is List && value.isNotEmpty) {
    final firstElement = value.first;
    if (firstElement is Map<String, dynamic>) {
      return '[]$typeName';
    }
    return '[]${_getGolangType(firstElement, typeName)}';
  }
  if (value is Map<String, dynamic>) return '*$typeName';
  return 'string';
}

bool _isPrimitiveGolangType(String type) {
  return type == 'string' || type == 'int' || type == 'float64' || type == 'bool';
}

String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _convertToUpperCamelCase(String s) {
  final parts = s.split('_');
  return parts.map(capitalize).join('');
}