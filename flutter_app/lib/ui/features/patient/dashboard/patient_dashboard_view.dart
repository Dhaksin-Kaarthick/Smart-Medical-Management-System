import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/medicine_log_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/medicine_repository.dart';
import '../../../../data/repositories/device_repository.dart';
import '../../../common/medicine_card.dart';
import '../../../common/adherence_card.dart';
import '../../../common/device_status_indicator.dart';
import '../../../common/section_header.dart';
import '../../../common/empty_state.dart';

/// Patient Home Dashboard displaying next dose countdown, today's schedule, adherence progress, and ESP32 device status.
class PatientDashboardView extends StatelessWidget {
  const PatientDashboardView({super.key});

  void _showMedicineDetails(BuildContext context, MedicineLogModel log) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.medicineName,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          log.dosage,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildDetailRow('Scheduled Time', DateFormatter.formatTime(log.scheduledTime)),
              _buildDetailRow(
                'Status',
                log.status.toUpperCase(),
                color: log.isTaken
                    ? AppColors.statusTaken
                    : log.isMissed
                        ? AppColors.statusMissed
                        : AppColors.statusUpcoming,
              ),
              if (log.takenTime != null)
                _buildDetailRow('Taken At', DateFormatter.formatTime(log.takenTime!)),
              _buildDetailRow('Device Link', log.deviceId ?? 'ESP32 Smart Dispenser'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final medRepo = context.watch<MedicineRepository>();
    final deviceRepo = context.watch<DeviceRepository>();

    final user = authRepo.currentUser;
    final firstName = user?.name.split(' ').first ?? 'User';
    final nextDose = medRepo.nextMedicine;
    final todayLogs = medRepo.todayLogs;
    final adherence = medRepo.adherenceStats;

    final completedCount = todayLogs.where((l) => l.isTaken).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormatter.getGreeting()}, $firstName',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              DateFormatter.formatDate(DateTime.now()),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Simulate ESP32 Heartbeat',
            onPressed: () {
              deviceRepo.recordHeartbeat();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ESP32 Heartbeat synchronized.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          deviceRepo.recordHeartbeat();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Device Status Pill
            DeviceStatusIndicator(
              device: deviceRepo.device,
              onRefresh: () => deviceRepo.toggleConnectionState(),
            ),
            const SizedBox(height: 18),

            // NEXT MEDICINE HERO CARD
            if (nextDose != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NEXT DOSE',
                            style: AppTextStyles.badgeText.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Text(
                          DateFormatter.formatTime(nextDose.scheduledTime),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nextDose.medicineName,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextDose.dosage,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.formatCountdown(nextDose.scheduledTime),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(double.infinity, 44),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                            label: const Text('Mark Taken'),
                            onPressed: () {
                              medRepo.markAsTaken(nextDose.logId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${nextDose.medicineName} marked as taken!'),
                                  backgroundColor: AppColors.statusTaken,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54, width: 1.5),
                              minimumSize: const Size(double.infinity, 44),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () => _showMedicineDetails(context, nextDose),
                            child: const Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // TODAY'S PROGRESS SUMMARY
            AdherenceCard(
              adherenceRate: adherence.overallPercentage,
              totalScheduled: todayLogs.length,
              totalTaken: completedCount,
              totalMissed: todayLogs.where((l) => l.isMissed).length,
            ),
            const SizedBox(height: 20),

            // TODAY'S SCHEDULE SECTION
            SectionHeader(
              title: "Today's Schedule",
              actionLabel: '$completedCount / ${todayLogs.length} Done',
              onAction: null,
            ),
            const SizedBox(height: 8),

            if (todayLogs.isEmpty)
              const EmptyState(
                icon: Icons.medication_outlined,
                title: 'No Medicines Today',
                description: 'You have no scheduled doses for today.',
              )
            else
              ...todayLogs.map(
                (log) => MedicineCard(
                  log: log,
                  showAction: true,
                  onTap: () => _showMedicineDetails(context, log),
                  onMarkTaken: () => medRepo.markAsTaken(log.logId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
