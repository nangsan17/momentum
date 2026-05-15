import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().init();

  runApp(const ProviderScope(child: MomentumApp()));
}

class MomentumApp extends StatefulWidget {
  const MomentumApp({super.key});

  static _MomentumAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MomentumAppState>();
  }

  @override
  State<MomentumApp> createState() => _MomentumAppState();
}

class _MomentumAppState extends State<MomentumApp> {
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Momentum',
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,

      home: const OnboardingScreen(),
    );
  }
}
