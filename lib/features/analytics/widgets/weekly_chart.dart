import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

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
