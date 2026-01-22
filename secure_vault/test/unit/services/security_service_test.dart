import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/services/security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecurityService Tests', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    tearDown(() {
      securityService.dispose();
    });

    group('Auto Lock Timeout', () {
      test('should have default timeout values', () {
        // Verify service can be instantiated
        expect(securityService, isNotNull);
      });

      test('should have valid timeout options', () {
        // AutoLockTimeout enum should have expected values
        expect(AutoLockTimeout.values.length, greaterThan(0));
      });

      test('should include immediate timeout', () {
        expect(AutoLockTimeout.values, contains(AutoLockTimeout.immediate));
      });

      test('should include 30 seconds timeout', () {
        expect(AutoLockTimeout.values, contains(AutoLockTimeout.thirtySeconds));
      });

      test('should include 1 minute timeout', () {
        expect(AutoLockTimeout.values, contains(AutoLockTimeout.oneMinute));
      });

      test('should include 5 minutes timeout', () {
        expect(AutoLockTimeout.values, contains(AutoLockTimeout.fiveMinutes));
      });

      test('should include 15 minutes timeout', () {
        expect(AutoLockTimeout.values, contains(AutoLockTimeout.fifteenMinutes));
      });

      test('should include 30 minutes timeout', () {
        expect(AutoLockTimeout.values, contains(AutoLockTimeout.thirtyMinutes));
      });

      test('should include never timeout', () {
        expect(AutoLockTimeout.values, contains(AutoLockTimeout.never));
      });
    });

    group('AutoLockTimeout Duration', () {
      test('immediate should return 0 duration', () {
        expect(AutoLockTimeout.immediate.duration, Duration.zero);
      });

      test('thirtySeconds should return 30 seconds', () {
        expect(AutoLockTimeout.thirtySeconds.duration, const Duration(seconds: 30));
      });

      test('oneMinute should return 1 minute', () {
        expect(AutoLockTimeout.oneMinute.duration, const Duration(minutes: 1));
      });

      test('fiveMinutes should return 5 minutes', () {
        expect(AutoLockTimeout.fiveMinutes.duration, const Duration(minutes: 5));
      });

      test('fifteenMinutes should return 15 minutes', () {
        expect(AutoLockTimeout.fifteenMinutes.duration, const Duration(minutes: 15));
      });

      test('thirtyMinutes should return 30 minutes', () {
        expect(AutoLockTimeout.thirtyMinutes.duration, const Duration(minutes: 30));
      });
    });

    group('AutoLockTimeout Display Names', () {
      test('should have display names for all options', () {
        for (final timeout in AutoLockTimeout.values) {
          expect(timeout.displayName, isNotEmpty);
        }
      });

      test('immediate should have appropriate name', () {
        expect(AutoLockTimeout.immediate.displayName.toLowerCase(), contains('ทันที'));
      });

      test('never should have appropriate name', () {
        expect(AutoLockTimeout.never.displayName.toLowerCase(), contains('ไม่ล็อค'));
      });
    });

    group('Initialization', () {
      test('should initialize without errors', () async {
        // Initialize should not throw
        expect(() => securityService.initialize(), returnsNormally);
      });
    });

    group('Lock State', () {
      test('should have isLocked getter', () {
        expect(securityService.isLocked, isA<bool>());
      });

      test('should start unlocked by default', () {
        // New service instance should be unlocked
        final newService = SecurityService();
        expect(newService.isLocked, isFalse);
        newService.dispose();
      });
    });

    group('Activity Tracking', () {
      test('should have recordActivity method', () {
        // Should not throw
        expect(() => securityService.recordActivity(), returnsNormally);
      });

      test('should record multiple activities', () {
        // Should handle multiple calls
        for (var i = 0; i < 10; i++) {
          securityService.recordActivity();
        }
        expect(true, isTrue); // No exception means success
      });
    });

    group('Lock/Unlock', () {
      test('should have lock method', () {
        expect(() => securityService.lock(), returnsNormally);
      });

      test('should have unlock method', () {
        expect(() => securityService.unlock(), returnsNormally);
      });

      test('should lock when lock is called', () {
        securityService.lock();
        expect(securityService.isLocked, isTrue);
      });

      test('should unlock when unlock is called', () {
        securityService.lock();
        expect(securityService.isLocked, isTrue);

        securityService.unlock();
        expect(securityService.isLocked, isFalse);
      });
    });

    group('Dispose', () {
      test('should dispose without errors', () {
        final service = SecurityService();
        expect(() => service.dispose(), returnsNormally);
      });

      test('should be safe to call dispose multiple times', () {
        final service = SecurityService();
        service.dispose();
        // Calling dispose again should not throw
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
