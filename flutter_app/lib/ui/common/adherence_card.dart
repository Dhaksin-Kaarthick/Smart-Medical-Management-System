import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Clean adherence summary card displaying percentage progress, taken vs scheduled metrics.
class AdherenceCard extends StatelessWidget {
  final double adherenceRate; // 0 - 100
  final int totalScheduled;
  final int totalTaken;
  final int totalMissed;
  final VoidCallback? onTap;

  const AdherenceCard({
    super.key,
    required this.adherenceRate,
    required this.totalScheduled,
    required this.totalTaken,
    this.totalMissed = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rate = adherenceRate.clamp(0.0, 100.0);
    final color = rate >= 80
        ? AppColors.statusTaken
        : rate >= 60
            ? AppColors.statusLate
            : AppColors.statusMissed;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Progress",
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${rate.toStringAsFixed(0)}% Adherence',
                        style: AppTextStyles.badgeText.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalScheduled > 0 ? (totalTaken / totalScheduled).clamp(0.0, 1.0) : 1.0,
                    backgroundColor: AppColors.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 14),
                // Stats Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      label: 'Scheduled',
                      value: '$totalScheduled doses',
                      color: AppColors.textSecondary,
                    ),
                    _buildStatItem(
                      label: 'Completed',
                      value: '$totalTaken doses',
                      color: AppColors.statusTaken,
                    ),
                    if (totalMissed > 0)
                      _buildStatItem(
                        label: 'Missed',
                        value: '$totalMissed doses',
                        color: AppColors.statusMissed,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
