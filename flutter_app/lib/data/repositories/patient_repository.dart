import 'package:flutter/foundation.dart';
import '../models/patient_model.dart';
import '../services/demo_data_service.dart';

/// Repository managing patient list, patient details, and caregiver assignments.
class PatientRepository extends ChangeNotifier {
  List<PatientModel> _patients = [];
  PatientModel? _selectedPatient;
  bool _isLoading = false;

  List<PatientModel> get patients => _patients;
  PatientModel? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;

  PatientRepository() {
    _patients = List.from(DemoDataService.demoCaregiverPatients);
    _selectedPatient = _patients.isNotEmpty ? _patients.first : null;
  }

  void selectPatient(String patientId) {
    final match = _patients.firstWhere(
      (p) => p.patientId == patientId,
      orElse: () => _patients.first,
    );
    _selectedPatient = match;
    notifyListeners();
  }

  Future<void> addPatient(PatientModel newPatient) async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));
    _patients.add(newPatient);
    _isLoading = false;
    notifyListeners();
  }
}
