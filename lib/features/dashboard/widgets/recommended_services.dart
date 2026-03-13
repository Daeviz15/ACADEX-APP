import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class RecommendedServices extends StatelessWidget {
  const RecommendedServices({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for recommended services
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Academic\nGuidance',
        'image': 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=600&auto=format&fit=crop', // Students studying
        'isBookmarked': false,
      },
      {
        'title': 'Custom\nSoftware',
        'image': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=600&auto=format&fit=crop', // Coding
        'isBookmarked': true,
      },
      {
        'title': 'Project\nReview',
        'image': 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=600&auto=format&fit=crop', // Writing/Review
        'isBookmarked': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended services for you',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Based on your activity',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220, // Height to match the reference cards
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(
                title: service['title'],
                imageUrl: service['image'],
                isBookmarked: service['isBookmarked'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String imageUrl,
    required bool isBookmarked,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4), // Darken image slightly for text readability
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Content
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          
          // Bookmark Icon
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBookmarked ? AppColors.primary : Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
