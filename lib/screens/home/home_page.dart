import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import '../auth/auth_wrapper.dart';
import '../../widgets/custom_drawer.dart';

// TODO: create homescreen
// this is just a placeholder home screen for testing
// repalce this with actual homescreen later
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Elbi Eats!'),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Text('User: ${authProvider.user?.email ?? 'Unknown'}');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
