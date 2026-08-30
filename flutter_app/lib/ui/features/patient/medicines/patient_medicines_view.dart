import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validation_helper.dart';
import '../../../../data/models/medicine_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/medicine_repository.dart';
import '../../../common/custom_button.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/empty_state.dart';

/// Patient view listing active prescriptions, dosages, frequency, and instructions
/// with interactive ability to add new medicines.
class PatientMedicinesView extends StatelessWidget {
  const PatientMedicinesView({super.key});

  void _showAddMedicineDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final freqCtrl = TextEditingController(text: 'Twice daily');
    final timesCtrl = TextEditingController(text: '09:00 AM, 08:00 PM');
    final instructCtrl = TextEditingController(text: 'Take after food');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                  const SizedBox(height: 16),
                  Text(
                    'Add New Medicine',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure your dosage and reminder schedule.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Medicine Name',
                    hint: 'e.g. Paracetamol / Metformin',
                    prefixIcon: Icons.medication_outlined,
                    validator: (v) => ValidationHelper.validateRequired(v, 'Medicine name'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: dosageCtrl,
                          label: 'Dosage',
                          hint: 'e.g. 500 mg / 1 tablet',
                          prefixIcon: Icons.scale_outlined,
                          validator: (v) => ValidationHelper.validateRequired(v, 'Dosage'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: freqCtrl,
                          label: 'Frequency',
                          hint: 'Twice daily',
                          prefixIcon: Icons.repeat_rounded,
                          validator: (v) => ValidationHelper.validateRequired(v, 'Frequency'),
                        ),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: timesCtrl,
                    label: 'Scheduled Reminder Times (comma-separated)',
                    hint: '09:00 AM, 08:00 PM',
                    prefixIcon: Icons.schedule_rounded,
                    validator: (v) => ValidationHelper.validateRequired(v, 'Scheduled times'),
                  ),
                  CustomTextField(
                    controller: instructCtrl,
                    label: 'Instructions',
                    hint: 'e.g. Take with warm water after meals',
                    prefixIcon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Save Medicine',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final currentUser = context.read<AuthRepository>().currentUser;
                      final patientId = currentUser?.userId ?? 'pat_001';

                      final newMed = MedicineModel(
                        medicineId: 'med_${DateTime.now().millisecondsSinceEpoch}',
                        patientId: patientId,
                        name: nameCtrl.text.trim(),
                        dosage: dosageCtrl.text.trim(),
                        frequency: freqCtrl.text.trim(),
                        scheduledTimes: timesCtrl.text.split(',').map((t) => t.trim()).toList(),
                        startDate: DateTime.now(),
                        instructions: instructCtrl.text.trim().isNotEmpty
                            ? instructCtrl.text.trim()
                            : 'Take as scheduled',
                      );

                      context.read<MedicineRepository>().addMedicine(newMed);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${newMed.name} added to schedule successfully!',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.statusTaken,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPrescriptionDetails(BuildContext context, MedicineModel med) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${med.dosage} • ${med.frequency}',
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
              _buildDetailItem(
                icon: Icons.schedule_rounded,
                title: 'Scheduled Times',
                value: med.scheduledTimes.join(', '),
              ),
              _buildDetailItem(
                icon: Icons.calendar_today_rounded,
                title: 'Start Date',
                value: DateFormatter.formatDate(med.startDate),
              ),
              _buildDetailItem(
                icon: Icons.info_outline_rounded,
                title: 'Instructions',
                value: med.instructions,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusMissed,
                  side: const BorderSide(color: AppColors.statusMissed, width: 1.5),
                  minimumSize: const Size(double.infinity, 44),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('Delete Medicine'),
                onPressed: () {
                  context.read<MedicineRepository>().deleteMedicine(med.medicineId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${med.name} removed from your prescriptions.'),
                      backgroundColor: AppColors.statusMissed,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medRepo = context.watch<MedicineRepository>();
    final medicines = medRepo.medicines;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Medicines'),
        actions: [
          IconButton(
            tooltip: 'Add Medicine',
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            onPressed: () => _showAddMedicineDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Medicine',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: medicines.isEmpty
          ? EmptyState(
              icon: Icons.medication_liquid_rounded,
              title: 'No Medicines Prescribed',
              description: 'Tap "+ Add Medicine" below to set up your first medicine reminder.',
              actionLabel: 'Add Medicine',
              onAction: () => _showAddMedicineDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showPrescriptionDetails(context, med),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med.name,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${med.dosage} • ${med.frequency}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Times: ${med.scheduledTimes.join(", ")}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
