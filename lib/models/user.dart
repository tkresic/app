import 'role.dart';

class User {
  int id;
  String name;
  String username;
  Role role;
  String? token;
  String? renewalToken;

  User({required this.id, required this.username, required this.name, required this.role, this.token, this.renewalToken});

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'role': role.toJson(),
    'token': token,
    'renewalToken': renewalToken,
  };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        name = json['name'],
        role = Role.fromJson(json['role']),
        token = json['token'],
        renewalToken = json['renewalToken'];
}