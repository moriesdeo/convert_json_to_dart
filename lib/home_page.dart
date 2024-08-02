import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'json_converter.dart';

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
