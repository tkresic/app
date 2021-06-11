import 'package:intl/intl.dart';

mixin FormatPrice {
  String formatPrice(int price, {String symbol = ''}) {
    return NumberFormat.currency(locale: 'hr', symbol: symbol).format(price / 100);
  }

  int unFormatPrice(String? price) {
    String withoutCurrencySymbol;
    if (price!.contains("HRK")) {
      withoutCurrencySymbol = price.substring(0, price.length - 4);
    } else {
      withoutCurrencySymbol = price.trim();
    }
    List<String> bothParts = withoutCurrencySymbol.split(',');
    String firstPart = bothParts[0].replaceAll(".", "");
    return int.parse("$firstPart${bothParts[1]}");
  }
}