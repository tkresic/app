import 'package:app/models/subcategory.dart';
import 'dart:convert';

class Product {
  int id;
  Subcategory subcategory;
  int subcategoryId;
  String name;
  int price;
  int quantity;
  String image;

  Product({required this.id, required this.subcategoryId, required this.subcategory, required this.name, required this.price, required this.quantity, required this.image});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      subcategoryId: json['subcategory_id'],
      subcategory: Subcategory.fromJson(json['subcategory']),
      name: json['name'],
      price: json['price'],
      quantity: 0,
      image: json['image']
    );
  }

  static List<Product> parseProducts(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromJson(json)).toList();
  }

  static Map<dynamic, dynamic> parseGroupedData(String responseBody) {
    Map<String, dynamic> data = jsonDecode(responseBody);

    data.keys.forEach((i) => {
      data[i].keys.forEach((j) => {
        data[i][j] = (data[i][j] as List).map((i) => Product.fromJson(i)).toList()
      })
    });

    return data;
  }
}