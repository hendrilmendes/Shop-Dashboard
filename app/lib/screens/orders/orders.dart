// ignore_for_file: use_build_context_synchronously

import 'package:dashboard/provider/orders_provider.dart';
import 'package:dashboard/widgets/orders/orders_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _refreshOrders() async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final initialOrderCount = orderProvider.orders.length;
      await orderProvider.fetchOrders();
      final newOrderCount = orderProvider.orders.length;

      if (newOrderCount > initialOrderCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você tem novos pedidos!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Erro ao atualizar pedidos. Tente novamente mais tarde.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            Provider.of<OrderProvider>(context, listen: false).fetchOrders(),
        builder: (ctx, snapshot) {
          final formatter = NumberFormat('#,##0.00', 'pt_BR');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return const Center(
              child: Text(
                'Erro ao carregar pedidos. Tente novamente mais tarde.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else {
            return Consumer<OrderProvider>(
              builder: (ctx, orderData, child) {
                var filteredOrders = orderData.orders;

                if (_startDate != null && _endDate != null) {
                  filteredOrders = filteredOrders.where((order) {
                    return order.date.isAfter(_startDate!) &&
                        order.date
                            .isBefore(_endDate!.add(const Duration(days: 1)));
                  }).toList();
                }

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum pedido encontrado',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (ctx, i) =>
                        OrderItemWidget(filteredOrders[i], formatter),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
