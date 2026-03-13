import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

import '../providers/dashboard_search_provider.dart';
import 'service_request_sheet.dart';

class DashSearchBar extends ConsumerStatefulWidget {
  const DashSearchBar({super.key});

  @override
  ConsumerState<DashSearchBar> createState() => _DashSearchBarState();
}

class _DashSearchBarState extends ConsumerState<DashSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });

    _searchController.addListener(() {
      ref.read(dashSearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 8),
          child: _SearchResultsOverlay(
            onItemSelected: _handleItemSelected,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleItemSelected(DashSearchResult result) {
    _focusNode.unfocus();
    _searchController.clear();
    ref.read(dashSearchQueryProvider.notifier).state = '';

    // Handle routing depending on type
    if (result.type == 'service') {
      ServiceRequestSheet.show(
        context,
        serviceId: result.id,
        serviceTitle: result.title,
        placeholders: [
          'E.g., I need assistance regarding ${result.title.toLowerCase()}...',
          'How does this service work?',
          'I need to schedule a consultation...'
        ],
        icon: result.icon,
      );
    } else if (result.type == 'nav') {
      // Future routing: e.g. using go_router
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to ${result.title}...')),
      );
    } else if (result.type == 'category') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Viewing category: ${result.title}...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focusNode.hasFocus
                ? AppColors.primary
                : AppColors.surfaceHighlight.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: _focusNode.hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search services, classes...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.7),
              size: 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      _searchController.clear();
                      ref.read(dashSearchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }
}

class _SearchResultsOverlay extends ConsumerWidget {
  final Function(DashSearchResult) onItemSelected;

  const _SearchResultsOverlay({required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(dashSearchQueryProvider);
    final results = ref.watch(dashSearchResultsProvider);

    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceHighlight.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No results found for "$query"',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return InkWell(
                      onTap: () => onItemSelected(result),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighlight
                                    .withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                result.icon,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.title,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    result.subtitle,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.surfaceHighlight,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
