import 'package:flutter/material.dart';

import '../widgets/reusable_dialog.dart';

class DifferencesSection extends StatelessWidget {
  final List<String> differences;

  const DifferencesSection({
    super.key,
    required this.differences,
  });

  void _showAllDifferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ReusableDialog(
        title: 'All Differences',
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: differences.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, color: Colors.redAccent),
                    Expanded(
                      child: Text(
                        differences[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: InkWell(
          onTap: differences.isNotEmpty
              ? () => _showAllDifferencesDialog(context)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.difference,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Differences',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (differences.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${differences.length}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 18, thickness: 1),
              differences.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No differences found or invalid JSON',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: differences
                          .take(3) // show only first 3 as preview
                          .map(
                            (diff) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.arrow_right,
                                      color: Colors.redAccent),
                                  Expanded(
                                    child: Text(diff,
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}