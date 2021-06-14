import 'package:flutter/material.dart';

class Loader extends StatefulWidget {
  const Loader({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  LoaderState createState() => LoaderState();
}

class LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.message),
            const SizedBox(width: 10),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)),
                height: 15.0,
                width: 15.0,
              ),
            )
          ]
        )
      )
    );
  }
}