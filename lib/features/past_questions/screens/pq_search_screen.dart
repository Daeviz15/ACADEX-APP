import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/pq_provider.dart';
import '../widgets/pq_filter_chips.dart';
import '../widgets/pq_card.dart';

class PqSearchScreen extends ConsumerStatefulWidget {
  const PqSearchScreen({super.key});

  @override
  ConsumerState<PqSearchScreen> createState() => _PqSearchScreenState();
}

class _PqSearchScreenState extends ConsumerState<PqSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() => setState(() {}));
  }

  void _onSearchChanged() {
    ref.read(pqSearchQueryProvider.notifier).state = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    ref.read(pqYearFilterProvider.notifier).state = null;
    ref.read(pqDeptFilterProvider.notifier).state = null;
    ref.read(pqLevelFilterProvider.notifier).state = null;
    ref.read(pqSemesterFilterProvider.notifier).state = null;
    ref.read(pqSearchQueryProvider.notifier).state = '';
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(filteredPastQuestionsProvider);
    final hasFilters = ref.watch(pqHasActiveFiltersProvider);
    final isFocused = _searchFocusNode.hasFocus;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.library_books_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Past Questions', style: AppTextStyles.h2),
                            const SizedBox(height: 2),
                            Text(
                              'Find and study exam papers',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (hasFilters)
                        TextButton.icon(
                          onPressed: _clearAllFilters,
                          icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            textStyle: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Search Bar ──
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFocused
                            ? AppColors.primary
                            : AppColors.surfaceHighlight.withValues(alpha: 0.3),
                        width: isFocused ? 1.5 : 1,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search by course code or title...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isFocused
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.6),
                          size: 22,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: AppColors.textSecondary,
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Filter Chips ──
                  const PqFilterChips(),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Results counter ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Text(
                '${results.length} result${results.length != 1 ? 's' : ''} found',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ── Results List / Empty State ──
            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return PqCard(
                          question: results[index],
                          index: index,
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 40 * index),
                              duration: 350.ms,
                            )
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              delay: Duration(milliseconds: 40 * index),
                              duration: 350.ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/books.json',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'No Past Questions Found',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search for a different course.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset Filters'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
