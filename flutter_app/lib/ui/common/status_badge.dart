import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Reusable status badge communicating state with both Icon and Text for accessibility.
class StatusBadge extends StatelessWidget {
  final String status; // 'upcoming', 'taken', 'missed', 'late'

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (normalized) {
      case 'taken':
        bgColor = AppColors.statusTakenBg;
        textColor = AppColors.statusTaken;
        icon = Icons.check_circle_rounded;
        label = 'TAKEN';
        break;
      case 'missed':
        bgColor = AppColors.statusMissedBg;
        textColor = AppColors.statusMissed;
        icon = Icons.error_rounded;
        label = 'MISSED';
        break;
      case 'late':
        bgColor = AppColors.statusLateBg;
        textColor = AppColors.statusLate;
        icon = Icons.warning_rounded;
        label = 'LATE';
        break;
      case 'upcoming':
      default:
        bgColor = AppColors.statusUpcomingBg;
        textColor = AppColors.statusUpcoming;
        icon = Icons.schedule_rounded;
        label = 'UPCOMING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.badgeText.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
