import 'package:flutter/material.dart';

mixin CustomSnackBar {

  SnackBar getCustomSnackBar(String text, Color color) {
    return SnackBar(
        width: 300.0,
        behavior: SnackBarBehavior.floating,
        content: Text(text),
        backgroundColor: color
    );
  }
}