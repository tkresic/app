class User {
  int id;
  String name;
  String username;
  String? type;
  String? token;
  String? renewalToken;

  User({required this.id, required this.username, required this.name, required this.type, this.token, this.renewalToken});

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'type': type,
    'token': token,
    'renewalToken': renewalToken,
  };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        name = json['name'],
        type = json['type'],
        token = json['token'],
        renewalToken = json['renewalToken'];
}