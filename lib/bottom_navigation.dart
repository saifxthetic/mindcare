// lib/bottom_navigation.dart

import 'package:flutter/material.dart';
import 'cart_manager.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavigation({super.key, required this.currentIndex});

  // 0=Shop  1=Cart  2=Wishlist  3=Orders  4=Profile
  void _go(BuildContext context, int index) {
    const routes = ['/home', '/cart', '/wishlist', '/orders', '/profile'];
    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = CartManager.instance.itemCount;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _go(context, index),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Shop',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}