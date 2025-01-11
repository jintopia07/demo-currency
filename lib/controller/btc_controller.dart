import 'dart:convert';
import 'package:flutter_demo/Model/btc_model.dart';
import 'package:http/http.dart' as http;

class BTCController {
  Future<Currentprice> fetchBTCPrice() async {
    final response = await http.get(
      Uri.parse('https://api.coindesk.com/v1/bpi/currentprice.json'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Currentprice.fromJson(data);
    } else {
      throw Exception('Failed to fetch BTC price');
    }
  }
}

class CandlestickData {
  final double open;
  final double close;
  final double high;
  final double low;

  CandlestickData({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });
}
