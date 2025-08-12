import 'package:flutter/material.dart';

import '../CustomElevatedButton.dart';

class ButtonRow extends StatelessWidget {
  final bool isLeft;
  final Function({required bool isLeft}) onPaste;
  final Function({required bool isLeft}) onClear;
  final Function({required bool isLeft}) onCopy;

  const ButtonRow({
    super.key,
    required this.isLeft,
    required this.onPaste,
    required this.onClear,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLeft ? Colors.blueAccent : Colors.teal;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomElevatedButton(
          onPressed: () => onPaste(isLeft: isLeft),
          backgroundColor: Colors.orange,
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
          onPressed: () => onClear(isLeft: isLeft),
          backgroundColor: Colors.red,
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
          onPressed: () => onCopy(isLeft: isLeft),
          backgroundColor: color,
          textColor: Colors.white,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.copy, size: 18, color: Colors.white),
              SizedBox(width: 6),
              Text('Copy'),
            ],
          ),
        ),
      ],
    );
  }
}
