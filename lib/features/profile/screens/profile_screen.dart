import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/user_service.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../achievements/screens/achievement_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    this.onThemeChanged,
    this.isDarkMode = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = 'Momentum User';

  String email = '';

  String imagePath = '';

  bool darkMode = false;

  TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();

    darkMode = widget.isDarkMode;

    loadUser();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final data = await UserService().getUser(user.uid);

    setState(() {
      username = data?['username'] ?? 'Momentum User';

      email = data?['email'] ?? '';

      imagePath = data?['imageUrl'] ?? '';
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await UserService().updateProfileImage(
      uid: user.uid,
      imageUrl: picked.path,
    );

    setState(() {
      imagePath = picked.path;
    });
  }

  Future<void> pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );

    if (time == null) return;

    setState(() {
      reminderTime = time;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set to ${time.format(context)} 🔔')),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,

              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,

                    backgroundColor: AppColors.primary,

                    backgroundImage: imagePath.isNotEmpty
                        ? FileImage(File(imagePath))
                        : null,

                    child: imagePath.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,

                    child: Container(
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              username,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              email,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),

            const SizedBox(height: 40),

            buildTile(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Update your username',
              onTap: () {},
            ),

            buildTile(
              icon: Icons.notifications,
              title: 'Reminder Time 🔔',
              subtitle: 'Choose your daily reminder',
              onTap: pickReminderTime,
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 16),

              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,

                borderRadius: BorderRadius.circular(20),
              ),

              child: SwitchListTile(
                value: darkMode,

                activeColor: AppColors.primary,

                title: const Text('Dark Mode 🌙'),

                subtitle: const Text('Enable dark theme'),

                onChanged: (value) {
                  setState(() {
                    darkMode = value;
                  });

                  widget.onThemeChanged?.call(value);
                },
              ),
            ),

            buildTile(
              icon: Icons.calendar_month,
              title: 'Habit Calendar',
              subtitle: 'Track your consistency 📅',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                );
              },
            ),
            buildTile(
              icon: Icons.emoji_events,
              title: 'Achievements',
              subtitle: 'View your unlocked badges 🏆',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementScreen()),
                );
              },
            ),

            buildTile(
              icon: Icons.lock_reset,
              title: 'Reset Password',
              subtitle: 'Change your password',
              onTap: () {},
            ),

            buildTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out from account',
              color: Colors.red,
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(20),
      ),

      child: ListTile(
        onTap: onTap,

        leading: Icon(icon, color: color ?? AppColors.primary),

        title: Text(title),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
