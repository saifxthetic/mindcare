// lib/product_detail.dart

import 'package:flutter/material.dart';
import 'cart_manager.dart';
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
  int _quantity = 1;

  Future<void> _buyNow() async {
    setState(() => _ordering = true);
    final data = await ApiService.placeOrder(widget.product.id,
        quantity: _quantity);
    if (!mounted) return;
    setState(() => _ordering = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Order request completed.')),
    );
    if (data['statusCode'] == 201 || data['statusCode'] == 200) {
      Navigator.pushReplacementNamed(context, '/orders');
    }
  }

  void _addToCart() {
    CartManager.instance.addProduct(widget.product, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.title} added to cart!'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  Future<void> _addWishlist() async {
    final data = await ApiService.addToWishlist(widget.product.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Wishlist updated.')),
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
    final product = widget.product;
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Add to Wishlist',
            onPressed: _addWishlist,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'View Cart',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 36, horizontal: 24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 62,
                      backgroundColor: primary.withOpacity(0.10),
                      child: Icon(_categoryIcon(product.category),
                          size: 58, color: primary),
                    ),
                    const SizedBox(height: 20),
                    Text(product.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(product.category),
                          avatar: Icon(_categoryIcon(product.category),
                              size: 16),
                          backgroundColor: primary.withOpacity(0.08),
                          labelStyle: TextStyle(color: primary),
                        ),
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(
                              product.isDigital ? 'Digital' : 'Physical'),
                          avatar: Icon(
                            product.isDigital
                                ? Icons.download_rounded
                                : Icons.local_shipping_outlined,
                            size: 16,
                          ),
                          backgroundColor: accent.withOpacity(0.15),
                          labelStyle:
                          const TextStyle(color: Color(0xFF26332D)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primary),
                        ),
                        const Spacer(),
                        _qtySelector(primary),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('About this product',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: TextStyle(
                          color: const Color(0xFF26332D).withOpacity(0.75),
                          height: 1.55,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal ($_quantity item${_quantity == 1 ? '' : 's'})',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '\$${(product.price * _quantity).toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _ordering ? null : _buyNow,
                      icon: _ordering
                          ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                          : const Icon(Icons.bolt_rounded),
                      label: const Text('Buy Now'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _addWishlist,
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Save to Wishlist'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtySelector(Color primary) {
    return Row(
      children: [
        _qtyBtn(
            icon: Icons.remove,
            onTap: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            primary: primary),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$_quantity',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        _qtyBtn(
            icon: Icons.add,
            onTap: () => setState(() => _quantity++),
            primary: primary),
      ],
    );
  }

  Widget _qtyBtn(
      {required IconData icon,
        required VoidCallback onTap,
        required Color primary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: primary),
      ),
    );
  }
}