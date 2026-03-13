import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class SocialLoginButton extends StatelessWidget {
  final String platform;
  final String iconPath;
  final VoidCallback onPressed;
  final bool isLightMode;

  const SocialLoginButton({
    super.key,
    required this.platform,
    required this.iconPath,
    required this.onPressed,
    this.isLightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isLightMode ? Colors.white : AppColors.surface;
    final borderColor = isLightMode ? Colors.grey[200]! : AppColors.surfaceHighlight;
    final textColor = isLightMode ? Colors.black87 : Colors.white;
    final splashColor = isLightMode ? Colors.grey[200]! : AppColors.surfaceHighlight.withOpacity(0.5);
    final highlightColor = isLightMode ? Colors.grey[100]! : AppColors.surfaceHighlight.withOpacity(0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Container(
          width: double.infinity,
          height: 56, // Slightly taller for the reference UI
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isLightMode
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              iconPath.isNotEmpty
                  ? Image.asset(
                      iconPath,
                      height: 24,
                      width: 24,
                    )
                  : Icon(
                      platform == 'Facebook' ? Icons.facebook : Icons.account_circle,
                      color: platform == 'Facebook' ? Colors.blue : Colors.grey,
                      size: 24,
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  platform == 'Google' ? 'Continue with Google' : 'Continue with Facebook',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (isLightMode)
                Icon(
                  Icons.arrow_forward,
                  color: Colors.black54,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
