import 'package:flutter/material.dart';

class SingleChoiceCheckBoxList extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String?> onSelected;

  const SingleChoiceCheckBoxList({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  _SingleChoiceCheckBoxListState createState() => _SingleChoiceCheckBoxListState();
}

class _SingleChoiceCheckBoxListState extends State<SingleChoiceCheckBoxList> {
  String? _selectedOption;

  void _handleOptionSelected(String? option) {
    setState(() {
      _selectedOption = option;
    });
    widget.onSelected(option);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: widget.options.map((option) {
        final isSelected = _selectedOption == option;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _handleOptionSelected(isSelected ? null : option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1).withOpacity(0.08) : Colors.white,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(Icons.check, size: 14, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    option,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF334155),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
