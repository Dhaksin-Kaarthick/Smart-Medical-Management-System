import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/medicine_repository.dart';
import '../../../../data/repositories/patient_repository.dart';
import '../../../common/section_header.dart';

/// Clinical Reports & Adherence Analytics view for caregivers with visual trend charts.
class CaregiverReportsView extends StatelessWidget {
  const CaregiverReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final medRepo = context.watch<MedicineRepository>();
    final patientRepo = context.watch<PatientRepository>();
    final adherence = medRepo.adherenceStats;
    final patients = patientRepo.patients;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adherence Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // OVERALL COMPLIANCE SCORE CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Clinical Adherence',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${adherence.overallPercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+2.4% this month',
                          style: AppTextStyles.badgeText.copyWith(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWhiteStat('This Week', '${adherence.weekPercentage}%'),
                    _buildWhiteStat('This Month', '${adherence.monthPercentage}%'),
                    _buildWhiteStat('Total Doses', '${adherence.totalScheduled}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // WEEKLY ADHERENCE TREND GRAPH
          SectionHeader(title: '7-Day Adherence Trend'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Compliance by Day',
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Target: 80%+',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusTaken, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Custom Clean Bar Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: adherence.weeklyTrend.map((data) {
                    final height = (data.rate / 100.0) * 100.0;
                    final barColor = data.rate >= 80
                        ? AppColors.statusTaken
                        : data.rate >= 60
                            ? AppColors.statusLate
                            : AppColors.statusMissed;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${data.rate.toInt()}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 22,
                          height: height.clamp(12.0, 100.0),
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.day,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // PATIENT ADHERENCE BREAKDOWN
          SectionHeader(title: 'Patient Compliance Rankings'),
          const SizedBox(height: 8),
          ...patients.map(
            (p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: AppTextStyles.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Risk: ${p.riskLevel}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: p.riskLevel.toUpperCase() == 'HIGH'
                                ? AppColors.statusMissed
                                : p.riskLevel.toUpperCase() == 'MEDIUM'
                                    ? AppColors.statusLate
                                    : AppColors.statusTaken,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${p.adherenceRate.toStringAsFixed(0)}%',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
