class Company {
  int id;
  String name;
  String pidn;
  String street;
  String number;
  String postalCode;
  String city;
  String phone;

  Company({
    required this.id,
    required this.name,
    required this.pidn,
    required this.street,
    required this.number,
    required this.postalCode,
    required this.city,
    required this.phone,
  });

  Company.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        pidn = json['pidn'],
        street = json['street'],
        number = json['number'],
        postalCode = json['postalCode'],
        city = json['city'],
        phone = json['phone'];
}