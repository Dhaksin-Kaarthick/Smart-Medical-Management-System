import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/notification_repository.dart';
import 'dashboard/patient_dashboard_view.dart';
import 'medicines/patient_medicines_view.dart';
import 'history/patient_history_view.dart';
import 'alerts/patient_alerts_view.dart';
import 'profile/patient_profile_view.dart';

/// Patient Main Navigation Shell with 5 bottom tabs and unread notification badge.
class PatientMainNavigation extends StatefulWidget {
  const PatientMainNavigation({super.key});

  @override
  State<PatientMainNavigation> createState() => _PatientMainNavigationState();
}

class _PatientMainNavigationState extends State<PatientMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PatientDashboardView(),
    PatientMedicinesView(),
    PatientHistoryView(),
    PatientAlertsView(),
    PatientProfileView(),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            activeIcon: Icon(Icons.medication_rounded),
            label: 'Medicines',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
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
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
