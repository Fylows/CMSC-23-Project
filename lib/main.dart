import 'package:elbi_eats/firebase_options.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/providers/posting/posting_provider.dart';
import 'package:elbi_eats/screens/pantry/post_item_page.dart';
import 'package:elbi_eats/screens/profile/profile_page.dart';
import 'package:elbi_eats/screens/profile/order_transactions_page.dart';
import 'package:elbi_eats/screens/profile/posted_items_page.dart';
import 'package:elbi_eats/widgets/navbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/home/home_page.dart';
import 'screens/notifications/notifications.dart';
import 'screens/leaderboard/leaderboard.dart';

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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostingProvider()),
      ],
      child: MaterialApp(
        title: 'Elbi Eats',
        theme: ThemeData(
          useMaterial3: true,
          // figma says inter but i used outfit here
          textTheme: GoogleFonts.outfitTextTheme(),
        ),
        initialRoute: '/',
        routes: {
          '/home': (context) => const MainScaffold(child: HomePage()),
          '/post-item': (context) => const PostItemPage(),

          '/notifications': (context) => const NotificationsPage(),
          // --- NAV BAR ---
          // '/pantry' : (context) => const MainScaffold(currentRoute: '/pantry', child: PantryScreen()),
          // '/chat' : (context) => const MainScaffold(currentRoute: '/chat', child: ChatScreen()),
          // '/cart' : (context) => const MainScaffold(currentRoute: '/cart', child: CartScreen()),

          // --- DRAWER ---
          '/profile': (context) => const ProfilePage(),
          '/order-transactions': (context) => const OrderTransactionsPage(),
          '/posted-items': (context) => const PostedItemsPage(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          // '/settings' : (context) => const SettingsScreen(),
        },
        home: const AuthWrapper(),
      ),
    );
  }
}
