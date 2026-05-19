import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:elbi_eats/models/leaderboard_entry_model.dart';
// ─── Rank Badge ───────────────────────────────────────────────────────────────

class RankBadge extends StatelessWidget {
  final int rank;

  const RankBadge(this.rank);

  Color get _color => switch (rank) {
    1 => const Color(0xFFE8C84A),
    2 => Colors.grey.shade600,
    3 => const Color(0xFF6BC76B),
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Top 3 Avatar ─────────────────────────────────────────────────────────────

class TopAvatar extends StatelessWidget {
  final LeaderboardEntry entry;
  final double size;
  final Color outlineColor;

  const TopAvatar({
    required this.entry,
    required this.size,
    required this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: outlineColor, width: 3),
                color: Colors.grey.shade300,
                image: entry.imageUrl != null
                    ? DecorationImage(
                        image: (entry.imageUrl!.startsWith('data:image')
                            ? MemoryImage(base64Decode(
                                entry.imageUrl!.split(',').last))
                            : NetworkImage(entry.imageUrl!)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: entry.imageUrl == null
                  ? Icon(
                      Icons.person,
                      size: size * 0.5,
                      color: Colors.grey.shade500,
                    )
                  : null,
            ),
            Positioned(top: -4, right: -4, child: RankBadge(entry.rank)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        Text(
          entry.contributions.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          ),
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// ─── Top 3 Podium ─────────────────────────────────────────────────────────────

class TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> top3;

  const TopThreePodium({required this.top3});

  @override
  Widget build(BuildContext context) {
    final first = top3.firstWhere((e) => e.rank == 1);
    final second = top3.firstWhere((e) => e.rank == 2);
    final third = top3.firstWhere((e) => e.rank == 3);

    return Container(
      color: const Color(0xFFFAF6EE),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          // 1st place centered on top
          TopAvatar(
            entry: first,
            size: 100,
            outlineColor: const Color(0xFFE8C84A),
          ),
          const SizedBox(height: 16),
          // 2nd and 3rd side by side
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopAvatar(
                entry: second,
                size: 76,
                outlineColor: Colors.grey.shade400,
              ),
              TopAvatar(
                entry: third,
                size: 76,
                outlineColor: const Color(0xFF6BC76B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── List Row ─────────────────────────────────────────────────────────────────

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: entry.isCurrentUser ? const Color(0xFFFDE8D8) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 48,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontWeight: entry.isCurrentUser
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              image: entry.imageUrl != null
                  ? DecorationImage(
                      image: (entry.imageUrl!.startsWith('data:image')
                          ? MemoryImage(
                              base64Decode(entry.imageUrl!.split(',').last))
                          : NetworkImage(entry.imageUrl!)) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: entry.imageUrl == null
                ? Icon(Icons.person, size: 20, color: Colors.grey.shade500)
                : null,
          ),
          const SizedBox(width: 12),
          // Username
          Expanded(
            child: Text(
              entry.username,
              style: TextStyle(
                fontSize: 14,
                fontWeight: entry.isCurrentUser
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
          // Contributions
          Text(
            '${entry.contributions}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: entry.isCurrentUser
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Column Headers ───────────────────────────────────────────────────────────

class ListHeader extends StatelessWidget {
  const ListHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 8),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text('RANK', style: _headerStyle)),
          Text('USER', style: _headerStyle),
          const Spacer(),
          Text('CONTRIBUTIONS', style: _headerStyle),
        ],
      ),
    );
  }

  TextStyle get _headerStyle => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade500,
    letterSpacing: 0.5,
  );
}

// ─── Leaderboard Page ─────────────────────────────────────────────────────────
