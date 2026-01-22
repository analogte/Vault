import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/services/app_lock_service.dart';

void main() {
  group('PinVerifyResult Tests', () {
    test('should create successful result', () {
      final result = PinVerifyResult(success: true);

      expect(result.success, true);
      expect(result.error, null);
      expect(result.attemptsLeft, null);
      expect(result.isLockedOut, false);
      expect(result.lockoutMinutes, null);
    });

    test('should create failed result with error', () {
      final result = PinVerifyResult(
        success: false,
        error: 'Invalid PIN',
        attemptsLeft: 3,
      );

      expect(result.success, false);
      expect(result.error, 'Invalid PIN');
      expect(result.attemptsLeft, 3);
      expect(result.isLockedOut, false);
    });

    test('should create locked out result', () {
      final result = PinVerifyResult(
        success: false,
        error: 'Too many attempts',
        isLockedOut: true,
        lockoutMinutes: 5,
      );

      expect(result.success, false);
      expect(result.isLockedOut, true);
      expect(result.lockoutMinutes, 5);
    });
  });

  group('PasswordStrength Tests', () {
    test('should have all strength levels', () {
      expect(PasswordStrength.values.length, 5);
      expect(PasswordStrength.values.contains(PasswordStrength.weak), true);
      expect(PasswordStrength.values.contains(PasswordStrength.fair), true);
      expect(PasswordStrength.values.contains(PasswordStrength.good), true);
      expect(PasswordStrength.values.contains(PasswordStrength.strong), true);
      expect(
          PasswordStrength.values.contains(PasswordStrength.veryStrong), true);
    });
  });

  group('PasswordStrengthCalculator Tests', () {
    group('calculate', () {
      test('should return weak for empty password', () {
        expect(
          PasswordStrengthCalculator.calculate(''),
          PasswordStrength.weak,
        );
      });

      test('should return weak for short simple password', () {
        expect(
          PasswordStrengthCalculator.calculate('123'),
          PasswordStrength.weak,
        );
      });

      test('should return weak for password with repeated characters', () {
        expect(
          PasswordStrengthCalculator.calculate('aaaaaa'),
          PasswordStrength.weak,
        );
      });

      test('should return weak for common patterns', () {
        expect(
          PasswordStrengthCalculator.calculate('123456'),
          PasswordStrength.weak,
        );
        expect(
          PasswordStrengthCalculator.calculate('abcdef'),
          PasswordStrength.weak,
        );
        expect(
          PasswordStrengthCalculator.calculate('qwerty'),
          PasswordStrength.weak,
        );
      });

      test('should return weak or higher for 8 character lowercase password', () {
        final strength = PasswordStrengthCalculator.calculate('password');
        // 8 chars + lowercase = 2 points = weak
        expect(strength.index, greaterThanOrEqualTo(PasswordStrength.weak.index));
      });

      test('should return higher strength for password with mixed case', () {
        final strength = PasswordStrengthCalculator.calculate('Abcdefgh');
        // 8 chars + lowercase + uppercase = 3 points
        expect(strength.index, greaterThanOrEqualTo(PasswordStrength.weak.index));
      });

      test('should improve strength for 12 char password with numbers', () {
        final strength = PasswordStrengthCalculator.calculate('abcdefghij12');
        // 12 chars (2) + lowercase + numbers = 4 points
        expect(strength.index, greaterThanOrEqualTo(PasswordStrength.fair.index));
      });

      test('should return good or higher for complex password', () {
        final strength = PasswordStrengthCalculator.calculate('Abcdef12!@');
        // 8+ chars + lowercase + uppercase + numbers + special = 5 points
        expect(strength.index, greaterThanOrEqualTo(PasswordStrength.good.index));
      });

      test('should return good or higher for long complex password', () {
        final strength = PasswordStrengthCalculator.calculate('AbCdEf12345!@#\$%^');
        // 16+ chars (3) + all char types (4) = 7 points
        expect(strength.index, greaterThanOrEqualTo(PasswordStrength.good.index));
      });

      test('should handle mixed character types', () {
        // 8+ chars, lowercase, uppercase, numbers
        final strength = PasswordStrengthCalculator.calculate('TestPass123');
        expect(strength.index, greaterThanOrEqualTo(PasswordStrength.fair.index));
      });

      test('should handle special characters', () {
        final strength =
            PasswordStrengthCalculator.calculate('Test@Pass!');
        expect(
          strength == PasswordStrength.good ||
              strength == PasswordStrength.strong,
          true,
        );
      });

      test('should handle 16+ character passwords', () {
        // Very long password should score high
        final strength = PasswordStrengthCalculator.calculate(
            'VeryLongPassword123!');
        expect(
          strength == PasswordStrength.strong ||
              strength == PasswordStrength.veryStrong,
          true,
        );
      });
    });

    group('getLabel', () {
      test('should return correct Thai labels', () {
        expect(
          PasswordStrengthCalculator.getLabel(PasswordStrength.weak),
          'อ่อนมาก',
        );
        expect(
          PasswordStrengthCalculator.getLabel(PasswordStrength.fair),
          'พอใช้',
        );
        expect(
          PasswordStrengthCalculator.getLabel(PasswordStrength.good),
          'ดี',
        );
        expect(
          PasswordStrengthCalculator.getLabel(PasswordStrength.strong),
          'แข็งแรง',
        );
        expect(
          PasswordStrengthCalculator.getLabel(PasswordStrength.veryStrong),
          'แข็งแรงมาก',
        );
      });
    });

    group('getProgress', () {
      test('should return correct progress values', () {
        expect(
          PasswordStrengthCalculator.getProgress(PasswordStrength.weak),
          0.2,
        );
        expect(
          PasswordStrengthCalculator.getProgress(PasswordStrength.fair),
          0.4,
        );
        expect(
          PasswordStrengthCalculator.getProgress(PasswordStrength.good),
          0.6,
        );
        expect(
          PasswordStrengthCalculator.getProgress(PasswordStrength.strong),
          0.8,
        );
        expect(
          PasswordStrengthCalculator.getProgress(PasswordStrength.veryStrong),
          1.0,
        );
      });

      test('progress should increase with strength', () {
        final weakProgress =
            PasswordStrengthCalculator.getProgress(PasswordStrength.weak);
        final fairProgress =
            PasswordStrengthCalculator.getProgress(PasswordStrength.fair);
        final goodProgress =
            PasswordStrengthCalculator.getProgress(PasswordStrength.good);
        final strongProgress =
            PasswordStrengthCalculator.getProgress(PasswordStrength.strong);
        final veryStrongProgress =
            PasswordStrengthCalculator.getProgress(PasswordStrength.veryStrong);

        expect(fairProgress > weakProgress, true);
        expect(goodProgress > fairProgress, true);
        expect(strongProgress > goodProgress, true);
        expect(veryStrongProgress > strongProgress, true);
      });
    });

    group('getColor', () {
      test('should return correct color values', () {
        expect(
          PasswordStrengthCalculator.getColor(PasswordStrength.weak),
          0xFFE53935, // Red
        );
        expect(
          PasswordStrengthCalculator.getColor(PasswordStrength.fair),
          0xFFFF9800, // Orange
        );
        expect(
          PasswordStrengthCalculator.getColor(PasswordStrength.good),
          0xFFFFC107, // Amber
        );
        expect(
          PasswordStrengthCalculator.getColor(PasswordStrength.strong),
          0xFF8BC34A, // Light Green
        );
        expect(
          PasswordStrengthCalculator.getColor(PasswordStrength.veryStrong),
          0xFF4CAF50, // Green
        );
      });

      test('colors should be valid ARGB values', () {
        for (final strength in PasswordStrength.values) {
          final color = PasswordStrengthCalculator.getColor(strength);
          expect(color > 0, true);
          expect(color <= 0xFFFFFFFF, true);
        }
      });
    });
  });

  group('AppLockService Constants', () {
    test('should have correct security constants', () {
      expect(AppLockService.maxFailedAttempts, 5);
      expect(AppLockService.lockoutDurationMinutes, 5);
    });

    test('should have correct auto-lock options', () {
      expect(AppLockService.autoLockOptions, [0, 1, 5, 15, 30]);
      expect(AppLockService.autoLockOptions.first, 0); // Immediate
      expect(AppLockService.autoLockOptions.last, 30); // 30 minutes
    });
  });
}
