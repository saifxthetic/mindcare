// lib/cart.dart

import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'bottom_navigation.dart';
import 'cart_manager.dart';
import 'models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartManager _cart = CartManager.instance;

  void _refresh() => setState(() {});

  void _increment(CartItem item) {
    _cart.incrementQuantity(item.product.id);
    _refresh();
  }

  void _decrement(CartItem item) {
    _cart.decrementQuantity(item.product.id);
    _refresh();
  }

  void _remove(CartItem item) {
    _cart.removeProduct(item.product.id);
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.product.title} removed from cart.')),
    );
  }

  IconData _categoryIcon(String category) {
    const icons = {
      'Meditation': Icons.self_improvement,
      'Therapy': Icons.psychology,
      'Journal': Icons.edit_note,
      'Course': Icons.school,
      'Ebook': Icons.menu_book,
      'Audio': Icons.headphones,
    };
    return icons[category] ?? Icons.spa;
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _cart.clear();
                          _refresh();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text('Clear',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/cart'),
      body: items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildCartCard(context, item, primary);
              },
            ),
          ),
          _buildOrderSummary(context, items, primary),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products from the marketplace',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse Products'),
              style: ElevatedButton.styleFrom(backgroundColor: primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartCard(
      BuildContext context, CartItem item, Color primary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primary.withOpacity(0.10),
              child: Icon(_categoryIcon(item.product.category),
                  color: primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)} each',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _qtyButton(
                          icon: Icons.remove,
                          onTap: () => _decrement(item),
                          primary: primary),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      _qtyButton(
                          icon: Icons.add,
                          onTap: () => _increment(item),
                          primary: primary),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primary),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _remove(item),
                  child: Icon(Icons.delete_outline,
                      color: Colors.red.shade400, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(
      {required IconData icon,
        required VoidCallback onTap,
        required Color primary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: primary),
      ),
    );
  }

  Widget _buildOrderSummary(
      BuildContext context, List<CartItem> items, Color primary) {
    final subtotal = _cart.total;
    const double shipping = 0.0;
    final total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _summaryRow('Shipping', shipping == 0 ? 'Free' : '\$$shipping'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _summaryRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isBold: true,
            valueColor: primary,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              icon: const Icon(Icons.payment),
              label: Text(
                  'Proceed to Checkout (${_cart.itemCount} item${_cart.itemCount == 1 ? '' : 's'})'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
                color: Colors.grey.shade700)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: isBold ? 18 : 14,
                color: valueColor ?? const Color(0xFF26332D))),
      ],
    );
  }
}