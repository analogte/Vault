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

    group('Initialization', () {
      test('should initialize without errors', () async {
        await expectLater(securityService.initialize(), completes);
      });
    });

    group('Lock State', () {
      test('should have isLocked getter', () {
        expect(securityService.isLocked, isA<bool>());
      });

      test('should start unlocked by default', () {
        expect(securityService.isLocked, isFalse);
      });
    });

    group('Activity Tracking', () {
      test('should have recordActivity method', () {
        expect(() => securityService.recordActivity(), returnsNormally);
      });

      test('should record multiple activities', () {
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

    group('Current Vault', () {
      test('should have currentVaultId getter', () {
        expect(securityService.currentVaultId, isNull);
      });

      test('should set current vault', () {
        securityService.setCurrentVault(1);
        expect(securityService.currentVaultId, 1);
      });

      test('should clear current vault when set to null', () {
        securityService.setCurrentVault(1);
        securityService.setCurrentVault(null);
        expect(securityService.currentVaultId, isNull);
      });

      test('should clear current vault when locked', () {
        securityService.setCurrentVault(1);
        securityService.lock();
        expect(securityService.currentVaultId, isNull);
      });
    });

    group('Auto Lock Options', () {
      test('should return timeout options', () {
        final options = securityService.getTimeoutOptions();
        expect(options, isNotEmpty);
      });

      test('should have multiple timeout options', () {
        final options = securityService.getTimeoutOptions();
        expect(options.length, greaterThanOrEqualTo(3));
      });

      test('options should have valid seconds', () {
        final options = securityService.getTimeoutOptions();
        for (final option in options) {
          expect(option.seconds, greaterThan(0));
        }
      });

      test('options should have non-empty labels', () {
        final options = securityService.getTimeoutOptions();
        for (final option in options) {
          expect(option.label, isNotEmpty);
        }
      });
    });

    group('AutoLockOption', () {
      test('should create with required fields', () {
        final option = AutoLockOption(seconds: 60, label: '1 minute');
        expect(option.seconds, 60);
        expect(option.label, '1 minute');
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
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
