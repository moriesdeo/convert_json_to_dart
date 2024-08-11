import 'dart:convert';

import 'package:convert_json_to_class_dart/json_to_kotlin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'json_to_dart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _dartClass = '';
  String _filteredDartClass = '';

  void _convertJsonToDart() {
    final jsonString = _jsonController.text;
    final className = _classNameController.text;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final dartClass = jsonToDart(className, jsonMap);

      setState(() {
        _dartClass = dartClass;
        _filteredDartClass = dartClass;
      });
    } catch (e) {
      setState(() {
        _dartClass = 'Invalid JSON format';
        _filteredDartClass = 'Invalid JSON format';
      });
    }
  }

  void _convertJsonToKotlin() {
    final jsonString = _jsonController.text;
    final className = _classNameController.text;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final dartClass = jsonToKotlin(className, jsonMap);

      setState(() {
        _dartClass = dartClass;
        _filteredDartClass = dartClass;
      });
    } catch (e) {
      setState(() {
        _dartClass = 'Invalid JSON format';
        _filteredDartClass = 'Invalid JSON format';
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _filteredDartClass)).then((_) {
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

  void _filterResults(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDartClass = _dartClass;
      } else {
        final lines = _dartClass.split('\n');
        _filteredDartClass = lines.where((line) => line.toLowerCase().contains(query.toLowerCase())).join('\n');
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterResults('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _jsonController,
                    decoration: InputDecoration(
                      labelText: 'Enter JSON',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                    maxLines: 10,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
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
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _convertJsonToDart,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 5,
                  ),
                  child: const Text('Convert to Dart'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: _convertJsonToKotlin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 5,
                  ),
                  child: const Text('Convert to Kotlin'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: _copyToClipboard,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 5,
                  ),
                  child: const Text('Copy Result'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search in Result',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    onChanged: _filterResults,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  tooltip: 'Clear Search',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    _filteredDartClass,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}