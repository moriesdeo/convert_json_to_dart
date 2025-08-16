import 'package:flutter/material.dart';

import '../component/custom_text.dart';

class ReusableDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final bool showYesNoButtons;
  final VoidCallback? onYes;
  final VoidCallback? onNo;

  const ReusableDialog({
    super.key,
    required this.title,
    required this.content,
    this.showYesNoButtons = false,
    this.onYes,
    this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText.title(title),
                const SizedBox(height: 16),
                content,
                const SizedBox(height: 24),
                if (showYesNoButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onNo?.call();
                        },
                        child: const CustomText(text: 'No'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onYes?.call();
                        },
                        child: const CustomText(text: 'Yes'),
                      ),
                    ],
                  )
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )
        ],
      ),
    );
  }
}
