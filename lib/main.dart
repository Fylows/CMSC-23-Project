import 'package:elbi_eats/firebase_options.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/widgets/navbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_wrapper.dart';
import '../../screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Elbi Eats',
        theme: ThemeData(
          useMaterial3: true,
          // figma says inter but i used outfit here
          textTheme: GoogleFonts.outfitTextTheme(),
        ),
        initialRoute: '/',
        routes: {
          '/home': (context) =>
              const MainScaffold(currentRoute: '/home', child: HomeScreen()),

          // --- NAV BAR ---
          // '/pantry' : (context) => const MainScaffold(currentRoute: '/pantry', child: PantryScreen()),
          // '/chat' : (context) => const MainScaffold(currentRoute: '/chat', child: ChatScreen()),
          // '/cart' : (context) => const MainScaffold(currentRoute: '/cart', child: CartScreen()),

          // --- DRAWER ---
          // '/profile' : (context) => const ProfileScreen(),
          // '/leaderboard' : (context) => const LeaderboardScreen(),
          // '/settings' : (context) => const SettingsScreen(),
        },
        home: const AuthWrapper(),
      ),
    );
  }
}
