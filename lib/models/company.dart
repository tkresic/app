class Company {
  int id;
  String name;
  String address;
  String pidn;
  String phone;

  Company({
    required this.id,
    required this.name,
    required this.address,
    required this.pidn,
    required this.phone
  });

  Company.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        address = json['address'],
        pidn = json['pidn'],
        phone = json['phone'];
}