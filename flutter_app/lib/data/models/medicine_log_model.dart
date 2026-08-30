/// Medicine Log record tracking individual dose events, timestamps, and status.
class MedicineLogModel {
  final String logId;
  final String patientId;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final String status; // 'upcoming', 'taken', 'missed', 'late'
  final String? deviceId;
  final DateTime createdAt;

  const MedicineLogModel({
    required this.logId,
    required this.patientId,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.deviceId,
    required this.createdAt,
  });

  bool get isTaken => status == 'taken';
  bool get isMissed => status == 'missed';
  bool get isUpcoming => status == 'upcoming';
  bool get isLate => status == 'late';

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'patientId': patientId,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'dosage': dosage,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'status': status,
      'deviceId': deviceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicineLogModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return MedicineLogModel(
      logId: documentId ?? map['logId'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      medicineId: map['medicineId'] as String? ?? '',
      medicineName: map['medicineName'] as String? ?? 'Medicine',
      dosage: map['dosage'] as String? ?? '',
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.tryParse(map['scheduledTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      takenTime: map['takenTime'] != null
          ? DateTime.tryParse(map['takenTime'].toString())
          : null,
      status: map['status'] as String? ?? 'upcoming',
      deviceId: map['deviceId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MedicineLogModel copyWith({
    String? logId,
    String? patientId,
    String? medicineId,
    String? medicineName,
    String? dosage,
    DateTime? scheduledTime,
    DateTime? takenTime,
    String? status,
    String? deviceId,
    DateTime? createdAt,
  }) {
    return MedicineLogModel(
      logId: logId ?? this.logId,
      patientId: patientId ?? this.patientId,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
