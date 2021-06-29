import 'package:app/models/category.dart';
import 'package:app/models/product.dart';
import 'dart:convert';

class Subcategory {
  int? id;
  Category? category;
  int? categoryId;
  String? name;
  bool active;
  List<Product>? products;

  Subcategory({this.id, this.categoryId, this.name, required this.active, this.category, this.products});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      category: Category.fromJson(json['category']),
      categoryId: json['category_id'],
      name: json['name'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'category': category!.toJson(),
    'name': name,
    'active': active,
  };

  static List<Subcategory> parseSubcategories(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Subcategory>((json) => Subcategory.fromJson(json)).toList();
  }
}