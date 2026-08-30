import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/notification_model.dart';

/// Reusable alert card with severity icons, timestamps, and read/unread status.
class AlertCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;

  const AlertCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    switch (notification.type.toLowerCase()) {
      case 'missed':
      case 'risk_alert':
        iconBgColor = AppColors.statusMissedBg;
        iconColor = AppColors.statusMissed;
        icon = Icons.warning_rounded;
        break;
      case 'late':
      case 'device_offline':
        iconBgColor = AppColors.statusLateBg;
        iconColor = AppColors.statusLate;
        icon = Icons.cloud_off_rounded;
        break;
      case 'device_reconnect':
        iconBgColor = AppColors.statusTakenBg;
        iconColor = AppColors.statusTaken;
        icon = Icons.cloud_done_rounded;
        break;
      case 'reminder':
      default:
        iconBgColor = AppColors.statusUpcomingBg;
        iconColor = AppColors.statusUpcoming;
        icon = Icons.notifications_active_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notification.read ? AppColors.surface : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notification.read ? AppColors.cardBorder : AppColors.primaryLight.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap ?? onMarkRead,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 14,
                                fontWeight: notification.read ? FontWeight.w600 : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormatter.formatDateTime(notification.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
