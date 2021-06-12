import 'dart:convert';
import 'user.dart';

class Shift {
  int id;
  String start;
  String? end;
  User user;
  int gross;

  Shift({required this.id, required this.start, required this.end, required this.user, required this.gross});

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
        id: json['id'],
        start: json['start'],
        end: json['end'] ?? '/',
        user: User.fromJson(json['user']),
        gross: json['gross'],
    );
  }

  static List<Shift> parseShifts(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Shift>((json) => Shift.fromJson(json)).toList();
  }
}