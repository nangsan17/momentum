import 'package:flutter/material.dart';

class AchievementCard
    extends StatelessWidget {
  final String title;
  final String emoji;

  const AchievementCard({
    super.key,
    required this.title,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin:
          const EdgeInsets.only(right: 16),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Text(
            emoji,

            style: const TextStyle(
              fontSize: 42,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}