/// Medicine prescription entity with schedule, dosage, and instructions.
class MedicineModel {
  final String medicineId;
  final String patientId;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> scheduledTimes; // e.g. ["09:00 AM", "08:00 PM"]
  final DateTime startDate;
  final DateTime? endDate;
  final String instructions;
  final bool active;

  const MedicineModel({
    required this.medicineId,
    required this.patientId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.scheduledTimes,
    required this.startDate,
    this.endDate,
    this.instructions = 'Take as prescribed',
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'patientId': patientId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'scheduledTimes': scheduledTimes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
      'active': active,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return MedicineModel(
      medicineId: documentId ?? map['medicineId'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      frequency: map['frequency'] as String? ?? 'Daily',
      scheduledTimes: (map['scheduledTimes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['09:00 AM'],
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'].toString())
          : null,
      instructions: map['instructions'] as String? ?? 'Take as prescribed',
      active: map['active'] as bool? ?? true,
    );
  }

  MedicineModel copyWith({
    String? medicineId,
    String? patientId,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? scheduledTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    bool? active,
  }) {
    return MedicineModel(
      medicineId: medicineId ?? this.medicineId,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      active: active ?? this.active,
    );
  }
}
