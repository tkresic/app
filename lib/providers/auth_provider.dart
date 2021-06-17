import 'dart:async';
import 'dart:convert';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  notLoggedIn,
  authenticating,
  loggedIn,
  loggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.notLoggedIn;
  Status get loggedInStatus => _loggedInStatus;

  Future<Map<String, dynamic>> login(String username, String password) async {
    _loggedInStatus = Status.authenticating;
    notifyListeners();

    Map<String, dynamic> result;

    final Map<String, dynamic> loginData = {
      "grant_type": "password",
      "username": username,
      "password": password,
      "audience": dotenv.env['AUTH0_AUDIENCE'],
      "client_id": dotenv.env['AUTH0_CLIENT_ID'],
      "client_secret": dotenv.env['AUTH0_CLIENT_SECRET']
    };

    http.Response response = await http.post(
      Uri.parse("${dotenv.env['AUTH0_DOMAIN']}/oauth/token"),
      body: json.encode(loginData),
      headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {

      final Map<String, dynamic> responseData = json.decode(response.body);

      // TODO => Switch to flutter secure storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', responseData['access_token']);

      // TODO => Get user data from accounts or transfer the login to accounts and return the user with login
      final Map<String, dynamic> userData = {
        "id": 1,
        "username": "tkresic",
        "name": "Toni",
        "surname": "Krešić",
        "role": {
          "id": 1,
          "name": "Administrator"
        },
        "accessToken": responseData['access_token'],
        "renewalToken": "token_renewal_example" // TODO => Remove
      };

      User authUser = User.fromJson(userData);
      SharedPref sharedPref = SharedPref();
      sharedPref.save("user", authUser);

      _loggedInStatus = Status.loggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.notLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)
      };
    }
    return result;
  }
}