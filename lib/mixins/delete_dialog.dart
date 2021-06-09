import 'package:flutter/material.dart';

mixin DeleteDialog {
  void deleteDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("Odustani", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Obriši", style: TextStyle(color: Colors.red)),
              onPressed: () {
                // TODO => Delete API and snackbar for successful deletion
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}