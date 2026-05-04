import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/screens/auth/auth_wrapper.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Logo and Dark Mode Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Elbi-Eats',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCB2020),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.nightlight_round_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Home Button
            _buildDrawerItem(
              context,
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name != '/home') {
                  Navigator.pushNamed(context, '/home');
                }
              },
            ),

            // Profile Button
            _buildDrawerItem(
              context,
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name != '/profile') {
                  Navigator.pushNamed(context, '/profile');
                }
              },
            ),

            _buildDrawerItem(
              context,
              icon: Icons.leaderboard_outlined,
              title: 'Leaderboards',
              onTap: () {},
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),

            const Spacer(),

            // Log Out Button - FIXED HERE
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextButton.icon(
                    // Use authProvider.isLoading instead of AuthProvider.isLoading
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            Navigator.pop(context);

                            // Use authProvider.signOut() instead of AuthProvider.signOut()
                            await authProvider.signOut();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthWrapper(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
