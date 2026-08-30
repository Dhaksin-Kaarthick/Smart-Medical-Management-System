import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../models/device_model.dart';
import '../models/ai_prediction_model.dart';
import '../models/notification_model.dart';

/// Service managing real-time Firestore streams and CRUD operations.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCol => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _patientsCol => _firestore.collection('patients');
  CollectionReference<Map<String, dynamic>> get _medicinesCol => _firestore.collection('medicines');
  CollectionReference<Map<String, dynamic>> get _logsCol => _firestore.collection('medicine_logs');
  CollectionReference<Map<String, dynamic>> get _devicesCol => _firestore.collection('devices');
  CollectionReference<Map<String, dynamic>> get _predictionsCol => _firestore.collection('ai_predictions');
  CollectionReference<Map<String, dynamic>> get _notificationsCol => _firestore.collection('notifications');

  // Stream patients managed by a caregiver
  Stream<List<UserModel>> streamCaregiverPatients(String caregiverId) {
    return _patientsCol
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Get user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, documentId: doc.id);
    }
    return null;
  }

  // Save or update user profile
  Future<void> saveUserProfile(UserModel user) async {
    await _usersCol.doc(user.userId).set(user.toMap(), SetOptions(merge: true));
  }

  // Stream today's logs for a patient
  Stream<List<MedicineLogModel>> streamPatientLogs(String patientId) {
    return _logsCol
        .where('patientId', isEqualTo: patientId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineLogModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Stream active medicines for a patient
  Stream<List<MedicineModel>> streamMedicines(String patientId) {
    return _medicinesCol
        .where('patientId', isEqualTo: patientId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Stream device status for real-time ESP32 connectivity
  Stream<DeviceModel?> streamDeviceStatus(String deviceId) {
    return _devicesCol.doc(deviceId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return DeviceModel.fromMap(doc.data()!, documentId: doc.id);
    });
  }

  // Stream notifications
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _notificationsCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Update dose event when taken
  Future<void> updateLogStatus(String logId, String status, [DateTime? takenTime]) async {
    await _logsCol.doc(logId).update({
      'status': status,
      'takenTime': takenTime?.toIso8601String(),
    });
  }

  // Save new medicine prescription
  Future<void> saveMedicine(MedicineModel medicine) async {
    await _medicinesCol.doc(medicine.medicineId).set(medicine.toMap());
  }

  // Save AI prediction
  Future<void> savePrediction(AiPredictionModel prediction) async {
    await _predictionsCol.doc(prediction.predictionId).set(prediction.toMap());
  }
}
