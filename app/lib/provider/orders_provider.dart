import 'package:dashboard/api/api.dart';
import 'package:dashboard/models/order.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/orders'));

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        if (kDebugMode) {
          print('Resposta da API: $extractedData');
        }

        if (extractedData.isEmpty) {
          if (kDebugMode) {
            print('Nenhum pedido encontrado.');
          }
          return;
        }

        final List<Order> loadedOrders = extractedData.map<Order>((orderData) {
          return Order(
            id: orderData['id'].toString(),
            customerName: orderData['customerName']?.toString() ?? '',
            address: orderData['address']?.toString() ?? '',
            paymentMethod: orderData['paymentMethod']?.toString() ?? '',
            amount: (orderData['amount'] as num).toDouble(),
            date: DateTime.parse(orderData['date']),
            items: (json.decode(orderData['items']) as List<dynamic>)
                .map<OrderItem>((item) {
              return OrderItem(
                title: item['title']?.toString() ?? '',
                quantity: item['quantity'] as int,
                price: (item['price'] as num).toDouble(),
                color: item['color']?.toString() ?? '',
                size: item['size']?.toString() ?? '',
              );
            }).toList(),
            isNew: orderData['isNew'] ?? false,
          );
        }).toList();

        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      } else {
        if (kDebugMode) {
          print(
              'Erro ao carregar pedidos: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao carregar pedidos: $error');
      }
    }
  }
}
