import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../viewmodels/user_registration_viewmodel.dart';

class RegisterUserScreen extends StatelessWidget {
  const RegisterUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRegistrationViewModel(),
      child: Consumer<UserRegistrationViewModel>(
        builder: (context, viewModel, child) {
          final maxWidth = MediaQuery.of(context).size.width > 600 ? 500.0 : double.infinity;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text('Apply for Registration'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        context,
                        controller: viewModel.nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        inputType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        controller: viewModel.cnicController,
                        label: 'CNIC (13 digits)',
                        icon: Icons.credit_card,
                        inputType: TextInputType.number,
                        maxLength: 13,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        controller: viewModel.phoneController,
                        label: 'Phone 03...(11 digits)',
                        icon: Icons.phone_android,
                        inputType: TextInputType.phone,
                        maxLength: 11,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: viewModel.selectedRole,
                        decoration: const InputDecoration(labelText: 'Select Role'),
                        items: ['Voter', 'Admin'].map((role) {
                          return DropdownMenuItem(value: role, child: Text(role));
                        }).toList(),
                        onChanged: (value) {
                          viewModel.selectedRole = value!;
                          viewModel.notifyListeners();
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: viewModel.selectedJobType,
                        decoration: const InputDecoration(labelText: 'Select Job Type'),
                        items: viewModel.jobTypes.map((job) {
                          return DropdownMenuItem(value: job, child: Text(job));
                        }).toList(),
                        onChanged: viewModel.setSelectedJobType,
                      ),
                      if (viewModel.selectedJobType == 'Other') ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          context,
                          controller: viewModel.jobTypeController,
                          label: 'Enter Job Type',
                          icon: Icons.work,
                          inputType: TextInputType.text, // <-- FIXED: added required param
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: viewModel.isSubmitting
                            ? null
                            : () => viewModel.submitRegistrationRequest(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: viewModel.isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit Request', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required TextInputType inputType,
        int? maxLength,
      }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: [
        if (inputType == TextInputType.number || inputType == TextInputType.phone)
          FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        counterText: '',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
