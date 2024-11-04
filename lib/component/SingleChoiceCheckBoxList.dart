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
    return ListView.builder(
      itemCount: widget.options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final option = widget.options[index];
        return CheckboxListTile(
          value: _selectedOption == option,
          title: Text(option),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (isSelected) {
            if (isSelected == true) {
              _handleOptionSelected(option);
            } else {
              _handleOptionSelected(null);
            }
          },
        );
      },
    );
  }
}
