import 'package:app/models/subcategory.dart';
import 'dart:convert';

class Category {
  int id;
  String name;
  List<Subcategory>? subcategories;

  Category({required this.id, required this.name, this.subcategories});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }

  static List<Category> parseCategories(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Category>((json) => Category.fromJson(json)).toList();
  }
}