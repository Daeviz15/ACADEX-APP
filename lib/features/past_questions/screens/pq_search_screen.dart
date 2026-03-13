import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';

class PqSearchScreen extends StatelessWidget {
  const PqSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text('Past Questions', 
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}
