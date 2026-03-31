import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/widgets/password_strength_meter.dart';
import 'package:acadex/core/widgets/custom_button.dart';
import 'package:acadex/core/widgets/custom_text_field.dart';
import 'package:acadex/core/widgets/social_login_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/lottie_loading.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _password = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {
        _password = _passwordController.text;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match!')));
      return;
    }

    try {
      await ref.read(authNotifierProvider.notifier).register(name, email, password);
      if (mounted) {
        // Pass the email to the OTP screen!
        context.push('/otp', extra: email);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B633E), // Match Login Screen dark green
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.push('/login');
                      }
                    },
                    child: Text(
                      'Login',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            // Header Texts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Sign Up',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.montserrat,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  const SizedBox(height: 12),
                  Text(
                    'Create an account to start enjoying premium academic services.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                      fontSize: 18,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  const SizedBox(height: 36),
                ],
              ),
            ),

            // Slightly Lighter Grey Bottom Sheet
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5), // Match Login whiter bottom
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 40.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Fields
                      CustomTextField(
                         hintText: 'John Doe',
                        prefixIcon: Icons.person_outline,
                        controller: _nameController,
                        isLightMode: true,
                      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      CustomTextField(
                        key: const ValueKey('email_reg_input'),
                         hintText: 'name@university.edu',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        isLightMode: true,
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      CustomTextField(
                         hintText: 'Create a strong password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        isLightMode: true,
                      ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),

                      const SizedBox(height: 16),

                      PasswordStrengthMeter(password: _password)
                          .animate()
                          .fadeIn(delay: 600.ms),

                      const SizedBox(height: 24),

                      CustomTextField(
                         hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_reset_outlined,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        isLightMode: true,
                      ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),

                      const SizedBox(height: 40),

                      // Sign Up Button -> Lottie Loader Check
                      ref.watch(authNotifierProvider).isLoading
                          ? const CustomLottieLoading(height: 60)
                          : CustomButton(
                              text: 'Create Account',
                              backgroundColor: const Color(0xFF1B633E), // Match Login screen button style
                              textColor: Colors.white,
                              onPressed: _handleRegister,
                            ).animate().fadeIn(delay: 750.ms).scale(begin: const Offset(0.95, 0.95)),

                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or Sign Up With', 
                              style: AppTextStyles.bodySmall.copyWith(letterSpacing: 0.5, color: Colors.black54),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                        ],
                      ).animate().fadeIn(delay: 800.ms),

                      const SizedBox(height: 24),

                      // Google Button
                      SocialLoginButton(
                        platform: 'Google',
                        iconPath: 'assets/icons/google.png',
                        isLightMode: true,
                        onPressed: () {
                          ref.read(authNotifierProvider.notifier).googleLogin();
                        },
                      ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.push('/login');
                            }
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Login',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
