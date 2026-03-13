import 'dart:math';
import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class DailyMotivationCard extends StatelessWidget {
  const DailyMotivationCard({super.key});

  static const List<Map<String, String>> _quotes = [
    {
      'quote': 'Education is the most powerful weapon which you can use to change the world.',
      'author': 'Nelson Mandela',
    },
    {
      'quote': 'The beautiful thing about learning is that no one can take it away from you.',
      'author': 'B.B. King',
    },
    {
      'quote': 'Live as if you were to die tomorrow. Learn as if you were to live forever.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'The roots of education are bitter, but the fruit is sweet.',
      'author': 'Aristotle',
    },
    {
      'quote': 'Intelligence plus character—that is the goal of true education.',
      'author': 'Martin Luther King Jr.',
    },
    {
      'quote': 'The mind is not a vessel to be filled, but a fire to be kindled.',
      'author': 'Plutarch',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Pick a random quote for this build
    final randomQuote = _quotes[Random().nextInt(_quotes.length)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: AppColors.primary.withOpacity(0.8),
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Motivation',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${randomQuote['quote']}"',
            style: AppTextStyles.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.textPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${randomQuote['author']}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
