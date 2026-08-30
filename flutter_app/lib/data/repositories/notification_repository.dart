import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/local_database_service.dart';

/// Repository managing system notifications, alerts, and read states using local database storage.
class NotificationRepository extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;

  List<NotificationModel> _notifications = [];
  String? _currentUserId;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  NotificationRepository() {
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    final activeUser = await _localDb.getActiveUser();
    if (activeUser != null) {
      await loadForUser(activeUser.userId);
    }
  }

  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    _notifications = await _localDb.getNotifications(userId);
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      if (_currentUserId != null) {
        await _localDb.markNotificationRead(_currentUserId!, notificationId);
      }
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    if (_currentUserId != null) {
      await _localDb.markAllNotificationsRead(_currentUserId!);
    }
    notifyListeners();
  }

  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    if (_currentUserId != null) {
      await _localDb.addNotification(_currentUserId!, notification);
    }
    notifyListeners();
  }
}
