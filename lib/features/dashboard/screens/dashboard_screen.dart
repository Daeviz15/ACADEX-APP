import 'package:flutter/material.dart';

import '../widgets/greeting_header.dart';
import '../widgets/dash_search_bar.dart';
import '../widgets/quick_categories.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/recommended_services.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent, // Let MainShell background show through
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              GreetingHeader(userName: 'David'),
              SizedBox(height: 24),
              
              // Search Bar
              DashSearchBar(),
              SizedBox(height: 24),
              
              // Quick Categories (replaces cooking/arts)
              QuickCategories(),
              SizedBox(height: 32),
              
              // Recent Activity (replaces recent class)
              RecentActivityCard(),
              SizedBox(height: 32),
              
              // Recommended Services (replaces recommended classes)
              RecommendedServices(),
              
              // Bottom padding to clear the curved nav bar
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
