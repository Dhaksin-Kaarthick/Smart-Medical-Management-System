/// Notification entity representing alerts, reminders, and offline warnings.
class NotificationModel {
  final String notificationId;
  final String userId;
  final String type; // 'reminder', 'missed', 'late', 'risk_alert', 'device_offline', 'device_reconnect'
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.read = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return NotificationModel(
      notificationId: documentId ?? map['notificationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? 'reminder',
      title: map['title'] as String? ?? 'Notification',
      message: map['message'] as String? ?? '',
      read: map['read'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? type,
    String? title,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
