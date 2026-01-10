import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/input_validators.dart';
import '../../../app/app.dart';
import '../../../screens/main_screen.dart';
import '../../election/views/voter_dashboard_screen.dart';

class LoginViewModel extends ChangeNotifier {
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool isLoading = false;
  String? verificationId;
  bool showOtpField = false;

  void showMessage(String msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.TOP);
  }

  Future<void> checkAndSendOtp(BuildContext context) async {
    final cnic = cnicController.text.trim();
    final phone = phoneController.text.trim();

    if (!InputValidators.isValidCNIC(cnic)) {
      showMessage('Enter valid 13-digit CNIC');
      return;
    }
    if (!InputValidators.isValidPhone(phone)) {
      showMessage('Enter valid phone number');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('cnic', isEqualTo: cnic)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        showMessage('User not found. Please register first.');
        isLoading = false; // ✅ Fix: stop loading
        notifyListeners();
        return;
      }

      final fullPhone = '+92${phone.substring(1)}';

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          loginSuccess(context, query.docs.first.data());
        },
        verificationFailed: (e) {
          String message;
          switch (e.code) {
            case 'invalid-phone-number':
              message = 'Invalid phone number format.';
              break;
            case 'too-many-requests':
              message = 'Too many OTP requests. Try again later.';
              break;
            default:
              message = 'OTP Failed: ${e.message}';
          }
          showMessage(message);
          isLoading = false;
          notifyListeners();
        },
        codeSent: (id, _) {
          verificationId = id;
          showOtpField = true;
          isLoading = false;
          notifyListeners();
          showMessage("OTP Sent to $fullPhone");
        },
        codeAutoRetrievalTimeout: (id) {
          verificationId = id;
        },
      );
    } catch (e) {
      showMessage('Unexpected error: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtpAndLogin(BuildContext context) async {
    final otp = otpController.text.trim();
    if (verificationId == null || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      showMessage("Enter valid 6-digit OTP");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('cnic', isEqualTo: cnicController.text.trim())
          .where('phone', isEqualTo: phoneController.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        showMessage("User record not found after OTP verification");
        isLoading = false;
        notifyListeners();
        return;
      }

      loginSuccess(context, snapshot.docs.first.data());
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Invalid OTP entered.';
          break;
        case 'session-expired':
          message = 'OTP session expired. Request a new OTP.';
          break;
        default:
          message = 'Invalid OTP: ${e.message}';
      }
      showMessage(message);
    } catch (e) {
      showMessage("Unexpected error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void loginSuccess(BuildContext context, Map<String, dynamic> userData) {
    final role = userData['role'];
    showMessage("Login successful!");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => role == 'admin'
            ? MainScreen()
            : const VoterDashboardScreen(),
      ),
    );
  }

  @override
  void dispose() {
    cnicController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
