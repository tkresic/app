import 'package:intl/intl.dart';

mixin FormatPrice {
  String formatPrice(int price, {String symbol = ''}){
    return NumberFormat.currency(locale: 'hr', symbol: symbol).format(price / 100);
  }
}