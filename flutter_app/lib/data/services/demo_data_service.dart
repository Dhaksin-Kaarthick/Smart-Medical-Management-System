import '../models/user_model.dart';
import '../models/patient_model.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../models/device_model.dart';
import '../models/ai_prediction_model.dart';
import '../models/notification_model.dart';
import '../models/adherence_stats_model.dart';

/// Preconfigured realistic demo data for portfolio, offline testing, and live presentations.
class DemoDataService {
  DemoDataService._();

  // Demo Users
  static final UserModel demoPatientUser = UserModel(
    userId: 'usr_patient_001',
    name: 'Arun Kumar',
    email: 'arun.kumar@example.com',
    phone: '+91 98765 43210',
    role: 'patient',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    dateOfBirth: DateTime(1956, 5, 14),
  );

  static final UserModel demoCaregiverUser = UserModel(
    userId: 'usr_caregiver_001',
    name: 'Dr. Priya Sharma',
    email: 'priya.caregiver@example.com',
    phone: '+91 98765 12345',
    role: 'caregiver',
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
  );

  // Demo Patients
  static final PatientModel demoPatient = PatientModel(
    patientId: 'pat_001',
    userId: 'usr_patient_001',
    caregiverId: 'usr_caregiver_001',
    deviceId: 'esp32_001',
    name: 'Arun Kumar',
    age: 68,
    bloodGroup: 'B+',
    emergencyContact: '+91 98765 12345 (Dr. Priya)',
    adherenceRate: 92.5,
    riskLevel: 'LOW',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  );

  static final List<PatientModel> demoCaregiverPatients = [
    demoPatient,
    PatientModel(
      patientId: 'pat_002',
      userId: 'usr_patient_002',
      caregiverId: 'usr_caregiver_001',
      deviceId: 'esp32_002',
      name: 'Lakshmi Devi',
      age: 72,
      bloodGroup: 'O+',
      emergencyContact: '+91 98765 22334',
      adherenceRate: 64.0,
      riskLevel: 'HIGH',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    PatientModel(
      patientId: 'pat_003',
      userId: 'usr_patient_003',
      caregiverId: 'usr_caregiver_001',
      deviceId: 'esp32_003',
      name: 'Rajesh Patel',
      age: 61,
      bloodGroup: 'A+',
      emergencyContact: '+91 98765 99887',
      adherenceRate: 85.0,
      riskLevel: 'MEDIUM',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  // Demo Medicines
  static final List<MedicineModel> demoMedicines = [
    MedicineModel(
      medicineId: 'med_001',
      patientId: 'pat_001',
      name: 'Paracetamol',
      dosage: '500 mg',
      frequency: 'Twice daily',
      scheduledTimes: ['09:00 AM', '08:00 PM'],
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      instructions: 'Take after food with warm water',
      active: true,
    ),
    MedicineModel(
      medicineId: 'med_002',
      patientId: 'pat_001',
      name: 'Vitamin D3',
      dosage: '1000 IU',
      frequency: 'Once daily',
      scheduledTimes: ['01:00 PM'],
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      instructions: 'Take with lunch',
      active: true,
    ),
    MedicineModel(
      medicineId: 'med_003',
      patientId: 'pat_001',
      name: 'Amlodipine',
      dosage: '5 mg',
      frequency: 'Once daily',
      scheduledTimes: ['08:00 PM'],
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      instructions: 'Blood pressure medication. Do not skip.',
      active: true,
    ),
  ];

  // Demo Today's Logs
  static List<MedicineLogModel> getTodayLogs() {
    final now = DateTime.now();
    return [
      MedicineLogModel(
        logId: 'log_today_01',
        patientId: 'pat_001',
        medicineId: 'med_001',
        medicineName: 'Paracetamol',
        dosage: '500 mg',
        scheduledTime: DateTime(now.year, now.month, now.day, 9, 0),
        takenTime: DateTime(now.year, now.month, now.day, 9, 3),
        status: 'taken',
        deviceId: 'ESP32_001',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      MedicineLogModel(
        logId: 'log_today_02',
        patientId: 'pat_001',
        medicineId: 'med_002',
        medicineName: 'Vitamin D3',
        dosage: '1000 IU',
        scheduledTime: DateTime(now.year, now.month, now.day, 13, 0),
        takenTime: null,
        status: 'upcoming',
        deviceId: 'ESP32_001',
        createdAt: now,
      ),
      MedicineLogModel(
        logId: 'log_today_03',
        patientId: 'pat_001',
        medicineId: 'med_003',
        medicineName: 'Amlodipine',
        dosage: '5 mg',
        scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
        takenTime: null,
        status: 'upcoming',
        deviceId: 'ESP32_001',
        createdAt: now,
      ),
    ];
  }

  // Demo History Logs
  static List<MedicineLogModel> getHistoryLogs() {
    final now = DateTime.now();
    final logs = <MedicineLogModel>[];

    // Today
    logs.addAll(getTodayLogs());

    // Yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    logs.add(MedicineLogModel(
      logId: 'log_yest_01',
      patientId: 'pat_001',
      medicineId: 'med_001',
      medicineName: 'Paracetamol',
      dosage: '500 mg',
      scheduledTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 0),
      takenTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 5),
      status: 'taken',
      deviceId: 'ESP32_001',
      createdAt: yesterday,
    ));
    logs.add(MedicineLogModel(
      logId: 'log_yest_02',
      patientId: 'pat_001',
      medicineId: 'med_002',
      medicineName: 'Vitamin D3',
      dosage: '1000 IU',
      scheduledTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 0),
      takenTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 40),
      status: 'late',
      deviceId: 'ESP32_001',
      createdAt: yesterday,
    ));
    logs.add(MedicineLogModel(
      logId: 'log_yest_03',
      patientId: 'pat_001',
      medicineId: 'med_003',
      medicineName: 'Amlodipine',
      dosage: '5 mg',
      scheduledTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 20, 0),
      takenTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 20, 10),
      status: 'taken',
      deviceId: 'ESP32_001',
      createdAt: yesterday,
    ));

    // 2 Days Ago (Missed dose example)
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    logs.add(MedicineLogModel(
      logId: 'log_2d_01',
      patientId: 'pat_001',
      medicineId: 'med_001',
      medicineName: 'Paracetamol',
      dosage: '500 mg',
      scheduledTime: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 9, 0),
      takenTime: null,
      status: 'missed',
      deviceId: 'ESP32_001',
      createdAt: twoDaysAgo,
    ));

    return logs;
  }

  // Demo IoT Device
  static final DeviceModel demoDevice = DeviceModel(
    deviceId: 'esp32_001',
    patientId: 'pat_001',
    deviceName: 'ESP32-Box-01',
    status: 'connected',
    lastSeen: DateTime.now().subtract(const Duration(seconds: 25)),
    firmwareVersion: 'v2.1.0-prod',
  );

  // Demo AI Prediction
  static final AiPredictionModel demoAiPrediction = AiPredictionModel(
    predictionId: 'pred_001',
    patientId: 'pat_001',
    riskLevel: 'LOW',
    riskScore: 0.12,
    confidence: 0.94,
    explanation: 'Medication adherence has remained stable at 92.5% over the past 14 days.',
    generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  // Demo Notifications
  static final List<NotificationModel> demoNotifications = [
    NotificationModel(
      notificationId: 'notif_001',
      userId: 'usr_patient_001',
      type: 'reminder',
      title: 'Upcoming Dose: Vitamin D3',
      message: 'Time for your 1:00 PM dose of Vitamin D3 (1000 IU). Take with lunch.',
      read: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      notificationId: 'notif_002',
      userId: 'usr_patient_001',
      type: 'device_reconnect',
      title: 'ESP32 Synchronized',
      message: 'Smart Medicine Dispenser connected successfully over Wi-Fi.',
      read: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      notificationId: 'notif_003',
      userId: 'usr_caregiver_001',
      title: 'Patient Missed Dose Alert',
      message: 'Lakshmi Devi missed her 2:00 PM blood pressure medication.',
      type: 'missed',
      read: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // Demo Adherence Stats
  static final AdherenceStatsModel demoAdherenceStats = AdherenceStatsModel(
    overallPercentage: 92.5,
    weekPercentage: 94.0,
    monthPercentage: 91.2,
    totalScheduled: 42,
    totalTaken: 38,
    totalMissed: 2,
    totalLate: 2,
    weeklyTrend: [
      DailyAdherenceData(day: 'Mon', rate: 100),
      DailyAdherenceData(day: 'Tue', rate: 100),
      DailyAdherenceData(day: 'Wed', rate: 66.6),
      DailyAdherenceData(day: 'Thu', rate: 100),
      DailyAdherenceData(day: 'Fri', rate: 100),
      DailyAdherenceData(day: 'Sat', rate: 100),
      DailyAdherenceData(day: 'Sun', rate: 90),
    ],
  );
}
