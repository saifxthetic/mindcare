import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
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
        _items = (data['wishlist'] as List).map((item) => Product.fromJson(item)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? const Center(child: Text('Your wishlist is empty.'))
            : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final product = _items[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.favorite)),
                title: Text(product.title),
                subtitle: Text('${product.category} • \$${product.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _remove(product),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}
