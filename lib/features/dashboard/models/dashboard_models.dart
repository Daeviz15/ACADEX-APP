import 'package:flutter/material.dart';

class DashboardSummary {
  final MotivationModel motivation;
  final UserActivity? lastActivity;

  DashboardSummary({
    required this.motivation,
    this.lastActivity,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      motivation: MotivationModel.fromJson(json['motivation']),
      lastActivity: json['last_activity'] != null 
          ? UserActivity.fromJson(json['last_activity']) 
          : null,
    );
  }
}

class MotivationModel {
  final String quote;
  final String author;

  MotivationModel({required this.quote, required this.author});

  factory MotivationModel.fromJson(Map<String, dynamic> json) {
    return MotivationModel(
      quote: json['quote'],
      author: json['author'],
    );
  }
}

class UserActivity {
  final String id;
  final String type; // 'chat', 'quiz', 'service_request'
  final String title;
  final String? statusText;
  final double progress;
  final DateTime createdAt;

  UserActivity({
    required this.id,
    required this.type,
    required this.title,
    this.statusText,
    required this.progress,
    required this.createdAt,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'],
      type: json['activity_type'],
      title: json['title'],
      statusText: json['status_text'],
      progress: (json['progress'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  IconData get icon {
    switch (type) {
      case 'chat': return Icons.psychology_outlined;
      case 'quiz': return Icons.quiz_outlined;
      case 'service_request': return Icons.support_agent_outlined;
      default: return Icons.star_outline_rounded;
    }
  }
}

class ServiceRecommendation {
  final String id;
  final String title;
  final String subtitle;
  final String lottie;
  final String iconName;
  final List<String> placeholders;

  ServiceRecommendation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lottie,
    required this.iconName,
    required this.placeholders,
  });

  factory ServiceRecommendation.fromJson(Map<String, dynamic> json) {
    return ServiceRecommendation(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      lottie: json['lottie'],
      iconName: json['icon'],
      placeholders: List<String>.from(json['placeholders']),
    );
  }

  IconData get icon {
    switch (iconName) {
      case 'school_rounded': return Icons.school_rounded;
      case 'code_rounded': return Icons.code_rounded;
      case 'engineering_rounded': return Icons.engineering_rounded;
      case 'edit_document': return Icons.edit_document;
      case 'quiz_rounded': return Icons.quiz_rounded;
      case 'people_alt_rounded': return Icons.people_alt_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}
