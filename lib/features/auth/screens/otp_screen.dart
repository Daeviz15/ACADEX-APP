import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/widgets/custom_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/lottie_loading.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  
  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    // Start the lock animation loop
    _startLockAnimation();
  }

  void _startLockAnimation() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isLocked = !_isLocked;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length < 6) return;
    
    try {
      await ref.read(authNotifierProvider.notifier).verifyOtp(widget.email, otpCode);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Animated Lock Icon (Refined size and static position)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                        color: AppColors.primary,
                        size: 32,
                      )
                      .animate(target: _isLocked ? 1 : 0)
                      .shakeX(hz: 2, amount: 1)
                      .scale(
                        begin: const Offset(0.9, 0.9), 
                        end: const Offset(1.1, 1.1), 
                        duration: 500.ms, 
                        curve: Curves.elasticOut
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: AppTextStyles.montserrat,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      children: [
                        const TextSpan(text: 'Enter OTP to '),
                        TextSpan(
                          text: 'Verify\n',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        const TextSpan(text: 'Your Identity '),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  Text(
                    'A one-time password (OTP) has been sent to\nyour registered email or phone number.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 48),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        height: 60,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.montserrat,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(35),
                              borderSide: const BorderSide(color: AppColors.surfaceHighlight, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(35),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.surface.withOpacity(0.5),
                          ),
                        ),
                      ).animate().fadeIn(delay: (400 + (index * 100)).ms).scale(begin: const Offset(0.8, 0.8));
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Resend Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Resend code in ',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        '00:30',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 48),

                  ref.watch(authNotifierProvider).isLoading
                      ? const CustomLottieLoading(height: 60)
                      : CustomButton(
                          text: 'Continue',
                          onPressed: _handleContinue,
                        ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.95, 0.95)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
