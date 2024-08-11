String javaToDart(String javaCode) {
  final buffer = StringBuffer();
  final lines = javaCode.split('\n');

  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('import')) {
      // Convert Java imports to Dart imports
      buffer.writeln(_convertImport(line));
    } else if (line.startsWith('public class') || line.startsWith('class')) {
      // Convert class definition
      buffer.writeln(_convertClassDefinition(line));
    } else if (line.startsWith('public') || line.startsWith('private') || line.startsWith('protected')) {
      // Convert method or field definitions
      buffer.writeln(_convertMethodOrField(line));
    } else {
      // Copy any other line as is
      buffer.writeln(line);
    }
  }

  return buffer.toString();
}

String _convertImport(String line) {
  // Simple conversion for import statements
  final javaPackage = line.replaceFirst('import', '').trim().replaceAll(';', '');
  return 'import \'package:$javaPackage.dart\';';
}

String _convertClassDefinition(String line) {
  // Convert Java class to Dart class
  return line.replaceFirst('public class', 'class').replaceFirst('class', 'class');
}

String _convertMethodOrField(String line) {
  if (line.contains('(') && line.contains(')')) {
    // Convert method definition
    return _convertMethod(line);
  } else {
    // Convert field definition
    return _convertField(line);
  }
}

String _convertMethod(String line) {
  // Basic conversion for method signature from Java to Dart
  line = line
      .replaceFirst('public', '')
      .replaceFirst('private', '')
      .replaceFirst('protected', '')
      .replaceFirst('void', 'void')
      .replaceAll(';', '')
      .trim();

  return line;
}

String _convertField(String line) {
  // Basic conversion for field declaration from Java to Dart
  line = line.replaceFirst('public', '').replaceFirst('private', '').replaceFirst('protected', '').replaceAll(';', '').trim();

  final parts = line.split(' ');
  if (parts.length >= 2) {
    final type = _mapJavaTypeToDart(parts[0]);
    final fieldName = parts.sublist(1).join(' ');
    return 'final $type $fieldName;';
  }
  return line;
}

String _mapJavaTypeToDart(String javaType) {
  // Mapping of common Java types to Dart types
  switch (javaType) {
    case 'int':
      return 'int';
    case 'double':
      return 'double';
    case 'float':
      return 'double';
    case 'boolean':
      return 'bool';
    case 'String':
      return 'String';
    case 'List':
      return 'List';
    default:
      return javaType; // Default to the same type name if not mapped
  }
}
