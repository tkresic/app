import 'package:flutter/material.dart';

class SwitchState extends StatefulWidget {
  const SwitchState({
    Key? key,
    required this.entity,
  }) : super(key: key);

  final dynamic entity;

  @override
  _SwitchState createState() => _SwitchState(entity: entity);
}

class _SwitchState extends State<SwitchState> {
  _SwitchState({
    required this.entity,
  });

  dynamic entity;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: entity.active,
      onChanged: (value) {
        setState(() {
          entity.active = value;
        });
      },
      activeTrackColor: Colors.orangeAccent,
      activeColor: Colors.orange,
    );
  }
}

