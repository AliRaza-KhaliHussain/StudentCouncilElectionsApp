import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_model.dart';

class FeedbackViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  FeedbackModel feedback = FeedbackModel(rating: 0, suggestion: '', issue: '', trustLevel: 0);
  bool isSubmitting = false;
  String? error;

  void setRating(int value) {
    feedback.rating = value;
    notifyListeners();
  }

  void setTrustLevel(int value) {
    feedback.trustLevel = value;
    notifyListeners();
  }

  void setSuggestion(String value) {
    feedback.suggestion = value.trim();
  }

  void setIssue(String value) {
    feedback.issue = value.trim();
  }

  Future<bool> submitFeedback(String electionId) async {
    if (!formKey.currentState!.validate()) return false;

    if (feedback.rating == 0) {
      error = 'Please provide a star rating.';
      notifyListeners();
      return false;
    }

    if (feedback.trustLevel < 1 || feedback.trustLevel > 5) {
      error = 'Please rate blockchain trust (1–5 hearts).';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await FirebaseFirestore.instance
          .collection('feedback')
          .doc('${user.uid}_$electionId')
          .set(feedback.toMap());

      return true;
    } catch (e) {
      error = 'Failed to submit feedback: $e';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
