import 'package:app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    String? object = prefs.getString("user");

    if (object != null) {
      return User.fromJson(json.decode(object));
    } else {
      return null;
    }
  }

  read(String key) async {
    final prefs = await SharedPreferences.getInstance();

    String? object = prefs.getString(key);

    if (object != null) {
      return json.decode(object);
    } else {
      return null;
    }
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}