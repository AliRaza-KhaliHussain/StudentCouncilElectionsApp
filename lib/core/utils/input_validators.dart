/// A utility class for common input validation across the app.
class InputValidators {
  /// Validates a 13-digit CNIC string.
  static String? validateCNIC(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter CNIC';
    if (!RegExp(r'^\d{13}$').hasMatch(value.trim())) return 'CNIC must be exactly 13 digits';
    return null;
  }

  /// Validates a Pakistani phone number starting with 03 and 11 digits long.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter phone number';
    if (!RegExp(r'^03\d{9}$').hasMatch(value.trim())) return 'Enter valid 11-digit phone starting with 03';
    return null;
  }

  /// Quick boolean check for CNIC validity.
  static bool isValidCNIC(String cnic) {
    return RegExp(r'^\d{13}$').hasMatch(cnic.trim());
  }

  /// Quick boolean check for phone validity.
  static bool isValidPhone(String phone) {
    return RegExp(r'^03\d{9}$').hasMatch(phone.trim());
  }
}
