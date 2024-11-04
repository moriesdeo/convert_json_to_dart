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
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _dartClass = '';
  String _filteredDartClass = '';
  bool _isNullable = false;
  bool _hasDefaultValue = false;
  bool _hasDefaultValueNull = false;
  bool _hasDefaultValueDummy = false;

  void _updateDefaultOption(String? selectedOption) {
    setState(() {
      _hasDefaultValueNull = selectedOption == 'Default Value Null';
      _hasDefaultValueDummy = selectedOption == 'Default Value Dummy';
    });
  }

  void _convertJsonToDart() {
    final jsonString = _jsonController.text;
    final className = _classNameController.text;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final dartClass = jsonToDart(
        className,
        jsonMap,
        nullable: _isNullable,
        defaultValue: _hasDefaultValueDummy,
      );

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

      // Menggunakan `useDummyDefaults` berdasarkan pilihan pengguna
      final kotlinClass = jsonToKotlin(
        className,
        jsonMap,
        useDummyDefaults: _hasDefaultValueDummy,
      );

      setState(() {
        _dartClass = kotlinClass;
        _filteredDartClass = kotlinClass;
      });
    } catch (e) {
      setState(() {
        _dartClass = 'Invalid JSON format';
        _filteredDartClass = 'Invalid JSON format';
      });
    }
  }

  void _convertJsonToJava() {
    final jsonString = _jsonController.text;
    final className = _classNameController.text;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      // Menggunakan `useDummyDefaults` berdasarkan pilihan pengguna
      final javaClass = jsonToJava(
        className,
        jsonMap,
        useDummyDefaults: _hasDefaultValueDummy,
      );

      setState(() {
        _dartClass = javaClass;
        _filteredDartClass = javaClass;
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

  void _toJsonFormatter() {
    navigateToScreen(
      context,
      '',
      (data) => const JsonFormatterPage(),
    );
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
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _classNameController,
                    labelText: 'Class Name',
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _jsonController,
                          labelText: 'Enter JSON',
                          maxLines: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          _buildIconButton(
                            icon: Icons.paste,
                            onPressed: _pasteFromClipboard,
                            tooltip: 'Paste Input',
                          ),
                          _buildIconButton(
                            icon: Icons.clear,
                            onPressed: _clearInput,
                            tooltip: 'Clear Input',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildHorizontalButtonRow(),
                  const SizedBox(height: 20),
                  SingleChoiceCheckBoxList(
                    options: ['Default Value Null', 'Default Value Dummy'],
                    onSelected: _updateDefaultOption,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _searchController,
                          labelText: 'Search in Result',
                          onChanged: _filterResults,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildIconButton(
                        icon: Icons.clear,
                        onPressed: _clearSearch,
                        tooltip: 'Clear Search',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildResultContainer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildHorizontalButtonRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomElevatedButton(
            onPressed: _convertJsonToDart,
            text: 'Convert to Dart',
          ),
          const SizedBox(width: 15),
          CustomElevatedButton(
            onPressed: _convertJsonToKotlin,
            text: 'Convert to Kotlin',
          ),
          const SizedBox(width: 15),
          CustomElevatedButton(
            onPressed: _convertJsonToJava,
            text: 'Convert to Java',
          ),
          const SizedBox(width: 15),
          CustomElevatedButton(
            onPressed: _copyToClipboard,
            text: 'Copy Result',
          ),
          const SizedBox(width: 15),
          CustomElevatedButton(
            onPressed: _toJsonFormatter,
            text: 'JSON Formatter',
          ),
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
    final lines = text.split('\n');

    for (var line in lines) {
      final words = line.split(' ');

      for (var word in words) {
        if (_isClassName(word)) {
          spans.add(TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600), // Warna untuk nama kelas
          ));
        } else if (_isType(word)) {
          spans.add(TextSpan(
            text: '$word ',
            style: const TextStyle(
                color: Colors.purple, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600), // Warna untuk tipe data
          ));
        } else if (_isParameter(word)) {
          spans.add(TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600), // Warna untuk parameter
          ));
        } else {
          spans.add(TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600), // Warna default hitam
          ));
        }
      }
      spans.add(const TextSpan(text: '\n')); // Baris baru di akhir setiap baris
    }

    return TextSpan(children: spans);
  }

  bool _isClassName(String word) {
    return RegExp(r'^[A-Z]').hasMatch(word); // Misal: nama kelas dimulai dengan huruf besar
  }

  bool _isType(String word) {
    const types = ['int', 'double', 'String', 'bool', 'List', 'Map'];
    return types.contains(word); // Misal: tipe data dasar
  }

  bool _isParameter(String word) {
    return RegExp(r'^[a-z]').hasMatch(word) && !_isType(word); // Parameter mulai dengan huruf kecil
  }
}

class CheckBoxItem {
  final String title;
  bool isChecked;

  CheckBoxItem({required this.title, this.isChecked = false});
}

class CheckBoxList extends StatefulWidget {
  final ValueChanged<String?> onCheckList;

  const CheckBoxList({super.key, required this.onCheckList});

  @override
  State<CheckBoxList> createState() => _CheckBoxListState();
}

class _CheckBoxListState extends State<CheckBoxList> {
  final List<CheckBoxItem> _listCheckBox = [
    CheckBoxItem(title: 'Nullable'),
    // CheckBoxItem(title: 'Default Value'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _listCheckBox.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = _listCheckBox[index];
        return CheckboxListTile(
          value: item.isChecked,
          title: Text(item.title),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            setState(() {
              for (var checkBoxItem in _listCheckBox) {
                checkBoxItem.isChecked = false;
              }
              item.isChecked = value ?? false;
            });
            widget.onCheckList(
              item.isChecked ? item.title : null,
            );
          },
        );
      },
    );
  }
}
