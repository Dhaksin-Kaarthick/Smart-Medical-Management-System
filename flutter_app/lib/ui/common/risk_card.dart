import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/ai_prediction_model.dart';

/// Reusable AI Adherence Risk Card communicating risk level, confidence, and medical disclaimer.
class RiskCard extends StatelessWidget {
  final AiPredictionModel prediction;
  final VoidCallback? onRefresh;

  const RiskCard({
    super.key,
    required this.prediction,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Color riskColor;
    Color riskBgColor;
    IconData riskIcon;

    if (prediction.isLowRisk) {
      riskColor = AppColors.riskLow;
      riskBgColor = AppColors.riskLowBg;
      riskIcon = Icons.shield_outlined;
    } else if (prediction.isMediumRisk) {
      riskColor = AppColors.riskMedium;
      riskBgColor = AppColors.riskMediumBg;
      riskIcon = Icons.info_outline_rounded;
    } else {
      riskColor = AppColors.riskHigh;
      riskBgColor = AppColors.riskHighBg;
      riskIcon = Icons.warning_amber_rounded;
    }

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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with AI Tag and Risk Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Adherence Analysis',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: riskColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(riskIcon, size: 14, color: riskColor),
                      const SizedBox(width: 4),
                      Text(
                        '${prediction.riskLevel} RISK',
                        style: AppTextStyles.badgeText.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Explanation
            Text(
              prediction.explanation,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            // Metrics row
            Row(
              children: [
                Text(
                  'Confidence: ${(prediction.confidence * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Score: ${(prediction.riskScore * 100).toStringAsFixed(0)}/100',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Disclaimer
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppConstants.aiDisclaimer,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
