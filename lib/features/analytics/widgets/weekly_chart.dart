import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyInsightProvider = FutureProvider<String>((ref) async {
  return 'Keep building your habits consistently!';
});

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = [3.5, 4, 2.5, 5, 4.5, 3, 5];

    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Weekly Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // WEEKLY AI INSIGHT CARD
          FadeInDown(
            child: Consumer(
              builder: (context, ref, _) {
                final insightAsync = ref.watch(weeklyInsightProvider);
                return Container(
                  margin: const EdgeInsets.only(bottom: 28),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D5DF6), Color(0xFF46A0FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6D5DF6).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🤖', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly AI Insight',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Powered by Claude AI',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      insightAsync.when(
                        data: (insight) => Text(
                          insight,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        loading: () => const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Analyzing your habits...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        error: (_, __) => const Text(
                          '🔥 Keep building your habits consistently!',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 220,

            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,

                maxY: 5,

                gridData: const FlGridData(show: false),

                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),

                  rightTitles: const AxisTitles(),

                  leftTitles: const AxisTitles(),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),

                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: weeklyData
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,

                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),

                            width: 22,

                            borderRadius: BorderRadius.circular(12),

                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9B54), Color(0xFFFFB26B)],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
