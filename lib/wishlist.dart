// lib/wishlist.dart

import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'bottom_navigation.dart';
import 'cart_manager.dart';
import 'models/product.dart';
import 'product_detail.dart';
import 'services/api_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _loading = true);
    final data = await ApiService.getWishlist();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (data['wishlist'] is List) {
        _items = (data['wishlist'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      }
    });
  }

  Future<void> _remove(Product product) async {
    final data = await ApiService.removeFromWishlist(product.id);
    if (!mounted) return;
    setState(() => _items.removeWhere((item) => item.id == product.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Removed from wishlist.')),
    );
  }

  void _addToCart(Product product) {
    CartManager.instance.addProduct(product);
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/wishlist'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline,
                  size: 70, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Your wishlist is empty.',
                  style:
                  TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final product = _items[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary.withOpacity(0.10),
                  child: Icon(Icons.favorite, color: primary),
                ),
                title: Text(product.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${product.category} • \$${product.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart,
                          color: primary),
                      tooltip: 'Add to Cart',
                      onPressed: () => _addToCart(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      tooltip: 'Remove',
                      onPressed: () => _remove(product),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(product: product)),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}