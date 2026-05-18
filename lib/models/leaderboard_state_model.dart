// lib/models/leaderboard_state.dart
import 'leaderboard_entry_model.dart';

class LeaderboardState {
  final List<LeaderboardEntry> topThree;
  final List<LeaderboardEntry> rest;
  final LeaderboardEntry? currentUser;
  final bool isLoading;
  final String? error;
  final DateTime? lastFetched;

  const LeaderboardState({
    this.topThree = const [],
    this.rest = const [],
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.lastFetched,
  });

  // Check if cache is still fresh (within 24 hours)
  bool get isCacheValid {
    if (lastFetched == null) return false;
    return DateTime.now().difference(lastFetched!) < const Duration(hours: 24);
  }

  LeaderboardState copyWith({
    List<LeaderboardEntry>? topThree,
    List<LeaderboardEntry>? rest,
    LeaderboardEntry? currentUser,
    bool? isLoading,
    String? error,
    DateTime? lastFetched,
  }) {
    return LeaderboardState(
      topThree: topThree ?? this.topThree,
      rest: rest ?? this.rest,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}
