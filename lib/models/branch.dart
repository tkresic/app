class Branch {
  int id;
  String name;
  String address;
  String phone;
  int businessPlaceLabel;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.businessPlaceLabel,
  });

  Branch.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        address = json['address'],
        phone = json['phone'],
        businessPlaceLabel = json['businessPlaceLabel'];
}