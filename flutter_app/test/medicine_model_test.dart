import 'package:flutter_test/flutter_test.dart';
import 'package:smart_medical_management/data/models/medicine_model.dart';
import 'package:smart_medical_management/data/models/medicine_log_model.dart';

void main() {
  group('Medicine Model Tests', () {
    test('MedicineModel serialization & deserialization', () {
      final now = DateTime.now();
      final med = MedicineModel(
        medicineId: 'med_101',
        patientId: 'pat_01',
        name: 'Paracetamol',
        dosage: '500 mg',
        frequency: 'Twice daily',
        scheduledTimes: ['09:00 AM', '08:00 PM'],
        startDate: now,
        instructions: 'Take after meals',
        active: true,
      );

      final map = med.toMap();
      expect(map['medicineId'], 'med_101');
      expect(map['name'], 'Paracetamol');

      final fromMap = MedicineModel.fromMap(map);
      expect(fromMap.medicineId, 'med_101');
      expect(fromMap.dosage, '500 mg');
      expect(fromMap.scheduledTimes.length, 2);
    });

    test('MedicineLogModel status helpers', () {
      final logTaken = MedicineLogModel(
        logId: 'log_01',
        patientId: 'pat_01',
        medicineId: 'med_01',
        medicineName: 'Amlodipine',
        dosage: '5 mg',
        scheduledTime: DateTime.now(),
        takenTime: DateTime.now(),
        status: 'taken',
        createdAt: DateTime.now(),
      );

      expect(logTaken.isTaken, isTrue);
      expect(logTaken.isMissed, isFalse);

      final logMissed = logTaken.copyWith(status: 'missed', takenTime: null);
      expect(logMissed.isMissed, isTrue);
      expect(logMissed.isTaken, isFalse);
    });
  });
}
