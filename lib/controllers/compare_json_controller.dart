import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompareJsonController {
  final TextEditingController leftController = TextEditingController();
  final TextEditingController rightController = TextEditingController();

  String leftFormattedJson = '';
  String rightFormattedJson = '';

  String leftErrorMessage = '';
  String rightErrorMessage = '';

  String copyMessage = '';

  dynamic leftDecodedJson;
  dynamic rightDecodedJson;

  List<String> differences = [];

  void initControllers(Function setState) {
    leftController.addListener(() => formatJson(isLeft: true, setState: setState));
    rightController.addListener(() => formatJson(isLeft: false, setState: setState));
  }

  void disposeControllers() {
    leftController.dispose();
    rightController.dispose();
  }

  void formatJson({required bool isLeft, required Function setState}) {
    final controller = isLeft ? leftController : rightController;

    setState(() {
      if (isLeft) {
        leftErrorMessage = '';
      } else {
        rightErrorMessage = '';
      }

      copyMessage = '';

      try {
        final decodedJson = json.decode(controller.text);
        final formattedJson = const JsonEncoder.withIndent('  ').convert(decodedJson);

        if (isLeft) {
          leftDecodedJson = decodedJson;
          leftFormattedJson = formattedJson;
        } else {
          rightDecodedJson = decodedJson;
          rightFormattedJson = formattedJson;
        }

        if (leftDecodedJson != null && rightDecodedJson != null) {
          findDifferences();
        }
      } catch (e) {
        if (isLeft) {
          leftFormattedJson = '';
          leftDecodedJson = null;
          leftErrorMessage = 'Invalid JSON format';
        } else {
          rightFormattedJson = '';
          rightDecodedJson = null;
          rightErrorMessage = 'Invalid JSON format';
        }
      }
    });
  }

  void findDifferences() {
    differences = [];

    if (leftDecodedJson == null || rightDecodedJson == null) return;

    // Check for type mismatch at root level
    if (leftDecodedJson.runtimeType != rightDecodedJson.runtimeType) {
      differences.add('Root type mismatch: ${leftDecodedJson.runtimeType} vs ${rightDecodedJson.runtimeType}');
      return;
    }

    // Handle Maps
    if (leftDecodedJson is Map<String, dynamic> && rightDecodedJson is Map<String, dynamic>) {
      // Compare root level keys
      final leftKeys = (leftDecodedJson as Map<String, dynamic>).keys.toSet();
      final rightKeys = (rightDecodedJson as Map<String, dynamic>).keys.toSet();

      final missingInRight = leftKeys.difference(rightKeys);
      final missingInLeft = rightKeys.difference(leftKeys);

      for (var key in missingInRight) {
        differences.add('Key "$key" exists in left JSON but missing in right JSON');
      }

      for (var key in missingInLeft) {
        differences.add('Key "$key" exists in right JSON but missing in left JSON');
      }

      // Compare common keys
      final commonKeys = leftKeys.intersection(rightKeys);
      for (var key in commonKeys) {
        compareValues(key, leftDecodedJson[key], rightDecodedJson[key], path: key);
      }
    } 
    // Handle Lists
    else if (leftDecodedJson is List && rightDecodedJson is List) {
      final leftList = leftDecodedJson as List;
      final rightList = rightDecodedJson as List;

      if (leftList.length != rightList.length) {
        differences.add('Root array length mismatch: ${leftList.length} vs ${rightList.length}');
      }

      final minLength = leftList.length < rightList.length ? leftList.length : rightList.length;

      for (var i = 0; i < minLength; i++) {
        compareValues('[$i]', leftList[i], rightList[i], path: '[$i]');
      }
    }
  }

  void compareValues(String key, dynamic leftValue, dynamic rightValue, {required String path}) {
    // Different types
    if (leftValue.runtimeType != rightValue.runtimeType) {
      differences.add('Value type mismatch at "$path": ${leftValue.runtimeType} vs ${rightValue.runtimeType}');
      return;
    }

    // Recursive compare for maps
    if (leftValue is Map && rightValue is Map) {
      final leftKeys = leftValue.keys.toSet();
      final rightKeys = rightValue.keys.toSet();

      final missingInRight = leftKeys.difference(rightKeys);
      final missingInLeft = rightKeys.difference(leftKeys);

      for (var key in missingInRight) {
        differences.add('Key "$key" exists in left JSON but missing in right JSON at "$path"');
      }

      for (var key in missingInLeft) {
        differences.add('Key "$key" exists in right JSON but missing in left JSON at "$path"');
      }

      final commonKeys = leftKeys.intersection(rightKeys);
      for (var key in commonKeys) {
        compareValues(key.toString(), leftValue[key], rightValue[key], path: '$path.$key');
      }
    }
    // Recursive compare for lists
    else if (leftValue is List && rightValue is List) {
      if (leftValue.length != rightValue.length) {
        differences.add('Array length mismatch at "$path": ${leftValue.length} vs ${rightValue.length}');
      }

      final minLength = leftValue.length < rightValue.length ? leftValue.length : rightValue.length;

      for (var i = 0; i < minLength; i++) {
        compareValues('[$i]', leftValue[i], rightValue[i], path: '$path[$i]');
      }
    }
    // Compare primitive values
    else if (leftValue != rightValue) {
      differences.add('Value mismatch at "$path": $leftValue vs $rightValue');
    }
  }

  Future<void> pasteFromClipboard({required bool isLeft, required Function setState}) async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        setState(() {
          if (isLeft) {
            leftController.text = data.text ?? '';
            leftErrorMessage = '';
            copyMessage = '';
            formatJson(isLeft: true, setState: setState);
          } else {
            rightController.text = data.text ?? '';
            rightErrorMessage = '';
            copyMessage = '';
            formatJson(isLeft: false, setState: setState);
          }
          copyMessage = '';
        });
      } else {
        setState(() {
          if (isLeft) {
            leftErrorMessage = 'Clipboard is empty or inaccessible';
          } else {
            rightErrorMessage = 'Clipboard is empty or inaccessible';
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isLeft) {
          leftErrorMessage = 'Failed to access clipboard. Please try again.';
        } else {
          rightErrorMessage = 'Failed to access clipboard. Please try again.';
        }
      });
      debugPrint('Clipboard error: $e');
    }
  }

  void clearText({required bool isLeft, required Function setState}) {
    setState(() {
      if (isLeft) {
        leftController.clear();
        leftFormattedJson = '';
        leftErrorMessage = '';
        leftDecodedJson = null;
      } else {
        rightController.clear();
        rightFormattedJson = '';
        rightErrorMessage = '';
        rightDecodedJson = null;
      }
      copyMessage = '';
      differences = [];
    });
  }

  Future<void> copyResultToClipboard({required bool isLeft, required Function setState}) async {
    final formattedJson = isLeft ? leftFormattedJson : rightFormattedJson;

    if (formattedJson.isNotEmpty) {
      try {
        await Clipboard.setData(ClipboardData(text: formattedJson));
        setState(() {
          copyMessage = 'JSON copied to clipboard!';
        });
      } catch (e) {
        setState(() {
          copyMessage = 'Failed to copy result. Please try again.';
        });
      }
    }
  }
}
