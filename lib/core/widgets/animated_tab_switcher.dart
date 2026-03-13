import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class AnimatedTabSwitcher extends StatefulWidget {
  final String leftLabel;
  final String rightLabel;
  final Function(int index) onTabChanged;

  const AnimatedTabSwitcher({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.onTabChanged,
  });

  @override
  State<AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<AnimatedTabSwitcher> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight.withOpacity(
          0.5,
        ), // Softer inner background
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              // Animated Background Pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                left: _selectedIndex == 0 ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Tap targets
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedIndex = 0);
                        widget.onTabChanged(0);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: AppTextStyles.button.copyWith(
                            color: _selectedIndex == 0
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontWeight: _selectedIndex == 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          child: Text(widget.leftLabel),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        widget.onTabChanged(1);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: AppTextStyles.button.copyWith(
                            color: _selectedIndex == 1
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontWeight: _selectedIndex == 1
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          child: Text(widget.rightLabel),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
