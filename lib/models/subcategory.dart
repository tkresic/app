import 'package:app/models/category.dart';
import 'package:app/models/product.dart';
import 'dart:convert';

class Subcategory {
  int id;
  Category category;
  int categoryId;
  String name;
  List<Product>? products;

  Subcategory({required this.id, required this.categoryId, required this.name, required this.category, this.products});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      category: Category.fromJson(json['category']),
      categoryId: json['category_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'category': category.toJson(),
    'name': name,
  };

  static List<Subcategory> parseSubcategories(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Subcategory>((json) => Subcategory.fromJson(json)).toList();
  }
}