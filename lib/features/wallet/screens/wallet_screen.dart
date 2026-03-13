import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text('Wallet', 
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}
