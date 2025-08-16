import 'package:flutter/material.dart';

import 'component/button_row.dart';
import 'component/differences_section.dart';
import 'component/json_input_section.dart';
import 'component/json_viewer_container.dart';
import 'constants/app_colors.dart';
import 'controllers/compare_json_controller.dart';
import 'utils/json_formatter.dart';

class CompareJson extends StatefulWidget {
  const CompareJson({super.key});

  @override
  State<CompareJson> createState() => _CompareJsonState();
}

class _CompareJsonState extends State<CompareJson> {
  final CompareJsonController _controller = CompareJsonController();

  @override
  void initState() {
    super.initState();
    _controller.initControllers((fn) => setState(fn));
  }

  @override
  void dispose() {
    _controller.disposeControllers();
    super.dispose();
  }


  TextSpan _buildColoredJson(String json) {
    return JsonFormatter.buildColoredJson(json);
  }

  Widget _buildJsonInputSection({required bool isLeft}) {
    final controller = isLeft ? _controller.leftController : _controller.rightController;
    final errorMessage = isLeft ? _controller.leftErrorMessage : _controller.rightErrorMessage;

    return JsonInputSection(
      isLeft: isLeft,
      controller: controller,
      errorMessage: errorMessage,
    );
  }

  Widget _buildButtonRow({required bool isLeft}) {
    return ButtonRow(
      isLeft: isLeft,
      onPaste: ({required bool isLeft}) => _controller.pasteFromClipboard(isLeft: isLeft, setState: (fn) => setState(fn)),
      onClear: ({required bool isLeft}) => _controller.clearText(isLeft: isLeft, setState: (fn) => setState(fn)),
      onCopy: ({required bool isLeft}) => _controller.copyResultToClipboard(isLeft: isLeft, setState: (fn) => setState(fn)),
    );
  }

  Widget _buildJsonViewer({required bool isLeft}) {
    final decodedJson = isLeft ? _controller.leftDecodedJson : _controller.rightDecodedJson;
    final formattedJson = isLeft ? _controller.leftFormattedJson : _controller.rightFormattedJson;

    return JsonViewerContainer(
      isLeft: isLeft,
      decodedJson: decodedJson,
      formattedJson: formattedJson,
      buildColoredJson: _buildColoredJson,
    );
  }

  Widget _buildDifferencesSection() {
    return DifferencesSection(differences: _controller.differences);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'JSON Comparator',
              style: TextStyle(
                color: AppColors.titleText,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5
              ),
            ),
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
                          if (_controller.copyMessage.isNotEmpty)
              AnimatedOpacity(
                opacity: _controller.copyMessage.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _controller.copyMessage,
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
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
