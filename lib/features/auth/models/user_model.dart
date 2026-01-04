class AppUser {
  final String id;
  final String name;
  final String phone;
  final String cnic;
  final String jobType;
  final String role;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.cnic,
    required this.jobType,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      cnic: data['cnic'] ?? '',
      jobType: data['job_type'] ?? '',
      role: data['role'] ?? '',
    );
  }

  /// ✅ Add this method:
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'cnic': cnic,
      'job_type': jobType,
      'role': role,
    };
  }
}
