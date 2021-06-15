import 'dart:convert';

class Role {
  int id;
  String name;

  Role({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };

  Role.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  static List<Role> parseRoles(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Role>((json) => Role.fromJson(json)).toList();
  }
}