// lib/orders.dart

import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'bottom_navigation.dart';
import 'models/order.dart';
import 'order_detail.dart';
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
        _orders = (data['orders'] as List)
            .map((item) => OrderModel.fromJson(item))
            .toList();
      }
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'processing':
        return const Color(0xFF5E8C75);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh'),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/orders'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
            ? _buildEmptyState(context, primary)
            : RefreshIndicator(
          onRefresh: _loadOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _orders.length,
            itemBuilder: (context, index) =>
                _buildOrderCard(context, _orders[index], primary),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text('No orders yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Your past orders will appear here',
              style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 28),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Start Shopping'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, OrderModel order, Color primary) {
    final statusColor = _statusColor(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order)),
          ).then((_) => _loadOrders());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withOpacity(0.10),
                    child: Icon(Icons.receipt_long, color: primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #${order.id}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(order.paymentMethod,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tap to view details',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                  Row(
                    children: [
                      Icon(Icons.add_shopping_cart,
                          size: 14, color: primary),
                      const SizedBox(width: 4),
                      Text('Reorder',
                          style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}