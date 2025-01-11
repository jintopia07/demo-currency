// ignore_for_file: unused_field, unused_element

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_demo/Model/btc_model.dart';
import 'package:flutter_demo/controller/btc_controller.dart';
import 'package:flutter_demo/widgets/line_chart.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  final BTCController _controller = BTCController();
  Currentprice? _btcModel;
  Timer? _timer;
  double currentPriceUSD = 0.0;
  double currentPriceTHB = 0.0;
  final List<double> _historicalPrices = [];
  final List<CandlestickData> _candlestickData = [];
  bool isGraphLoading = true;
  String selectedCurrency = 'USD';

  @override
  void initState() {
    _updatePrice();

    _timer =
        Timer.periodic(const Duration(seconds: 30), (timer) => _updatePrice());

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<double> fetchUSDToTHBRate() async {
    return 34.5; // Replace with the actual rate
  }

  Future<void> _updatePrice() async {
    try {
      final btcModel = await _controller.fetchBTCPrice();
      final usdToThbRate = await fetchUSDToTHBRate();

      setState(() {
        // ดึงราคาตามสกุลเงินที่เลือก
        switch (selectedCurrency) {
          case 'GBP':
            currentPriceUSD = btcModel.bpi.gbp.rateFloat;
            break;
          case 'EUR':
            currentPriceUSD = btcModel.bpi.eur.rateFloat;
            break;
          default:
            currentPriceUSD = btcModel.bpi.usd.rateFloat;
        }

        currentPriceTHB = currentPriceUSD * usdToThbRate;

        if (_historicalPrices.isNotEmpty) {
          final previousPrice = _historicalPrices.last;
          _candlestickData.add(CandlestickData(
            open: previousPrice,
            close: currentPriceUSD,
            high: max(previousPrice, currentPriceUSD),
            low: min(previousPrice, currentPriceUSD),
          ));
        }

        _historicalPrices.add(currentPriceUSD);

        // จำกัดรายการข้อมูลให้มีสูงสุด 10 แท่งเทียน
        if (_historicalPrices.length > 10) {
          _historicalPrices.removeAt(0);
          if (_candlestickData.length > 10) {
            _candlestickData.removeAt(0);
          }
        }

        // ปิด loading
        if (isGraphLoading && _candlestickData.isNotEmpty) {
          isGraphLoading = false;
        }
      });
    } catch (e) {
      print("Error fetching price: $e");
    }
  }

  void _handleTouch(Offset localPosition) {
    final double barWidth =
        MediaQuery.of(context).size.width / _candlestickData.length;

    // คำนวณตำแหน่งของแท่งเทียนที่ถูกแตะ
    final int index = (localPosition.dx / barWidth).floor();

    if (index >= 0 && index < _candlestickData.length) {
      final data = _candlestickData[index];
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('รายละเอียดราคาแท่งที่ ${index + 1}'),
          content: Text(
            'Open: ${data.open.toStringAsFixed(2)}\n'
            'Close: ${data.close.toStringAsFixed(2)}\n'
            'High: ${data.high.toStringAsFixed(2)}\n'
            'Low: ${data.low.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInitialCandlestickChart() {
    return CustomPaint(
      painter: CombinedChartPainter(_historicalPrices, _candlestickData),
      child: Container(
        height: 200,
        color: Colors.black,
      ),
    );
  }

  String formatNumberWithComma(double number) {
    String formatted = number.toStringAsFixed(2);
    RegExp regExp = RegExp(r'(\d)(?=(\d{3})+\.)');
    formatted =
        formatted.replaceAllMapped(regExp, (match) => '${match.group(1)},');
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BTC currency'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Current BTC Price',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    DropdownButton<String>(
                      value: selectedCurrency,
                      dropdownColor: Colors.grey[900],
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: ['USD', 'GBP', 'EUR'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCurrency = newValue;
                            isGraphLoading = true;
                          });
                          _updatePrice();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$selectedCurrency: ${formatNumberWithComma(currentPriceUSD)}',
                      style: TextStyle(
                        fontSize: 20,
                        color: _historicalPrices.length > 1 &&
                                currentPriceUSD >=
                                    _historicalPrices[
                                        _historicalPrices.length - 2]
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Text(
                      'THB: ฿${formatNumberWithComma(currentPriceTHB)}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Historical Prices ($selectedCurrency) (10 Minute) ',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    height: 200,
                    child: isGraphLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueGrey),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: _candlestickData.length * 20,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  _handleTouch(details.localPosition);
                                },
                                child: CustomPaint(
                                  painter: CombinedChartPainter(
                                      _historicalPrices, _candlestickData),
                                  child: Container(),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white),
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price History (Last 30 Seconds)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      reverse: false,
                      itemCount: _historicalPrices.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final currentTime = DateTime.now();
                          return ListTile(
                            title: Text(
                              '$selectedCurrency: ${formatNumberWithComma(currentPriceUSD)}',
                              style: TextStyle(
                                color: _historicalPrices.isNotEmpty &&
                                        currentPriceUSD < _historicalPrices.last
                                    ? Colors
                                        .red // ถ้าราคาน้อยกว่าราคาเดิม แสดงเป็นสีแดง
                                    : Colors
                                        .green, // ถ้าราคามากกว่าราคาเดิม แสดงเป็นสีเขียว
                              ),
                            ),
                            subtitle: Text(
                              'Time: ${currentTime.toLocal().toString().split('.').first}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        } else {
                          // แสดงรายการประวัติ
                          final reversedPrices =
                              _historicalPrices.reversed.toList();
                          final currentPrice = reversedPrices[index - 1];
                          final previousPrice = index < reversedPrices.length
                              ? reversedPrices[index]
                              : currentPrice;

                          final timestamp = DateTime.now().subtract(
                            Duration(seconds: 30 * index),
                          );

                          return ListTile(
                            title: Text(
                              'USD: \$${formatNumberWithComma(currentPrice)}',
                              style: TextStyle(
                                color: currentPrice < previousPrice
                                    ? Colors
                                        .red // ถ้าราคาน้อยกว่าราคาเดิม แสดงเป็นสีแดง
                                    : Colors
                                        .green, // ถ้าราคามากกว่าราคาเดิม แสดงเป็นสีเขียว
                              ),
                            ),
                            subtitle: Text(
                              'Time: ${timestamp.toLocal().toString().split('.').first}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
