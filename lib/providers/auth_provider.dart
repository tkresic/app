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

    http.Response response = await http.post(
        Uri.parse("${dotenv.env['ACCOUNTS_API_URI']}/login"),
        body: json.encode({
          "username": username
        }),
        headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {

      User authUser = User.fromJson(json.decode(const Utf8Decoder().convert(response.bodyBytes)));

      final Map<String, dynamic> loginData = {
        "grant_type": "password",
        "username": authUser.email,
        "password": password,
        "audience": dotenv.env['AUTH0_AUDIENCE'],
        "client_id": dotenv.env['AUTH0_CLIENT_ID'],
        "client_secret": dotenv.env['AUTH0_CLIENT_SECRET']
      };

      http.Response login = await http.post(
          Uri.parse("${dotenv.env['AUTH0_DOMAIN']}/oauth/token"),
          body: json.encode(loginData),
          headers: {'Content-Type': 'application/json'}
      );

      if (login.statusCode == 200) {

        final Map<String, dynamic> loginData = json.decode(login.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('accessToken', loginData['access_token']);

        authUser.accessToken = loginData['access_token'];

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
          'message': json.decode(login.body)
        };
      }
    } else {
      _loggedInStatus = Status.notLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': "Nepostojeće korisničko ime"
      };
    }
    return result;
  }
}