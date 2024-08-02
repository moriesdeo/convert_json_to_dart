import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON to Dart Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'JSON to Dart Converter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  String _dartClass = '';

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

  void _convertJson() {
    final jsonString = _jsonController.text;
    final className = _classNameController.text;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final dartClass = jsonToDart(className, jsonMap);

      setState(() {
        _dartClass = dartClass;
      });
    } catch (e) {
      setState(() {
        _dartClass = 'Invalid JSON format';
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _dartClass)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    });
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null) {
      _jsonController.text = clipboardData.text ?? '';
    }
  }

  void _clearInput() {
    _jsonController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _jsonController,
                    decoration: const InputDecoration(
                      labelText: 'Enter JSON',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: _pasteFromClipboard,
                  tooltip: 'Paste Input',
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearInput,
                  tooltip: 'Clear Input',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _convertJson,
                  child: const Text('Convert'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _copyToClipboard,
                  child: const Text('Copy Result'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _dartClass,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
