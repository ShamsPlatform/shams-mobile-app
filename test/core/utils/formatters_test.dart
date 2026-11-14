import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/core/utils/formatters.dart';

void main() {
  group('formatRelativeTime', () {
    final now = DateTime(2026, 11, 15, 12, 0, 0);

    test('matches legacy PostModel relative time outputs', () {
      final cases = <(DateTime, String)>[
        (now.subtract(const Duration(seconds: 30)), 'الآن'),
        (now.subtract(const Duration(minutes: 1)), 'منذ 1 دقيقة'),
        (now.subtract(const Duration(minutes: 45)), 'منذ 45 دقيقة'),
        (now.subtract(const Duration(hours: 1)), 'منذ 1 ساعة'),
        (now.subtract(const Duration(hours: 5)), 'منذ 5 ساعة'),
        (now.subtract(const Duration(days: 1)), 'منذ 1 يوم'),
        (now.subtract(const Duration(days: 7)), 'منذ 7 يوم'),
        (now.subtract(const Duration(days: 8)), '2026-11-7'),
        (DateTime(2025, 1, 5, 10, 0), '2025-1-5'),
      ];

      for (final (dateTime, expected) in cases) {
        expect(formatRelativeTime(dateTime, now: now), expected);
      }
    });
  });

  group('formatCompactNumber', () {
    test('matches legacy compact number formatting', () {
      final cases = <(int, String)>[
        (0, '0'),
        (999, '999'),
        (1000, '1.0K'),
        (45800, '45.8K'),
        (1000000, '1.0M'),
        (2500000, '2.5M'),
      ];

      for (final (input, expected) in cases) {
        expect(formatCompactNumber(input), expected);
      }
    });
  });
}
