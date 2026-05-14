import 'package:flutter/material.dart';

import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/habits/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../main.dart';
import '../../core/theme/app_theme.dart';
import '../../features/calendar/screens/calendar_screen.dart';

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = MomentumApp.of(context);
    return MainNavigation(
      isDarkMode: appState?.isDarkMode ?? false,
      onThemeChanged: appState?.toggleTheme ?? (_) {},
    );
  }
}

class MainNavigation extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const MainNavigation({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final screens = [
      const HomeScreen(),
      const AnalyticsScreen(),
      const CalendarScreen(),
      ProfileScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    final navBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final outerBgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF6F3EE);
    final scaffoldBgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF6F3EE);

    return Scaffold(
      backgroundColor: outerBgColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: BoxDecoration(
            color: scaffoldBgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            child: Scaffold(
              backgroundColor: scaffoldBgColor,
              body: screens[currentIndex],
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: NavigationBar(
                    height: 70,
                    backgroundColor: navBgColor,
                    indicatorColor: isDark
                        ? AppColors.primary.withOpacity(0.25)
                        : const Color(0xFFFFE4D6),
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      setState(() => currentIndex = index);
                    },
                    destinations: [
                      NavigationDestination(
                        icon: Icon(
                          Icons.home_rounded,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        selectedIcon: const Icon(
                          Icons.home_rounded,
                          color: AppColors.primary,
                        ),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.bar_chart_rounded,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        selectedIcon: const Icon(
                          Icons.bar_chart_rounded,
                          color: AppColors.primary,
                        ),
                        label: 'Analytics',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        selectedIcon: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                        ),
                        label: 'Calendar',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.person_rounded,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        selectedIcon: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                        ),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
