import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/services/clipboard_service.dart';

void main() {
  group('ClipboardTimeoutOption Tests', () {
    test('should create option with correct values', () {
      final option = ClipboardTimeoutOption(
        seconds: 30,
        label: '30 seconds',
      );

      expect(option.seconds, 30);
      expect(option.label, '30 seconds');
    });

    test('should handle various timeout values', () {
      final options = [
        ClipboardTimeoutOption(seconds: 10, label: '10 วินาที'),
        ClipboardTimeoutOption(seconds: 15, label: '15 วินาที'),
        ClipboardTimeoutOption(seconds: 30, label: '30 วินาที'),
        ClipboardTimeoutOption(seconds: 60, label: '1 นาที'),
        ClipboardTimeoutOption(seconds: 120, label: '2 นาที'),
      ];

      expect(options.length, 5);
      expect(options[0].seconds, 10);
      expect(options[2].seconds, 30);
      expect(options[4].seconds, 120);
    });
  });

  group('ClipboardService Constants', () {
    test('should have correct default timeout', () {
      expect(ClipboardService.defaultTimeout, 30);
    });
  });

  group('ClipboardService getTimeoutOptions', () {
    late ClipboardService service;

    setUp(() {
      service = ClipboardService();
    });

    test('should return list of timeout options', () {
      final options = service.getTimeoutOptions();

      expect(options, isNotEmpty);
      expect(options.length, 6);
    });

    test('timeout options should have correct values', () {
      final options = service.getTimeoutOptions();

      expect(options[0].seconds, 10);
      expect(options[0].label, '10 วินาที');

      expect(options[1].seconds, 15);
      expect(options[1].label, '15 วินาที');

      expect(options[2].seconds, 30);
      expect(options[2].label, '30 วินาที');

      expect(options[3].seconds, 45);
      expect(options[3].label, '45 วินาที');

      expect(options[4].seconds, 60);
      expect(options[4].label, '1 นาที');

      expect(options[5].seconds, 120);
      expect(options[5].label, '2 นาที');
    });

    test('all timeout options should have positive seconds', () {
      final options = service.getTimeoutOptions();

      for (final option in options) {
        expect(option.seconds > 0, true);
      }
    });

    test('all timeout options should have non-empty labels', () {
      final options = service.getTimeoutOptions();

      for (final option in options) {
        expect(option.label.isNotEmpty, true);
      }
    });

    test('timeout options should be in ascending order', () {
      final options = service.getTimeoutOptions();

      for (int i = 1; i < options.length; i++) {
        expect(options[i].seconds > options[i - 1].seconds, true);
      }
    });
  });
}
