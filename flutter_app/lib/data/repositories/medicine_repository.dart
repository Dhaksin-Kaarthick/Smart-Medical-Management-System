import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../models/adherence_stats_model.dart';
import '../services/local_database_service.dart';

/// Repository managing medicines, schedules, log streams, dose events, and adherence statistics
/// using purely local persistent database storage (0 default tablets).
class MedicineRepository extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;

  List<MedicineModel> _medicines = [];
  List<MedicineLogModel> _todayLogs = [];
  List<MedicineLogModel> _historyLogs = [];
  String? _currentPatientId;
  bool _isLoading = false;

  List<MedicineModel> get medicines => _medicines;
  List<MedicineLogModel> get todayLogs => _todayLogs;
  List<MedicineLogModel> get historyLogs => _historyLogs;
  bool get isLoading => _isLoading;

  MedicineRepository() {
    _initLocalData();
  }

  Future<void> _initLocalData() async {
    final activeUser = await _localDb.getActiveUser();
    if (activeUser != null) {
      await loadForPatient(activeUser.userId);
    }
  }

  /// Load medicines and dose logs for a specific patient from local database
  Future<void> loadForPatient(String patientId) async {
    _currentPatientId = patientId;
    _isLoading = true;
    notifyListeners();

    try {
      _medicines = await _localDb.getMedicines(patientId);
      final allLogs = await _localDb.getLogs(patientId);

      final now = DateTime.now();
      _todayLogs = allLogs.where((l) {
        return l.scheduledTime.year == now.year &&
            l.scheduledTime.month == now.month &&
            l.scheduledTime.day == now.day;
      }).toList();

      _historyLogs = allLogs;
    } catch (e) {
      debugPrint('[MedicineRepo] Error loading patient data: $e');
      _medicines = [];
      _todayLogs = [];
      _historyLogs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get the upcoming next dose for patient home screen
  MedicineLogModel? get nextMedicine {
    final upcoming = _todayLogs.where((l) => l.isUpcoming).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return upcoming.first;
  }

  /// Calculate real-time adherence stats from user's actual dose logs
  AdherenceStatsModel get adherenceStats {
    final allLogs = _historyLogs;
    if (allLogs.isEmpty) {
      return AdherenceStatsModel.empty();
    }

    final scheduled = allLogs.length;
    final taken = allLogs.where((l) => l.isTaken).length;
    final missed = allLogs.where((l) => l.isMissed).length;
    final lateDoses = allLogs.where((l) => l.isLate).length;

    final overall = scheduled > 0 ? (taken / scheduled) * 100.0 : 100.0;

    return AdherenceStatsModel(
      overallPercentage: double.parse(overall.toStringAsFixed(1)),
      weekPercentage: double.parse(overall.toStringAsFixed(1)),
      monthPercentage: double.parse(overall.toStringAsFixed(1)),
      totalScheduled: scheduled,
      totalTaken: taken,
      totalMissed: missed,
      totalLate: lateDoses,
      weeklyTrend: [
        DailyAdherenceData(day: 'Mon', rate: overall),
        DailyAdherenceData(day: 'Tue', rate: overall),
        DailyAdherenceData(day: 'Wed', rate: overall),
        DailyAdherenceData(day: 'Thu', rate: overall),
        DailyAdherenceData(day: 'Fri', rate: overall),
        DailyAdherenceData(day: 'Sat', rate: overall),
        DailyAdherenceData(day: 'Sun', rate: overall),
      ],
    );
  }

  /// Mark a dose as taken (called manually or via ESP32 IR detection event)
  Future<void> markAsTaken(String logId, [DateTime? takenTime]) async {
    final now = takenTime ?? DateTime.now();

    // Update today's logs
    final index = _todayLogs.indexWhere((l) => l.logId == logId);
    if (index != -1) {
      _todayLogs[index] = _todayLogs[index].copyWith(
        status: 'taken',
        takenTime: now,
      );
    }

    // Update history
    final histIndex = _historyLogs.indexWhere((l) => l.logId == logId);
    if (histIndex != -1) {
      _historyLogs[histIndex] = _historyLogs[histIndex].copyWith(
        status: 'taken',
        takenTime: now,
      );
    }

    if (_currentPatientId != null) {
      await _localDb.updateLogStatus(_currentPatientId!, logId, 'taken', now);
    }

    notifyListeners();
  }

  /// Add new medicine prescription and generate scheduled dose logs for today
  Future<void> addMedicine(MedicineModel medicine) async {
    _isLoading = true;
    notifyListeners();

    _medicines.add(medicine);

    final now = DateTime.now();
    final newLogs = <MedicineLogModel>[];

    // Generate dose logs for each scheduled time string (e.g. "09:00 AM", "08:00 PM")
    for (int i = 0; i < medicine.scheduledTimes.length; i++) {
      final timeStr = medicine.scheduledTimes[i];
      final parsedTime = _parseTimeString(timeStr, now);

      final log = MedicineLogModel(
        logId: 'log_${medicine.medicineId}_${now.millisecondsSinceEpoch}_$i',
        patientId: medicine.patientId,
        medicineId: medicine.medicineId,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        scheduledTime: parsedTime,
        status: 'upcoming',
        deviceId: 'ESP32_001',
        createdAt: now,
      );

      newLogs.add(log);
      _todayLogs.add(log);
      _historyLogs.add(log);
    }

    if (_currentPatientId != null || medicine.patientId.isNotEmpty) {
      final targetId = _currentPatientId ?? medicine.patientId;
      await _localDb.addMedicine(targetId, medicine);
      for (final log in newLogs) {
        await _localDb.addLog(targetId, log);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Edit existing medicine
  Future<void> updateMedicine(MedicineModel medicine) async {
    final index = _medicines.indexWhere((m) => m.medicineId == medicine.medicineId);
    if (index != -1) {
      _medicines[index] = medicine;
      if (_currentPatientId != null) {
        await _localDb.updateMedicine(_currentPatientId!, medicine);
      }
      notifyListeners();
    }
  }

  /// Delete medicine prescription
  Future<void> deleteMedicine(String medicineId) async {
    _medicines.removeWhere((m) => m.medicineId == medicineId);
    _todayLogs.removeWhere((l) => l.medicineId == medicineId);
    _historyLogs.removeWhere((l) => l.medicineId == medicineId && l.isUpcoming);

    if (_currentPatientId != null) {
      await _localDb.deleteMedicine(_currentPatientId!, medicineId);
    }

    notifyListeners();
  }

  DateTime _parseTimeString(String timeStr, DateTime referenceDate) {
    try {
      final cleaned = timeStr.trim().toUpperCase();
      final isPm = cleaned.contains('PM');
      final isAm = cleaned.contains('AM');
      final parts = cleaned.replaceAll(RegExp(r'[^\d:]'), '').split(':');

      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
        hour,
        minute,
      );
    } catch (_) {
      return DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
        9,
        0,
      );
    }
  }
}
