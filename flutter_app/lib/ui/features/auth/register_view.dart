import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validation_helper.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../common/custom_button.dart';
import '../../common/custom_text_field.dart';
import '../patient/patient_main_navigation.dart';
import '../caregiver/caregiver_main_navigation.dart';

/// User registration screen with Patient / Caregiver role selection and validation.
class RegisterView extends StatefulWidget {
  final String initialRole;

  const RegisterView({
    super.key,
    this.initialRole = AppConstants.rolePatient,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  late String _selectedRole;
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1960),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormatter.formatDate(picked);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authRepo = context.read<AuthRepository>();
    final success = await authRepo.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      dateOfBirth: _selectedDob,
    );

    if (success && mounted) {
      if (_selectedRole == AppConstants.roleCaregiver) {
        await Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const CaregiverMainNavigation()),
          (route) => false,
        );
      } else {
        await Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const PatientMainNavigation()),
          (route) => false,
        );
      }
    } else if (mounted && authRepo.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authRepo.errorMessage!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusMissed,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final isPatient = _selectedRole == AppConstants.rolePatient;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Smart Medical Management',
                  style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select your role to configure your personalized dashboard.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),

                // Role Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildRoleTab(
                          title: 'Patient',
                          icon: Icons.person_rounded,
                          isSelected: isPatient,
                          onTap: () => setState(() => _selectedRole = AppConstants.rolePatient),
                        ),
                      ),
                      Expanded(
                        child: _buildRoleTab(
                          title: 'Caregiver',
                          icon: Icons.health_and_safety_rounded,
                          isSelected: !isPatient,
                          onTap: () => setState(() => _selectedRole = AppConstants.roleCaregiver),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: isPatient ? 'e.g. Arun Kumar' : 'e.g. Dr. Priya Sharma',
                  prefixIcon: Icons.badge_outlined,
                  validator: ValidationHelper.validateName,
                ),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: ValidationHelper.validateEmail,
                ),

                // Phone
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+91 98765 43210',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: ValidationHelper.validatePhone,
                ),

                // Date of Birth (Patient Only)
                if (isPatient)
                  CustomTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    hint: 'Select Date of Birth',
                    prefixIcon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDob,
                    validator: (v) => ValidationHelper.validateRequired(v, 'Date of birth'),
                  ),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: ValidationHelper.validatePassword,
                ),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (val) =>
                      ValidationHelper.validateConfirmPassword(val, _passwordController.text),
                ),

                const SizedBox(height: 12),
                CustomButton(
                  text: 'Register Account',
                  isLoading: authRepo.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
