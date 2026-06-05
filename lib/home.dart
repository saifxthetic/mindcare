// lib/home.dart

import 'package:flutter/material.dart';

import 'bottom_navigation.dart';
import 'models/product.dart';
import 'product_detail.dart';
import 'services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Meditation',
    'Therapy',
    'Journal',
    'Course',
    'Ebook',
    'Audio',
  ];

  String _selectedCategory = 'All';
  List<Product> _products = [];

  bool _loading = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
    });

    final data = await ApiService.getProducts(
      category: _selectedCategory,
      search: _searchController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;

      if (data['products'] is List) {
        _products = (data['products'] as List)
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _products = [];
      }
    });
  }

  Future<void> _addWishlist(Product product) async {
    final data = await ApiService.addToWishlist(product.id);

    if (!mounted) return;

    _showMessage(data['message']?.toString() ?? 'Wishlist updated.');
  }

  Future<void> _deleteProduct(Product product) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete "${product.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _deleting = true;
    });

    final data = await ApiService.deleteProduct(product.id);

    if (!mounted) return;

    setState(() {
      _deleting = false;
    });

    if (data['statusCode'] == 200) {
      setState(() {
        _products.removeWhere((item) => item.id == product.id);
      });

      _showMessage(data['message']?.toString() ?? 'Product deleted.');
    } else {
      _showMessage(data['message']?.toString() ?? 'Failed to delete product.');
    }
  }

  Future<void> _openProductDialog({Product? product}) async {
    final bool? saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ProductEditorDialog(
          product: product,
          categories: _categories.where((item) => item != 'All').toList(),
        );
      },
    );

    if (saved == true) {
      await _loadProducts();
    }
  }

  Widget _productIcon(Product product) {
    final icons = {
      'Meditation': Icons.self_improvement,
      'Therapy': Icons.psychology,
      'Journal': Icons.edit_note,
      'Course': Icons.school,
      'Ebook': Icons.menu_book,
      'Audio': Icons.headphones,
    };

    return CircleAvatar(
      radius: 28,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      child: Icon(
        icons[product.category] ?? Icons.spa,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      child: ListTile(
        leading: _productIcon(product),
        title: Text(
          product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${product.category} • \$${product.price.toStringAsFixed(2)}',
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'wishlist') {
              _addWishlist(product);
            } else if (value == 'edit') {
              _openProductDialog(product: product);
            } else if (value == 'delete') {
              _deleteProduct(product);
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'wishlist',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border),
                    SizedBox(width: 8),
                    Text('Add to Wishlist'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No products found.\nTap + to add a product.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindCare Marketplace'),
        actions: [
          IconButton(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search wellness products',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _loadProducts,
                      ),
                    ),
                    onSubmitted: (_) => _loadProducts(),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];

                        return ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });

                            _loadProducts();
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _products.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
                ],
              ),
            ),

            if (_deleting)
              Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openProductDialog();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}

class ProductEditorDialog extends StatefulWidget {
  final Product? product;
  final List<String> categories;

  const ProductEditorDialog({
    super.key,
    required this.product,
    required this.categories,
  });

  @override
  State<ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  late String _selectedCategory;

  bool _saving = false;
  String? _errorMessage;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.product?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );

    _priceController = TextEditingController(
      text: widget.product == null
          ? ''
          : widget.product!.price.toStringAsFixed(2),
    );

    _selectedCategory = widget.product?.category ?? widget.categories.first;

    if (!widget.categories.contains(_selectedCategory)) {
      _selectedCategory = widget.categories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (price == null) {
      setState(() {
        _errorMessage = 'Please enter a valid price.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    late final Map<String, dynamic> data;

    if (_isEditMode) {
      data = await ApiService.updateProduct(
        productId: widget.product!.id,
        title: title,
        description: description,
        category: _selectedCategory,
        price: price,
      );
    } else {
      data = await ApiService.addProduct(
        title: title,
        description: description,
        category: _selectedCategory,
        price: price,
      );
    }

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    final statusCode = data['statusCode'];

    if (statusCode == 200 || statusCode == 201) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage =
            data['message']?.toString() ?? 'Failed to save product.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              TextFormField(
                controller: _titleController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product title is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                enabled: !_saving,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _priceController,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null || price < 0) {
                    return 'Enter a valid price';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _saveProduct,
          child: _saving
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(_isEditMode ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}