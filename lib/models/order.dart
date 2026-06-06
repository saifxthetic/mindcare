// lib/models/order.dart

import 'product.dart';

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});
}

class OrderModel {
  final int id;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parsedItems = [];
    if (json['items'] is List) {
      for (final itemJson in json['items'] as List) {
        try {
          final productJson = itemJson['product'] ?? itemJson;
          final product =
          Product.fromJson(Map<String, dynamic>.from(productJson));
          final quantity =
              int.tryParse(itemJson['quantity']?.toString() ?? '1') ?? 1;
          parsedItems.add(OrderItem(product: product, quantity: quantity));
        } catch (_) {}
      }
    }

    return OrderModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      totalAmount:
      double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'Pending',
      paymentMethod:
      json['payment_method']?.toString() ?? 'Demo Payment',
      items: parsedItems,
    );
  }
}