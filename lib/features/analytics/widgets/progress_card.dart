import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const ProgressCard({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF9B54),
            Color(0xFFFFB26B),
          ],
        ),

        borderRadius: BorderRadius.circular(32),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  completed == total
                      ? 'Daily Champion 🏆'
                      : 'Today Progress',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '$completed / $total habits completed',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  completed == total
                      ? 'Perfect day! You crushed it 🔥'
                      : completed >= total / 2
                          ? 'Great progress today 🚀'
                          : 'Keep building momentum 💪',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          SizedBox(
            height: 80,
            width: 80,

            child: Stack(
              alignment: Alignment.center,

              children: [
                SizedBox(
                  height: 80,
                  width: 80,

                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,

                    backgroundColor:
                        Colors.white.withValues(
                      alpha: 0.25,
                    ),

                    valueColor:
                        const AlwaysStoppedAnimation(
                      Colors.white,
                    ),
                  ),
                ),

                Text(
                  '${(progress * 100).toInt()}%',

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}