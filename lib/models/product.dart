import 'package:app/models/subcategory.dart';
import 'dart:convert';

class Product {
  int? id;
  Subcategory? subcategory;
  int? subcategoryId;
  String? name;
  String? sku;
  int price;
  int? cost;
  int quantity;
  String? image;

  Product({
    this.id,
    this.subcategoryId,
    this.subcategory,
    this.name,
    this.sku,
    required this.price,
    this.cost,
    required this.quantity,
    this.image
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      subcategoryId: json['subcategory_id'],
      subcategory: Subcategory.fromJson(json['subcategory']),
      name: json['name'],
      sku: json['sku'],
      price: json['price'],
      cost: json['cost'],
      quantity: 0,
      image: json['image']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subcategoryId': subcategoryId,
    'subcategory': subcategory!.toJson(),
    'name': name,
    'price': price,
    'cost': cost,
    'quantity': quantity,
    'image': image,
  };

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