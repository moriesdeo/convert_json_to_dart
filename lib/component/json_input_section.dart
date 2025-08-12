import 'package:flutter/material.dart';

class JsonInputSection extends StatelessWidget {
  final bool isLeft;
  final TextEditingController controller;
  final String errorMessage;

  const JsonInputSection({
    super.key,
    required this.isLeft,
    required this.controller,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, isLeft ? Colors.blue.shade50 : Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (isLeft ? Colors.blueAccent : Colors.greenAccent).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: isLeft ? 'Left JSON Input' : 'Right JSON Input',
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700, 
              color: isLeft ? Colors.blueGrey : Colors.teal,
            ),
            hintText: 'Paste your JSON here',
            errorText: errorMessage.isNotEmpty ? errorMessage : null,
            prefixIcon: Icon(
              Icons.input, 
              color: isLeft ? Colors.blueAccent : Colors.teal,
            ),
          ),
          maxLines: 8,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 15),
        ),
      ),
    );
  }
}
