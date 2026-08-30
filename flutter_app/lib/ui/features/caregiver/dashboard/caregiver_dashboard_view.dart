import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/patient_repository.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../common/patient_card.dart';
import '../../../common/alert_card.dart';
import '../../../common/section_header.dart';
import '../patient_details/patient_detail_view.dart';

/// Caregiver Home Dashboard providing high-level adherence metrics, patient risk flags, and real-time alerts.
class CaregiverDashboardView extends StatelessWidget {
  const CaregiverDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final patientRepo = context.watch<PatientRepository>();
    final notifRepo = context.watch<NotificationRepository>();

    final user = authRepo.currentUser;
    final patients = patientRepo.patients;
    final alerts = notifRepo.notifications;

    final highRiskCount = patients.where((p) => p.riskLevel.toUpperCase() == 'HIGH').length;
    final avgAdherence = patients.isNotEmpty
        ? patients.map((p) => p.adherenceRate).reduce((a, b) => a + b) / patients.length
        : 100.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormatter.getGreeting()}, ${user?.name ?? "Caregiver"}',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Clinical Monitoring Overview',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // METRIC CARDS ROW
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Patients',
                  value: '${patients.length}',
                  icon: Icons.people_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: 'Adherence',
                  value: '${avgAdherence.toStringAsFixed(0)}%',
                  icon: Icons.insights_rounded,
                  color: AppColors.statusTaken,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Missed Doses',
                  value: '2',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.statusLate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: 'High-Risk',
                  value: '$highRiskCount',
                  icon: Icons.priority_high_rounded,
                  color: AppColors.statusMissed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // PATIENTS SECTION
          SectionHeader(
            title: 'Monitored Patients',
            actionLabel: 'View All (${patients.length})',
            onAction: () {},
          ),
          const SizedBox(height: 8),
          ...patients.map(
            (patient) => PatientCard(
              patient: patient,
              onTap: () {
                patientRepo.selectPatient(patient.patientId);
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => PatientDetailView(patient: patient),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // RECENT ALERTS SECTION
          SectionHeader(
            title: 'Recent Alerts',
            actionLabel: 'Mark all read',
            onAction: () => notifRepo.markAllAsRead(),
          ),
          const SizedBox(height: 8),
          ...alerts.take(3).map(
                (alert) => AlertCard(
                  notification: alert,
                  onMarkRead: () => notifRepo.markAsRead(alert.notificationId),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.highlightNumber.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
