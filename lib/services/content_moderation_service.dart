class ContentModerationService {
  // List of harmful and explicit keywords that trigger moderation
  static final List<String> _flaggedKeywords = [
    // Explicit content
    'porn',
    'xxx',
    'sex',
    'nude',
    'naked',
    
    // Violence
    'kill',
    'murder',
    'bomb',
    'terrorist',
    'weapon',
    
    // Hate speech
    'hate',
    'racist',
    'nazi',
    
    // Harassment
    'harassment',
    'bully',
    'threat',
    
    // Drugs
    'drug',
    'cocaine',
    'heroin',
    'meth',
    
    // Scams/Spam
    'scam',
    'fraud',
    'phishing',
    
    // Other harmful content
    'suicide',
    'self-harm',
    'abuse',
  ];

  /// Checks if content contains any flagged keywords
  /// Returns a Map with 'isFlagged' (bool) and 'matchedKeywords' (List<String>)
  static Map<String, dynamic> checkContent(String title, String content) {
    final fullText = '${title.toLowerCase()} ${content.toLowerCase()}';
    final List<String> matchedKeywords = [];

    for (final keyword in _flaggedKeywords) {
      if (fullText.contains(keyword.toLowerCase())) {
        matchedKeywords.add(keyword);
      }
    }

    return {
      'isFlagged': matchedKeywords.isNotEmpty,
      'matchedKeywords': matchedKeywords,
    };
  }

  /// Get a formatted string of matched keywords
  static String getMatchedKeywordsString(List<String> keywords) {
    if (keywords.isEmpty) return 'None';
    return keywords.join(', ');
  }

  /// Check if user is attempting to bypass filters with special characters
  static bool checkForBypassAttempts(String text) {
    // Check for common bypass patterns like sp4c3s, l33tsp34k, etc.
    final suspiciousPatterns = [
      RegExp(r'[a-zA-Z]\s+[a-zA-Z]\s+[a-zA-Z]'), // Excessive spacing
      RegExp(r'[^\w\s]{3,}'), // Multiple special characters in a row
    ];

    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }

    return false;
  }

  /// Get all flagged keywords (for admin reference)
  static List<String> getAllFlaggedKeywords() {
    return List.from(_flaggedKeywords);
  }

  /// Add a new keyword to the flagged list (admin functionality)
  static void addFlaggedKeyword(String keyword) {
    if (!_flaggedKeywords.contains(keyword.toLowerCase())) {
      _flaggedKeywords.add(keyword.toLowerCase());
    }
  }

  /// Remove a keyword from the flagged list (admin functionality)
  static void removeFlaggedKeyword(String keyword) {
    _flaggedKeywords.remove(keyword.toLowerCase());
  }
}
