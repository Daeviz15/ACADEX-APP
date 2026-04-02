import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  static String get baseHost {
    // Using your computer's actual local IP address so the physical phone can connect
    if (kIsWeb) return 'http://192.168.100.191:8000';
    if (Platform.isAndroid) return 'http://192.168.100.191:8000';
    return 'http://192.168.100.191:8000';
  }

  static String get baseUrl => '$baseHost/api/v1';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String me = '/auth/me';
  static const String updateAvatar = '/users/me/avatar';
  static const String updateBanner = '/users/me/banner';
  
  // Dashboard & Services
  static const String dashboardSummary = '/dashboard/summary';
  static const String recommendedServices = '/services/recommended';
  static const String logActivity = '/dashboard/activity';

  // Past Questions
  static const String pastQuestions = '/past-questions';
  static const String pastQuestionFilters = '/past-questions/filters';
  static String pastQuestionQuiz(String id) => '/past-questions/$id/quiz';
  static String generateQuiz(String id) => '/past-questions/$id/generate-quiz';
  static const String gradeTheory = '/past-questions/grade-theory';
}
