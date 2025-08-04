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

  // Tambahan: Hitung jumlah parameter di root JSON
  int _countRootParams(Map<String, dynamic>? json) {
    if (json == null) return 0;
    return json.keys.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paramCount = _countRootParams(_decodedJson);

    return Scaffold(
      backgroundColor: const LinearGradient(
                colors: [Color(0xFFF6F7FB), Color(0xFFE3E9F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(const Rect.fromLTWH(0, 0, 500, 500)) !=
              null
          ? null
          : const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_align_left, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('JSON Formatter',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.08),
              child: const Icon(Icons.code, color: Colors.blueAccent),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Enter JSON',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.blueGrey),
                    hintText: 'Paste your JSON here',
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                    prefixIcon:
                        const Icon(Icons.input, color: Colors.blueAccent),
                  ),
                  maxLines: 8,
                  style: const TextStyle(
                      fontFamily: 'JetBrains Mono', fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomElevatedButton(
                  onPressed: _pasteFromClipboard,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.paste, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Paste'),
                    ],
                  ),
                ),
                CustomElevatedButton(
                  onPressed: _clearText,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Clear'),
                    ],
                  ),
                ),
                CustomElevatedButton(
                  onPressed: _copyResultToClipboard,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Copy Result'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_decodedJson != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.list_alt,
                              color: Colors.blueAccent, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Parameter',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                                fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$paramCount',
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _buildParameterButtons(_decodedJson!)
                              .map((w) => MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      curve: Curves.easeInOut,
                                      child: w,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.code,
                                    color: Colors.deepPurple, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Formatted JSON',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const Divider(height: 18, thickness: 1),
                            Expanded(
                              child: SingleChildScrollView(
                                child: SelectableText.rich(
                                  _buildColoredJson(_formattedJson),
                                  style: const TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.visibility,
                                    color: Colors.teal, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'JSON Viewer',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const Divider(height: 18, thickness: 1),
                            Expanded(
                              child: _decodedJson != null
                                  ? SingleChildScrollView(
                                      child: JsonViewer(_decodedJson!),
                                    )
                                  : const Center(
                                      child: Text(
                                        'Invalid JSON',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (_copyMessage.isNotEmpty)
              AnimatedOpacity(
                opacity: _copyMessage.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _copyMessage,
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
