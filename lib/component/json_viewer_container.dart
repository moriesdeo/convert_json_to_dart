import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

class JsonViewerContainer extends StatelessWidget {
  final bool isLeft;
  final Map<String, dynamic>? decodedJson;
  final String formattedJson;
  final Function(String) buildColoredJson;

  const JsonViewerContainer({
    super.key,
    required this.isLeft,
    required this.decodedJson,
    required this.formattedJson,
    required this.buildColoredJson,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isLeft ? Colors.deepPurple : Colors.teal;
    final titleIcon = isLeft ? Icons.format_align_left : Icons.format_align_right;
    final titleText = isLeft ? 'Left JSON' : 'Right JSON';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: titleColor.withOpacity(0.06),
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
            Row(
              children: [
                Icon(titleIcon, color: titleColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    fontSize: 15
                  ),
                ),
              ],
            ),
            const Divider(height: 18, thickness: 1),
            Expanded(
              child: decodedJson != null
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        // Formatted text view
                        SelectableText.rich(
                          buildColoredJson(formattedJson),
                          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        // Tree view
                        JsonViewer(decodedJson!),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      'No valid JSON',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.normal),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
