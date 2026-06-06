// lib/app_drawer.dart

import 'package:flutter/material.dart';
import 'user_data.dart';
import 'services/api_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _navigate(BuildContext context, String route) {
    if (currentRoute == route) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pop();
    await ApiService.logout();
    UserData.clear();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    bool isDestructive = false,
  }) {
    final bool isActive = currentRoute == route;
    final Color activeColor = Theme.of(context).colorScheme.primary;
    final Color itemColor = isDestructive
        ? Colors.red.shade600
        : isActive
        ? activeColor
        : const Color(0xFF26332D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive ? activeColor.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigate(context, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: itemColor, size: 22),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: itemColor,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userName = UserData.name.isNotEmpty ? UserData.name : 'User';
    final String userEmail = UserData.email.isNotEmpty ? UserData.email : '';
    final String avatarLetter = userName[0].toUpperCase();
    final Color primary = Theme.of(context).colorScheme.primary;

    return Drawer(
      backgroundColor: const Color(0xFFF7F4EF),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (userEmail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
              child: Text(
                'MENU',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 4),

            _drawerItem(
              context: context,
              icon: Icons.storefront_outlined,
              label: 'Marketplace',
              route: '/home',
            ),
            _drawerItem(
              context: context,
              icon: Icons.shopping_cart_outlined,
              label: 'My Cart',
              route: '/cart',
            ),
            _drawerItem(
              context: context,
              icon: Icons.favorite_outline,
              label: 'Wishlist',
              route: '/wishlist',
            ),
            _drawerItem(
              context: context,
              icon: Icons.receipt_long_outlined,
              label: 'My Orders',
              route: '/orders',
            ),
            _drawerItem(
              context: context,
              icon: Icons.person_outline,
              label: 'Profile',
              route: '/profile',
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Divider(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _logout(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red.shade600, size: 22),
                        const SizedBox(width: 16),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.spa, color: primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'MindCare Wellness',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}