import 'package:intl/intl.dart';

mixin FormatPrice {
  String formatPrice(int price, {String symbol = ''}){
    return NumberFormat.currency(locale: 'hr', symbol: symbol).format(price / 100);
  }

  int unFormatPrice(String? price) {
    String withoutCurrencySymbol = price!.substring(0, price.length - 4);
    List<String> bothParts = withoutCurrencySymbol.split(',');
    return int.parse("${bothParts[0]}${bothParts[1]}");
  }
}