import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../common/custom_button.dart';
import '../auth/login_view.dart';

/// 3-step onboarding walkthrough explaining Medicine Reminders, ESP32 IoT, and AI Risk Prediction.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _pages = const [
    _OnboardingItem(
      title: 'Never Miss a Medicine',
      description:
          'Get intelligent, scheduled medication reminders tailored to your daily routine with zero hassle.',
      icon: Icons.alarm_on_rounded,
      color: AppColors.primary,
    ),
    _OnboardingItem(
      title: 'Stay Connected with IoT',
      description:
          'Integrated ESP32 smart dispenser with IR sensors and LCD display monitors dose intake in real time.',
      icon: Icons.sensors_rounded,
      color: AppColors.secondary,
    ),
    _OnboardingItem(
      title: 'Smarter Care with AI',
      description:
          'Machine learning models analyze historical adherence patterns to help caregivers prevent missed doses early.',
      icon: Icons.psychology_rounded,
      color: AppColors.primaryLight,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginView()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Skip',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Icon Box
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 72,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title
                        Text(
                          item.title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          item.description,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Action Area
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    onPressed: _onNext,
                    icon: _currentPage == _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
