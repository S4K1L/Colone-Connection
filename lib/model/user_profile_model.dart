class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.image,
    required this.profile,
    this.isActive = true,
  });

  final int id;
  final String email;
  final String fullName;
  final String phone;
  final String image;
  final UserProfileDetails profile;
  final bool isActive;

  factory UserProfileModel.empty() {
    return const UserProfileModel(
      id: 0,
      email: '',
      fullName: '',
      phone: '',
      image: '',
      profile: UserProfileDetails.empty(),
      isActive: true,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      profile: UserProfileDetails.fromJson(
        json['profile'] is Map<String, dynamic>
            ? json['profile'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      isActive: true,
    );
  }

  UserProfileModel copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phone,
    String? image,
    UserProfileDetails? profile,
    bool? isActive,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      profile: profile ?? this.profile,
      isActive: isActive ?? this.isActive,
    );
  }
}

class UserProfileDetails {
  const UserProfileDetails({
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.city,
    required this.country,
    required this.postalCode,
    required this.bio,
    required this.website,
    required this.facebook,
    required this.linkedin,
    required this.twitter,
    required this.company,
    required this.jobTitle,
  });

  final String address;
  final String dateOfBirth;
  final String gender;
  final String city;
  final String country;
  final String postalCode;
  final String bio;
  final String website;
  final String facebook;
  final String linkedin;
  final String twitter;
  final String company;
  final String jobTitle;

  const UserProfileDetails.empty()
      : address = '',
        dateOfBirth = '',
        gender = '',
        city = '',
        country = '',
        postalCode = '',
        bio = '',
        website = '',
        facebook = '',
        linkedin = '',
        twitter = '',
        company = '',
        jobTitle = '';

  factory UserProfileDetails.fromJson(Map<String, dynamic> json) {
    return UserProfileDetails(
      address: (json['address'] ?? '').toString(),
      dateOfBirth: (json['date_of_birth'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      postalCode: (json['postal_code'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      facebook: (json['facebook'] ?? '').toString(),
      linkedin: (json['linkedin'] ?? '').toString(),
      twitter: (json['twitter'] ?? '').toString(),
      company: (json['company'] ?? '').toString(),
      jobTitle: (json['job_title'] ?? '').toString(),
    );
  }
}
