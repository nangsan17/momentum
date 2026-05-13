import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/user_service.dart';
import '../widgets/achievement_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null) return;

    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent ✨')),
    );
  }

  Future<void> pickReminderTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,

      initialTime: const TimeOfDay(hour: 21, minute: 0),
    );

    if (time == null) return;

    await NotificationService.scheduleCustomNotification(
      time.hour,
      time.minute,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for ${time.format(context)} 🔥')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return StreamBuilder(
      stream: UserService().getUserStream(),

      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final username = data?['name'] ?? 'Momentum User';

        final email = data?['email'] ?? '';

        return Scaffold(
          backgroundColor: AppColors.background,

          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    const CircleAvatar(
                      radius: 55,

                      backgroundColor: AppColors.primary,

                      child: Icon(Icons.person, size: 55, color: Colors.white),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      username,

                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      email,

                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        'Achievements 🏆',

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 170,

                      child: ListView(
                        scrollDirection: Axis.horizontal,

                        children: const [
                          AchievementCard(title: '7 Day Streak', emoji: '🔥'),

                          AchievementCard(title: 'First Habit', emoji: '🚀'),

                          AchievementCard(
                            title: 'Consistency King',
                            emoji: '👑',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(28),
                      ),

                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.notifications_active_rounded,
                              color: AppColors.primary,
                            ),

                            title: const Text('Set Reminder Time 🔔'),

                            subtitle: const Text('Choose your daily reminder'),

                            onTap: () => pickReminderTime(context),
                          ),

                          const Divider(),

                          SwitchListTile(
                            value: isDark,

                            title: const Text('Dark Mode 🌙'),

                            onChanged: (value) {
                              ref.read(themeProvider.notifier).state = value;
                            },
                          ),

                          const Divider(),

                          ListTile(
                            leading: const Icon(
                              Icons.calendar_month,
                              color: Colors.orange,
                            ),

                            title: const Text('Habit Calendar'),

                            subtitle: const Text('Track your consistency 📅'),
                          ),

                          const Divider(),

                          ListTile(
                            leading: const Icon(
                              Icons.lock_reset_rounded,
                              color: Colors.orange,
                            ),

                            title: const Text('Reset Password'),

                            onTap: () => resetPassword(context),
                          ),

                          const Divider(),

                          ListTile(
                            leading: const Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                            ),

                            title: const Text('Logout'),

                            onTap: () => logout(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Keep building consistency 🔥',

                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
