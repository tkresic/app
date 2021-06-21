import 'dart:convert';
import 'role.dart';

class User {
  int? id;
  String username;
  String name;
  String surname;
  String email;
  int? roleId;
  Role? role;
  String? accessToken;
  String? renewalToken;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.roleId,
    required this.role,
    this.accessToken,
    this.renewalToken
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'surname': surname,
    'email': email,
    'roleId': roleId,
    'role': role!.toJson(),
    'token': accessToken,
    'renewalToken': renewalToken,
  };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        name = json['name'],
        surname = json['surname'],
        email = json['email'],
        roleId = Role.fromJson(json['role']).id,
        role = Role.fromJson(json['role']),
        accessToken = json['accessToken'],
        renewalToken = json['renewalToken'];

  static List<User> parseUsers(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }
}