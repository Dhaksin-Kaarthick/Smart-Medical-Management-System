import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/notification_repository.dart';
import 'dashboard/caregiver_dashboard_view.dart';
import 'patients/caregiver_patients_view.dart';
import 'reports/caregiver_reports_view.dart';
import 'profile/caregiver_profile_view.dart';
import '../patient/alerts/patient_alerts_view.dart';

/// Caregiver Main Navigation Shell with 5 bottom tabs and badge counters.
class CaregiverMainNavigation extends StatefulWidget {
  const CaregiverMainNavigation({super.key});

  @override
  State<CaregiverMainNavigation> createState() => _CaregiverMainNavigationState();
}

class _CaregiverMainNavigationState extends State<CaregiverMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CaregiverDashboardView(),
    CaregiverPatientsView(),
    PatientAlertsView(),
    CaregiverReportsView(),
    CaregiverProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final notifRepo = context.watch<NotificationRepository>();
    final unreadCount = notifRepo.unreadCount;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              backgroundColor: AppColors.statusMissed,
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              backgroundColor: AppColors.statusMissed,
              child: const Icon(Icons.notifications_rounded),
            ),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
