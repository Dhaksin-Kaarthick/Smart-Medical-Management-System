import 'package:intl/intl.dart';

/// Formatting utilities for dates, times, countdowns, and last-sync strings.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateFormat = DateFormat('EEE, dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');
  static final DateFormat _fullDateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatTime(DateTime dateTime) => _timeFormat.format(dateTime);

  static String formatDate(DateTime dateTime) => _dateFormat.format(dateTime);

  static String formatShortDate(DateTime dateTime) => _shortDateFormat.format(dateTime);

  static String formatDateTime(DateTime dateTime) => _fullDateTimeFormat.format(dateTime);

  /// Returns user-friendly countdown: "Next dose in 42 minutes" or "Due now"
  static String formatCountdown(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.isNegative) {
      final elapsed = now.difference(scheduledTime);
      if (elapsed.inMinutes < 60) {
        return 'Scheduled ${elapsed.inMinutes}m ago';
      }
      return 'Scheduled ${elapsed.inHours}h ago';
    }

    if (difference.inHours >= 24) {
      final days = difference.inDays;
      return 'Next dose in $days day${days > 1 ? "s" : ""}';
    } else if (difference.inHours >= 1) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      if (minutes == 0) return 'Next dose in $hours hour${hours > 1 ? "s" : ""}';
      return 'Next dose in ${hours}h ${minutes}m';
    } else if (difference.inMinutes > 0) {
      return 'Next dose in ${difference.inMinutes} minutes';
    } else {
      return 'Due right now';
    }
  }

  /// Returns readable device sync status: "Last synced 20 sec ago" or "2 minutes ago"
  static String formatLastSync(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 45) {
      return 'Last synced just now';
    } else if (difference.inMinutes < 60) {
      return 'Last synced ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Last synced ${difference.inHours} hr ago';
    } else {
      return 'Last synced on ${formatShortDate(lastSeen)}';
    }
  }

  /// Calculates greeting based on current hour: "Good morning", "Good afternoon", etc.
  static String getGreeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
