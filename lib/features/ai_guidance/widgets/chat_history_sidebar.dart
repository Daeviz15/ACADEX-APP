import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/ai_chat_provider.dart';

class ChatHistorySidebar extends ConsumerWidget {
  const ChatHistorySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatProvider);
    final sessions = chatState.sessions;

    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat History',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.montserrat,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(aiChatProvider.notifier).startNewSession();
                      Navigator.pop(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: AppColors.surfaceHighlight.withOpacity(0.5),
                height: 1,
              ),
            ),

            const SizedBox(height: 8),

            // Session list
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No conversations yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isActive =
                            session.id == chatState.activeSessionId;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            onTap: () {
                              ref
                                  .read(aiChatProvider.notifier)
                                  .openSession(session.id);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: isActive
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary.withOpacity(0.15)
                                    : AppColors.surfaceHighlight.withOpacity(
                                        0.5,
                                      ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.chat_rounded,
                                size: 18,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.urbanist,
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            subtitle: Text(
                              _formatDate(session.createdAt),
                              style: const TextStyle(
                                fontFamily: AppTextStyles.urbanist,
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                ref
                                    .read(aiChatProvider.notifier)
                                    .deleteSession(session.id);
                              },
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
