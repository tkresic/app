class User {
  int id;
  // String name;
  // String surname;
  String username;
  // String password;
  String type;
  // String address;
  // String city;
  // String postalCode;
  // String phone;
  // String oib;
  String? token;
  String? renewalToken;

  User({required this.id, required this.username, required this.type, this.token, this.renewalToken});

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'type': type,
    'token': token,
    'renewalToken': renewalToken,
  };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        type = json['type'],
        token = json['token'],
        renewalToken = json['renewalToken'];

  // TODO => Remove. Used for demonstration purposes.
  static List<User> getData() {
    return [
      new User(id: 1, username: 'tkresic', type: 'Administrator'),
      new User(id: 2, username: 'ihorvat', type: 'Zaposlenik'),
      new User(id: 3, username: 'mmikic', type: 'Zaposlenik'),
    ];
  }
}