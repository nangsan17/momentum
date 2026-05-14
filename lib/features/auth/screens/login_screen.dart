import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/main_navigation.dart';
import '../../../shared/widgets/primary_button.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await AuthService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // LOGO
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🔥', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: const Text(
                      'Build\nMomentum.',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: const Text(
                      'Track habits, stay consistent,\nand improve every day.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

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
                        : PrimaryButton(text: 'Login', onPressed: login),
                  ),

                  const SizedBox(height: 16),

                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}