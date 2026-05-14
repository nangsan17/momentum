import 'dart:convert';
import 'dart:typed_data';

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
  String imageBase64 = '';
  bool darkMode = false;
  bool uploadingImage = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);

  int xp = 420;

  int get level => (xp ~/ 100) + 1;

  double get levelProgress => (xp % 100) / 100;

  String get levelTitle {
    if (level >= 15) {
      return "👑 Discipline Master";
    }

    if (level >= 10) {
      return "🔥 Consistency Beast";
    }

    if (level >= 5) {
      return "⚡ Momentum Builder";
    }

    return "🌱 Beginner";
  }

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
    if (!mounted) return;
    setState(() {
      username = data?['username'] ?? 'Momentum User';
      email = data?['email'] ?? '';
      imageBase64 = data?['imageBase64'] ?? '';
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (picked == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => uploadingImage = true);

    try {
      final Uint8List bytes = await picked.readAsBytes();
      await UserService().uploadProfileImage(uid: user.uid, imageBytes: bytes);
      if (!mounted) return;
      setState(() {
        imageBase64 = base64Encode(bytes);
        uploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated! ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => uploadingImage = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload: $e')));
    }
  }

  Future<void> showEditUsernameDialog() async {
    final controller = TextEditingController(text: username);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new username',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isEmpty) return;

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              await UserService().updateUsername(
                uid: user.uid,
                username: newUsername,
              );

              if (!mounted) return;
              setState(() => username = newUsername);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Username updated! ✅')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> showResetPasswordDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset Password'),
        content: Text('A reset link will be sent to:\n\n${user.email}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: user.email!,
              );
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset email sent! Check your inbox 📧'),
                ),
              );
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  Future<void> pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (time == null) return;
    setState(() => reminderTime = time);
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

  ImageProvider? get profileImage {
    if (imageBase64.isNotEmpty) {
      return MemoryImage(base64Decode(imageBase64));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PROFILE PICTURE
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary,
                    backgroundImage: profileImage,
                    child: uploadingImage
                        ? const CircularProgressIndicator(color: Colors.white)
                        : profileImage == null
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
                        Icons.camera_alt,
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
              onTap: showEditUsernameDialog,
            ),

            buildTile(
              icon: Icons.notifications,
              title: 'Reminder Time 🔔',
              subtitle: 'Choose your daily reminder',
              onTap: pickReminderTime,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 24),

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D5DF6), Color(0xFF46A0FF)],
                ),

                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      const Text("🎮", style: TextStyle(fontSize: 34)),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Level $level",

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 24,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              levelTitle,

                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "$xp XP",

                        style: const TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.bold,

                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: LinearProgressIndicator(
                      value: levelProgress,

                      minHeight: 14,

                      backgroundColor: Colors.white24,

                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "${100 - (xp % 100)} XP until next level 🚀",

                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
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
                  setState(() => darkMode = value);
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
              onTap: showResetPasswordDialog,
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
