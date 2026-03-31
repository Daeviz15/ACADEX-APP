import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

import '../providers/wallet_provider.dart';
import 'package:acadex/core/widgets/acadex_loader.dart';

/// Model for a recent activity item.
class RecentActivityItem {
  final String title;
  final String duration;
  final String status;
  final IconData icon;
  final Color accentColor;

  const RecentActivityItem({
    required this.title,
    required this.duration,
    required this.status,
    required this.icon,
    this.accentColor = AppColors.primary,
  });
}

/// Mock data — will be replaced by Riverpod provider later.
final List<RecentActivityItem> mockRecentActivities = [
  const RecentActivityItem(
    title: 'Data Structures',
    duration: '45 min',
    status: 'Completed',
    icon: Icons.code_rounded,
    accentColor: AppColors.primary,
  ),
  const RecentActivityItem(
    title: 'Calculus II',
    duration: '30 min',
    status: 'In Progress',
    icon: Icons.functions_rounded,
    accentColor: Color(0xFF7C4DFF),
  ),
  const RecentActivityItem(
    title: 'Circuit Theory',
    duration: '20 min',
    status: 'Completed',
    icon: Icons.electrical_services_rounded,
    accentColor: Color(0xFFFF6D00),
  ),
  const RecentActivityItem(
    title: 'Physics I',
    duration: '15 min',
    status: 'Completed',
    icon: Icons.science_rounded,
    accentColor: Color(0xFF00BCD4),
  ),
];

class RecentActivityCarousel extends ConsumerWidget {
  const RecentActivityCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Recent Activity',
                style: AppTextStyles.h3.copyWith(fontSize: 18, color: isDark ? c.textPrimary : Colors.white),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Show all',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Scrolling Cards mapped to Riverpod
          SizedBox(
            height: 130,
            child: ref.watch(walletNotifierProvider).when(
                  data: (data) {
                    if (data.transactions.isEmpty) {
                      return Center(
                        child: Text(
                          "No recent transactions.",
                          style: AppTextStyles.bodyMedium.copyWith(color: c.textHint),
                        ),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: data.transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final tx = data.transactions[index];
                        // Map TransactionModel to RecentActivityItem
                        final item = RecentActivityItem(
                          title: tx.transactionType == 'CREDIT_PURCHASE' ? 'Paystack Top-up' : 'Service Spend',
                          duration: '+${tx.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} pts',
                          status: tx.status,
                          icon: tx.transactionType == 'CREDIT_PURCHASE' ? Icons.add_card_rounded : Icons.shopping_bag_rounded,
                          accentColor: tx.transactionType == 'CREDIT_PURCHASE' ? AppColors.primary : const Color(0xFFFF6D00),
                        );
                        return _ActivityCard(item: item)
                            .animate()
                            .fadeIn(
                              duration: 400.ms,
                              delay: Duration(milliseconds: 100 * index),
                            )
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              delay: Duration(milliseconds: 100 * index),
                              curve: Curves.easeOutCubic,
                            );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: AcadexLoader(size: 40),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Failed to load history',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final RecentActivityItem item;

  const _ActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    final isCompleted = item.status == 'Completed';

    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? c.surface : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(
          color: item.accentColor.withValues(alpha: 0.15),
          width: 1,
        ) : Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark ? [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon + Duration Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: item.accentColor,
                  size: 18,
                ),
              ),
              Text(
                item.duration,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? c.textHint : Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Title
          Text(
            item.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? c.textPrimary : Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? c.primary.withValues(alpha: 0.1)
                  : const Color(0xFFFF6D00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.access_time_rounded,
                  size: 12,
                  color: isCompleted
                      ? c.primary
                      : const Color(0xFFFF6D00),
                ),
                const SizedBox(width: 4),
                Text(
                  item.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isCompleted
                        ? c.primary
                        : const Color(0xFFFF6D00),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
