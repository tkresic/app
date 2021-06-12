import 'dart:convert';
import 'payment_method.dart';
import 'product.dart';
import 'tax.dart';
import 'user.dart';

class Bill {
  int id;
  int paymentMethodId;
  PaymentMethod? paymentMethod;
  Bill? restoredBill;
  Bill? restoredByBill;
  User user;
  // // Branch branch
  List<Product> products;
  int number;
  int businessPlaceLabel;
  String label;
  int gross;
  int net;
  List<Tax> taxes;
  String createdAt;
  String? restoringReason;

  Bill({
    required this.id,
    required this.paymentMethodId,
    this.paymentMethod,
    this.restoredBill,
    this.restoredByBill,
    required this.user,
    required this.products,
    required this.businessPlaceLabel,
    required this.label,
    required this.number,
    required this.gross,
    required this.net,
    required this.taxes,
    this.restoringReason,
    required this.createdAt
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      paymentMethodId: json['payment_method_id'],
      paymentMethod: json['payment_method'] == null ? null : PaymentMethod.fromJson(json['payment_method']),
      restoredBill: json['restored_bill'] == null ? null : Bill.fromJson(json['restored_bill']),
      restoredByBill: json['restored_by_bill'] == null ? null : Bill.fromJson(json['restored_by_bill']),
      user: User.fromJson(json['user']),
      products: parseProducts(json["products"]),
      businessPlaceLabel: json['business_place_label'],
      label: json['label'],
      number: json['number'],
      gross: json['gross'],
      net: json['net'],
      taxes: parseTaxes(json['taxes']),
      restoringReason: json['restoring_reason'],
      createdAt: json['created_at'],
    );
  }

  static List<Product> parseProducts(List<dynamic> products) {
    List<Product> list = products.map((json) => Product(
        id: json['id'],
        subcategoryId: json['subcategory_id'],
        name: json['name'],
        sku: json['sku'],
        price: json['price'],
        cost: json['cost'],
        quantity: json['quantity'],
        image: json['image']
    )).toList();
    return list;
  }

  static List<Tax> parseTaxes(List<dynamic> taxes) {
    List<Tax> list = taxes.map((json) => Tax(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        total: json['total'],
    )).toList();
    return list;
  }

  static List<Bill> parseBills(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Bill>((json) => Bill.fromJson(json)).toList();
  }
}