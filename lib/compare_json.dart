import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'component/button_row.dart';
import 'component/differences_section.dart';
import 'component/json_input_section.dart';
import 'component/json_viewer_container.dart';
import 'utils/json_formatter.dart';

class CompareJson extends StatefulWidget {
  const CompareJson({super.key});

  @override
  State<CompareJson> createState() => _CompareJsonState();
}

class _CompareJsonState extends State<CompareJson> {
  final TextEditingController _leftController = TextEditingController();
  final TextEditingController _rightController = TextEditingController();

  String _leftFormattedJson = '';
  String _rightFormattedJson = '';

  String _leftErrorMessage = '';
  String _rightErrorMessage = '';

  String _copyMessage = '';

  Map<String, dynamic>? _leftDecodedJson;
  Map<String, dynamic>? _rightDecodedJson;

  List<String> _differences = [];

  @override
  void initState() {
    super.initState();
    _leftController.addListener(() => _formatJson(isLeft: true));
    _rightController.addListener(() => _formatJson(isLeft: false));
  }

  @override
  void dispose() {
    _leftController.removeListener(() => _formatJson(isLeft: true));
    _rightController.removeListener(() => _formatJson(isLeft: false));
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _formatJson({required bool isLeft}) {
    final controller = isLeft ? _leftController : _rightController;

    setState(() {
      if (isLeft) {
        _leftErrorMessage = '';
      } else {
        _rightErrorMessage = '';
      }

      _copyMessage = '';

      try {
        final decodedJson = json.decode(controller.text);
        final formattedJson = const JsonEncoder.withIndent('  ').convert(decodedJson);

        if (isLeft) {
          _leftDecodedJson = decodedJson;
          _leftFormattedJson = formattedJson;
        } else {
          _rightDecodedJson = decodedJson;
          _rightFormattedJson = formattedJson;
        }

        if (_leftDecodedJson != null && _rightDecodedJson != null) {
          _findDifferences();
        }
      } catch (e) {
        if (isLeft) {
          _leftFormattedJson = '';
          _leftDecodedJson = null;
          _leftErrorMessage = 'Invalid JSON format';
        } else {
          _rightFormattedJson = '';
          _rightDecodedJson = null;
          _rightErrorMessage = 'Invalid JSON format';
        }
      }
    });
  }

  void _findDifferences() {
    _differences = [];

    if (_leftDecodedJson == null || _rightDecodedJson == null) return;

    // Compare root level keys
    final leftKeys = _leftDecodedJson!.keys.toSet();
    final rightKeys = _rightDecodedJson!.keys.toSet();

    final missingInRight = leftKeys.difference(rightKeys);
    final missingInLeft = rightKeys.difference(leftKeys);

    for (var key in missingInRight) {
      _differences.add('Key "$key" exists in left JSON but missing in right JSON');
    }

    for (var key in missingInLeft) {
      _differences.add('Key "$key" exists in right JSON but missing in left JSON');
    }

    // Compare common keys
    final commonKeys = leftKeys.intersection(rightKeys);
    for (var key in commonKeys) {
      _compareValues(key, _leftDecodedJson![key], _rightDecodedJson![key], path: key);
    }
  }

  void _compareValues(String key, dynamic leftValue, dynamic rightValue, {required String path}) {
    // Different types
    if (leftValue.runtimeType != rightValue.runtimeType) {
      _differences.add('Value type mismatch at "$path": ${leftValue.runtimeType} vs ${rightValue.runtimeType}');
      return;
    }

    // Recursive compare for maps
    if (leftValue is Map<String, dynamic> && rightValue is Map<String, dynamic>) {
      final leftKeys = leftValue.keys.toSet();
      final rightKeys = rightValue.keys.toSet();

      final missingInRight = leftKeys.difference(rightKeys);
      final missingInLeft = rightKeys.difference(leftKeys);

      for (var key in missingInRight) {
        _differences.add('Key "$key" exists in left JSON but missing in right JSON at "$path"');
      }

      for (var key in missingInLeft) {
        _differences.add('Key "$key" exists in right JSON but missing in left JSON at "$path"');
      }

      final commonKeys = leftKeys.intersection(rightKeys);
      for (var key in commonKeys) {
        _compareValues(key, leftValue[key], rightValue[key], path: '$path.$key');
      }
    }
    // Recursive compare for lists
    else if (leftValue is List && rightValue is List) {
      if (leftValue.length != rightValue.length) {
        _differences.add('Array length mismatch at "$path": ${leftValue.length} vs ${rightValue.length}');
      }

      final minLength = leftValue.length < rightValue.length ? leftValue.length : rightValue.length;

      for (var i = 0; i < minLength; i++) {
        _compareValues('[$i]', leftValue[i], rightValue[i], path: '$path[$i]');
      }
    }
    // Compare primitive values
    else if (leftValue != rightValue) {
      _differences.add('Value mismatch at "$path": $leftValue vs $rightValue');
    }
  }

  void _pasteFromClipboard({required bool isLeft}) async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        setState(() {
          if (isLeft) {
            _leftController.text = data.text ?? '';
            _leftErrorMessage = '';
            _copyMessage = '';
            _formatJson(isLeft: true);
          } else {
            _rightController.text = data.text ?? '';
            _rightErrorMessage = '';
            _copyMessage = '';
            _formatJson(isLeft: false);
          }
          _copyMessage = '';
        });
      } else {
        setState(() {
          if (isLeft) {
            _leftErrorMessage = 'Clipboard is empty or inaccessible';
          } else {
            _rightErrorMessage = 'Clipboard is empty or inaccessible';
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isLeft) {
          _leftErrorMessage = 'Failed to access clipboard. Please try again.';
        } else {
          _rightErrorMessage = 'Failed to access clipboard. Please try again.';
        }
      });
      debugPrint('Clipboard error: $e');
    }
  }

  void _clearText({required bool isLeft}) {
    setState(() {
      if (isLeft) {
        _leftController.clear();
        _leftFormattedJson = '';
        _leftErrorMessage = '';
        _leftDecodedJson = null;
      } else {
        _rightController.clear();
        _rightFormattedJson = '';
        _rightErrorMessage = '';
        _rightDecodedJson = null;
      }
      _copyMessage = '';
      _differences = [];
    });
  }

  void _copyResultToClipboard({required bool isLeft}) async {
    final formattedJson = isLeft ? _leftFormattedJson : _rightFormattedJson;

    if (formattedJson.isNotEmpty) {
      try {
        await Clipboard.setData(ClipboardData(text: formattedJson));
        setState(() {
          _copyMessage = 'JSON copied to clipboard!';
        });
      } catch (e) {
        setState(() {
          _copyMessage = 'Failed to copy result. Please try again.';
        });
      }
    }
  }

  TextSpan _buildColoredJson(String json) {
    return JsonFormatter.buildColoredJson(json);
  }

  Widget _buildJsonInputSection({required bool isLeft}) {
    final controller = isLeft ? _leftController : _rightController;
    final errorMessage = isLeft ? _leftErrorMessage : _rightErrorMessage;

    return JsonInputSection(
      isLeft: isLeft,
      controller: controller,
      errorMessage: errorMessage,
    );
  }

  Widget _buildButtonRow({required bool isLeft}) {
    return ButtonRow(
      isLeft: isLeft,
      onPaste: _pasteFromClipboard,
      onClear: _clearText,
      onCopy: _copyResultToClipboard,
    );
  }

  Widget _buildJsonViewer({required bool isLeft}) {
    final decodedJson = isLeft ? _leftDecodedJson : _rightDecodedJson;
    final formattedJson = isLeft ? _leftFormattedJson : _rightFormattedJson;

    return JsonViewerContainer(
      isLeft: isLeft,
      decodedJson: decodedJson,
      formattedJson: formattedJson,
      buildColoredJson: _buildColoredJson,
    );
  }

  Widget _buildDifferencesSection() {
    return DifferencesSection(differences: _differences);
  }

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.compare_arrows, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'JSON Comparator',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5
              ),
            ),
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
              backgroundColor: Colors.deepPurple.withOpacity(0.08),
              child: const Icon(Icons.code, color: Colors.deepPurple),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Input section (Left and Right)
            Row(
              children: [
                Expanded(
                  child: _buildJsonInputSection(isLeft: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildJsonInputSection(isLeft: false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Buttons section (Left and Right)
            Row(
              children: [
                Expanded(child: _buildButtonRow(isLeft: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildButtonRow(isLeft: false)),
              ],
            ),
            const SizedBox(height: 18),
            // Differences section
            SizedBox(
              height: 120,
              child: _buildDifferencesSection(),
            ),
            const SizedBox(height: 18),
            // JSON viewer section (Left and Right)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildJsonViewer(isLeft: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildJsonViewer(isLeft: false),
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _copyMessage,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
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
