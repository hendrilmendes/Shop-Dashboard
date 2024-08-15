import 'package:dashboard/models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderItemWidget extends StatelessWidget {
  final Order order;
  final NumberFormat formatter;

  const OrderItemWidget(this.order, this.formatter, {super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código do Pedido: ${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Nome do Cliente: ${order.customerName}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Endereço: ${order.address}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Método de Pagamento: ${order.paymentMethod}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Valor: R\$ ${formatter.format(order.amount)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Data: ${dateFormat.format(order.date.toLocal())}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Itens:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${item.title} (x${item.quantity})'),
                    subtitle:
                        Text('Cor: ${item.color} - Tamanho: ${item.size}'),
                    trailing: Text('R\$ ${formatter.format(item.price)}'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
