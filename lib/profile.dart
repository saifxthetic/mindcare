import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'services/api_service.dart';
import 'user_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final data = await ApiService.getProfile();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (data['user'] != null) {
        UserData.id = int.tryParse(data['user']['id'].toString());
        UserData.name = data['user']['name'] ?? '';
        UserData.email = data['user']['email'] ?? '';
      }
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    UserData.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                child: Text(
                  UserData.name.isNotEmpty ? UserData.name[0].toUpperCase() : 'M',
                  style: const TextStyle(fontSize: 34),
                ),
              ),
              const SizedBox(height: 18),
              Text(UserData.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(UserData.email),
              const SizedBox(height: 28),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.spa),
                  title: const Text('MindCare Wellness Marketplace'),
                  subtitle: const Text('Browse digital wellness products and services.'),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }
}
