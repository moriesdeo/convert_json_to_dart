String jsonToDart(String className, Map<String, dynamic> json) {
  final buffer = StringBuffer();
  buffer.writeln('class $className {');
  json.forEach((key, value) {
    final type = _getType(value);
    buffer.writeln('  final $type $key;');
  });

  buffer.writeln();
  buffer.writeln('  $className({');
  json.forEach((key, _) {
    buffer.writeln('    required this.$key,');
  });
  buffer.writeln('  });');
  buffer.writeln();
  buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) => $className(');
  json.forEach((key, _) {
    buffer.writeln('    $key: json[\'$key\'],');
  });
  buffer.writeln('  );');
  buffer.writeln();
  buffer.writeln('  Map<String, dynamic> toJson() => {');
  json.forEach((key, _) {
    buffer.writeln('    \'$key\': $key,');
  });
  buffer.writeln('  };');
  buffer.writeln('}');

  return buffer.toString();
}

String _getType(dynamic value) {
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is List) return 'List<${_getType(value.first)}>';
  return 'String';
}
