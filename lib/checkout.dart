// lib/checkout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cart_manager.dart';
import 'models/cart_item.dart';
import 'services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _shippingFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();

  final CartManager _cart = CartManager.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  int _currentStep = 0;
  bool _placing = false;

  String _paymentMethod = 'Cash on Delivery';

  static const List<String> _paymentMethods = <String>[
    'Credit Card',
    'Debit Card',
    'PayPal',
    'Cash on Delivery',
  ];

  bool get _isCardPayment =>
      _paymentMethod == 'Credit Card' || _paymentMethod == 'Debit Card';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _continueStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      if (!(_shippingFormKey.currentState?.validate() ?? false)) return;
      setState(() => _currentStep = 1);
      return;
    }

    if (_currentStep == 1) {
      if (_isCardPayment &&
          !(_paymentFormKey.currentState?.validate() ?? false)) return;
      setState(() => _currentStep = 2);
      return;
    }

    _placeOrder();
  }

  void _cancelStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _placeOrder() async {
    if (_cart.items.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    setState(() => _placing = true);

    bool anySuccess = false;

    try {
      for (final CartItem item in _cart.items) {
        final data = await ApiService.placeOrder(
          item.product.id,
          quantity: item.quantity,
          paymentMethod: _paymentMethod,
        );
        final statusCode = data['statusCode'];
        if (statusCode == 200 || statusCode == 201) {
          anySuccess = true;
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order failed')),
      );
      return;
    }

    if (!mounted) return;

    setState(() => _placing = false);

    if (anySuccess) {
      _cart.clear();
      _showOrderSuccess();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order could not be placed')),
      );
    }
  }

  void _showOrderSuccess() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0x205E8C75),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF5E8C75),
                    size: 52,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order Placed!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Thank you, ${_nameController.text.trim()}! Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/orders',
                            (route) => route.settings.name == '/home',
                      );
                    },
                    child: const Text('View My Orders'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (route) => false,
                    );
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _placing
          ? const Center(child: CircularProgressIndicator())
          : _cart.items.isEmpty
          ? _buildEmptyCart()
          : SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Stepper(
              currentStep: _currentStep,
              type: StepperType.vertical,
              onStepContinue: _continueStep,
              onStepCancel: _cancelStep,
              steps: [
                _buildShippingStep(),
                _buildPaymentStep(primary),
                _buildReviewStep(primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('Your cart is empty', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
      ],
    ),
  );

  Step _buildShippingStep() => Step(
    title: const Text('Shipping Info'),
    isActive: _currentStep >= 0,
    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    content: Form(
      key: _shippingFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name *'),
            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email *'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address *'),
            validator: (v) => v == null || v.isEmpty ? 'Address is required' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City *'),
                  validator: (v) => v == null || v.isEmpty ? 'City required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _zipController,
                  decoration: const InputDecoration(labelText: 'ZIP *'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'ZIP required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Step _buildPaymentStep(Color primary) => Step(
    title: const Text('Payment'),
    isActive: _currentStep >= 1,
    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    content: Form(
      key: _paymentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: const InputDecoration(labelText: 'Payment Method'),
            items: _paymentMethods
                .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                .toList(),
            onChanged: (value) => setState(() => _paymentMethod = value ?? _paymentMethod),
          ),
          if (_isCardPayment) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(labelText: 'Card Number *'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              validator: (v) {
                if (!_isCardPayment) return null;
                if (v == null || v.isEmpty) return 'Card number required';
                if (v.length < 16) return 'Enter valid 16-digit number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardHolderController,
              decoration: const InputDecoration(labelText: 'Cardholder Name *'),
              validator: (v) {
                if (!_isCardPayment) return null;
                if (v == null || v.isEmpty) return 'Cardholder name required';
                return null;
              },
            ),
          ],
        ],
      ),
    ),
  );

  Step _buildReviewStep(Color primary) => Step(
    title: const Text('Review & Place Order'),
    isActive: _currentStep >= 2,
    state: _currentStep == 2 ? StepState.indexed : StepState.disabled,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivering to: ${_nameController.text}'),
        Text('${_addressController.text}, ${_cityController.text} ${_zipController.text}'),
        Text('Payment: $_paymentMethod'),
        const Divider(height: 24),
        ..._cart.items.map((item) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(item.product.title), Text('x${item.quantity}')],
        )),
      ],
    ),
  );
}