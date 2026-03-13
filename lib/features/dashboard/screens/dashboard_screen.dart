import 'package:flutter/material.dart';

import '../widgets/greeting_header.dart';
import '../widgets/dash_search_bar.dart';
import '../widgets/quick_categories.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/recommended_services.dart';
import '../widgets/daily_motivation_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let MainShell background show through
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              const GreetingHeader(userName: 'David'),
              const SizedBox(height: 24),
              
              // Search Bar
              const DashSearchBar(),
              const SizedBox(height: 24),
              
              // Quick Categories (replaces cooking/arts)
              const QuickCategories(),
              const SizedBox(height: 32),
              
              // Recent Activity (replaces recent class)
              const RecentActivityCard(),
              const SizedBox(height: 32),
              
              // Recommended Services (replaces recommended classes)
              const RecommendedServices(),
              const SizedBox(height: 32),
              
              // Daily Motivation Quote
              const DailyMotivationCard(),
              
              // Bottom padding to clear the curved nav bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
