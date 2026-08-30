import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/medicine_repository.dart';
import '../../../common/medicine_card.dart';
import '../../../common/empty_state.dart';

/// Patient Medicine History with timeframes (Daily/Weekly/Monthly) and status filters (All/Taken/Missed/Late).
class PatientHistoryView extends StatefulWidget {
  const PatientHistoryView({super.key});

  @override
  State<PatientHistoryView> createState() => _PatientHistoryViewState();
}

class _PatientHistoryViewState extends State<PatientHistoryView> {
  String _selectedStatusFilter = 'ALL';
  String _selectedTimeframe = 'WEEKLY';

  @override
  Widget build(BuildContext context) {
    final medRepo = context.watch<MedicineRepository>();
    final allLogs = medRepo.historyLogs;

    // Filter by status
    final filteredLogs = allLogs.where((log) {
      if (_selectedStatusFilter == 'ALL') return true;
      return log.status.toUpperCase() == _selectedStatusFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine History'),
      ),
      body: Column(
        children: [
          // Timeframe Tabs (Daily / Weekly / Monthly)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildTimeframeTab('DAILY'),
                const SizedBox(width: 8),
                _buildTimeframeTab('WEEKLY'),
                const SizedBox(width: 8),
                _buildTimeframeTab('MONTHLY'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Status Filter Chips (All, Taken, Missed, Late)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildStatusChip('ALL', 'All'),
                const SizedBox(width: 8),
                _buildStatusChip('TAKEN', 'Taken', AppColors.statusTaken),
                const SizedBox(width: 8),
                _buildStatusChip('MISSED', 'Missed', AppColors.statusMissed),
                const SizedBox(width: 8),
                _buildStatusChip('LATE', 'Late', AppColors.statusLate),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: filteredLogs.isEmpty
                ? const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'No History Found',
                    description: 'No medicine logs match the selected filter criteria.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return MedicineCard(log: log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeTab(String timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeframe = timeframe),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            timeframe,
            style: AppTextStyles.badgeText.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, [Color? color]) {
    final isSelected = _selectedStatusFilter == value;
    final activeColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatusFilter = value),
      selectedColor: activeColor.withOpacity(0.15),
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? activeColor : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? activeColor : AppColors.cardBorder,
      ),
      showCheckmark: false,
    );
  }
}
