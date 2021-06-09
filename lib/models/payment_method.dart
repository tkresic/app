import 'dart:convert';

class PaymentMethod {
  int id;
  String name;
  bool active;

  PaymentMethod({required this.id, required this.name, required this.active});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'active': active,
  };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      active: json['active'] == 1
    );
  }

  static List<PaymentMethod> parsePaymentMethods(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PaymentMethod>((json) => PaymentMethod.fromJson(json)).toList();
  }
}