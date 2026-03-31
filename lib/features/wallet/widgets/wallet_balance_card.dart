import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/wallet_provider.dart';
import 'package:acadex/core/widgets/acadex_loader.dart';

class WalletBalanceCard extends ConsumerWidget {
  const WalletBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(
              color: c.surfaceHighlight.withValues(alpha: 0.3),
              width: 1,
            ) : Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            color: isDark ? null : Colors.white.withValues(alpha: 0.08),
            gradient: isDark ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                c.surface.withValues(alpha: 0.98),
                c.surface.withValues(alpha: 0.92),
              ],
            ) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Acadex Credits',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? c.textSecondary : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: isDark ? c.primary.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  )
                ],
              ),
              const SizedBox(height: 8),

              // Riverpod State Listener
              ref.watch(walletNotifierProvider).when(
                    data: (data) => Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: data.balance.toInt().toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},'),
                          ),
                          TextSpan(
                            text: ' pts',
                            style: TextStyle(
                              fontSize: 18,
                              color: c.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 36,
                        letterSpacing: -1,
                        color: isDark ? c.textPrimary : Colors.white,
                      ),
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: AcadexLoader(size: 40),
                      ),
                    ),
                    error: (err, _) => Text(
                      'Failed to load balance',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                    ),
                  ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Top Up',
                      colors: c,
                      onTap: () async {
                         try {
                           await ref.read(walletNotifierProvider.notifier).simulateDeposit(5000);
                         } catch (e) {
                           if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: const Text('Server unreachable. Please try again later.'),
                                 backgroundColor: Colors.red.shade700,
                                 behavior: SnackBarBehavior.floating,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                 margin: const EdgeInsets.all(16),
                               ),
                             );
                           }
                         }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
