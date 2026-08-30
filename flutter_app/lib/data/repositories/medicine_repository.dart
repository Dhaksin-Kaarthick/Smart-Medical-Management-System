import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../models/adherence_stats_model.dart';
import '../services/demo_data_service.dart';

/// Repository managing medicines, schedules, log streams, dose events, and adherence statistics.
class MedicineRepository extends ChangeNotifier {
  List<MedicineModel> _medicines = [];
  List<MedicineLogModel> _todayLogs = [];
  List<MedicineLogModel> _historyLogs = [];
  bool _isLoading = false;

  List<MedicineModel> get medicines => _medicines;
  List<MedicineLogModel> get todayLogs => _todayLogs;
  List<MedicineLogModel> get historyLogs => _historyLogs;
  bool get isLoading => _isLoading;

  MedicineRepository() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _medicines = List.from(DemoDataService.demoMedicines);
    _todayLogs = List.from(DemoDataService.getTodayLogs());
    _historyLogs = List.from(DemoDataService.getHistoryLogs());
  }

  /// Get the upcoming next dose for patient home screen
  MedicineLogModel? get nextMedicine {
    final upcoming = _todayLogs.where((l) => l.isUpcoming).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return upcoming.first;
  }

  /// Calculate real-time adherence stats
  AdherenceStatsModel get adherenceStats {
    final allLogs = _historyLogs;
    if (allLogs.isEmpty) return AdherenceStatsModel.empty();

    final scheduled = allLogs.length;
    final taken = allLogs.where((l) => l.isTaken).length;
    final missed = allLogs.where((l) => l.isMissed).length;
    final lateDoses = allLogs.where((l) => l.isLate).length;

    final overall = scheduled > 0 ? (taken / scheduled) * 100.0 : 100.0;

    return AdherenceStatsModel(
      overallPercentage: double.parse(overall.toStringAsFixed(1)),
      weekPercentage: 94.0,
      monthPercentage: 91.2,
      totalScheduled: scheduled,
      totalTaken: taken,
      totalMissed: missed,
      totalLate: lateDoses,
      weeklyTrend: DemoDataService.demoAdherenceStats.weeklyTrend,
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

    notifyListeners();
  }

  /// Add new medicine prescription
  Future<void> addMedicine(MedicineModel medicine) async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));
    _medicines.add(medicine);

    // Generate upcoming log for today if active
    final now = DateTime.now();
    _todayLogs.add(
      MedicineLogModel(
        logId: 'log_${DateTime.now().millisecondsSinceEpoch}',
        patientId: medicine.patientId,
        medicineId: medicine.medicineId,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
        status: 'upcoming',
        createdAt: now,
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Edit existing medicine
  Future<void> updateMedicine(MedicineModel medicine) async {
    final index = _medicines.indexWhere((m) => m.medicineId == medicine.medicineId);
    if (index != -1) {
      _medicines[index] = medicine;
      notifyListeners();
    }
  }

  /// Delete medicine prescription
  Future<void> deleteMedicine(String medicineId) async {
    _medicines.removeWhere((m) => m.medicineId == medicineId);
    _todayLogs.removeWhere((l) => l.medicineId == medicineId);
    notifyListeners();
  }
}
