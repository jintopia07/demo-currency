import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_demo/controller/btc_controller.dart';

class CandlestickChartPainter extends CustomPainter {
  final List<CandlestickData> candlestickData;

  CandlestickChartPainter(this.candlestickData);

  @override
  void paint(Canvas canvas, Size size) {
    if (candlestickData.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final double barWidth = size.width / candlestickData.length / 2;

    final double maxPrice = candlestickData.map((e) => e.high).reduce(max);
    final double minPrice = candlestickData.map((e) => e.low).reduce(min);

    for (int i = 0; i < candlestickData.length; i++) {
      final data = candlestickData[i];
      final x = (i * size.width / candlestickData.length) +
          (size.width / candlestickData.length / 2);

      final highY = size.height -
          ((data.high - minPrice) / (maxPrice - minPrice)) * size.height;
      final lowY = size.height -
          ((data.low - minPrice) / (maxPrice - minPrice)) * size.height;
      final openY = size.height -
          ((data.open - minPrice) / (maxPrice - minPrice)) * size.height;
      final closeY = size.height -
          ((data.close - minPrice) / (maxPrice - minPrice)) * size.height;

      final isUp = data.close >= data.open;
      paint.color = isUp ? Colors.green : Colors.red;

      canvas.drawLine(
          Offset(x, highY), Offset(x, lowY), paint..strokeWidth = 1);

      canvas.drawRect(
        Rect.fromLTRB(
          x - barWidth / 2,
          isUp ? closeY : openY,
          x + barWidth / 2,
          isUp ? openY : closeY,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CombinedChartPainter extends CustomPainter {
  final List<double> linePrices;
  final List<CandlestickData> candlestickData;

  CombinedChartPainter(this.linePrices, this.candlestickData);

  @override
  void paint(Canvas canvas, Size size) {
    if (linePrices.isEmpty || candlestickData.isEmpty) return;

    // **วาดกราฟเส้น**
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    final maxPriceLine = linePrices.reduce(max);
    final minPriceLine = linePrices.reduce(min);

    for (int i = 0; i < linePrices.length; i++) {
      final x = i * (size.width / (linePrices.length - 1));
      final y = size.height -
          ((linePrices[i] - minPriceLine) / (maxPriceLine - minPriceLine)) *
              size.height;
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // **วาดกราฟแท่งเทียน**
    final candlestickPaint = Paint()..style = PaintingStyle.fill;
    final double barWidth = size.width / candlestickData.length / 2;

    final maxPriceCandle = candlestickData.map((e) => e.high).reduce(max);
    final minPriceCandle = candlestickData.map((e) => e.low).reduce(min);

    double lastTextPositionY = -100;

    for (int i = 0; i < candlestickData.length; i++) {
      final data = candlestickData[i];
      final x = (i * size.width / candlestickData.length) +
          (size.width / candlestickData.length / 2);

      final highY = size.height -
          ((data.high - minPriceCandle) / (maxPriceCandle - minPriceCandle)) *
              size.height;
      final lowY = size.height -
          ((data.low - minPriceCandle) / (maxPriceCandle - minPriceCandle)) *
              size.height;
      final openY = size.height -
          ((data.open - minPriceCandle) / (maxPriceCandle - minPriceCandle)) *
              size.height;
      final closeY = size.height -
          ((data.close - minPriceCandle) / (maxPriceCandle - minPriceCandle)) *
              size.height;

      final isUp = data.close >= data.open;
      candlestickPaint.color = isUp ? Colors.green : Colors.red;

      canvas.drawLine(
          Offset(x, highY), Offset(x, lowY), candlestickPaint..strokeWidth = 1);

      canvas.drawRect(
        Rect.fromLTRB(
          x - barWidth / 2,
          isUp ? closeY : openY,
          x + barWidth / 2,
          isUp ? openY : closeY,
        ),
        candlestickPaint,
      );

      if ((lastTextPositionY - highY).abs() < 20) continue;
      lastTextPositionY = highY;

      final textSpan = TextSpan(
        text: data.high.toStringAsFixed(2),
        style: TextStyle(
          color: isUp ? Colors.green : Colors.red,
          fontSize: 10,
        ),
      );
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = 0.5;

      canvas.drawLine(
          Offset(x, highY), Offset(x, lowY), candlestickPaint..strokeWidth = 1);

      canvas.drawRect(
        Rect.fromLTRB(
          x - barWidth / 2,
          isUp ? closeY : openY,
          x + barWidth / 2,
          isUp ? openY : closeY,
        ),
        candlestickPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(
          x - barWidth / 2,
          isUp ? closeY : openY,
          x + barWidth / 2,
          isUp ? openY : closeY,
        ),
        borderPaint,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, highY - 14));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
