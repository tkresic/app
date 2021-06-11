import 'dart:convert';
import 'payment_method.dart';
import 'product.dart';
import 'user.dart';

class Bill {
  int id;
  int paymentMethodId;
  PaymentMethod paymentMethod;
  // Bill? restoredBill;
  int? restoredBillId;
  User user;
  // // Branch branch
  List<Product> products;
  int number;
  int businessPlaceLabel;
  String label;
  int gross;
  String createdAt;
  String? restoringReason;

  Bill({
    required this.id,
    required this.paymentMethodId,
    required this.paymentMethod,
    this.restoredBillId,
    required this.user,
    required this.products,
    required this.businessPlaceLabel,
    required this.label,
    required this.number,
    required this.gross,
    this.restoringReason,
    required this.createdAt
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      paymentMethodId: json['payment_method_id'],
      paymentMethod: PaymentMethod.fromJson(json['payment_method']),
      restoredBillId: json['restored_bill_id'],
      user: User.fromJson(json['user']),
      products: parseProducts(json["products"]),
      businessPlaceLabel: json['business_place_label'],
      label: json['label'],
      number: json['number'],
      gross: json['gross'],
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

  static List<Bill> parseBills(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Bill>((json) => Bill.fromJson(json)).toList();
  }
}