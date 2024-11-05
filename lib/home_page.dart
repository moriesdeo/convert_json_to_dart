import 'dart:convert';

import 'package:convert_json_to_class_dart/CustomElevatedButton.dart';
import 'package:convert_json_to_class_dart/format_json.dart';
import 'package:convert_json_to_class_dart/json_to_java.dart';
import 'package:convert_json_to_class_dart/json_to_kotlin.dart';
import 'package:convert_json_to_class_dart/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'component/SingleChoiceCheckBoxList.dart';
import 'json_to_dart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _jsonController = TextEditingController();
  final _classNameController = TextEditingController();
  final _searchController = TextEditingController();

  String _dartClass = '';
  String _filteredDartClass = '';
  bool _isNullable = false;
  bool _hasDefaultValueNull = false;
  bool _hasDefaultValueDummy = false;

  void _updateDefaultOption(String? selectedOption) {
    setState(() {
      _hasDefaultValueNull = selectedOption == 'Default Value Null';
      _hasDefaultValueDummy = selectedOption == 'Default Value Dummy';
    });
  }

  void _convertJsonToDart() => _convertJson((className, jsonMap) => jsonToDart(
        className,
        jsonMap,
        nullable: _isNullable,
        defaultValue: _hasDefaultValueDummy,
      ));

  void _convertJsonToKotlin() => _convertJson((className, jsonMap) => jsonToKotlin(
        className,
        jsonMap,
        useDummyDefaults: _hasDefaultValueDummy,
      ));

  void _convertJsonToJava() => _convertJson((className, jsonMap) => jsonToJava(
        className,
        jsonMap,
        useDummyDefaults: _hasDefaultValueDummy,
      ));

  void _convertJson(String Function(String, Map<String, dynamic>) convertFunction) {
    final jsonString = _jsonController.text;
    final className = _classNameController.text;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final resultClass = convertFunction(className, jsonMap);
      setState(() {
        _dartClass = resultClass;
        _filteredDartClass = resultClass;
      });
    } catch (_) {
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

  void _clearInput() => _jsonController.clear();

  void _filterResults(String query) {
    setState(() {
      _filteredDartClass = query.isEmpty
          ? _dartClass
          : _dartClass.split('\n').where((line) => line.toLowerCase().contains(query.toLowerCase())).join('\n');
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterResults('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_classNameController, 'Class Name'),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTextField(_jsonController, 'Enter JSON', maxLines: 10)),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        _buildIconButton(Icons.paste, _pasteFromClipboard, 'Paste Input'),
                        _buildIconButton(Icons.clear, _clearInput, 'Clear Input'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildHorizontalButtonRow(),
                const SizedBox(height: 20),
                SingleChoiceCheckBoxList(
                  options: const ['Default Value Null', 'Default Value Dummy'],
                  onSelected: _updateDefaultOption,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _searchController,
                        'Search in Result',
                        onChanged: _filterResults,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildIconButton(Icons.clear, _clearSearch, 'Clear Search'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildResultContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, String tooltip) {
    return IconButton(icon: Icon(icon), onPressed: onPressed, tooltip: tooltip);
  }

  Widget _buildHorizontalButtonRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomElevatedButton(onPressed: _pasteFromClipboard, text: 'Paste Input'),
          const SizedBox(width: 15),
          CustomElevatedButton(onPressed: _clearInput, text: 'Clear Input'),
          const SizedBox(width: 15),
          CustomElevatedButton(onPressed: _copyToClipboard, text: 'Copy Result'),
          const SizedBox(width: 15),
          CustomElevatedButton(onPressed: _convertJsonToDart, text: 'Convert to Dart', backgroundColor: Colors.blue),
          const SizedBox(width: 15),
          CustomElevatedButton(
            onPressed: _convertJsonToKotlin,
            text: 'Convert to Kotlin',
            backgroundColor: Colors.purpleAccent,
          ),
          const SizedBox(width: 15),
          CustomElevatedButton(onPressed: _convertJsonToJava, text: 'Convert to Java', backgroundColor: Colors.orange),
          const SizedBox(width: 15),
          CustomElevatedButton(
              onPressed: () => navigateToScreen(context, '', (_) => const JsonFormatterPage()),
              backgroundColor: Colors.pinkAccent,
              text: 'JSON Formatter'),
        ],
      ),
    );
  }

  Widget _buildResultContainer() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SelectableText.rich(
        _buildColoredText(_filteredDartClass),
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.left,
      ),
    );
  }

  TextSpan _buildColoredText(String text) {
    final spans = <TextSpan>[];
    for (var line in text.split('\n')) {
      for (var word in line.split(' ')) {
        spans.add(TextSpan(
          text: '$word ',
          style: _getTextStyleForWord(word),
        ));
      }
      spans.add(const TextSpan(text: '\n'));
    }
    return TextSpan(children: spans);
  }

  TextStyle _getTextStyleForWord(String word) {
    if (_isClassName(word)) {
      return const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600);
    } else if (_isType(word)) {
      return const TextStyle(color: Colors.purple, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600);
    } else if (_isParameter(word)) {
      return const TextStyle(color: Colors.black, fontWeight: FontWeight.w600);
    } else {
      return const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600);
    }
  }

  bool _isClassName(String word) => RegExp(r'^[A-Z]').hasMatch(word);

  bool _isType(String word) => ['int', 'double', 'String', 'bool', 'List', 'Map'].contains(word);

  bool _isParameter(String word) => RegExp(r'^[a-z]').hasMatch(word) && !_isType(word);
}
