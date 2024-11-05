import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

import 'CustomElevatedButton.dart';

class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({super.key});

  @override
  _JsonFormatterPageState createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> {
  final TextEditingController _controller = TextEditingController();
  String _formattedJson = '';
  String _errorMessage = '';
  String _copyMessage = '';
  Map<String, dynamic>? _decodedJson;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_formatJson);
  }

  @override
  void dispose() {
    _controller.removeListener(_formatJson);
    _controller.dispose();
    super.dispose();
  }

  void _formatJson() {
    setState(() {
      _errorMessage = '';
      _copyMessage = '';
      try {
        _decodedJson = json.decode(_controller.text);
        _formattedJson = const JsonEncoder.withIndent('  ').convert(_decodedJson);
      } catch (e) {
        _formattedJson = '';
        _decodedJson = null;
        _errorMessage = 'Invalid JSON format';
      }
    });
  }

  void _pasteFromClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        setState(() {
          _controller.text = data.text!;
          _formattedJson = '';
          _errorMessage = '';
          _copyMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'Clipboard is empty or inaccessible';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to access clipboard. Please try again.';
      });
      debugPrint('Clipboard error: $e'); // To log the error for debugging
    }
  }

  void _clearText() {
    setState(() {
      _controller.clear();
      _formattedJson = '';
      _errorMessage = '';
      _copyMessage = '';
      _decodedJson = null;
    });
  }

  void _copyResultToClipboard() async {
    if (_formattedJson.isNotEmpty) {
      try {
        await Clipboard.setData(ClipboardData(text: _formattedJson));
        setState(() {
          _copyMessage = 'Result copied to clipboard!';
        });
      } catch (e) {
        setState(() {
          _copyMessage = 'Failed to copy result. Please try again.';
        });
      }
    }
  }

  void _selectParameter(String path) {
    setState(() {
      final selectedData = _getNestedData(_decodedJson, path.split('.'));

      if (selectedData is List && selectedData.isNotEmpty) {
        final firstObject = selectedData.first;
        _formattedJson = const JsonEncoder.withIndent('  ').convert(firstObject);
      } else {
        _formattedJson = const JsonEncoder.withIndent('  ').convert(selectedData);
      }
    });
  }

  dynamic _getNestedData(Map<String, dynamic>? json, List<String> pathSegments) {
    dynamic data = json;
    for (var segment in pathSegments) {
      if (data is Map<String, dynamic> && data.containsKey(segment)) {
        data = data[segment];
      } else {
        return null;
      }
    }
    return data;
  }

  List<Widget> _buildParameterButtons(Map<String, dynamic> json, [String path = '']) {
    List<Widget> buttons = [];
    json.forEach((key, value) {
      final fullPath = path.isEmpty ? key : '$path.$key';

      if (value is Map<String, dynamic> || (value is List && value.isNotEmpty && value.first is Map)) {
        buttons.add(
          CustomElevatedButton(
            onPressed: () => _selectParameter(fullPath),
            text: key,
          ),
        );
        if (value is Map<String, dynamic>) {
          buttons.addAll(_buildParameterButtons(value, fullPath));
        }
      }
    });
    return buttons;
  }

  TextSpan _buildColoredJson(String json) {
    final List<TextSpan> spans = [];
    final regExp = RegExp(r'(".*?":)|(:)|(\d+)|(".*?")|(\[)|(\])|(\{)|(\})|(\btrue\b|\bfalse\b)');

    int lastMatchEnd = 0;

    for (var match in regExp.allMatches(json)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: json.substring(lastMatchEnd, match.start)));
      }

      final matchText = match.group(0)!;

      if (matchText == '{' || matchText == '}') {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)));
      } else if (matchText == '[' || matchText == ']') {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)));
      } else if (matchText.endsWith('":')) {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)));
      } else if (matchText.startsWith('"') && matchText.endsWith('"')) {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)));
      } else if (RegExp(r'^\d+$').hasMatch(matchText)) {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)));
      } else if (matchText == 'true' || matchText == 'false') {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600)));
      } else {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: Colors.black)));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < json.length) {
      spans.add(TextSpan(text: json.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('JSON Formatter'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Enter JSON',
                hintText: 'Paste your JSON here',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomElevatedButton(
                  onPressed: _pasteFromClipboard,
                  text: 'Paste',
                  backgroundColor: Colors.orange,
                ),
                CustomElevatedButton(
                  onPressed: _clearText,
                  text: 'Clear',
                  backgroundColor: Colors.red,
                ),
                CustomElevatedButton(
                  onPressed: _copyResultToClipboard,
                  text: 'Copy Result',
                  backgroundColor: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_decodedJson != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _buildParameterButtons(_decodedJson!),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText.rich(
                          _buildColoredJson(_formattedJson),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _decodedJson != null
                          ? SingleChildScrollView(
                              child: JsonViewer(_decodedJson!),
                            )
                          : const Center(
                              child: Text(
                                'Invalid JSON',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.normal),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (_copyMessage.isNotEmpty)
              Text(
                _copyMessage,
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}
