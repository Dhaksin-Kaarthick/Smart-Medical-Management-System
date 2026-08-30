import 'package:flutter/material.dart';

/// Centralized color palette for Smart Medical Management System.
/// Follows modern medical SaaS aesthetic with calm blues, teals, and clear status indicators.
class AppColors {
  AppColors._();

  // Primary & Secondary Brand Colors
  static const Color primary = Color(0xFF0F4C81); // Deep Medical Blue
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Accent Blue
  static const Color primaryDark = Color(0xFF0A2540); // Deep Navy
  static const Color secondary = Color(0xFF0D9488); // Healthcare Teal
  static const Color secondaryLight = Color(0xFF14B8A6);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Clean Slate Tint
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceElevated = Color(0xFFF1F5F9); // Light Slate
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle Border

  // Status & Medical Adherence Colors
  static const Color statusTaken = Color(0xFF10B981); // Soft Green
  static const Color statusTakenBg = Color(0xFFECFDF5);
  static const Color statusUpcoming = Color(0xFF0284C7); // Informative Blue
  static const Color statusUpcomingBg = Color(0xFFF0F9FF);
  static const Color statusMissed = Color(0xFFEF4444); // Alert Red
  static const Color statusMissedBg = Color(0xFFFEF2F2);
  static const Color statusLate = Color(0xFFF59E0B); // Amber Warning
  static const Color statusLateBg = Color(0xFFFFFBEB);

  // AI Risk Levels
  static const Color riskLow = Color(0xFF10B981); // Green
  static const Color riskLowBg = Color(0xFFECFDF5);
  static const Color riskMedium = Color(0xFFF59E0B); // Amber
  static const Color riskMediumBg = Color(0xFFFFFBEB);
  static const Color riskHigh = Color(0xFFEF4444); // Red
  static const Color riskHighBg = Color(0xFFFEF2F2);

  // Device Connectivity
  static const Color deviceConnected = Color(0xFF10B981);
  static const Color deviceOffline = Color(0xFF94A3B8);

  // Text & Neutral Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Divider & Shimmer
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
