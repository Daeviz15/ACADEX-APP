import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/storage/local_storage.dart';
import 'package:acadex/core/widgets/feature_discovery/feature_discovery.dart';
import '../providers/pq_provider.dart';
import '../widgets/pq_filter_chips.dart';
import '../widgets/pq_card.dart';

class PqSearchScreen extends ConsumerStatefulWidget {
  const PqSearchScreen({super.key});

  @override
  ConsumerState<PqSearchScreen> createState() => _PqSearchScreenState();
}

class _PqSearchScreenState extends ConsumerState<PqSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final AnimationController _emptyLottieController;

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _filtersKey = GlobalKey();

  bool _discoveryChecked = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() => setState(() {}));
    _emptyLottieController = AnimationController(vsync: this);
  }

  Future<void> _checkAndShowDiscovery() async {
    if (_discoveryChecked) return;

    final storage = ref.read(storageServiceProvider);
    if (!storage.hasSeenPqDiscovery) {
      _discoveryChecked = true;
      FeatureDiscoveryOverlay.show(
        context,
        steps: [
          FeatureDiscoveryStep(
            targetKey: _searchKey,
            title: 'Search by Course',
            description:
                'Quickly find past questions by typing the course code or title here.',
            lottiePath: 'assets/lottie/books.json',
          ),
          FeatureDiscoveryStep(
            targetKey: _filtersKey,
            title: 'Advanced Filters',
            description:
                'Narrow down your search results by Year, Department, Level, and Semester.',
          ),
        ],
        onComplete: () {
          storage.setHasSeenPqDiscovery();
        },
      );
    }
  }

  void _onSearchChanged() {
    ref.read(pqSearchQueryProvider.notifier).state = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _emptyLottieController.dispose();
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
    final c = context.colors;
    final isDark = context.isDarkMode;
    final results = ref.watch(filteredPastQuestionsProvider);
    final hasFilters = ref.watch(pqHasActiveFiltersProvider);
    final isFocused = _searchFocusNode.hasFocus;

    return VisibilityDetector(
      key: const Key('pq_search_visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndShowDiscovery();
          });
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? c.background : const Color(0xFF00664F),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            SafeArea(
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
                                color: isDark ? c.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.library_books_rounded,
                                color: isDark ? c.primary : Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Past Questions',
                                    style: AppTextStyles.h2.copyWith(
                                      color: isDark ? c.textPrimary : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Find and study exam papers',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark ? c.textSecondary : Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasFilters)
                              TextButton.icon(
                                onPressed: _clearAllFilters,
                                icon: const Icon(
                                  Icons.filter_alt_off_rounded,
                                  size: 16,
                                ),
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
                        Container(
                          key: _searchKey,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? c.surface.withValues(alpha: isFocused ? 0.95 : 0.7)
                                  : const Color(0xFF00664F),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isFocused
                                    ? (isDark ? c.primary :Color(0xFF00664F))
                                    : (isDark ? c.surfaceHighlight.withValues(alpha: 0.5) : Color(0xFF00664F)),
                                width: isFocused ? 1.5 : 1.2,
                              ),
                              boxShadow: isFocused
                                  ? [
                                      BoxShadow(
                                        color: isDark ? c.primary.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: c.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search by course code or title...',
                                hintStyle: AppTextStyles.bodyLarge.copyWith(
                                  color: c.textHint,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: isFocused ? c.primary : c.textHint,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                        ),
                                        color: c.textSecondary,
                                        onPressed: () {
                                          _searchController.clear();
                                          _searchFocusNode.unfocus();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Filter Chips ──
                        Container(
                          key: _filtersKey,
                          child: const PqFilterChips(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // ── Results counter ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    child: Text(
                      '${results.length} result${results.length != 1 ? 's' : ''} found',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? c.textHint : Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ── Results List / Empty State ──
                  Expanded(
                    child: results.isEmpty
                        ? _buildEmptyState(c)
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
                                    delay: Duration(
                                        milliseconds: 20 * (index % 10)),
                                    duration: 250.ms,
                                  )
                                  .scale(
                                    begin: const Offset(0.98, 0.98),
                                    end: const Offset(1, 1),
                                    delay: Duration(
                                        milliseconds: 20 * (index % 10)),
                                    duration: 250.ms,
                                    curve: Curves.easeOutCubic,
                                  );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColorScheme c) {
    final isDark = context.isDarkMode;
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VisibilityDetector(
                key: const Key('pq_empty_lottie'),
                onVisibilityChanged: (info) {
                  if (!mounted) return;
                  if (info.visibleFraction > 0.2) {
                    _emptyLottieController.repeat();
                  } else {
                    _emptyLottieController.stop();
                  }
                },
                child: Lottie.asset(
                  'assets/lottie/books.json',
                  controller: _emptyLottieController,
                  onLoaded: (comp) {
                    _emptyLottieController.duration = comp.duration;
                    _emptyLottieController.repeat();
                  },
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Past Questions Found',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 18,
                  color: isDark ? c.textPrimary : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or search for a different course.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? c.textHint : Colors.white.withValues(alpha: 0.6),
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
                  foregroundColor: c.primary,
                  textStyle: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
