import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'custom_drawer.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      (icon: Icons.home_rounded, label: 'Home', route: '/home'),
      (icon: Icons.kitchen_rounded, label: 'Pantry', route: '/pantry'),
      (icon: Icons.chat_rounded, label: 'Chat', route: '/chat'),
      (icon: Icons.shopping_cart_rounded, label: 'Cart', route: '/cart'),
    ];

    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          switch (currentRoute) {
            '/home' => 'Home',
            '/pantry' => 'Pantry',
            '/chat' => 'Chat',
            '/cart' => 'Cart',
            _ => 'Elbi Eats',
          },
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) => IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () async {
                await authProvider.signOut();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navItems
            .indexWhere((i) => i.route == currentRoute)
            .clamp(0, navItems.length - 1),
        onDestinationSelected: (index) {
          final route = navItems[index].route;
          if (currentRoute == route) return;
          route == '/home'
              ? Navigator.pushReplacementNamed(context, route)
              : Navigator.pushNamed(context, route);
        },
        destinations: navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
      body: child,
    );
  }
}
