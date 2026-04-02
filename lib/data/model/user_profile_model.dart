/// Display profile for the Profile & Settings tab (replace with API user DTO).
class UserProfileModel {
  const UserProfileModel({
    required this.displayName,
    required this.jobTitle,
    required this.employeeId,
    required this.email,
    required this.phone,
    required this.company,
    this.isActive = true,
  });

  final String displayName;
  final String jobTitle;
  final String employeeId;
  final String email;
  final String phone;
  final String company;
  final bool isActive;

  UserProfileModel copyWith({
    String? displayName,
    String? jobTitle,
    String? employeeId,
    String? email,
    String? phone,
    String? company,
    bool? isActive,
  }) {
    return UserProfileModel(
      displayName: displayName ?? this.displayName,
      jobTitle: jobTitle ?? this.jobTitle,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      isActive: isActive ?? this.isActive,
    );
  }
}
