import 'dart:async';
import 'dart:convert';

import 'package:app/util/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:app/models/user.dart';

enum Status {
  NotLoggedIn,
  Authenticating,
  LoggedIn,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status get loggedInStatus => _loggedInStatus;

  Future<Map<String, dynamic>> login(String username, String password) async {
    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    var result;

    // TODO => Send username instead of email
    final Map<String, dynamic> loginData = {
      "email": username,
      "password": password
    };

    // TODO => Replace URI
    Response response = await post(
      Uri.parse("https://admin.fenjer.hr/api/auth/login"),
      body: json.encode(loginData),
      headers: {'Content-Type': 'application/json', 'api-key': '4Nih8908KDKBfHBzyaMBcSGtjYfqOXON6xIlgxLJMU0Q6Lc9BUn6xBbdl3cOqNQ9w8TXTIYiB1MZImikAX7xbZGyjOz3LEb4mtsbLjupQqLEDurQDoTcwstVix4ffmMP'},
    );

    // Example with paginated resources TODO => Products provider
    Response responseProducts = await get(
      Uri.parse("https://admin.fenjer.hr/api/categories/bozic"),
      headers: {'Content-Type': 'application/json', 'api-key': '4Nih8908KDKBfHBzyaMBcSGtjYfqOXON6xIlgxLJMU0Q6Lc9BUn6xBbdl3cOqNQ9w8TXTIYiB1MZImikAX7xbZGyjOz3LEb4mtsbLjupQqLEDurQDoTcwstVix4ffmMP'},
    );

    final Map<String, dynamic> responseProductsData = json.decode(responseProducts.body);

    if (response.statusCode == 200) {
      // TODO => Not used
      // final Map<String, dynamic> responseData = json.decode(response.body);

      // TODO => Replace with real data
      // var userData = responseData['data'];

      final Map<String, dynamic> userData = {
        "id": 1,
        "username": "tkresic",
        "type": "employee",
        "token": "token_example",
        "renewalToken": "token_renewal_example"
      };

      User authUser = User.fromJson(userData);

      SharedPref sharedPref = SharedPref();
      sharedPref.save("user", authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)
      };
    }
    return result;
  }
}