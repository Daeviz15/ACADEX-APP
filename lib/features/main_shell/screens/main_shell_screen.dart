import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import '../widgets/curved_bottom_nav_bar.dart';

// Import our 5 tab screens
import '../../dashboard/screens/dashboard_screen.dart';
import '../../ai_guidance/screens/ai_chat_screen.dart';
import '../../past_questions/screens/pq_search_screen.dart';
import '../../quiz/screens/quiz_lobby_screen.dart';
import '../../wallet/screens/wallet_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AiChatScreen(),
    const PqSearchScreen(),
    const QuizLobbyScreen(),
    const WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // We align the custom nav bar to the bottom exactly.
      bottomNavigationBar: CurvedBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
