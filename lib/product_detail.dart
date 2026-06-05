import 'package:flutter/material.dart';
import 'models/product.dart';
import 'services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _ordering = false;

  Future<void> _buyNow() async {
    setState(() => _ordering = true);
    final data = await ApiService.placeOrder(widget.product.id);
    if (!mounted) return;
    setState(() => _ordering = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Order request completed.')),
    );

    if (data['statusCode'] == 201) {
      Navigator.pushReplacementNamed(context, '/orders');
    }
  }

  Future<void> _addWishlist() async {
    final data = await ApiService.addToWishlist(widget.product.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Wishlist updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 58,
                  child: Icon(Icons.spa, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              Text(product.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Chip(label: Text(product.category)),
              const SizedBox(height: 10),
              Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 18),
              Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _ordering ? null : _buyNow,
                icon: _ordering
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.shopping_bag),
                label: const Text('Buy Now'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addWishlist,
                icon: const Icon(Icons.favorite_border),
                label: const Text('Add to Wishlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
