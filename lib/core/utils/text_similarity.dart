/// Pure-Dart Text Similarity Engine for cost-free Theory Quiz validation
class TextSimilarity {
  /// Common stop words to safely ignore when grading theory questions
  static const _stopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'but', 'by', 'for', 'if', 'in',
    'into', 'is', 'it', 'no', 'not', 'of', 'on', 'or', 'such', 'that', 'the',
    'their', 'then', 'there', 'these', 'they', 'this', 'to', 'was', 'will', 'with'
  };

  /// Tokenizes a string: lowercases, removes punctuation, and splits by whitespace, ignoring stop words.
  static Set<String> _tokenize(String text) {
    if (text.isEmpty) return {};
    final cleanedText = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final tokens = cleanedText.split(RegExp(r'\s+'));
    return tokens.where((token) => token.isNotEmpty && !_stopWords.contains(token)).toSet();
  }

  /// Calculates the Jaccard Similarity index between user answer and correct answer.
  /// Returns a normalized score between 0.0 and 100.0.
  static double calculateSimilarity(String userAnswer, String correctAnswer) {
    if (userAnswer.isEmpty || correctAnswer.isEmpty) return 0.0;

    final userTokens = _tokenize(userAnswer);
    final correctTokens = _tokenize(correctAnswer);

    if (userTokens.isEmpty || correctTokens.isEmpty) return 0.0;

    int intersection = 0;
    for (final token in userTokens) {
      if (correctTokens.contains(token)) {
        intersection++;
      } else {
        // Allow for minor typos using basic substring checks on longer words
        if (token.length > 4) {
          bool fuzzyMatch = correctTokens.any((ct) => ct.contains(token) || token.contains(ct));
          if (fuzzyMatch) intersection++;
        }
      }
    }

    // Instead of strict Union (which severely punishes slightly verbose user answers),
    // we grade based on how many of the core "correct" terms the user hit.
    // However, if the user just typed random words, it won't inflate.
    double baseScore = (intersection / correctTokens.length);
    
    // Cap at 1.0 (100%)
    return (baseScore > 1.0 ? 1.0 : baseScore) * 100;
  }

  /// Generates a static classification based on the percentage score
  static String getGradeFeedback(double score) {
    if (score >= 80) return "Excellent! You nailed the core concepts. 🔥";
    if (score >= 60) return "Good job! You captured most of the idea. ✅";
    if (score >= 40) return "On the right track, but missing some key details. 🤔";
    return "Not quite. Check the detailed explanation below to see what you missed. ❌";
  }
}
