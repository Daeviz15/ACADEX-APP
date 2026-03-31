import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/pq_provider.dart';
import '../data/mock_past_questions.dart';

class PqFilterChips extends ConsumerWidget {
  const PqFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(pqYearFilterProvider);
    final selectedDept = ref.watch(pqDeptFilterProvider);
    final selectedLevel = ref.watch(pqLevelFilterProvider);
    final selectedSemester = ref.watch(pqSemesterFilterProvider);

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _FilterChip(
            label: selectedYear ?? 'Year',
            isActive: selectedYear != null,
            icon: Icons.calendar_today_rounded,
            onTap: () => _showPicker(
              context,
              title: 'Select Year',
              options: availableYears,
              selected: selectedYear,
              onSelected: (val) =>
                  ref.read(pqYearFilterProvider.notifier).state = val,
            ),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: selectedDept ?? 'Department',
            isActive: selectedDept != null,
            icon: Icons.school_rounded,
            onTap: () => _showPicker(
              context,
              title: 'Select Department',
              options: availableDepartments,
              selected: selectedDept,
              onSelected: (val) =>
                  ref.read(pqDeptFilterProvider.notifier).state = val,
            ),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: selectedLevel != null ? '$selectedLevel Level' : 'Level',
            isActive: selectedLevel != null,
            icon: Icons.trending_up_rounded,
            onTap: () => _showLevelPicker(
              context,
              selected: selectedLevel,
              onSelected: (val) =>
                  ref.read(pqLevelFilterProvider.notifier).state = val,
            ),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: selectedSemester ?? 'Semester',
            isActive: selectedSemester != null,
            icon: Icons.view_agenda_rounded,
            onTap: () => _showPicker(
              context,
              title: 'Select Semester',
              options: availableSemesters,
              selected: selectedSemester,
              onSelected: (val) =>
                  ref.read(pqSemesterFilterProvider.notifier).state = val,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PickerSheet(
        title: title,
        options: options,
        selected: selected,
        onSelected: (val) {
          onSelected(val);
          Navigator.pop(ctx);
        },
        onClear: () {
          onSelected(null);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showLevelPicker(
    BuildContext context, {
    required int? selected,
    required ValueChanged<int?> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PickerSheet(
        title: 'Select Level',
        options: availableLevels.map((l) => '$l Level').toList(),
        selected: selected != null ? '$selected Level' : null,
        onSelected: (val) {
          if (val != null) {
            final level = int.parse(val.replaceAll(' Level', ''));
            onSelected(level);
          }
          Navigator.pop(ctx);
        },
        onClear: () {
          onSelected(null);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ── Individual Filter Chip ──

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? c.primary.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.25))
                : (isDark ? c.surface : Colors.white.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? (isDark ? c.primary : Colors.white.withValues(alpha: 0.8))
                  : (isDark ? c.surfaceHighlight.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.2)),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? (isDark ? c.primary : Colors.white)
                    : (isDark ? c.textSecondary : Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? (isDark ? c.primary : Colors.white)
                      : (isDark ? c.textSecondary : Colors.white.withValues(alpha: 0.7)),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: isDark ? c.primary.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Picker Bottom Sheet ──

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final VoidCallback onClear;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.surfaceHighlight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.h3.copyWith(color: c.textPrimary),
              ),
              if (selected != null)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: Text(
                    'Clear',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Options
          ...options.map((option) {
            final isSelected = option == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelected(option),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? c.primary.withValues(alpha: 0.12)
                          : c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? c.primary
                            : c.surfaceHighlight.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? c.primary
                                  : c.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: c.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
