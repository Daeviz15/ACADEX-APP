import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/widgets/acadex_skeleton.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';

class RecentActivityCard extends ConsumerWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dashboardAsync = ref.watch(dashboardSummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 44),
        Text(
          'Recent Activity',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        dashboardAsync.when(
          data: (data) => data.lastActivity != null
              ? _buildActivityCard(context, c, data.lastActivity!)
              : _buildEmptyState(context, c),
          loading: () => const AcadexSkeleton(height: 120, width: double.infinity),
          error: (_, __) => _buildEmptyState(context, c),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, AppColorScheme c, UserActivity activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: c.surfaceHighlight.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : c.primary)
                .withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              activity.icon,
              size: 100,
              color: c.primary.withValues(alpha: 0.03),
            ),
          ),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.primary.withValues(alpha: 0.1),
                      c.primary.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    activity.icon,
                    color: c.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          activity.statusText ?? 'Last action',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(activity.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: c.primary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: activity.progress,
                              backgroundColor: c.surfaceHighlight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                c.primary,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppColorScheme c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: c.surfaceHighlight.withValues(alpha: 0.4),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.history_toggle_off_rounded, color: c.textSecondary.withValues(alpha: 0.3), size: 48),
          const SizedBox(height: 12),
          Text(
            'Your story begins here',
            style: AppTextStyles.bodyMedium.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete an action to see it here.',
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
