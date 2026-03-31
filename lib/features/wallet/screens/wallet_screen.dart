import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/recent_activity_carousel.dart';
import '../widgets/profile_settings_list.dart';
import 'package:acadex/core/widgets/acadex_loader.dart';
import 'package:acadex/features/auth/providers/auth_provider.dart';
import 'package:acadex/features/wallet/providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFF00664F),
      body: Stack(
        children: [
          // Ambient Background Orbs removed per user request for a cleaner look.

          AcadexRefreshIndicator(
            onRefresh: () async {
              // Refresh both auth profile and wallet data concurrently
              await Future.wait([
                ref.read(authNotifierProvider.notifier).getMe(),
                ref.read(walletNotifierProvider.notifier).fetchWalletData(),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // 1. Profile Header with Gradient + Avatar
                  ProfileHeader(),
                  SizedBox(height: 28),

                  // 2. Wallet Balance Card
                  WalletBalanceCard(),
                  SizedBox(height: 32),

                  // 3. Profile Settings
                  ProfileSettingsList(),

                  SizedBox(height: 32),

                  // 4. Recent Activity
                  RecentActivityCarousel(),

                  // Bottom padding for curved nav bar
                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}