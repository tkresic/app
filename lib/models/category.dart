import 'package:app/models/subcategory.dart';
import 'dart:convert';

class Category {
  int? id;
  String? name;
  bool active;
  List<Subcategory>? subcategories;

  Category({this.id, this.name, required this.active, this.subcategories});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'active': active,
  };

  static List<Category> parseCategories(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Category>((json) => Category.fromJson(json)).toList();
  }
}