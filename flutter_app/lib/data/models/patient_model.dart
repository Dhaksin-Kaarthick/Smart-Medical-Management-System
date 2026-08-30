/// Patient profile entity linking to user, caregiver, and IoT device.
class PatientModel {
  final String patientId;
  final String userId;
  final String? caregiverId;
  final String? deviceId;
  final String name;
  final int age;
  final String? bloodGroup;
  final String? emergencyContact;
  final double adherenceRate; // 0.0 - 100.0
  final String riskLevel; // 'LOW', 'MEDIUM', 'HIGH'
  final DateTime createdAt;

  const PatientModel({
    required this.patientId,
    required this.userId,
    this.caregiverId,
    this.deviceId,
    required this.name,
    this.age = 65,
    this.bloodGroup,
    this.emergencyContact,
    this.adherenceRate = 100.0,
    this.riskLevel = 'LOW',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'userId': userId,
      'caregiverId': caregiverId,
      'deviceId': deviceId,
      'name': name,
      'age': age,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
      'adherenceRate': adherenceRate,
      'riskLevel': riskLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return PatientModel(
      patientId: documentId ?? map['patientId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      caregiverId: map['caregiverId'] as String?,
      deviceId: map['deviceId'] as String?,
      name: map['name'] as String? ?? 'Patient',
      age: (map['age'] as num?)?.toInt() ?? 65,
      bloodGroup: map['bloodGroup'] as String?,
      emergencyContact: map['emergencyContact'] as String?,
      adherenceRate: (map['adherenceRate'] as num?)?.toDouble() ?? 100.0,
      riskLevel: map['riskLevel'] as String? ?? 'LOW',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  PatientModel copyWith({
    String? patientId,
    String? userId,
    String? caregiverId,
    String? deviceId,
    String? name,
    int? age,
    String? bloodGroup,
    String? emergencyContact,
    double? adherenceRate,
    String? riskLevel,
    DateTime? createdAt,
  }) {
    return PatientModel(
      patientId: patientId ?? this.patientId,
      userId: userId ?? this.userId,
      caregiverId: caregiverId ?? this.caregiverId,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      riskLevel: riskLevel ?? this.riskLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
