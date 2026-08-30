import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/medicine_repository.dart';
import 'data/repositories/patient_repository.dart';
import 'data/repositories/device_repository.dart';
import 'data/repositories/ai_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'ui/features/splash/splash_view.dart';

/// Top-level application widget with MultiProvider dependency injection.
class SmartMedApp extends StatelessWidget {
  const SmartMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(create: (_) => MedicineRepository()),
        ChangeNotifierProvider(create: (_) => PatientRepository()),
        ChangeNotifierProvider(create: (_) => DeviceRepository()),
        ChangeNotifierProvider(create: (_) => AiRepository()),
        ChangeNotifierProvider(create: (_) => NotificationRepository()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashView(),
      ),
    );
  }
}
