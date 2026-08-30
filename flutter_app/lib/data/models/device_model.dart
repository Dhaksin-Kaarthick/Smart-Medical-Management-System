import '../../core/constants/app_constants.dart';

/// IoT Device entity representing ESP32 hardware pairing, heartbeat, and status.
class DeviceModel {
  final String deviceId;
  final String patientId;
  final String deviceName;
  final String status; // 'connected' or 'offline'
  final DateTime lastSeen;
  final String firmwareVersion;

  const DeviceModel({
    required this.deviceId,
    required this.patientId,
    required this.deviceName,
    required this.status,
    required this.lastSeen,
    this.firmwareVersion = 'v1.0.0',
  });

  /// Evaluates real-time connection using heartbeat timestamp threshold.
  bool get isConnected {
    if (status.toLowerCase() != 'connected') return false;
    final diff = DateTime.now().difference(lastSeen);
    return diff.inMinutes < AppConstants.deviceOfflineThresholdMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'patientId': patientId,
      'deviceName': deviceName,
      'status': status,
      'lastSeen': lastSeen.toIso8601String(),
      'firmwareVersion': firmwareVersion,
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return DeviceModel(
      deviceId: documentId ?? map['deviceId'] as String? ?? 'ESP32_DEV',
      patientId: map['patientId'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? 'Smart Med Dispenser',
      status: map['status'] as String? ?? 'offline',
      lastSeen: map['lastSeen'] != null
          ? DateTime.tryParse(map['lastSeen'].toString()) ?? DateTime.now()
          : DateTime.now(),
      firmwareVersion: map['firmwareVersion'] as String? ?? 'v1.0.0',
    );
  }

  DeviceModel copyWith({
    String? deviceId,
    String? patientId,
    String? deviceName,
    String? status,
    DateTime? lastSeen,
    String? firmwareVersion,
  }) {
    return DeviceModel(
      deviceId: deviceId ?? this.deviceId,
      patientId: patientId ?? this.patientId,
      deviceName: deviceName ?? this.deviceName,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }
}
