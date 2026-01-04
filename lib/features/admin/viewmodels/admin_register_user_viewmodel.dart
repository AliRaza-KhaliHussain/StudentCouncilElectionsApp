

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';

class AdminRegisterUserViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();
  final jobTypeController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  String? selectedRole;
  bool isLoading = false;

  List<String> jobTypeSuggestions = [
    "TEACHER", "LECTURER", "PROFESSOR", "PRINCIPAL", "DEAN",
    "REGISTRAR", "HOD", "ACCOUNTANT", "ASSISTANT PROFESSOR", "LIBRARIAN",
    // ... (rest of your job type suggestions)
  ];

  @override
  void dispose() {
    nameController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    jobTypeController.dispose();
    super.dispose();
  }

  void setRole(String? role) {
    selectedRole = role;
    notifyListeners();
  }

  Future<void> fetchJobTypesFromFirestore(BuildContext context) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('job_types').get();
      final firestoreJobs = snapshot.docs.map((doc) => doc['name'].toString().toUpperCase()).toSet();
      jobTypeSuggestions = {...jobTypeSuggestions.map((e) => e.toUpperCase()), ...firestoreJobs}.toList();
      notifyListeners();
    } catch (_) {
      showMessage("Could not fetch job types.", context: context);
    }
  }

  void showMessage(String message, {bool success = false, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.primary : Colors.red,
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> registerUserByAdmin(BuildContext context) async {
    if (!formKey.currentState!.validate() || selectedRole == null) {
      showMessage("Please fill all fields and select a role", context: context);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final cnic = cnicController.text.trim();
      final phone = phoneController.text.trim();
      final jobType = jobTypeController.text.trim().toUpperCase();
      final name = nameController.text.trim().toUpperCase();

      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('cnic', isEqualTo: cnic)
          .where('phone', isEqualTo: phone)
          .get();

      if (existingUser.docs.isNotEmpty) {
        showMessage("User with this CNIC and phone already exists.", context: context);
        return;
      }

      final currentAdmin = FirebaseAuth.instance.currentUser;
      if (currentAdmin == null) {
        showMessage("Admin not logged in.", context: context);
        return;
      }

      final jobTypeSnapshot = await FirebaseFirestore.instance.collection('job_types').get();
      final existingTypes = jobTypeSnapshot.docs.map((doc) => doc['name'].toString().toUpperCase()).toSet();

      if (!existingTypes.contains(jobType)) {
        await FirebaseFirestore.instance.collection('job_types').add({
          'name': jobType,
          'created_at': FieldValue.serverTimestamp(),
        });
        showMessage("New job type '$jobType' added.", success: true, context: context);
      }

      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'cnic': cnic,
        'phone': phone,
        'role': selectedRole,
        'job_type': jobType,
        'created_by': currentAdmin.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      showMessage("User registered successfully!", success: true, context: context);
      nameController.clear();
      cnicController.clear();
      phoneController.clear();
      jobTypeController.clear();
      selectedRole = null;
      await fetchJobTypesFromFirestore(context);
    } catch (e) {
      showMessage("Error: ${e.toString()}", context: context);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}