import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../admin/viewmodels/feedback_viewmodel.dart';
import '../../../core/widgets/rating_bar_widget.dart';
import '../../../shared/widgets/likert_hearts_widget.dart';

class ThankYouFeedbackScreen extends StatelessWidget {
  final String electionId;

  const ThankYouFeedbackScreen({super.key, required this.electionId});

  void _navigateToDashboard(BuildContext context, {bool showThanks = false}) {
    if (showThanks) {
      Fluttertoast.showToast(
        msg: "🎉 Thanks! You're done.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    Navigator.popUntil(context, ModalRoute.withName('/voter_dashboard'));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Feedback')),
        body: Consumer<FeedbackViewModel>(
          builder: (context, vm, _) => Form(
            key: vm.formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('⭐ Rate your voting experience'),
                RatingBarWidget(
                  rating: vm.feedback.rating,
                  onChanged: vm.setRating,
                ),
                const SizedBox(height: 20),

                const Text('❤️ How much do you trust our blockchain?'),
                LikertHeartsWidget(
                  value: vm.feedback.trustLevel,
                  onChanged: vm.setTrustLevel,
                ),
                const SizedBox(height: 20),

                const Text('💡 Suggestions (optional, max 50 chars)'),
                TextFormField(
                  maxLength: 50,
                  onChanged: vm.setSuggestion,
                  decoration: const InputDecoration(
                    hintText: 'Your idea or suggestion...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('🐞 Report an issue (optional, max 150 chars)'),
                TextFormField(
                  maxLength: 150,
                  onChanged: vm.setIssue,
                  decoration: const InputDecoration(
                    hintText: 'Bugs, concerns, problems...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                if (vm.isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Feedback'),
                    onPressed: () async {
                      final success = await vm.submitFeedback(electionId);
                      if (success && context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            title: const Text('🎉 Thank You!'),
                            content: const Text('Your feedback was submitted successfully.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close dialog
                                  _navigateToDashboard(context, showThanks: true);
                                },
                                child: const Text('Go to Dashboard'),
                              ),
                            ],
                          ),
                        );
                      } else if (vm.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vm.error!)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    label: const Text('Cancel and Skip Feedback'),
                    onPressed: () {
                      _navigateToDashboard(context, showThanks: true);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
