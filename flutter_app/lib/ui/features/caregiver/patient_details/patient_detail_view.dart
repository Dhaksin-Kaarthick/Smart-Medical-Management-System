import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validation_helper.dart';
import '../../../../data/models/patient_model.dart';
import '../../../../data/models/medicine_model.dart';
import '../../../../data/repositories/medicine_repository.dart';
import '../../../../data/repositories/device_repository.dart';
import '../../../../data/repositories/ai_repository.dart';
import '../../../common/device_status_indicator.dart';
import '../../../common/risk_card.dart';
import '../../../common/medicine_card.dart';
import '../../../common/adherence_card.dart';
import '../../../common/section_header.dart';
import '../../../common/empty_state.dart';
import '../../../common/custom_button.dart';
import '../../../common/custom_text_field.dart';

/// Comprehensive patient monitoring view for caregivers: IoT link, AI Risk Analysis, Prescription Manager, and Live Logs.
class PatientDetailView extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailView({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<PatientDetailView> {
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
                    'Prescribe New Medicine',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set dosage and schedule for ${widget.patient.name}.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Medicine Name',
                    hint: 'e.g. Metformin',
                    prefixIcon: Icons.medication_outlined,
                    validator: (v) => ValidationHelper.validateRequired(v, 'Medicine name'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: dosageCtrl,
                          label: 'Dosage',
                          hint: '500 mg',
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
                    label: 'Scheduled Times (comma-separated)',
                    hint: '09:00 AM, 08:00 PM',
                    prefixIcon: Icons.schedule_rounded,
                    validator: (v) => ValidationHelper.validateRequired(v, 'Scheduled times'),
                  ),
                  CustomTextField(
                    controller: instructCtrl,
                    label: 'Special Instructions',
                    hint: 'e.g. Take after breakfast',
                    prefixIcon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Save Prescription',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final newMed = MedicineModel(
                        medicineId: 'med_${DateTime.now().millisecondsSinceEpoch}',
                        patientId: widget.patient.patientId,
                        name: nameCtrl.text.trim(),
                        dosage: dosageCtrl.text.trim(),
                        frequency: freqCtrl.text.trim(),
                        scheduledTimes: timesCtrl.text.split(',').map((t) => t.trim()).toList(),
                        startDate: DateTime.now(),
                        instructions: instructCtrl.text.trim(),
                      );
                      context.read<MedicineRepository>().addMedicine(newMed);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${newMed.name} added to schedule!'),
                          backgroundColor: AppColors.statusTaken,
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

  @override
  Widget build(BuildContext context) {
    final medRepo = context.watch<MedicineRepository>();
    final deviceRepo = context.watch<DeviceRepository>();
    final aiRepo = context.watch<AiRepository>();

    final medicines = medRepo.medicines;
    final todayLogs = medRepo.todayLogs;
    final adherence = medRepo.adherenceStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Prescription',
            onPressed: () => _showAddMedicineDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // PATIENT BIO CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        widget.patient.name.isNotEmpty ? widget.patient.name[0].toUpperCase() : 'P',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patient.name,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Age ${widget.patient.age} • Blood Group: ${widget.patient.bloodGroup ?? "N/A"}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.emergency_outlined, size: 16, color: AppColors.statusMissed),
                    const SizedBox(width: 6),
                    Text(
                      'Emergency: ${widget.patient.emergencyContact ?? "None"}',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // PAIRED IOT DISPENSER STATUS
          DeviceStatusIndicator(
            device: deviceRepo.device,
            onRefresh: () => deviceRepo.toggleConnectionState(),
          ),
          const SizedBox(height: 20),

          // AI ADHERENCE RISK SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Adherence Risk Model',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Re-evaluate'),
                onPressed: aiRepo.isLoading
                    ? null
                    : () {
                        aiRepo.fetchPrediction(
                          patientId: widget.patient.patientId,
                          adherenceRate: widget.patient.adherenceRate,
                          missedDoses: adherence.totalMissed,
                          lateDoses: adherence.totalLate,
                        );
                      },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (aiRepo.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else
            RiskCard(prediction: aiRepo.prediction),
          const SizedBox(height: 20),

          // ADHERENCE PROGRESS
          AdherenceCard(
            adherenceRate: widget.patient.adherenceRate,
            totalScheduled: adherence.totalScheduled,
            totalTaken: adherence.totalTaken,
            totalMissed: adherence.totalMissed,
          ),
          const SizedBox(height: 20),

          // TODAY'S MEDICINE SCHEDULE
          SectionHeader(
            title: "Today's Prescriptions",
            actionLabel: '+ Add Medicine',
            onAction: () => _showAddMedicineDialog(context),
          ),
          const SizedBox(height: 8),
          if (todayLogs.isEmpty)
            const EmptyState(
              icon: Icons.event_available_outlined,
              title: 'No doses scheduled for today',
              subtitle: 'Tap "+ Add Medicine" to prescribe a new medicine schedule.',
            )
          else
            ...todayLogs.map(
              (log) => MedicineCard(
                log: log,
                showAction: false,
              ),
            ),
          const SizedBox(height: 20),

          // PRESCRIBED MEDICINE REPOSITORY
          SectionHeader(
            title: 'Prescribed Medicines (${medicines.length})',
          ),
          const SizedBox(height: 8),
          if (medicines.isEmpty)
            const EmptyState(
              icon: Icons.medication_outlined,
              title: 'No medicines added yet',
              subtitle: 'Prescribe medicines to start tracking adherence.',
            )
          else
            ...medicines.map(
              (med) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: AppTextStyles.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${med.dosage} • ${med.frequency} (${med.scheduledTimes.join(", ")})',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusMissed, size: 20),
                      onPressed: () {
                        medRepo.deleteMedicine(med.medicineId);
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
