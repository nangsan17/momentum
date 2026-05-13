import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: MomentumApp(),
    ),
  );
}

class MomentumApp
    extends ConsumerWidget {
  const MomentumApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isDark = ref.watch(
      themeProvider,
    );

    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title: 'Momentum',

      theme:
          isDark
              ? darkTheme
              : AppTheme.lightTheme,

      home:
          const OnboardingScreen(),
    );
  }
}