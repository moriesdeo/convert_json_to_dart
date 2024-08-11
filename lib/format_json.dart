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
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      setState(() {
        _controller.text = data.text!;
        _formattedJson = '';
        _errorMessage = '';
        _copyMessage = '';
      });
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

  void _copyResultToClipboard() {
    if (_formattedJson.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _formattedJson));
      setState(() {
        _copyMessage = 'Result copied to clipboard!';
      });
    }
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomElevatedButton(
                  onPressed: _pasteFromClipboard,
                  text: 'Paste',
                ),
                CustomElevatedButton(
                  onPressed: _clearText,
                  text: 'Clear',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Tampilan sebelah kiri menggunakan SelectableText.rich untuk teks berwarna
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
                  // Tampilan sebelah kanan tetap menggunakan JsonViewer
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
            CustomElevatedButton(
              onPressed: _copyResultToClipboard,
              text: 'Copy Result',
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
