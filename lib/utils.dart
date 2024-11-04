import 'package:flutter/material.dart';

void navigateToScreen<T>(BuildContext context, T data, Widget Function(T) screenBuilder) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => screenBuilder(data),
    ),
  );
}
