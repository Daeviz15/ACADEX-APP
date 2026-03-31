import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:acadex/core/widgets/acadex_skeleton.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/features/main_shell/providers/shell_provider.dart';

class GreetingHeader extends ConsumerStatefulWidget {
  final String userName;
  final String? avatarUrl;

  const GreetingHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
  });

  @override
  ConsumerState<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends ConsumerState<GreetingHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Safe default
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Replay animation each time user navigates to the Dashboard tab
    ref.listen<int>(shellProvider, (prev, next) {
      if (next == 0 && _lottieController.duration != null) {
        _lottieController.reset();
        _lottieController.forward();
      }
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Welcome Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.userName}',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What do you want to learn today?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        
        // Notifications and Profile
        Row(
          children: [
            // Notification Bell
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            
            // Profile Lottie Avatar
            InkWell(
              onTap: () => ref.read(shellProvider.notifier).state = 4, // Navigate to Profile Tab
              borderRadius: BorderRadius.circular(23),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: widget.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.avatarUrl!,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 500),
                          placeholder: (context, url) => AcadexSkeleton.circle(size: 46),
                          errorWidget: (context, url, error) => Lottie.asset(
                            'assets/lottie/profilepic.json',
                            controller: _lottieController,
                            onLoaded: (composition) {
                              _lottieController.duration = composition.duration;
                              _lottieController.forward();
                            },
                            fit: BoxFit.cover,
                          ),
                        )
                      : Lottie.asset(
                          'assets/lottie/profilepic.json',
                          controller: _lottieController,
                          onLoaded: (composition) {
                            _lottieController.duration = composition.duration;
                            _lottieController.forward();
                          },
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
