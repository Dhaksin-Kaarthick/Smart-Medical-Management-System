import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/demo_data_service.dart';

/// Repository managing system notifications, alerts, and read states.
class NotificationRepository extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  NotificationRepository() {
    _notifications = List.from(DemoDataService.demoNotifications);
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
