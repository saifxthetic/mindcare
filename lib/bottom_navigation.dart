import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavigation({super.key, required this.currentIndex});

  void _go(BuildContext context, int index) {
    final routes = ['/home', '/wishlist', '/orders', '/profile'];
    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _go(context, index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.storefront), label: 'Shop'),
        NavigationDestination(icon: Icon(Icons.favorite), label: 'Wishlist'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
