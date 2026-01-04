import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/admin_register_user_viewmodel.dart';

class AdminRegisterUserScreen extends StatelessWidget {
  const AdminRegisterUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminRegisterUserViewModel(),
      child: const _AdminRegisterForm(),
    );
  }
}

class _AdminRegisterForm extends StatelessWidget {
  const _AdminRegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminRegisterUserViewModel>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final background = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    // Fetch job types when the screen is first built
    Future.microtask(() => vm.fetchJobTypesFromFirestore(context));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Register New User'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: vm.formKey,
              child: ListView(
                children: [
                  _buildTextField(
                    controller: vm.nameController,
                    label: 'Name (e.g. ALI)',
                    icon: Icons.person,
                    inputFormatters: [UpperCaseTextFormatter()],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter name';
                      if (!RegExp(r"^[A-Z ]+$").hasMatch(val.toUpperCase())) {
                        return 'Only alphabets and spaces allowed';
                      }
                      return null;
                    },
                    fillColor: fillColor,
                  ),
                  _buildTextField(
                    controller: vm.cnicController,
                    label: 'CNIC (e.g. 3550106114303)',
                    icon: Icons.credit_card,
                    inputType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter CNIC';
                      if (!RegExp(r'^[0-9]{13}$').hasMatch(val)) {
                        return 'Enter valid 13-digit CNIC';
                      }
                      return null;
                    },
                    fillColor: fillColor,
                  ),
                  _buildTextField(
                    controller: vm.phoneController,
                    label: 'Phone (e.g. 03444043167)',
                    icon: Icons.phone,
                    inputType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter phone';
                      if (!RegExp(r'^[0-9]{11}$').hasMatch(val)) {
                        return 'Enter valid 11-digit phone';
                      }
                      return null;
                    },
                    fillColor: fillColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Autocomplete<String>(
                      optionsBuilder: (textEditingValue) {
                        return vm.jobTypeSuggestions
                            .where((type) => type.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                            .toList();
                      },
                      onSelected: (String selection) {
                        vm.jobTypeController.text = selection;
                      },
                      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                        textController.text = vm.jobTypeController.text;
                        textController.addListener(() {
                          vm.jobTypeController.text = textController.text;
                        });

                        return TextFormField(
                          controller: textController,
                          focusNode: focusNode,
                          inputFormatters: [UpperCaseTextFormatter()],
                          validator: (val) => val == null || val.trim().isEmpty ? 'Enter job type' : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.work, color: AppColors.primary),
                            labelText: 'Job Type',
                            filled: true,
                            fillColor: fillColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Select Role", style: TextStyle(fontWeight: FontWeight.bold)),
                  Consumer<AdminRegisterUserViewModel>(
                    builder: (context, vm, child) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: 'admin',
                            groupValue: vm.selectedRole,
                            onChanged: vm.setRole,
                            activeColor: AppColors.primary,
                          ),
                          const Text("Admin"),
                          Radio<String>(
                            value: 'voter',
                            groupValue: vm.selectedRole,
                            onChanged: vm.setRole,
                            activeColor: AppColors.primary,
                          ),
                          const Text("Voter"),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Consumer<AdminRegisterUserViewModel>(
                    builder: (context, vm, child) {
                      return vm.isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : ElevatedButton.icon(
                        onPressed: () => vm.registerUserByAdmin(context),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Register User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    required Color fillColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          filled: true,
          fillColor: fillColor,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}