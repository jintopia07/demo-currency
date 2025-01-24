import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should display BTC price from mock data',
      (WidgetTester tester) async {
    // mock data
    const mockResponse = '''
    {
      "bpi": {
        "USD": {
          "rate": "40,000"
        }
      }
    }
    ''';

    // ดึงข้อมูลจาก mockResponse
    final price = fetchBitcoinPriceFromMock(mockResponse);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FutureBuilder<String>(
          future: price,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('USD: ${snapshot.data}');
            }
          },
        ),
      ),
    ));

    await tester.pump(const Duration(seconds: 5));

    // ตรวจสอบผลลัพธ์ที่แสดงใน UI
    expect(find.textContaining('USD: 40,000'), findsOneWidget);
  });
}

Future<String> fetchBitcoinPriceFromMock(String mockResponse) async {
  final data = json.decode(mockResponse);
  return data['bpi']['USD']['rate'];
}
