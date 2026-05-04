import 'package:flutter/material.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final _navItems = [
    (icon: Icons.home_rounded, label: 'Home', route: '/home'),
    (icon: Icons.kitchen_rounded, label: 'Pantry', route: '/pantry'),
    (icon: Icons.chat_rounded, label: 'Chat', route: '/chat'),
    (icon: Icons.shopping_cart_rounded, label: 'Cart', route: '/cart'),
  ];

  void _onTap(String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == route) return;

    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navItems
            .indexWhere((i) => i.route == currentRoute)
            .clamp(0, _navItems.length - 1),
        onDestinationSelected: (index) => _onTap(_navItems[index].route),
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
