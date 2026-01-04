// //register_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../constants/app_colors.dart';
// import '../utils/input_validators.dart';
// import 'voter_dashboard_screen.dart';
// import 'login_screen.dart';
// import 'admin_dashboard_screen.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final nameController = TextEditingController();
//   final cnicController = TextEditingController();
//   final phoneController = TextEditingController();
//
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   String? selectedRole;
//
//   Future<void> registerUser() async {
//     if (!_formKey.currentState!.validate() || selectedRole == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields correctly and select a role')),
//       );
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       final email = '${cnicController.text.trim()}@example.com';
//       final password = phoneController.text.trim() + '_pass123';
//
//       final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final user = userCredential.user;
//
//       if (user != null) {
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'uid': user.uid,
//           'name': nameController.text.trim(),
//           'cnic': cnicController.text.trim(),
//           'phone': phoneController.text.trim(),
//           'role': selectedRole,
//           'created_at': Timestamp.now(),
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("User registered successfully")),
//         );
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => selectedRole == 'admin'
//                 ? const AdminDashboardScreen()
//                 : const VoterDashboardScreen(),
//           ),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Firebase Error: ${e.message}")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $e")),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Widget buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon),
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         validator: validator,
//       ),
//     );
//   }
//
//   Widget buildRoleSelector() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8, bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Select Role:', style: TextStyle(fontWeight: FontWeight.bold)),
//           Row(
//             children: [
//               Radio<String>(
//                 value: 'admin',
//                 groupValue: selectedRole,
//                 onChanged: (value) => setState(() => selectedRole = value),
//               ),
//               const Text('Admin'),
//               Radio<String>(
//                 value: 'voter',
//                 groupValue: selectedRole,
//                 onChanged: (value) => setState(() => selectedRole = value),
//               ),
//               const Text('Voter'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWide = screenWidth > 600;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 500),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   buildTextField(
//                     controller: nameController,
//                     label: 'Full Name',
//                     icon: Icons.person,
//                     validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
//                   ),
//                   buildTextField(
//                     controller: cnicController,
//                     label: 'CNIC (13-digit)',
//                     icon: Icons.credit_card,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(13),
//                     ],
//                     validator: InputValidators.validateCNIC,
//
//                   ),
//                   buildTextField(
//                     controller: phoneController,
//                     label: 'Phone Number',
//                     icon: Icons.phone,
//                     keyboardType: TextInputType.phone,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(11),
//                     ],
//                     validator: InputValidators.validatePhone,
//
//                   ),
//                   buildRoleSelector(),
//                   const SizedBox(height: 20),
//                   isLoading
//                       ? const CircularProgressIndicator()
//                       : SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: registerUser,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('Register', style: TextStyle(fontSize: 16)),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextButton(
//                     onPressed: () => Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const LoginScreen()),
//                     ),
//                     child: const Text('Already have an account? Login'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     cnicController.dispose();
//     phoneController.dispose();
//     super.dispose();
//   }
// }
