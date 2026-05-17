import 'package:flutter/material.dart';
import 'package:elbi_eats/widgets/custom_drawer.dart';
import 'package:elbi_eats/screens/leaderboard/leaderboard_handler.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/providers/leaderboard/leaderboard_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user!.uid;
      context.read<LeaderboardProvider>().loadLeaderboard(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;

    // Auth still loading or user signed out
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final leaderboard = context.watch<LeaderboardProvider>();

    if (leaderboard.isLoading || leaderboard.topThree.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return RefreshIndicator(
      onRefresh: () {
        final uid = context.read<AuthProvider>().user!.uid;
        return context.read<LeaderboardProvider>().refresh(uid);
      },

      child: Scaffold(
        backgroundColor: Color(0xFFFAF6EE),
        drawer: const CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Leaderboard',
            style: TextStyle(
              color: Color(0xFFCB2020),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[300], height: 1),
          ),
        ),
        body: Column(
          children: [
            TopThreePodium(top3: leaderboard.state.topThree),

            // Scrollable list with rounded top
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: Column(
                    children: [
                      const ListHeader(),
                      const Divider(height: 1),
                      if (leaderboard.state.currentUser != null)
                        LeaderboardRow(entry: leaderboard.state.currentUser!),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: leaderboard.state.rest.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) => LeaderboardRow(
                            entry: leaderboard.state.rest[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
