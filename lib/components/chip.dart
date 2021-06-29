import 'package:flutter/material.dart';

class ChipState extends StatelessWidget {
  ChipState({
    required this.active,
  });

  bool active;

  @override
  Widget build(BuildContext context) {
    return active ?
    const Chip(
        label: Text('Da', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      )
      :
      const Chip(
        label: Text('Ne', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      );
  }
}

