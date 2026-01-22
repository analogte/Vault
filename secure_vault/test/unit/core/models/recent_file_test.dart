import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/models/recent_file.dart';

void main() {
  group('RecentFile Model Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 22, 10, 30, 0);
    });

    group('Constructor', () {
      test('should create recent file with all fields', () {
        final recentFile = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        expect(recentFile.id, 1);
        expect(recentFile.fileId, 100);
        expect(recentFile.vaultId, 10);
        expect(recentFile.accessedAt, testDate);
      });

      test('should create recent file without id', () {
        final recentFile = RecentFile(
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        expect(recentFile.id, null);
        expect(recentFile.fileId, 100);
        expect(recentFile.vaultId, 10);
      });
    });

    group('toMap', () {
      test('should convert to map with id', () {
        final recentFile = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final map = recentFile.toMap();

        expect(map['id'], 1);
        expect(map['file_id'], 100);
        expect(map['vault_id'], 10);
        expect(map['accessed_at'], testDate.millisecondsSinceEpoch);
      });

      test('should convert to map without id when null', () {
        final recentFile = RecentFile(
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final map = recentFile.toMap();

        expect(map.containsKey('id'), false);
        expect(map['file_id'], 100);
        expect(map['vault_id'], 10);
      });
    });

    group('fromMap', () {
      test('should create from map with id', () {
        final map = {
          'id': 1,
          'file_id': 100,
          'vault_id': 10,
          'accessed_at': testDate.millisecondsSinceEpoch,
        };

        final recentFile = RecentFile.fromMap(map);

        expect(recentFile.id, 1);
        expect(recentFile.fileId, 100);
        expect(recentFile.vaultId, 10);
        expect(recentFile.accessedAt, testDate);
      });

      test('should create from map without id', () {
        final map = {
          'id': null,
          'file_id': 100,
          'vault_id': 10,
          'accessed_at': testDate.millisecondsSinceEpoch,
        };

        final recentFile = RecentFile.fromMap(map);

        expect(recentFile.id, null);
        expect(recentFile.fileId, 100);
        expect(recentFile.vaultId, 10);
      });

      test('should parse accessed_at timestamp correctly', () {
        final timestamp = DateTime(2025, 6, 15, 14, 30, 0);
        final map = {
          'id': 1,
          'file_id': 100,
          'vault_id': 10,
          'accessed_at': timestamp.millisecondsSinceEpoch,
        };

        final recentFile = RecentFile.fromMap(map);

        expect(recentFile.accessedAt.year, 2025);
        expect(recentFile.accessedAt.month, 6);
        expect(recentFile.accessedAt.day, 15);
        expect(recentFile.accessedAt.hour, 14);
        expect(recentFile.accessedAt.minute, 30);
      });
    });

    group('copyWith', () {
      test('should create copy with updated id', () {
        final original = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final copy = original.copyWith(id: 2);

        expect(copy.id, 2);
        expect(copy.fileId, original.fileId);
        expect(copy.vaultId, original.vaultId);
        expect(copy.accessedAt, original.accessedAt);
      });

      test('should create copy with updated fileId', () {
        final original = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final copy = original.copyWith(fileId: 200);

        expect(copy.id, original.id);
        expect(copy.fileId, 200);
        expect(copy.vaultId, original.vaultId);
        expect(copy.accessedAt, original.accessedAt);
      });

      test('should create copy with updated vaultId', () {
        final original = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final copy = original.copyWith(vaultId: 20);

        expect(copy.id, original.id);
        expect(copy.fileId, original.fileId);
        expect(copy.vaultId, 20);
        expect(copy.accessedAt, original.accessedAt);
      });

      test('should create copy with updated accessedAt', () {
        final original = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final newDate = DateTime(2025, 12, 25, 12, 0, 0);
        final copy = original.copyWith(accessedAt: newDate);

        expect(copy.id, original.id);
        expect(copy.fileId, original.fileId);
        expect(copy.vaultId, original.vaultId);
        expect(copy.accessedAt, newDate);
      });

      test('should preserve all values when no params provided', () {
        final original = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.fileId, original.fileId);
        expect(copy.vaultId, original.vaultId);
        expect(copy.accessedAt, original.accessedAt);
      });

      test('should update multiple fields at once', () {
        final original = RecentFile(
          id: 1,
          fileId: 100,
          vaultId: 10,
          accessedAt: testDate,
        );

        final newDate = DateTime.now();
        final copy = original.copyWith(
          id: 2,
          fileId: 200,
          vaultId: 20,
          accessedAt: newDate,
        );

        expect(copy.id, 2);
        expect(copy.fileId, 200);
        expect(copy.vaultId, 20);
        expect(copy.accessedAt, newDate);
      });
    });

    group('Round-trip Serialization', () {
      test('should serialize and deserialize correctly', () {
        final original = RecentFile(
          id: 42,
          fileId: 123,
          vaultId: 456,
          accessedAt: testDate,
        );

        final map = original.toMap();
        final restored = RecentFile.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.fileId, original.fileId);
        expect(restored.vaultId, original.vaultId);
        expect(restored.accessedAt, original.accessedAt);
      });

      test('should handle round-trip without id', () {
        final original = RecentFile(
          fileId: 123,
          vaultId: 456,
          accessedAt: testDate,
        );

        final map = original.toMap();
        // Simulate database insert returning id
        map['id'] = 1;
        final restored = RecentFile.fromMap(map);

        expect(restored.id, 1);
        expect(restored.fileId, original.fileId);
        expect(restored.vaultId, original.vaultId);
      });
    });
  });
}
