import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/widgets/acadex_skeleton.dart';
import '../providers/dashboard_provider.dart';

class DailyMotivationCard extends ConsumerWidget {
  const DailyMotivationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dashboardAsync = ref.watch(dashboardSummaryProvider);

    return dashboardAsync.when(
      data: (data) => _buildCard(context, c, data.motivation.quote, data.motivation.author),
      loading: () => const AcadexSkeleton(height: 180, width: double.infinity),
      error: (_, __) => _buildCard(
        context,
        c,
        "The beautiful thing about learning is that no one can take it away from you.",
        "B.B. King",
      ),
    );
  }

  Widget _buildCard(BuildContext context, AppColorScheme c, String quote, String author) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          // Faded massive quote watermark
          Positioned(
            left: -10,
            top: -20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 140,
              color: c.primary.withValues(alpha: 0.03),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: c.primary.withValues(alpha: 0.8),
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Motivation',
                    style: AppTextStyles.h1.copyWith(
                      color: c.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"$quote"',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: c.textPrimary.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '— $author',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
