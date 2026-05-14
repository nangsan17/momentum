import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HeatmapWidget
    extends StatelessWidget {
  const HeatmapWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      startDate: DateTime(2025, 1, 1),

      endDate: DateTime.now(),

      datasets: {
        DateTime.now(): 3,
      },

      colorMode:
          ColorMode.opacity,

      showText: true,

      scrollable: true,

      colorsets: const {
        1: Colors.orange,
      },
    );
  }
}