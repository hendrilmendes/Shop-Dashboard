class OrderItem {
  final String title;
  final int quantity;
  final double price;
  final String color;
  final String size;

  OrderItem({
    required this.title,
    required this.quantity,
    required this.price,
    required this.color,
    required this.size,
  });
}

class Order {
  final String id;
  final String customerName;
  final String address;
  final String paymentMethod;
  final double amount;
  final DateTime date;
  final List<OrderItem> items;
  final bool isNew;

  Order({
    required this.id,
    required this.customerName,
    required this.address,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    required this.items,
    this.isNew = false,
  });
}
