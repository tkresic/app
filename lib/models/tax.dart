import 'dart:convert';

class Tax {
  int? id;
  String? name;
  int? amount;
  int? total;

  Tax({this.id, this.name, this.amount, this.total});

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'total': total,
  };

  static List<Tax> parseTaxes(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Tax>((json) => Tax.fromJson(json)).toList();
  }
}