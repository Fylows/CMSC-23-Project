class LeaderboardEntry {
  final int rank;
  final String username;
  final int contributions;
  final String? imageUrl;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.contributions,
    this.imageUrl,
    this.isCurrentUser = false,
  });
}
