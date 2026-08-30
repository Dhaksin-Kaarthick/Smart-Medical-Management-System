import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../auth/login_view.dart';

/// Caregiver profile and settings view with clinical account details, notification rules, and sign out.
class CaregiverProfileView extends StatelessWidget {
  const CaregiverProfileView({super.key});

  void _handleSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from the caregiver dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusMissed,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthRepository>().signOut();
              if (context.mounted) {
                await Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final user = authRepo.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Caregiver Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Caregiver ID Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  child: Text(
                    user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'C',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Dr. Priya Sharma',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'priya.caregiver@example.com',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CAREGIVER / PHYSICIAN',
                          style: AppTextStyles.badgeText.copyWith(
                            color: AppColors.secondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Alert Thresholds & Notification Configuration
          Text(
            'Emergency & Alert Rules',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                  title: Text('Missed Dose Push Alerts'),
                  subtitle: Text('Notify immediately when patient misses dose by 30 min'),
                  trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusTaken, size: 20),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.psychology_outlined, color: AppColors.secondary),
                  title: Text('AI Risk Escalation Notifications'),
                  subtitle: Text('Alert when patient adherence drops to HIGH risk'),
                  trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusTaken, size: 20),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.router_outlined, color: AppColors.statusLate),
                  title: Text('IoT Device Disconnect Warnings'),
                  subtitle: Text('Trigger if ESP32 offline > 5 minutes'),
                  trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusTaken, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // System Info
          Text(
            'System Architecture',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_queue_rounded, color: AppColors.primary),
                  title: const Text('Backend Cloud'),
                  subtitle: const Text('Google Cloud Firestore & FastAPI ML Service'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.memory_rounded, color: AppColors.secondary),
                  title: const Text('IoT Firmware'),
                  subtitle: const Text('ESP32 Dual-Core • DS3231 RTC • IR Pill Sensor'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sign Out Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.statusMissed,
              side: const BorderSide(color: AppColors.statusMissed, width: 1.5),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Sign Out'),
            onPressed: () => _handleSignOut(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
