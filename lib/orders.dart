import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'models/order.dart';
import 'services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final data = await ApiService.getOrders();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (data['orders'] is List) {
        _orders = (data['orders'] as List).map((item) => OrderModel.fromJson(item)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
            ? const Center(child: Text('No orders yet.'))
            : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text('Order #${order.id}'),
                subtitle: Text('${order.status} • ${order.paymentMethod}'),
                trailing: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}
