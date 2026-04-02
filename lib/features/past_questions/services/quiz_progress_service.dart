import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Comprehensive local state model for a Quiz in progress
class QuizProgressState {
  final int currentPage;
  final Map<int, int> selectedAnswers;
  final Map<int, String> theoryAnswers;
  final Map<int, double> theoryScores;
  final Map<int, String> theoryAIFeedbacks;
  final Map<int, bool> answeredQuestions;
  final int correctCount;
  final int currentWinStreak;
  final int currentFailStreak;

  QuizProgressState({
    required this.currentPage,
    required this.selectedAnswers,
    required this.theoryAnswers,
    required this.theoryScores,
    required this.theoryAIFeedbacks,
    required this.answeredQuestions,
    required this.correctCount,
    required this.currentWinStreak,
    required this.currentFailStreak,
  });

  Map<String, dynamic> toJson() {
    // SharedPreferences doesn't natively accept Map<int, dynamic> inside JSON encoding 
    // without manual conversion of int keys to String keys.
    return {
      'currentPage': currentPage,
      'selectedAnswers': selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'theoryAnswers': theoryAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'theoryScores': theoryScores.map((k, v) => MapEntry(k.toString(), v)),
      'theoryAIFeedbacks': theoryAIFeedbacks.map((k, v) => MapEntry(k.toString(), v)),
      'answeredQuestions': answeredQuestions.map((k, v) => MapEntry(k.toString(), v)),
      'correctCount': correctCount,
      'currentWinStreak': currentWinStreak,
      'currentFailStreak': currentFailStreak,
    };
  }

  factory QuizProgressState.fromJson(Map<String, dynamic> json) {
    // Safely parse dynamically casted lists back to Map<int, T>
    Map<int, T> _parseMap<T>(dynamic mapData, T Function(dynamic) valueParser) {
      if (mapData == null) return <int, T>{};
      final stringKeyMap = mapData as Map<String, dynamic>;
      return stringKeyMap.map((key, value) => MapEntry(int.parse(key), valueParser(value)));
    }

    return QuizProgressState(
      currentPage: json['currentPage'] ?? 0,
      selectedAnswers: _parseMap<int>(json['selectedAnswers'], (v) => v as int),
      theoryAnswers: _parseMap<String>(json['theoryAnswers'], (v) => v.toString()),
      theoryScores: _parseMap<double>(json['theoryScores'], (v) => (v as num).toDouble()),
      theoryAIFeedbacks: _parseMap<String>(json['theoryAIFeedbacks'], (v) => v.toString()),
      answeredQuestions: _parseMap<bool>(json['answeredQuestions'], (v) => v as bool),
      correctCount: json['correctCount'] ?? 0,
      currentWinStreak: json['currentWinStreak'] ?? 0,
      currentFailStreak: json['currentFailStreak'] ?? 0,
    );
  }
}

class QuizProgressService {
  static const String _storagePrefix = 'quiz_progress_';

  /// Save current quiz state locally
  Future<void> saveProgress(String pastQuestionId, QuizProgressState state) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '$_storagePrefix$pastQuestionId';
    final String jsonString = jsonEncode(state.toJson());
    await prefs.setString(key, jsonString);
  }

  /// Retrieve existing progress, returns null if non-existent
  Future<QuizProgressState?> queryProgress(String pastQuestionId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '$_storagePrefix$pastQuestionId';
    final String? jsonString = prefs.getString(key);
    
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return QuizProgressState.fromJson(jsonMap);
    } catch (e) {
      // In case of parsing error or version change corruption, wipe it
      await clearProgress(pastQuestionId);
      return null;
    }
  }

  /// Wipe saved progress
  Future<void> clearProgress(String pastQuestionId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '$_storagePrefix$pastQuestionId';
    await prefs.remove(key);
  }
}

final quizProgressServiceProvider = Provider<QuizProgressService>((ref) {
  return QuizProgressService();
});
