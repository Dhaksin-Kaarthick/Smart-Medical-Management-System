import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../common/alert_card.dart';
import '../../../common/empty_state.dart';

/// Patient Notifications & Alerts screen with unread filters and mark all as read.
class PatientAlertsView extends StatelessWidget {
  const PatientAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifRepo = context.watch<NotificationRepository>();
    final notifications = notifRepo.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notifRepo.markAllAsRead(),
              child: Text(
                'Mark all read',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: "You're all caught up",
              description: 'No new medicine alerts or device notifications.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return AlertCard(
                  notification: notif,
                  onMarkRead: () => notifRepo.markAsRead(notif.notificationId),
                );
              },
            ),
    );
  }
}
