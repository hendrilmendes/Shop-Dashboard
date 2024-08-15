import 'package:dashboard/models/order.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  Future<void> fetchOrders() async {
    try {
      final response =
          await http.get(Uri.parse('http://45.174.192.150:3000/api/orders'));
      final List<dynamic> extractedData = json.decode(response.body);

      if (extractedData.isEmpty) {
        return;
      }

      final List<Order> loadedOrders = extractedData.map((orderData) {
        return Order(
          id: orderData['id'],
          customerName: orderData['customerName'],
          address: orderData['address'],
          paymentMethod: orderData['paymentMethod'],
          amount: orderData['amount'].toDouble(),
          date: DateTime.parse(orderData['date']),
          items: (orderData['items'] as List<dynamic>).map((item) {
            return OrderItem(
              title: item['title'],
              quantity: item['quantity'],
              price: item['price'].toDouble(),
              color: item['color'],
              size: item['size'],
            );
          }).toList(),
        );
      }).toList();

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao carregar pedidos: $error');
      }
    }
  }
}
