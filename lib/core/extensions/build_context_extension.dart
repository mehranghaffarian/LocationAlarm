import 'package:flutter/material.dart';

extension ShowSnack on BuildContext{
  void showSnack(String message, Color color) =>  ScaffoldMessenger.of(this).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}