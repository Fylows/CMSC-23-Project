import 'package:flutter/material.dart';
import 'package:elbi_eats/widgets/custom_drawer.dart';
import 'package:elbi_eats/screens/leaderboard/leaderboard_handler.dart';

// ─── Sample Data ──────────────────────────────────────────────────────────────

final _topThree = [
  const LeaderboardEntry(
    rank: 1,
    username: 'Mike Oxmole',
    contributions: 1200,
    imageUrl: 'https://i.pravatar.cc/150?img=12',
  ),
  const LeaderboardEntry(
    rank: 2,
    username: 'Mike Oxmed',
    contributions: 1200,
    imageUrl: 'https://i.pravatar.cc/150?img=47',
  ),
  const LeaderboardEntry(
    rank: 3,
    username: 'Mike Oxvig',
    contributions: 1200,
    imageUrl: 'https://i.pravatar.cc/150?img=32',
  ),
];

final _currentUser = const LeaderboardEntry(
  rank: 8,
  username: 'MyUser',
  contributions: 120,
  isCurrentUser: true,
);

final _restOfList = [
  LeaderboardEntry(rank: 4, username: 'Maria Santos', contributions: 980),
  LeaderboardEntry(rank: 5, username: 'Juan dela Cruz', contributions: 870),
  LeaderboardEntry(rank: 6, username: 'Ana Reyes', contributions: 760),
  LeaderboardEntry(rank: 7, username: 'Carlo Mendoza', contributions: 540),
  LeaderboardEntry(
    rank: _currentUser.rank,
    username: _currentUser.username,
    contributions: _currentUser.contributions,
    isCurrentUser: _currentUser.isCurrentUser,
  ),
  LeaderboardEntry(rank: 9, username: 'Rosa Villanueva', contributions: 95),
  LeaderboardEntry(rank: 10, username: 'Pedro Bautista', contributions: 80),
  LeaderboardEntry(rank: 11, username: 'Liza Gomez', contributions: 60),
];

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          TopThreePodium(top3: _topThree),

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
                    LeaderboardRow(entry: _currentUser),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _restOfList.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) =>
                            LeaderboardRow(entry: _restOfList[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
