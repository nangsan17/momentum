import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';

class CalendarScreen
    extends StatefulWidget {
  const CalendarScreen({
    super.key,
  });

  @override
  State<CalendarScreen> createState() =>
      _CalendarScreenState();
}

class _CalendarScreenState
    extends State<CalendarScreen> {
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        title: const Text(
          'Habit Calendar 📅',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Container(
          padding:
              const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
                  28,
                ),
          ),

          child: TableCalendar(
            focusedDay: today,
            firstDay:
                DateTime.utc(2020),
            lastDay:
                DateTime.utc(2035),

            selectedDayPredicate:
                (day) {
              return isSameDay(
                today,
                day,
              );
            },

            onDaySelected:
                (
                  selectedDay,
                  focusedDay,
                ) {
              setState(() {
                today = selectedDay;
              });
            },

            calendarStyle:
                CalendarStyle(
                  todayDecoration:
                      BoxDecoration(
                        color:
                            AppColors
                                .primary,

                        shape:
                            BoxShape.circle,
                      ),

                  selectedDecoration:
                      BoxDecoration(
                        color:
                            Colors.orange,

                        shape:
                            BoxShape.circle,
                      ),
                ),
          ),
        ),
      ),
    );
  }
}