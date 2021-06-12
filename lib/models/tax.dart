import 'dart:convert';

class Tax {
  int? id;
  String? name;
  int? amount;

  Tax({this.id, this.name, this.amount});

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
  };

  static List<Tax> parseTaxes(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Tax>((json) => Tax.fromJson(json)).toList();
  }
}