import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/screens/login_screen.dart';
import '../models/onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentIndex = 0;

  final List<List<Color>> gradients = [
    [const Color(0xFFFFE0D2), const Color(0xFFFFF4EC)],

    [const Color(0xFFE6D6FF), const Color(0xFFF6F0FF)],

    [const Color(0xFFFFD6E7), const Color(0xFFFFF3F7)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),

      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),

          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),

                blurRadius: 30,

                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),

              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,

                      itemCount: onboardingPages.length,

                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },

                      itemBuilder: (context, index) {
                        final page = onboardingPages[index];

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),

                          curve: Curves.easeInOut,

                          padding: const EdgeInsets.all(28),

                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,

                              end: Alignment.bottomRight,

                              colors: gradients[index],
                            ),

                            borderRadius: BorderRadius.circular(36),
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Container(
                                padding: const EdgeInsets.all(28),

                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.45),

                                  shape: BoxShape.circle,
                                ),

                                child: Text(
                                  page.emoji,

                                  style: const TextStyle(fontSize: 82),
                                ),
                              ),

                              const SizedBox(height: 42),

                              Text(
                                page.title,

                                textAlign: TextAlign.center,

                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,

                                      fontSize: 38,

                                      letterSpacing: -1,

                                      height: 1.1,

                                      color: const Color(0xFF2B2B2B),
                                    ),
                              ),

                              const SizedBox(height: 22),

                              Text(
                                page.description,

                                textAlign: TextAlign.center,

                                style: const TextStyle(
                                  fontSize: 17,

                                  color: Colors.black54,

                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 34),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: List.generate(
                      onboardingPages.length,

                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),

                        margin: const EdgeInsets.symmetric(horizontal: 5),

                        width: currentIndex == index ? 28 : 8,

                        height: 8,

                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? const Color(0xFFFF9B54)
                              : Colors.grey.shade300,

                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),

                  SizedBox(
                    width: double.infinity,

                    child: PrimaryButton(
                      text: currentIndex == onboardingPages.length - 1
                          ? 'Get Started'
                          : 'Next',

                      onPressed: () {
                        if (currentIndex == onboardingPages.length - 1) {
                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 450),

                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
