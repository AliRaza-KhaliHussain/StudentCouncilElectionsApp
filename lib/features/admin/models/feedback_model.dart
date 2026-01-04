class FeedbackModel {
  int rating;
  String suggestion;
  String issue;
  int trustLevel;

  FeedbackModel({
    required this.rating,
    required this.suggestion,
    required this.issue,
    required this.trustLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'suggestion': suggestion.trim(),
      'issue': issue.trim(),
      'trust_level': trustLevel,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// ✅ Add this method to deserialize Firestore data
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      rating: map['rating'] ?? 0,
      suggestion: map['suggestion'] ?? '',
      issue: map['issue'] ?? '',
      trustLevel: map['trust_level'] ?? 0,
    );
  }
}
