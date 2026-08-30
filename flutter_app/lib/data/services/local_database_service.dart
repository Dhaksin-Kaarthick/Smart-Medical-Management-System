import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../models/notification_model.dart';
import '../models/device_model.dart';

/// Robust local database service using SharedPreferences and JSON persistence.
/// All user records, prescriptions, dose logs, and device states are stored locally on device.
class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();

  static const String _keyUsers = 'local_db_users';
  static const String _keyActiveUser = 'local_db_active_user';
  static const String _keyMedicinesPrefix = 'local_db_medicines_';
  static const String _keyLogsPrefix = 'local_db_logs_';
  static const String _keyNotificationsPrefix = 'local_db_notifications_';
  static const String _keyDevicePrefix = 'local_db_device_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==========================================
  // AUTHENTICATION & USER MANAGEMENT
  // ==========================================

  /// Check if user exists in local database
  Future<bool> userExists(String email) async {
    final prefs = await _getPrefs();
    final usersRaw = prefs.getString(_keyUsers);
    if (usersRaw == null || usersRaw.isEmpty) return false;
    try {
      final Map<String, dynamic> usersMap = jsonDecode(usersRaw) as Map<String, dynamic>;
      return usersMap.containsKey(email.trim().toLowerCase());
    } catch (_) {
      return false;
    }
  }

  /// Register a new patient account in local database
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    DateTime? dateOfBirth,
  }) async {
    final prefs = await _getPrefs();
    final normalizedEmail = email.trim().toLowerCase();

    Map<String, dynamic> usersMap = {};
    final usersRaw = prefs.getString(_keyUsers);
    if (usersRaw != null && usersRaw.isNotEmpty) {
      try {
        usersMap = Map<String, dynamic>.from(jsonDecode(usersRaw) as Map);
      } catch (_) {}
    }

    if (usersMap.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists.');
    }

    final userId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      userId: userId,
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      role: 'patient',
      createdAt: DateTime.now(),
      dateOfBirth: dateOfBirth,
    );

    usersMap[normalizedEmail] = {
      'user': user.toMap(),
      'password': password,
    };

    await prefs.setString(_keyUsers, jsonEncode(usersMap));
    await saveActiveUser(user);

    // Initialize clean, empty medicine and log stores for the new patient (NO default tablets)
    await saveMedicines(userId, []);
    await saveLogs(userId, []);

    return user;
  }

  /// Authenticate patient user locally
  Future<UserModel?> authenticateUser(String email, String password) async {
    final prefs = await _getPrefs();
    final normalizedEmail = email.trim().toLowerCase();
    final usersRaw = prefs.getString(_keyUsers);

    if (usersRaw == null || usersRaw.isEmpty) return null;

    try {
      final Map<String, dynamic> usersMap = Map<String, dynamic>.from(jsonDecode(usersRaw) as Map);
      if (!usersMap.containsKey(normalizedEmail)) return null;

      final userData = usersMap[normalizedEmail] as Map<String, dynamic>;
      final savedPassword = userData['password'] as String?;

      if (savedPassword != password) {
        throw Exception('Incorrect password.');
      }

      final userMap = Map<String, dynamic>.from(userData['user'] as Map);
      final user = UserModel.fromMap(userMap);
      await saveActiveUser(user);
      return user;
    } catch (e) {
      if (e.toString().contains('Incorrect password')) rethrow;
      debugPrint('[LocalDB] Auth error: $e');
      return null;
    }
  }

  /// Get currently signed in user
  Future<UserModel?> getActiveUser() async {
    final prefs = await _getPrefs();
    final activeUserRaw = prefs.getString(_keyActiveUser);
    if (activeUserRaw == null || activeUserRaw.isEmpty) return null;

    try {
      final userMap = Map<String, dynamic>.from(jsonDecode(activeUserRaw) as Map);
      return UserModel.fromMap(userMap);
    } catch (_) {
      return null;
    }
  }

  /// Save current active user session
  Future<void> saveActiveUser(UserModel user) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyActiveUser, jsonEncode(user.toMap()));
  }

  /// Sign out / clear active user session
  Future<void> clearActiveUser() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyActiveUser);
  }

  /// Reset password locally
  Future<bool> resetPassword(String email) async {
    final prefs = await _getPrefs();
    final normalizedEmail = email.trim().toLowerCase();
    final usersRaw = prefs.getString(_keyUsers);
    if (usersRaw == null) return false;

    try {
      final Map<String, dynamic> usersMap = Map<String, dynamic>.from(jsonDecode(usersRaw) as Map);
      return usersMap.containsKey(normalizedEmail);
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // MEDICINES MANAGEMENT (0 DEFAULT TABLETS)
  // ==========================================

  /// Get medicines for a patient (defaults to empty list if none added)
  Future<List<MedicineModel>> getMedicines(String userId) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('$_keyMedicinesPrefix$userId');
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => MedicineModel.fromMap(Map<String, dynamic>.from(item as Map))).toList();
    } catch (e) {
      debugPrint('[LocalDB] Error reading medicines: $e');
      return [];
    }
  }

  /// Save medicines list for patient
  Future<void> saveMedicines(String userId, List<MedicineModel> medicines) async {
    final prefs = await _getPrefs();
    final jsonList = medicines.map((m) => m.toMap()).toList();
    await prefs.setString('$_keyMedicinesPrefix$userId', jsonEncode(jsonList));
  }

  /// Add medicine for patient
  Future<void> addMedicine(String userId, MedicineModel medicine) async {
    final meds = await getMedicines(userId);
    meds.add(medicine);
    await saveMedicines(userId, meds);
  }

  /// Update existing medicine
  Future<void> updateMedicine(String userId, MedicineModel medicine) async {
    final meds = await getMedicines(userId);
    final index = meds.indexWhere((m) => m.medicineId == medicine.medicineId);
    if (index != -1) {
      meds[index] = medicine;
      await saveMedicines(userId, meds);
    }
  }

  /// Delete medicine for patient
  Future<void> deleteMedicine(String userId, String medicineId) async {
    final meds = await getMedicines(userId);
    meds.removeWhere((m) => m.medicineId == medicineId);
    await saveMedicines(userId, meds);

    // Also remove associated upcoming logs
    final logs = await getLogs(userId);
    logs.removeWhere((l) => l.medicineId == medicineId && l.isUpcoming);
    await saveLogs(userId, logs);
  }

  // ==========================================
  // MEDICINE LOGS & DOSE TRACKING
  // ==========================================

  /// Get dose logs for patient (defaults to empty list if none generated)
  Future<List<MedicineLogModel>> getLogs(String userId) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('$_keyLogsPrefix$userId');
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => MedicineLogModel.fromMap(Map<String, dynamic>.from(item as Map))).toList();
    } catch (e) {
      debugPrint('[LocalDB] Error reading logs: $e');
      return [];
    }
  }

  /// Save logs list for patient
  Future<void> saveLogs(String userId, List<MedicineLogModel> logs) async {
    final prefs = await _getPrefs();
    final jsonList = logs.map((l) => l.toMap()).toList();
    await prefs.setString('$_keyLogsPrefix$userId', jsonEncode(jsonList));
  }

  /// Add single log
  Future<void> addLog(String userId, MedicineLogModel log) async {
    final logs = await getLogs(userId);
    logs.add(log);
    await saveLogs(userId, logs);
  }

  /// Update log status (e.g. mark as taken)
  Future<void> updateLogStatus(
    String userId,
    String logId,
    String status, [
    DateTime? takenTime,
  ]) async {
    final logs = await getLogs(userId);
    final index = logs.indexWhere((l) => l.logId == logId);
    if (index != -1) {
      logs[index] = logs[index].copyWith(
        status: status,
        takenTime: takenTime,
      );
      await saveLogs(userId, logs);
    }
  }

  // ==========================================
  // NOTIFICATIONS & ALERTS
  // ==========================================

  /// Get notifications for user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('$_keyNotificationsPrefix$userId');
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => NotificationModel.fromMap(Map<String, dynamic>.from(item as Map))).toList();
    } catch (e) {
      debugPrint('[LocalDB] Error reading notifications: $e');
      return [];
    }
  }

  /// Save notifications
  Future<void> saveNotifications(String userId, List<NotificationModel> notifications) async {
    final prefs = await _getPrefs();
    final jsonList = notifications.map((n) => n.toMap()).toList();
    await prefs.setString('$_keyNotificationsPrefix$userId', jsonEncode(jsonList));
  }

  /// Add notification
  Future<void> addNotification(String userId, NotificationModel notif) async {
    final list = await getNotifications(userId);
    list.insert(0, notif);
    await saveNotifications(userId, list);
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String userId, String notifId) async {
    final list = await getNotifications(userId);
    final index = list.indexWhere((n) => n.notificationId == notifId);
    if (index != -1) {
      list[index] = list[index].copyWith(read: true);
      await saveNotifications(userId, list);
    }
  }

  /// Mark all notifications read
  Future<void> markAllNotificationsRead(String userId) async {
    final list = await getNotifications(userId);
    final updated = list.map((n) => n.copyWith(read: true)).toList();
    await saveNotifications(userId, updated);
  }

  // ==========================================
  // DEVICE SETTINGS
  // ==========================================

  /// Get device for patient
  Future<DeviceModel> getDevice(String userId) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('$_keyDevicePrefix$userId');
    if (raw != null && raw.isNotEmpty) {
      try {
        return DeviceModel.fromMap(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      } catch (_) {}
    }

    return DeviceModel(
      deviceId: 'esp32_001',
      patientId: userId,
      deviceName: 'ESP32 Smart Dispenser',
      status: 'connected',
      lastSeen: DateTime.now(),
      firmwareVersion: 'v2.1.0-local',
    );
  }

  /// Save device state
  Future<void> saveDevice(String userId, DeviceModel device) async {
    final prefs = await _getPrefs();
    await prefs.setString('$_keyDevicePrefix$userId', jsonEncode(device.toMap()));
  }
}
