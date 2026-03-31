import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:acadex/config/theme/app_colors.dart';
import '../widgets/greeting_header.dart';
import '../widgets/dash_search_bar.dart';
import '../widgets/quick_categories.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/recommended_services.dart';
import '../widgets/daily_motivation_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import 'package:acadex/core/widgets/acadex_loader.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final firstName = user?.name.split(' ')[0] ?? 'Student';

    // Calculate the total height of the fixed header section so the scrolling content knows where to start.
    // Roughly: SafeArea top + Greeting (80) + Search Bar (70) + Quick categories (100) + paddings (~100)
    // We'll use a fixed height of 340 for the green curved background to cover these items.
    const double headerCurveHeight = 360.0;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let MainShell background show through
      body: AcadexRefreshIndicator(
        onRefresh: () async {
          // Future expansions will add dashboard-specific refresh logic here
          await ref.read(authNotifierProvider.notifier).getMe();
        },
        child: Stack(
          children: [
          // ── Ambient Background Orbs (Light Mode specifically) ──
          Positioned.fill(
            child: Builder(
              builder: (context) {
                if (context.isDarkMode) return const SizedBox.shrink();
                return Stack(
                  children: [
                    // Top-right subtle green blur
                    Positioned(
                      top: 100,
                      right: -100,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              context.colors.primary.withValues(alpha: 0.1),
                              context.colors.primary.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom-left subtle secondary blur
                    Positioned(
                      bottom: 50,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.blue.withValues(alpha: 0.08),
                              Colors.blue.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Main Scrollable Content (Underneath the fixed header widgets) ──
          // We use a ListView with a top padding so it scrolls behind the static header
          Positioned.fill(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(
                  top:
                      headerCurveHeight -
                      30, // Start scrolling content just below the fixed items
                  left: 24.0,
                  right: 24.0,
                  bottom: 100.0,
                ),
                children: const [
                  // Recent Activity
                  RecentActivityCard(),
                  SizedBox(height: 32),

                  // Recommended Services
                  RecommendedServices(),
                  SizedBox(height: 32),

                  // Daily Motivation Quote
                  DailyMotivationCard(),
                ],
              ),
            ),

          // ── Unique Curved Green Header Background (Fixed) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    height:
                        headerCurveHeight, // Now covers top elements + quick categories
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0A7D56), // unique, premium green
                          Color(0xFF065F41), // slightly darker shade for depth
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Subtle decorative circles
                        Positioned(
                          top: -40,
                          right: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 100,
                          left: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.03),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // The sweeping white border line mapped to the bottom curve
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HeaderBorderPainter(),
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Foreground Header Elements ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    // Greeting overlapping the green background
                    GreetingHeader(
                      userName: firstName,
                      avatarUrl: user?.fullAvatarUrl,
                    ),
                    const SizedBox(height: 16),

                    // Sleek Acadex Credits Pill injected dynamically from the Postgres DB stream!
                    ref.watch(walletNotifierProvider).when(
                      data: (data) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '${data.balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Credits',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),

                    // Search bar
                    const DashSearchBar(),
                    SizedBox(height: 24),

                    // Quick Categories (Now covered by the green background curve)
                    QuickCategories(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

// Custom clipper for a stylish, unique wave across the bottom
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);

    // Creates an asymmetrical elegant swoosh
    path.cubicTo(
      size.width * 0.25, size.height + 20, 
      size.width * 0.75, size.height - 80, 
      size.width, size.height - 10,       
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Painter for drawing the white border along the exact same curve
class _HeaderBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height - 50);
    
    // Exact same control points as the clipper
    path.cubicTo(
      size.width * 0.25, size.height + 20, 
      size.width * 0.75, size.height - 80, 
      size.width, size.height - 10,       
    );

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8) // White border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0; // Thickness of the curve line

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
