import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

import 'CustomElevatedButton.dart';
import 'constants/app_colors.dart';

class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({super.key});

  @override
  _JsonFormatterPageState createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _formattedJson = '';
  String _errorMessage = '';
  String _copyMessage = '';
  Map<String, dynamic>? _decodedJson;
  List<String> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_formatJson);
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _controller.removeListener(_formatJson);
    _searchController.removeListener(_performSearch);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _formatJson() {
    setState(() {
      _errorMessage = '';
      _copyMessage = '';
      _searchResults = [];
      _isSearching = false;
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
          _errorMessage = '';
          _copyMessage = '';
        });

        // Automatically try to format and display JSON after pasting
        try {
          final decoded = json.decode(data.text!);
          setState(() {
            _decodedJson = decoded is Map<String, dynamic> ? decoded : null;
            if (_decodedJson != null) {
              _formattedJson = const JsonEncoder.withIndent('  ').convert(_decodedJson);
              _copyMessage = 'JSON pasted and formatted successfully!';
            }
          });
        } catch (e) {
          // If it's not valid JSON, just keep it as plain text
          setState(() {
            _formattedJson = '';
            _decodedJson = null;
          });
        }
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
      _searchController.clear();
      _formattedJson = '';
      _errorMessage = '';
      _copyMessage = '';
      _decodedJson = null;
      _searchResults = [];
      _isSearching = false;
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

  void _beautifyJson() {
    if (_controller.text.isNotEmpty) {
      try {
        final decoded = json.decode(_controller.text);
        final beautified = const JsonEncoder.withIndent('  ').convert(decoded);
        setState(() {
          _controller.text = beautified;
          _formattedJson = beautified;
          _decodedJson = decoded is Map<String, dynamic> ? decoded : null;
          _errorMessage = '';
          _copyMessage = 'JSON beautified successfully!';
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Invalid JSON format';
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
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)));
      } else if (matchText == '[' || matchText == ']') {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)));
      } else if (matchText.endsWith('":')) {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: AppColors.syntaxType, fontWeight: FontWeight.w600)));
      } else if (matchText.startsWith('"') && matchText.endsWith('"')) {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: AppColors.syntaxKeyword, fontWeight: FontWeight.w600)));
      } else if (RegExp(r'^\d+$').hasMatch(matchText)) {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: AppColors.syntaxDefault, fontWeight: FontWeight.w600)));
      } else if (matchText == 'true' || matchText == 'false') {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)));
      } else {
        spans.add(TextSpan(text: matchText, style: const TextStyle(color: AppColors.bodyText)));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < json.length) {
      spans.add(TextSpan(text: json.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }

  // Perform search on JSON data
  void _performSearch() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = searchTerm.isNotEmpty;
      _searchResults = [];

      if (searchTerm.isNotEmpty && _decodedJson != null) {
        _searchInJson(_decodedJson!, '', searchTerm);
      } else if (searchTerm.isEmpty && _decodedJson != null) {
        // When search is cleared, restore the original formatted JSON
        _formattedJson = const JsonEncoder.withIndent('  ').convert(_decodedJson);
      }
    });
  }

  // Recursively search through JSON structure
  void _searchInJson(dynamic json, String path, String searchTerm) {
    if (json is Map<String, dynamic>) {
      json.forEach((key, value) {
        final currentPath = path.isEmpty ? key : '$path.$key';

        // Check if key contains search term
        if (key.toLowerCase().contains(searchTerm)) {
          _searchResults.add('$currentPath: ${_getValuePreview(value)}');
        }

        // Check if value contains search term (for string values)
        if (value is String && value.toLowerCase().contains(searchTerm)) {
          _searchResults.add('$currentPath: "$value"');
        } else if (value is num && value.toString().contains(searchTerm)) {
          _searchResults.add('$currentPath: $value');
        } else if (value is bool &&
            value.toString().toLowerCase().contains(searchTerm)) {
          _searchResults.add('$currentPath: $value');
        }

        // Continue searching in nested structures
        if (value is Map<String, dynamic> || value is List) {
          _searchInJson(value, currentPath, searchTerm);
        }
      });
    } else if (json is List) {
      for (int i = 0; i < json.length; i++) {
        final currentPath = '$path[$i]';
        final item = json[i];

        // Check if value contains search term (for string values)
        if (item is String && item.toLowerCase().contains(searchTerm)) {
          _searchResults.add('$currentPath: "$item"');
        } else if (item is num && item.toString().contains(searchTerm)) {
          _searchResults.add('$currentPath: $item');
        } else if (item is bool &&
            item.toString().toLowerCase().contains(searchTerm)) {
          _searchResults.add('$currentPath: $item');
        }

        // Continue searching in nested structures
        if (item is Map<String, dynamic> || item is List) {
          _searchInJson(item, currentPath, searchTerm);
        }
      }
    }
  }

  // Helper to get a preview of value for search results
  String _getValuePreview(dynamic value) {
    if (value is String) return '"${value.length > 30 ? value.substring(0, 27) + '...' : value}"';
    if (value is Map) return '{...}';
    if (value is List) return '[...]';
    return value.toString();
  }

  // Select specific JSON path from search results
  void _selectSearchResult(String result) {
    final pathPart = result.split(':').first.trim();

    // Handle array notation in path
    List<String> segments = [];
    RegExp(r'([^\[\]\.])+|\[(\d+)\]').allMatches(pathPart).forEach((match) {
      final segment = match.group(0);
      if (segment != null) {
        if (segment.startsWith('[') && segment.endsWith(']')) {
          segments.add(segment.substring(1, segment.length - 1));
        } else {
          segments.add(segment);
        }
      }
    });

    dynamic data = _decodedJson;
    for (var segment in segments) {
      if (data is Map<String, dynamic> && data.containsKey(segment)) {
        data = data[segment];
      } else if (data is List && int.tryParse(segment) != null) {
        final index = int.parse(segment);
        if (index >= 0 && index < data.length) {
          data = data[index];
        } else {
          return;
        }
      } else {
        return;
      }
    }

    setState(() {
      _formattedJson = const JsonEncoder.withIndent('  ').convert(data);
    });
  }

  // Clear search results and reset view
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _searchResults = [];
      if (_decodedJson != null) {
        _formattedJson = const JsonEncoder.withIndent('  ').convert(_decodedJson);
      }
    });
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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_align_left, color: AppColors.primary),
            SizedBox(width: 8),
            Text('JSON Formatter',
                style: TextStyle(
                    color: AppColors.titleText,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ],
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 1.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.icon),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.08),
              child: const Icon(Icons.code, color: AppColors.primary),
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
                gradient: const LinearGradient(
                  colors: [AppColors.cardBackground, AppColors.inputBackground],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.07),
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
                        fontWeight: FontWeight.w700, color: AppColors.labelText),
                    hintText: 'Paste your JSON here',
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                    prefixIcon:
                        const Icon(Icons.input, color: AppColors.primary),
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
                  backgroundColor: AppColors.syntaxDefault,
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
                  backgroundColor: AppColors.secondary,
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
                  onPressed: _beautifyJson,
                  backgroundColor: Colors.teal,
                  textColor: Colors.white,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.format_align_center, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Beautify'),
                    ],
                  ),
                ),
                CustomElevatedButton(
                  onPressed: _copyResultToClipboard,
                  backgroundColor: AppColors.primary,
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search parameters and values...',
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.labelText),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_isSearching)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _clearSearch,
                            color: AppColors.secondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    if (_isSearching && _searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return InkWell(
                              onTap: () => _selectSearchResult(result),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text(
                                  result,
                                  style: const TextStyle(fontSize: 13, fontFamily: 'JetBrains Mono'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            if (_decodedJson != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
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
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Parameter',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$paramCount',
                              style: const TextStyle(
                                  color: AppColors.primary,
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
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.06),
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
                                    color: AppColors.syntaxType, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Formatted JSON',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.syntaxType,
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
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.06),
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
                                    color: AppColors.syntaxKeyword, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'JSON Viewer',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.syntaxKeyword,
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
