import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRegistrationViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();
  final jobTypeController = TextEditingController();

  String selectedRole = 'Voter';
  String? selectedJobType;
  bool isSubmitting = false;

  final jobTypes = [
    'Engineer',
    'Doctor',
    'Teacher',
    'Lawyer',
    'Student',
    'Other',
  ];

  void setSelectedJobType(String? value) {
    selectedJobType = value;
    if (value != 'Other') jobTypeController.clear();
    notifyListeners();
  }

  Future<void> submitRegistrationRequest(BuildContext context) async {
    final name = nameController.text.trim();
    final cnic = cnicController.text.trim();
    final phone = phoneController.text.trim();
    final jobType = selectedJobType == 'Other'
        ? jobTypeController.text.trim()
        : selectedJobType;

    if (name.isEmpty || cnic.isEmpty || phone.isEmpty || jobType == null || jobType.isEmpty) {
      _showSnackBar(context, "Please fill all required fields.");
      return;
    }

    if (!RegExp(r'^\d{13}$').hasMatch(cnic)) {
      _showSnackBar(context, "CNIC must be 13 digits.");
      return;
    }

    if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
      _showSnackBar(context, "Phone number must start with 03 and be 11 digits.");
      return;
    }

    try {
      isSubmitting = true;
      notifyListeners();

      // 🔍 Check for existing pending request
      final existingQuery = await FirebaseFirestore.instance
          .collection('registration_requests')
          .where('cnic', isEqualTo: cnic)
          .where('phone', isEqualTo: phone)
          //.orderBy('requested_at', descending: true)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final existing = existingQuery.docs.first.data();
        final status = (existing['status'] ?? '').toString().toLowerCase();

        if (status == 'pending') {
          _showSnackBar(context, "You have already applied. Please wait for admin approval.");
          isSubmitting = false;
          notifyListeners();
          return;
        }

        if (status != 'rejected') {
          _showSnackBar(context, "Your previous request is under review or approved.");
          isSubmitting = false;
          notifyListeners();
          return;
        }
      }

      // ✅ Submit new request
      await FirebaseFirestore.instance.collection('registration_requests').add({
        'name': name,
        'cnic': cnic,
        'phone': phone,
        'role': selectedRole,
        'job_type': jobType,
        'status': 'pending',
        'requested_at': FieldValue.serverTimestamp(),
      });

      _showSnackBar(context, "Registration request submitted.", isError: false);
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar(context, "Submission failed: ${e.toString()}");
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    jobTypeController.dispose();
    super.dispose();
  }
}





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class UserRegistrationViewModel extends ChangeNotifier {
//   final nameController = TextEditingController();
//   final cnicController = TextEditingController();
//   final phoneController = TextEditingController();
//   final jobTypeController = TextEditingController();
//
//   String selectedRole = 'Voter';
//   String? selectedJobType;
//   bool isSubmitting = false;
//
//   final jobTypes = [
//     'Engineer',
//     'Doctor',
//     'Teacher',
//     'Lawyer',
//     'Student',
//     'Other',
//   ];
//
//   void setSelectedJobType(String? value) {
//     selectedJobType = value;
//     if (value != 'Other') jobTypeController.clear();
//     notifyListeners();
//   }
//
//   Future<void> submitRegistrationRequest(BuildContext context) async {
//     final name = nameController.text.trim();
//     final cnic = cnicController.text.trim();
//     final phone = phoneController.text.trim();
//     final jobType = selectedJobType == 'Other'
//         ? jobTypeController.text.trim()
//         : selectedJobType;
//
//     if (name.isEmpty || cnic.isEmpty || phone.isEmpty || jobType == null || jobType.isEmpty) {
//       _showSnackBar(context, "Please fill all required fields.");
//       return;
//     }
//
//     if (!RegExp(r'^\d{13}$').hasMatch(cnic)) {
//       _showSnackBar(context, "CNIC must be 13 digits.");
//       return;
//     }
//
//     if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
//       _showSnackBar(context, "Phone number must start with 03 and be 11 digits.");
//       return;
//     }
//
//     try {
//       isSubmitting = true;
//       notifyListeners();
//
//       await FirebaseFirestore.instance.collection('registration_requests').add({
//         'name': name,
//         'cnic': cnic,
//         'phone': phone,
//         'role': selectedRole,
//         'job_type': jobType, // 🔄 Use snake_case to match admin panel
//         'status': 'pending', // 🔄 Lowercase to match filter
//         'requested_at': FieldValue.serverTimestamp(), // ✅ Correct field name
//       });
//
//       _showSnackBar(context, "Registration request submitted.", isError: false);
//       Navigator.of(context).pop();
//     } catch (e) {
//       _showSnackBar(context, "Submission failed: ${e.toString()}");
//     } finally {
//       isSubmitting = false;
//       notifyListeners();
//     }
//   }
//
//   void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     cnicController.dispose();
//     phoneController.dispose();
//     jobTypeController.dispose();
//     super.dispose();
//   }
// }