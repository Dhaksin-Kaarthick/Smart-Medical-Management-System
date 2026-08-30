/// Global application constants, threshold settings, and storage keys.
class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Medical Management';
  static const String appTagline = 'Never miss your medicine.';
  static const String appVersion = '1.0.0';

  // Device Sync Constants
  static const int deviceOfflineThresholdMinutes = 5; // Offline if no heartbeat in 5 min
  static const Duration deviceHeartbeatInterval = Duration(seconds: 30);

  // Storage Keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyIsDemoMode = 'is_demo_mode';

  // AI Service Defaults
  static const String defaultAiApiUrl = 'http://10.0.2.2:8000'; // Local emulator mapping
  static const String aiDisclaimer =
      'AI-generated adherence insights are for monitoring purposes and are not medical advice.';
  
  // Roles
  static const String rolePatient = 'patient';
  static const String roleCaregiver = 'caregiver';

  // Medicine Statuses
  static const String statusUpcoming = 'upcoming';
  static const String statusTaken = 'taken';
  static const String statusMissed = 'missed';
  static const String statusLate = 'late';

  // Risk Levels
  static const String riskLow = 'LOW';
  static const String riskMedium = 'MEDIUM';
  static const String riskHigh = 'HIGH';
}
