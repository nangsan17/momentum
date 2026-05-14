import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/main_navigation.dart';
import '../../../shared/widgets/primary_button.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;

  Future<void> register() async {
    setState(() => loading = true);
    try {
      final userCredential = await AuthService().register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      await UserService().createUser(
        uid: userCredential.user!.uid,
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: const Text(
                    'Create\nAccount 🚀',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Start your habit journey today.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(text: 'Create Account', onPressed: register),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}