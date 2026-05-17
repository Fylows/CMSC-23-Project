import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:elbi_eats/models/user/user_model.dart';
import 'package:elbi_eats/screens/home/leaderboard_bar.dart';
import 'package:elbi_eats/screens/leaderboard/leaderboard_handler.dart';

class LeaderboardProvider {
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
      imageUrl: data['profilePictureUrl'], // nullable, matches your mock
      isCurrentUser: doc.id == currentUid, // compare uid
    );
  }

  Future<
    ({
      List<LeaderboardEntry> topThree,
      List<LeaderboardEntry> rest,
      LeaderboardEntry? currentUser,
      int currentUserRank,
    })
  >
  fetchLeaderboard(String currentUid) async {
    // 1. Fetch top 3
    final topSnap = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('contributorScore', descending: true)
        .limit(3)
        .get();

    final topThree = topSnap.docs
        .asMap()
        .entries
        .map((e) => _docToEntry(e.value, e.key + 1, currentUid))
        .toList();

    // 2. Fetch rest (4 onwards)
    final restSnap = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('contributorScore', descending: true)
        .startAfterDocument(topSnap.docs.last)
        .limit(20)
        .get();

    final rest = restSnap.docs
        .asMap()
        .entries
        .map((e) => _docToEntry(e.value, e.key + 4, currentUid)) // offset by 3
        .toList();

    // 3. Get current user's rank
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .get();
    final currentScore = currentUserDoc.data()?['contributorScore'] ?? 0;

    final aboveCount = await FirebaseFirestore.instance
        .collection('users')
        .where('contributorScore', isGreaterThan: currentScore)
        .count()
        .get();

    final currentUserRank = (aboveCount.count ?? 0) + 1;

    final currentUser = LeaderboardEntry(
      rank: currentUserRank,
      username: currentUserDoc.data()?['username'] ?? 'Me',
      contributions: currentScore,
      imageUrl: currentUserDoc.data()?['profilePictureUrl'],
      isCurrentUser: true,
    );

    return (
      topThree: topThree,
      rest: rest,
      currentUser: currentUser,
      currentUserRank: currentUserRank,
    );
  }
}
