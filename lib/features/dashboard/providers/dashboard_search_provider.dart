import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// The current search query
final dashSearchQueryProvider = StateProvider<String>((ref) => '');

// Search Result Model
class DashSearchResult {
  final String title;
  final String subtitle;
  final IconData icon;
  final String type; // 'service', 'category', 'nav'
  final String id;

  const DashSearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.id,
  });
}

// Global list of searchable items
final _allSearchableItems = <DashSearchResult>[
  // Services
  const DashSearchResult(id: 'academic_guidance', title: 'Academic Guidance', subtitle: 'Service • Expert academic advice', icon: Icons.school_rounded, type: 'service'),
  const DashSearchResult(id: 'custom_software', title: 'Custom Software', subtitle: 'Service • Tailored software solutions', icon: Icons.code_rounded, type: 'service'),
  const DashSearchResult(id: 'final_year_project', title: 'Final Year Project Assistance', subtitle: 'Service • End-to-end project support', icon: Icons.engineering_rounded, type: 'service'),
  const DashSearchResult(id: 'assignment_assistance', title: 'Assignment Assistance', subtitle: 'Service • Ace every assignment', icon: Icons.edit_document, type: 'service'),
  const DashSearchResult(id: 'past_questions', title: 'Request Past Question', subtitle: 'Service • Specific past question access', icon: Icons.quiz_rounded, type: 'service'),
  const DashSearchResult(id: 'tutoring_mentorship', title: 'Tutoring & Mentorship', subtitle: 'Service • One-on-one guidance', icon: Icons.people_alt_rounded, type: 'service'),

  // Quick Categories
  const DashSearchResult(id: 'cat_assignments', title: 'Assignments', subtitle: 'Category', icon: Icons.edit_document, type: 'category'),
  const DashSearchResult(id: 'cat_ai_tutors', title: 'AI Tutors', subtitle: 'Category', icon: Icons.psychology_rounded, type: 'category'),
  const DashSearchResult(id: 'cat_past_qsts', title: 'Past Questions', subtitle: 'Category', icon: Icons.library_books_rounded, type: 'category'),
  const DashSearchResult(id: 'cat_quizzes', title: 'Quizzes', subtitle: 'Category', icon: Icons.emoji_events_rounded, type: 'category'),
  const DashSearchResult(id: 'cat_software', title: 'Software', subtitle: 'Category', icon: Icons.laptop_mac_rounded, type: 'category'),

  // Nav Destinations
  const DashSearchResult(id: 'nav_ai_chat', title: 'AI Chat', subtitle: 'Navigation • Talk to your AI companion', icon: Icons.smart_toy_rounded, type: 'nav'),
  const DashSearchResult(id: 'nav_wallet', title: 'Wallet', subtitle: 'Navigation • Manage your funds', icon: Icons.account_balance_wallet_rounded, type: 'nav'),
];

// Provider that returns filtered results based on the query
final dashSearchResultsProvider = Provider<List<DashSearchResult>>((ref) {
  final query = ref.watch(dashSearchQueryProvider).toLowerCase().trim();
  
  if (query.isEmpty) return [];

  return _allSearchableItems.where((item) {
    return item.title.toLowerCase().contains(query) || 
           item.subtitle.toLowerCase().contains(query);
  }).toList();
});
