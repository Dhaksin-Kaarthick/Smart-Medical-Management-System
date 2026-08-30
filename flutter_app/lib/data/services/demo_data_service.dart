import '../models/user_model.dart';
import '../models/patient_model.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../models/device_model.dart';
import '../models/ai_prediction_model.dart';
import '../models/notification_model.dart';
import '../models/adherence_stats_model.dart';

/// Clean local baseline service with ZERO default tablets and patient-only configuration.
class DemoDataService {
  DemoDataService._();

  // Baseline Patient User
  static final UserModel demoPatientUser = UserModel(
    userId: 'usr_patient_001',
    name: 'Patient User',
    email: 'patient@example.com',
    phone: '+91 98765 43210',
    role: 'patient',
    createdAt: DateTime.now(),
    dateOfBirth: DateTime(1990, 1, 1),
  );

  // Baseline Patient Record
  static final PatientModel demoPatient = PatientModel(
    patientId: 'pat_001',
    userId: 'usr_patient_001',
    deviceId: 'esp32_001',
    name: 'Patient User',
    age: 34,
    bloodGroup: 'O+',
    emergencyContact: '+91 98765 43210',
    adherenceRate: 100.0,
    riskLevel: 'LOW',
    createdAt: DateTime.now(),
  );

  // ZERO DEFAULT TABLETS / MEDICINES
  static final List<MedicineModel> demoMedicines = [];

  // ZERO DEFAULT LOGS
  static List<MedicineLogModel> getTodayLogs() => [];

  // ZERO DEFAULT HISTORY
  static List<MedicineLogModel> getHistoryLogs() => [];

  // Default Paired IoT Device
  static final DeviceModel demoDevice = DeviceModel(
    deviceId: 'esp32_001',
    patientId: 'pat_001',
    deviceName: 'ESP32 Smart Dispenser',
    status: 'connected',
    lastSeen: DateTime.now(),
    firmwareVersion: 'v2.1.0-local',
  );

  // Baseline AI Prediction
  static final AiPredictionModel demoAiPrediction = AiPredictionModel(
    predictionId: 'pred_001',
    patientId: 'pat_001',
    riskLevel: 'LOW',
    riskScore: 0.05,
    confidence: 0.95,
    explanation: 'No missed doses recorded. Adherence is optimal.',
    generatedAt: DateTime.now(),
  );

  // Baseline Notifications
  static final List<NotificationModel> demoNotifications = [];

  // Baseline Adherence Stats
  static final AdherenceStatsModel demoAdherenceStats = AdherenceStatsModel.empty();
}
