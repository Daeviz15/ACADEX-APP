import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/features/auth/providers/auth_provider.dart';
import 'package:acadex/config/theme/theme_provider.dart';

class ProfileSettingsList extends ConsumerWidget {
  const ProfileSettingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.h3.copyWith(
              fontSize: 18,
              color: isDark ? c.textPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? c.surface : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: isDark ? Border.all(
                color: c.surfaceHighlight.withValues(alpha: 0.2),
                width: 1,
              ) : Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // ── Dark Mode Toggle ──
                _buildToggleRow(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  label: isDark ? 'Dark Mode' : 'Light Mode',
                  iconColor: isDark
                      ? const Color(0xFF7C4DFF)
                      : const Color(0xFFFFB74D),
                  isFirst: true,
                  colors: c,
                  isDark: isDark,
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: AppColors.primary,
                    onChanged: (_) {
                      ref.read(themeModeProvider.notifier).toggle();
                    },
                  ),
                ),
                _divider(c),

                // ── Edit Profile ──
                _buildRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  iconColor: AppColors.primary,
                  colors: c,
                  isDark: isDark,
                  onTap: () {},
                ),
                _divider(c),

                // ── Notifications ──
                _buildRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  iconColor: const Color(0xFF7C4DFF),
                  colors: c,
                  isDark: isDark,
                  onTap: () {},
                ),
                _divider(c),

                // ── Privacy & Security ──
                _buildRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Privacy & Security',
                  iconColor: const Color(0xFF00BCD4),
                  colors: c,
                  isDark: isDark,
                  onTap: () {},
                ),
                _divider(c),

                // ── Help & Support ──
                _buildRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  iconColor: const Color(0xFFFF6D00),
                  colors: c,
                  isDark: isDark,
                  onTap: () {},
                ),
                _divider(c),

                // ── About Acadex ──
                _buildRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About Acadex',
                  iconColor: c.textSecondary,
                  colors: c,
                  isDark: isDark,
                  onTap: () {},
                ),
                _divider(c),

                // ── Logout ──
                _buildRow(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  iconColor: c.error,
                  colors: c,
                  isDark: isDark,
                  isLast: true,
                  isDestructive: true,
                  onTap: () {
                    ref.read(authNotifierProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(AppColorScheme c) {
    return Divider(
      height: 1,
      color: c.surfaceHighlight.withValues(alpha: 0.15),
      indent: 56,
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required Color iconColor,
    required AppColorScheme colors,
    required bool isDark,
    bool isFirst = false,
    bool isLast = false,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? colors.error
                        : (isDark ? colors.textPrimary : Colors.white),
                  ),
                ),
              ),
              if (!isDestructive)
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? colors.textHint : Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required Color iconColor,
    required AppColorScheme colors,
    required bool isDark,
    required Widget trailing,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? colors.textPrimary : Colors.white,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
