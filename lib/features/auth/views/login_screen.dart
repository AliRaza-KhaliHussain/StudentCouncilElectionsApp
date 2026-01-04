import 'package:flutter/material.dart';
import 'package:project/features/auth/views/user_registration_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // Delay rendering animations until frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: _isReady
          ? const _LoginForm()
          : const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoginViewModel>(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.how_to_vote,
                  color: AppColors.primary,
                  size: isLargeScreen ? 100 : 72,
                ).animate().fadeIn(),

                const SizedBox(height: 12),

                Text(
                  'Secure Voting App',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 34 : 28,
                    fontWeight: FontWeight.bold ,
                    color: AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 32),

                _buildTextField(
                  controller: vm.cnicController,
                  label: 'CNIC (13-digit)',
                  icon: Icons.credit_card,
                  inputType: TextInputType.number,
                  maxLength: 13,
                  context: context,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: vm.phoneController,
                  label: 'Phone 03...(11-Digits)',
                  icon: Icons.phone_android,
                  inputType: TextInputType.phone,
                  maxLength: 11,
                  context: context,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                if (vm.showOtpField)
                  Pinput(
                    controller: vm.otpController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 56,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: theme.textTheme.bodyLarge!.color,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : vm.showOtpField
                        ? () => vm.verifyOtpAndLogin(context)
                        : () => vm.checkAndSendOtp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      vm.showOtpField ? 'Verify OTP & Login' : 'Send OTP',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 20),

                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterUserScreen()),
                  ),
                  icon: Icon(Icons.person_add_alt_1,
                      color: AppColors.primary),
                  label: Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType inputType,
    required BuildContext context,
    int? maxLength,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      style: TextStyle(color: theme.textTheme.bodyLarge!.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyLarge!.color),
        counterText: '',
        prefixIcon: Icon(icon, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
