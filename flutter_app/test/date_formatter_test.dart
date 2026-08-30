import 'package:flutter_test/flutter_test.dart';
import 'package:smart_medical_management/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatCountdown calculates future doses', () {
      final in30Mins = DateTime.now().add(const Duration(minutes: 30));
      final result = DateFormatter.formatCountdown(in30Mins);
      expect(result.contains('Next dose in'), isTrue);
    });

    test('formatLastSync returns readable relative time', () {
      final justNow = DateTime.now().subtract(const Duration(seconds: 10));
      expect(DateFormatter.formatLastSync(justNow), 'Last synced just now');

      final fiveMinsAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.formatLastSync(fiveMinsAgo), 'Last synced 5 min ago');
    });

    test('getGreeting returns morning, afternoon or evening', () {
      final morning = DateTime(2026, 8, 30, 9, 0);
      expect(DateFormatter.getGreeting(morning), 'Good morning');

      final afternoon = DateTime(2026, 8, 30, 14, 0);
      expect(DateFormatter.getGreeting(afternoon), 'Good afternoon');

      final evening = DateTime(2026, 8, 30, 19, 0);
      expect(DateFormatter.getGreeting(evening), 'Good evening');
    });
  });
}
