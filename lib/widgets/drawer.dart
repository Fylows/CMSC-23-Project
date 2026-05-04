import 'package:flutter/material.dart';

final drawerItems = [
  (icon: Icons.home, label: 'Home', route: '/home'),
  // (icon: Icons.person, label: 'Profile', route: '/profile'),
  // (icon: Icons.leaderboard, label: 'Leaderboards', route: '/leaderboards'),
  // (icon: Icons.settings, label: 'Settings', route: '/settings'),
];

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text('Menu', style: TextStyle(color: Colors.white)),
          ),
          ...drawerItems.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              onTap: () {
                Navigator.pop(context);
                final currentRoute = ModalRoute.of(context)?.settings.name;
                if (currentRoute != item.route) {
                  Navigator.pushNamed(context, item.route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
