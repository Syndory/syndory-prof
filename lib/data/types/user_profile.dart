import 'user_role.dart';

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isActive;
  final String? fcmToken;

  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    this.fcmToken,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.student,
      ),
      isActive: json['is_active'] as bool,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';
}
