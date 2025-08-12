import 'dart:convert';

import 'package:convert_json_to_class_dart/CustomElevatedButton.dart';
import 'package:convert_json_to_class_dart/compare_json.dart';
import 'package:convert_json_to_class_dart/format_json.dart';
import 'package:convert_json_to_class_dart/json_to_golang.dart';
import 'package:convert_json_to_class_dart/json_to_java.dart';
import 'package:convert_json_to_class_dart/json_to_kotlin.dart';
import 'package:convert_json_to_class_dart/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'component/SingleChoiceCheckBoxList.dart';
import 'constants/app_colors.dart';
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

  void _convertJsonToGolang() =>
      _convertJson((className, jsonMap) => jsonToGolang(
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
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.data_object,
                  color: Colors.white.withOpacity(0.95), size: 24),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  // Show info dialog or help
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Convert JSON to classes in various languages')),
                  );
                },
                tooltip: 'Help',
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.scaffoldBackground,
                  AppColors.inputBackground,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'Generate Classes from JSON',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.titleText,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.class_,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Class Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                                _classNameController, 'Enter class name'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.code,
                                        size: 20, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'JSON Input',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.paste_rounded,
                                          color: Colors.grey.shade700),
                                      onPressed: _pasteFromClipboard,
                                      tooltip: 'Paste from clipboard',
                                      splashRadius: 20,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.clear_rounded,
                                          color: Colors.grey.shade700),
                                      onPressed: _clearInput,
                                      tooltip: 'Clear input',
                                      splashRadius: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: _buildTextField(
                                  _jsonController,
                                  'Paste your JSON here...',
                                  maxLines: 10,
                                  codeStyle: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                _buildHorizontalButtonRow(),
                const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.settings,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Options',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SingleChoiceCheckBoxList(
                              options: const [
                                'Default Value Null',
                                'Default Value Dummy'
                              ],
                              onSelected: _updateDefaultOption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.search,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Search Result',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          child: Icon(Icons.search,
                                              color: Colors.grey.shade600,
                                              size: 20),
                                        ),
                                        Expanded(
                                          child: _buildTextField(
                                            _searchController,
                                            'Filter results...',
                                            onChanged: _filterResults,
                                            borderless: true,
                                          ),
                                        ),
                                        if (_searchController.text.isNotEmpty)
                                          IconButton(
                                            icon: const Icon(Icons.clear,
                                                size: 18),
                                            onPressed: _clearSearch,
                                            color: Colors.grey.shade600,
                                            splashRadius: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                _buildResultContainer(),
              ],
            ),
          ),
        ),
      ),
        ));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    int maxLines = 1,
    void Function(String)? onChanged,
    bool codeStyle = false,
    bool borderless = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: labelText,
        border: borderless ? InputBorder.none : null,
        enabledBorder: borderless ? InputBorder.none : null,
        focusedBorder: borderless ? InputBorder.none : null,
        labelStyle:
            TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        isDense: true,
        filled: !borderless,
        fillColor: borderless ? Colors.transparent : Colors.white,
      ),
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: codeStyle ? 'JetBrains Mono' : 'Inter',
        fontSize: codeStyle ? 14 : 15,
        color: AppColors.titleText,
      ),
    );
  }

  Widget _buildHorizontalButtonRow() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.transform, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CustomElevatedButton(
                    onPressed: _convertJsonToDart,
                    text: 'Convert to Dart',
                    backgroundColor: AppColors.syntaxKeyword,
                    child: const Row(
                      children: [
                        Icon(Icons.data_object, size: 18),
                        SizedBox(width: 8),
                        Text('Convert to Dart'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomElevatedButton(
                    onPressed: _convertJsonToKotlin,
                    text: 'Convert to Kotlin',
                    backgroundColor: AppColors.focusBorder,
                    child: const Row(
                      children: [
                        Icon(Icons.data_object, size: 18),
                        SizedBox(width: 8),
                        Text('Convert to Kotlin'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomElevatedButton(
                    onPressed: _convertJsonToJava,
                    text: 'Convert to Java',
                    backgroundColor: AppColors.syntaxDefault,
                    child: const Row(
                      children: [
                        Icon(Icons.data_object, size: 18),
                        SizedBox(width: 8),
                        Text('Convert to Java'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomElevatedButton(
                    onPressed: _convertJsonToGolang,
                    text: 'Convert to Golang',
                    backgroundColor: AppColors.syntaxDefault,
                    child: const Row(
                      children: [
                        Icon(Icons.data_object, size: 18),
                        SizedBox(width: 8),
                        Text('Convert to Golang'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomElevatedButton(
                    onPressed: _copyToClipboard,
                    text: 'Copy Result',
                    backgroundColor: AppColors.focusBorder,
                    child: const Row(
                      children: [
                        Icon(Icons.copy, size: 18),
                        SizedBox(width: 8),
                        Text('Copy Result'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomElevatedButton(
                    onPressed: () => navigateToScreen(
                        context, '', (_) => const JsonFormatterPage()),
                    backgroundColor: AppColors.secondary,
                    text: 'JSON Formatter',
                    child: const Row(
                      children: [
                        Icon(Icons.format_align_left, size: 18),
                        SizedBox(width: 8),
                        Text('JSON Formatter'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomElevatedButton(
                    onPressed: () => navigateToScreen(
                        context, '', (_) => const CompareJson()),
                    backgroundColor: AppColors.syntaxType,
                    text: 'JSON Compare',
                    child: const Row(
                      children: [
                        Icon(Icons.format_align_left, size: 18),
                        SizedBox(width: 8),
                        Text('JSON Compare'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContainer() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Generated Code',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                  onPressed: _copyToClipboard,
                  tooltip: 'Copy to clipboard',
                  splashRadius: 20,
                ),
              ],
            ),
            const Divider(),
            Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(16.0),
              child: SelectableText.rich(
                _buildColoredText(_filteredDartClass),
                style:
                    const TextStyle(fontSize: 15, fontFamily: 'JetBrains Mono'),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
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
      return const TextStyle(
          color: AppColors.primary, fontWeight: FontWeight.w600);
    } else if (_isType(word)) {
      return const TextStyle(
          color: AppColors.syntaxType,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600);
    } else if (_isParameter(word)) {
      return const TextStyle(
          color: AppColors.syntaxParameter, fontWeight: FontWeight.w600);
    } else if (_isKeyword(word)) {
      return const TextStyle(
          color: AppColors.syntaxKeyword, fontWeight: FontWeight.w600);
    } else {
      return const TextStyle(
          color: AppColors.syntaxDefault, fontWeight: FontWeight.w600);
    }
  }

  bool _isClassName(String word) => RegExp(r'^[A-Z]').hasMatch(word);

  bool _isType(String word) => [
        'int',
        'double',
        'String',
        'bool',
        'List',
        'Map',
        'final',
        'var',
        'void'
      ].contains(word);

  bool _isKeyword(String word) => [
        'class',
        'extends',
        'implements',
        'required',
        'const',
        'static',
        'get',
        'set',
        'function',
        'return',
        'import',
        'export',
        'package',
        'new',
        'this',
        'super'
      ].contains(word);

  bool _isParameter(String word) =>
      RegExp(r'^[a-z]').hasMatch(word) && !_isType(word) && !_isKeyword(word);
}
