import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

mixin DeleteDialog {

  bool error = false;
  bool success = false;

  Future<bool> deleteEntity(String uri) async {
    var response = await http.delete(Uri.parse(uri));
    return jsonDecode(response.body);
  }

  Future<bool> deleteDialog(BuildContext context, String title, String content, String uri, String message) async {
    bool fetchAgain = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("Odustani", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Obriši", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                bool response = await deleteEntity(uri);
                if (!response) {
                  error = true;
                } else {
                  success = true;
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      bool fetchAgain = success;
      // TODO => Slice snackbar.
      if (error) {
        final snackBar = SnackBar(
          width: 300.0,
          behavior: SnackBarBehavior.floating,
          content: const Text("Došlo je do greške"),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (success) {
        final snackBar = SnackBar(
          width: 300.0,
          behavior: SnackBarBehavior.floating,
          content: Text(message),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      success = false;
      error = false;
      return fetchAgain;
    });
    return fetchAgain;
  }
}