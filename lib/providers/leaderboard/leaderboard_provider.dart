import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elbi_eats/models/leaderboard_entry_model.dart';
import 'package:elbi_eats/models/leaderboard_state_model.dart';

class LeaderboardProvider extends ChangeNotifier {
  final String currentUid;

  LeaderboardProvider(this.currentUid) {
    loadLeaderboard(currentUid);
  }

  LeaderboardState _state = const LeaderboardState();
  LeaderboardState get state => _state;

  List<LeaderboardEntry> get topThree => _state.topThree;
  List<LeaderboardEntry> get rest => _state.rest;
  LeaderboardEntry? get currentUser => _state.currentUser;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  static const _cacheKey = 'leaderboard_last_fetched';

  // ─── Check persisted cache on startup ───────────────────────────────────
  Future<bool> _isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_cacheKey);
    if (stored == null) return false;

    final lastFetched = DateTime.tryParse(stored);
    if (lastFetched == null) return false;

    return DateTime.now().difference(lastFetched) < const Duration(hours: 24);
  }

  Future<void> _stampCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, DateTime.now().toIso8601String());
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  // ─── Load ────────────────────────────────────────────────────────────────
  Future<void> loadLeaderboard(
    String currentUid, {
    bool forceRefresh = false,
  }) async {
    final cacheValid = await _isCacheValid();

    if (cacheValid && !forceRefresh && _state.topThree.isNotEmpty) {
      return;
    }

    await _fetchAndUpdate(currentUid, silent: false);
  }

  Future<void> _fetchAndUpdate(String currentUid, {bool silent = false}) async {
    if (!silent) {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();
    }

    try {
      // 1. Top 3
      final topSnap = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('contributorScore', descending: true)
          .orderBy('createdAt')
          .orderBy('username')
          .limit(3)
          .get();

      if (topSnap.docs.isEmpty) {
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return;
      }

      final topThree = topSnap.docs
          .asMap()
          .entries
          .map((e) => _docToEntry(e.value, e.key + 1, currentUid))
          .toList();

      // 2. Rest — only fetch if there are more docs beyond top 3
      List<LeaderboardEntry> rest = [];
      if (topSnap.docs.length >= 3) {
        final restSnap = await FirebaseFirestore.instance
            .collection('users')
            .orderBy('contributorScore', descending: true)
            .orderBy('createdAt')
            .orderBy('username')
            .startAfterDocument(topSnap.docs.last)
            .limit(20)
            .get();

        rest = restSnap.docs
            .toList()
            .asMap()
            .entries
            .map(
              (e) => _docToEntry(e.value, e.key + 4, currentUid),
            ) // then index
            .toList();
      }

      // 3. Current user — derive rank from visible list first to avoid duplicates
      final allVisible = [...topThree, ...rest];
      final visibleEntry = allVisible.cast<LeaderboardEntry?>().firstWhere(
        (e) => e?.isCurrentUser == true,
        orElse: () => null,
      );

      LeaderboardEntry currentUser;

      if (visibleEntry != null) {
        // Already in the leaderboard — reuse the rank, it's consistent
        currentUser = visibleEntry;
      } else {
        // Outside visible window — compute rank respecting all sort fields
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .get();

        final data = currentUserDoc.data() ?? {};
        final currentScore = data['contributorScore'] ?? 0;
        final currentCreatedAt = data['createdAt'];

        final results = await Future.wait([
          // Users with a strictly higher score
          FirebaseFirestore.instance
              .collection('users')
              .where('contributorScore', isGreaterThan: currentScore)
              .count()
              .get(),
          // Users with the same score but an earlier createdAt (higher rank)
          if (currentCreatedAt != null)
            FirebaseFirestore.instance
                .collection('users')
                .where('contributorScore', isEqualTo: currentScore)
                .where('createdAt', isLessThan: currentCreatedAt)
                .count()
                .get(),
        ]);

        final aboveByScore = results[0].count ?? 0;
        final aboveByDate = results.length > 1 ? (results[1].count ?? 0) : 0;
        final rank = aboveByScore + aboveByDate + 1;

        currentUser = LeaderboardEntry(
          rank: rank,
          username: data['username'] ?? 'Me',
          contributions: currentScore,
          imageUrl: data['profilePictureUrl'],
          isCurrentUser: true,
        );
      }

      _state = _state.copyWith(
        topThree: topThree,
        rest: rest,
        currentUser: currentUser,
        isLoading: false,
        lastFetched: DateTime.now(),
      );
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }

    notifyListeners();
  }

  /// Pull-to-refresh — clears persisted cache and force fetches
  Future<void> refresh(String currentUid) async {
    await _clearCache();
    await _fetchAndUpdate(currentUid, silent: false);
  }

  LeaderboardEntry _docToEntry(
    DocumentSnapshot doc,
    int rank,
    String currentUid,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      rank: rank,
      username: data['username'] ?? data['displayName'] ?? 'Unknown',
      contributions: data['contributorScore'] ?? 0,
      imageUrl: data['profilePictureUrl'],
      isCurrentUser: doc.id == currentUid,
    );
  }
}
