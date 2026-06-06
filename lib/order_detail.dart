// lib/order_detail.dart

import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'models/order.dart';
import 'models/product.dart';
import 'services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loading = true;
  Map<String, dynamic> _detail = {};

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    final data = await ApiService.getOrderDetail(widget.order.id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _detail = data;
    });
  }

  void _addToCart(Product product) {
    CartManager.instance.addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart!'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  void _reorderAll() {
    final items = widget.order.items;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to reorder.')),
      );
      return;
    }
    for (final item in items) {
      CartManager.instance.addProduct(item.product, quantity: item.quantity);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${items.length} item(s) added to cart!'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
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

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'processing':
        return Icons.sync_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final primary = Theme.of(context).colorScheme.primary;
    final statusColor = _statusColor(order.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        actions: [
          if (order.items.isNotEmpty)
            TextButton.icon(
              onPressed: _reorderAll,
              icon: const Icon(Icons.replay, color: Colors.white),
              label: const Text('Reorder',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: statusColor.withOpacity(0.12),
                      child: Icon(_statusIcon(order.status),
                          color: statusColor, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: statusColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                      children: [
                        _infoTile('Order ID', '#${order.id}',
                            Icons.tag),
                        _infoTile('Payment', order.paymentMethod,
                            Icons.payment),
                        _infoTile(
                          'Total',
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          Icons.attach_money,
                          valueColor: primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              if (order.items.isNotEmpty) ...[
                _sectionLabel('Items Ordered'),
                ...order.items.map((item) => _buildItemCard(
                    item.product, item.quantity, primary)),
              ] else ...[
                _sectionLabel('Items Ordered'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text('No item details available',
                          style: TextStyle(
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              if (order.items.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _reorderAll,
                    icon: const Icon(Icons.add_shopping_cart),
                    label:
                    const Text('Add All to Cart & Reorder'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(height: 4),
        Text(label,
            style:
            TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: valueColor ?? const Color(0xFF26332D),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }

  Widget _buildItemCard(Product product, int quantity, Color primary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primary.withOpacity(0.10),
              child: Icon(Icons.spa, color: primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '${product.category} • Qty: $quantity',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(product.price * quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _addToCart(product),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}