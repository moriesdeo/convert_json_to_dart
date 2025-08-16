import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

import 'CustomElevatedButton.dart';
import 'constants/app_colors.dart';
import 'controllers/json_formatter_controller.dart';

class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({super.key});

  @override
  _JsonFormatterPageState createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> {
  late final JsonFormatterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = JsonFormatterController();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _pasteFromClipboard() async {
    await _controller.pasteFromClipboard();
  }

  void _clearText() {
    _controller.clearText();
  }

  void _copyResultToClipboard() async {
    await _controller.copyResultToClipboard();
  }

  void _beautifyJson() {
    _controller.beautifyJson();
  }

  List<Widget> _buildParameterButtons(Map<String, dynamic> json,
      [String path = '']) {
    List<Widget> buttons = [];
    json.forEach((key, value) {
      final fullPath = path.isEmpty ? key : '$path.$key';

      if (value is Map<String, dynamic> ||
          (value is List && value.isNotEmpty && value.first is Map)) {
        buttons.add(
          CustomElevatedButton(
            onPressed: () => _controller.selectParameter(fullPath),
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

  List<Widget> _buildArrayParameterButtons(List jsonArray, [String path = '']) {
    List<Widget> buttons = [];

    // Add buttons for array indexes
    for (int i = 0; i < jsonArray.length; i++) {
      final indexPath = path.isEmpty ? '$i' : '$path.$i';
      buttons.add(
        CustomElevatedButton(
          onPressed: () => _controller.selectParameter(indexPath),
          text: '[$i]',
        ),
      );

      // If the array element is an object, add buttons for its keys
      if (jsonArray[i] is Map<String, dynamic> && i == 0) {
        // Only show keys from the first object to avoid too many buttons
        Map<String, dynamic> firstObject = jsonArray[i];
        firstObject.forEach((key, value) {
          final fullPath = '$indexPath.$key';
          buttons.add(
            CustomElevatedButton(
              onPressed: () => _controller.selectParameter(fullPath),
              text: '[$i].$key',
            ),
          );
        });
      }
    }

    return buttons;
  }

  TextSpan _buildColoredJson(String json) {
    final List<TextSpan> spans = [];
    final regExp = RegExp(
        r'(".*?":)|(:)|(\d+)|(".*?")|(\[)|(\])|(\{)|(\})|(\btrue\b|\bfalse\b)');

    int lastMatchEnd = 0;

    for (var match in regExp.allMatches(json)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: json.substring(lastMatchEnd, match.start)));
      }

      final matchText = match.group(0)!;

      if (matchText == '{' || matchText == '}') {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600)));
      } else if (matchText == '[' || matchText == ']') {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.secondary, fontWeight: FontWeight.w600)));
      } else if (matchText.endsWith('":')) {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.syntaxType, fontWeight: FontWeight.w600)));
      } else if (matchText.startsWith('"') && matchText.endsWith('"')) {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.syntaxKeyword, fontWeight: FontWeight.w600)));
      } else if (RegExp(r'^\d+$').hasMatch(matchText)) {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.syntaxDefault, fontWeight: FontWeight.w600)));
      } else if (matchText == 'true' || matchText == 'false') {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.secondary, fontWeight: FontWeight.w600)));
      } else {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(color: AppColors.bodyText)));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < json.length) {
      spans.add(TextSpan(text: json.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }



  void _selectSearchResult(String result) {
    _controller.selectSearchResult(result);
  }

  void _clearSearch() {
    _controller.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> paramButtons = <Widget>[];
    if (_controller.rootJson != null) {
      if (_controller.rootJson is Map<String, dynamic>) {
        paramButtons = _buildParameterButtons(_controller.rootJson);
      } else if (_controller.rootJson is List && _controller.rootJson.isNotEmpty) {
        // For arrays, create buttons for each index and show keys of first object if possible
        paramButtons = _buildArrayParameterButtons(_controller.rootJson);
      }
    }
    final paramCount = paramButtons.length;

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
                  controller: _controller.inputController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Enter JSON',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.labelText),
                    hintText: 'Paste your JSON here',
                    errorText: _controller.errorMessage.isNotEmpty
                        ? _controller.errorMessage
                        : null,
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
            if (_controller.rootJson != null)
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
                            controller: _controller.searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search parameters and values...',
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.labelText),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_controller.isSearching)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _clearSearch,
                            color: AppColors.secondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    if (_controller.isSearching &&
                        _controller.searchResults.isNotEmpty)
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
                          itemCount: _controller.searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _controller.searchResults[index];
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
            if (_controller.rootJson != null)
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
                      ParameterHeader(title: 'Parameter', count: paramCount),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: paramButtons
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
                                  _buildColoredJson(_controller.formattedJson),
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
                              child: _controller.rootJson != null
                                  ? SingleChildScrollView(
                                      child: _controller.rootJson is Map<String, dynamic>
                                          ? JsonViewer(_controller.rootJson)
                                          : SelectableText(
                                              const JsonEncoder.withIndent('  ').convert(_controller.rootJson),
                                              style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14),
                                            ),
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
            if (_controller.copyMessage.isNotEmpty)
              AnimatedOpacity(
                opacity: _controller.copyMessage.isNotEmpty ? 1.0 : 0.0,
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
                        _controller.copyMessage,
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

class ParameterHeader extends StatelessWidget {
  final String title;
  final int count;

  const ParameterHeader({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.list_alt, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 15),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
      ],
    );
  }
}