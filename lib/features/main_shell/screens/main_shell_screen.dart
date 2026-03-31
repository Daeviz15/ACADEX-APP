import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import '../providers/shell_provider.dart';
import '../widgets/curved_bottom_nav_bar.dart';

// Import our 5 tab screens
import '../../dashboard/screens/dashboard_screen.dart';
import '../../ai_guidance/screens/ai_chat_screen.dart';
import '../../past_questions/screens/pq_search_screen.dart';
import '../../quiz/screens/quiz_lobby_screen.dart';
import '../../wallet/screens/wallet_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const AiChatScreen(),
    const PqSearchScreen(),
    const QuizLobbyScreen(),
    const WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(shellProvider);
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedBottomNavBar(
        selectedIndex: currentIndex,
        onItemSelected: (index) {
          ref.read(shellProvider.notifier).state = index;
        },
      ),
    );
  }
}
