import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/device_repository.dart';
import '../../auth/login_view.dart';

/// Patient Profile and Settings screen with personal information and device settings.
class PatientProfileView extends StatelessWidget {
  const PatientProfileView({super.key});

  void _handleSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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
    final deviceRepo = context.watch<DeviceRepository>();
    final user = authRepo.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // User Card
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
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
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
                        user?.name ?? 'Arun Kumar',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'arun.kumar@example.com',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PATIENT',
                          style: AppTextStyles.badgeText.copyWith(
                            color: AppColors.primary,
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

          // Device Pairing Section
          Text(
            'Hardware & IoT Settings',
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
                  leading: const Icon(Icons.router_rounded, color: AppColors.primary),
                  title: const Text('Paired Dispenser'),
                  subtitle: Text(deviceRepo.device.deviceName),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deviceRepo.isConnected ? AppColors.statusTakenBg : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      deviceRepo.isConnected ? 'CONNECTED' : 'OFFLINE',
                      style: AppTextStyles.badgeText.copyWith(
                        color: deviceRepo.isConnected ? AppColors.statusTaken : AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.wifi_tethering_rounded, color: AppColors.secondary),
                  title: const Text('Simulate Toggle State'),
                  subtitle: const Text('Test hardware online/offline behavior'),
                  onTap: () => deviceRepo.toggleConnectionState(),
                  trailing: const Icon(Icons.touch_app_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Settings
          Text(
            'Preferences',
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
                const ListTile(
                  leading: Icon(Icons.notifications_outlined, color: AppColors.primary),
                  title: Text('Sound & Reminders'),
                  subtitle: Text('Buzzer + Mobile notifications enabled'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                  title: const Text('About Smart Medical Management'),
                  subtitle: Text('Version ${AppConstants.appVersion} • Embedded Systems Capstone'),
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
