/// User model representing Patients and Caregivers.
class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role; // 'patient' or 'caregiver'
  final DateTime createdAt;
  final String? profileImage;
  final DateTime? dateOfBirth;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.profileImage,
    this.dateOfBirth,
  });

  bool get isPatient => role == 'patient';
  bool get isCaregiver => role == 'caregiver';

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'profileImage': profileImage,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parsedCreatedAt = DateTime.now();
    if (map['createdAt'] != null) {
      if (map['createdAt'] is DateTime) {
        parsedCreatedAt = map['createdAt'] as DateTime;
      } else {
        try {
          // Dynamic invocation handles Timestamp without importing cloud_firestore here
          final dynamic dynCreated = map['createdAt'];
          if (dynCreated.toDate != null) {
            parsedCreatedAt = dynCreated.toDate() as DateTime;
          } else {
            parsedCreatedAt = DateTime.tryParse(dynCreated.toString()) ?? DateTime.now();
          }
        } catch (_) {
          parsedCreatedAt = DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now();
        }
      }
    }

    DateTime? parsedDob;
    if (map['dateOfBirth'] != null) {
      if (map['dateOfBirth'] is DateTime) {
        parsedDob = map['dateOfBirth'] as DateTime;
      } else {
        try {
          final dynamic dynDob = map['dateOfBirth'];
          if (dynDob.toDate != null) {
            parsedDob = dynDob.toDate() as DateTime;
          } else {
            parsedDob = DateTime.tryParse(dynDob.toString());
          }
        } catch (_) {
          parsedDob = DateTime.tryParse(map['dateOfBirth'].toString());
        }
      }
    }

    return UserModel(
      userId: documentId ?? (map['uid'] as String?) ?? (map['userId'] as String?) ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: (map['role'] as String? ?? 'patient').toLowerCase(),
      createdAt: parsedCreatedAt,
      profileImage: map['profileImage'] as String?,
      dateOfBirth: parsedDob,
    );
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? profileImage,
    DateTime? dateOfBirth,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
