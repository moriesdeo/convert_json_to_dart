import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonFormatterController extends ChangeNotifier {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String formattedJson = '';
  String errorMessage = '';
  String copyMessage = '';
  Map<String, dynamic>? decodedJson;
  List<String> searchResults = [];
  bool isSearching = false;

  JsonFormatterController() {
    inputController.addListener(_formatJson);
    searchController.addListener(_performSearch);
  }

  void _formatJson() {
    errorMessage = '';
    copyMessage = '';
    searchResults = [];
    isSearching = false;
    try {
      decodedJson = json.decode(inputController.text);
      formattedJson = const JsonEncoder.withIndent('  ').convert(decodedJson);
    } catch (_) {
      formattedJson = '';
      decodedJson = null;
      errorMessage = 'Invalid JSON format';
    }
    notifyListeners();
  }

  Future<void> pasteFromClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        inputController.text = data.text!;
        errorMessage = '';
        copyMessage = '';
        try {
          final decoded = json.decode(data.text!);
          decodedJson = decoded is Map<String, dynamic> ? decoded : null;
          if (decodedJson != null) {
            formattedJson =
                const JsonEncoder.withIndent('  ').convert(decodedJson);
            copyMessage = 'JSON pasted and formatted successfully!';
          }
        } catch (_) {
          formattedJson = '';
          decodedJson = null;
        }
      } else {
        errorMessage = 'Clipboard is empty or inaccessible';
      }
    } catch (e) {
      errorMessage = 'Failed to access clipboard. Please try again.';
    }
    notifyListeners();
  }

  void clearText() {
    inputController.clear();
    searchController.clear();
    formattedJson = '';
    errorMessage = '';
    copyMessage = '';
    decodedJson = null;
    searchResults = [];
    isSearching = false;
    notifyListeners();
  }

  Future<void> copyResultToClipboard() async {
    if (formattedJson.isNotEmpty) {
      try {
        await Clipboard.setData(ClipboardData(text: formattedJson));
        copyMessage = 'Result copied to clipboard!';
      } catch (_) {
        copyMessage = 'Failed to copy result. Please try again.';
      }
      notifyListeners();
    }
  }

  void beautifyJson() {
    if (inputController.text.isNotEmpty) {
      try {
        final decoded = json.decode(inputController.text);
        final beautified = const JsonEncoder.withIndent('  ').convert(decoded);
        inputController.text = beautified;
        formattedJson = beautified;
        decodedJson = decoded is Map<String, dynamic> ? decoded : null;
        errorMessage = '';
        copyMessage = 'JSON beautified successfully!';
      } catch (_) {
        errorMessage = 'Invalid JSON format';
      }
      notifyListeners();
    }
  }

  void _performSearch() {
    final searchTerm = searchController.text.toLowerCase();
    isSearching = searchTerm.isNotEmpty;
    searchResults = [];
    if (searchTerm.isNotEmpty && decodedJson != null) {
      _searchInJson(decodedJson!, '', searchTerm);
    } else if (searchTerm.isEmpty && decodedJson != null) {
      formattedJson = const JsonEncoder.withIndent('  ').convert(decodedJson);
    }
    notifyListeners();
  }

  void _searchInJson(dynamic jsonData, String path, String searchTerm) {
    if (jsonData is Map<String, dynamic>) {
      jsonData.forEach((key, value) {
        final currentPath = path.isEmpty ? key : '$path.$key';
        if (key.toLowerCase().contains(searchTerm)) {
          searchResults.add('$currentPath: ${_getValuePreview(value)}');
        }
        if (value is String && value.toLowerCase().contains(searchTerm)) {
          searchResults.add('$currentPath: "$value"');
        } else if (value is num && value.toString().contains(searchTerm)) {
          searchResults.add('$currentPath: $value');
        } else if (value is bool &&
            value.toString().toLowerCase().contains(searchTerm)) {
          searchResults.add('$currentPath: $value');
        }
        if (value is Map<String, dynamic> || value is List) {
          _searchInJson(value, currentPath, searchTerm);
        }
      });
    } else if (jsonData is List) {
      for (int i = 0; i < jsonData.length; i++) {
        final currentPath = '$path[$i]';
        final item = jsonData[i];
        if (item is String && item.toLowerCase().contains(searchTerm)) {
          searchResults.add('$currentPath: "$item"');
        } else if (item is num && item.toString().contains(searchTerm)) {
          searchResults.add('$currentPath: $item');
        } else if (item is bool &&
            item.toString().toLowerCase().contains(searchTerm)) {
          searchResults.add('$currentPath: $item');
        }
        if (item is Map<String, dynamic> || item is List) {
          _searchInJson(item, currentPath, searchTerm);
        }
      }
    }
  }

  String _getValuePreview(dynamic value) {
    if (value is String) {
      return '"${value.length > 30 ? '${value.substring(0, 27)}...' : value}"';
    }
    if (value is Map) return '{...}';
    if (value is List) return '[...]';
    return value.toString();
  }

  dynamic getNestedData(Map<String, dynamic>? json, List<String> pathSegments) {
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

  void selectParameter(String path) {
    final selectedData = getNestedData(decodedJson, path.split('.'));

    if (selectedData is List && selectedData.isNotEmpty) {
      final firstObject = selectedData.first;
      formattedJson = const JsonEncoder.withIndent('  ').convert(firstObject);
    } else {
      formattedJson = const JsonEncoder.withIndent('  ').convert(selectedData);
    }
    notifyListeners();
  }

  void selectSearchResult(String result) {
    final pathPart = result.split(':').first.trim();

    List<String> segments = [];
    RegExp(r'([^\[\]\.])+').allMatches(pathPart).forEach((match) {
      final segment = match.group(0);
      if (segment != null) {
        segments.add(segment);
      }
    });

    dynamic data = decodedJson;
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

    formattedJson = const JsonEncoder.withIndent('  ').convert(data);
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    isSearching = false;
    searchResults = [];
    if (decodedJson != null) {
      formattedJson = const JsonEncoder.withIndent('  ').convert(decodedJson);
    }
    notifyListeners();
  }
}
