import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validation_helper.dart';
import '../../../../data/models/patient_model.dart';
import '../../../../data/repositories/patient_repository.dart';
import '../../../common/patient_card.dart';
import '../../../common/custom_button.dart';
import '../../../common/custom_text_field.dart';
import '../patient_details/patient_detail_view.dart';

/// Caregiver Patient List with search, filtering, and "Add Patient" modal form.
class CaregiverPatientsView extends StatefulWidget {
  const CaregiverPatientsView({super.key});

  @override
  State<CaregiverPatientsView> createState() => _CaregiverPatientsViewState();
}

class _CaregiverPatientsViewState extends State<CaregiverPatientsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddPatientDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final bloodCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final deviceIdCtrl = TextEditingController(text: 'esp32_004');

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
                    'Connect New Patient',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Link a patient account with an ESP32 Smart Dispenser.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Patient Full Name',
                    hint: 'e.g. Meena Sundaram',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: ValidationHelper.validateName,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: ageCtrl,
                          label: 'Age',
                          hint: '65',
                          prefixIcon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) => ValidationHelper.validateRequired(v, 'Age'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: bloodCtrl,
                          label: 'Blood Group',
                          hint: 'B+',
                          prefixIcon: Icons.bloodtype_outlined,
                          validator: (v) => ValidationHelper.validateRequired(v, 'Blood group'),
                        ),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: contactCtrl,
                    label: 'Emergency Contact',
                    hint: '+91 98765 00000',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: ValidationHelper.validatePhone,
                  ),
                  CustomTextField(
                    controller: deviceIdCtrl,
                    label: 'ESP32 Device ID',
                    hint: 'esp32_xxx',
                    prefixIcon: Icons.router_outlined,
                    validator: (v) => ValidationHelper.validateRequired(v, 'Device ID'),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'Connect Patient',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final newPatient = PatientModel(
                        patientId: 'pat_${DateTime.now().millisecondsSinceEpoch}',
                        userId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        age: int.tryParse(ageCtrl.text.trim()) ?? 60,
                        bloodGroup: bloodCtrl.text.trim(),
                        emergencyContact: contactCtrl.text.trim(),
                        deviceId: deviceIdCtrl.text.trim(),
                        adherenceRate: 100.0,
                        riskLevel: 'LOW',
                        createdAt: DateTime.now(),
                      );
                      context.read<PatientRepository>().addPatient(newPatient);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${newPatient.name} added successfully!'),
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
    final patientRepo = context.watch<PatientRepository>();
    final patients = patientRepo.patients;

    final filtered = patients.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Monitored Patients'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Patient'),
        onPressed: () => _showAddPatientDialog(context),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search patients by name...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Patients List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final patient = filtered[index];
                return PatientCard(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
