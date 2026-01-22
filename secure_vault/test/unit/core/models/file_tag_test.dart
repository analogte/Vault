import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/models/file_tag.dart';

void main() {
  group('FileTag Model Tests', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);

    group('Constructor', () {
      test('should create FileTag with required fields', () {
        final tag = FileTag(
          vaultId: 1,
          name: 'Important',
          createdAt: testCreatedAt,
        );

        expect(tag.id, isNull);
        expect(tag.vaultId, 1);
        expect(tag.name, 'Important');
        expect(tag.color, '#2196F3'); // Default blue
        expect(tag.createdAt, testCreatedAt);
      });

      test('should create FileTag with custom color', () {
        final tag = FileTag(
          vaultId: 1,
          name: 'Urgent',
          color: '#F44336', // Red
          createdAt: testCreatedAt,
        );

        expect(tag.color, '#F44336');
      });

      test('should create FileTag with all fields', () {
        final tag = FileTag(
          id: 42,
          vaultId: 1,
          name: 'Work',
          color: '#4CAF50', // Green
          createdAt: testCreatedAt,
        );

        expect(tag.id, 42);
        expect(tag.name, 'Work');
        expect(tag.color, '#4CAF50');
      });
    });

    group('toMap', () {
      test('should convert to map without id when null', () {
        final tag = FileTag(
          vaultId: 1,
          name: 'Test',
          createdAt: testCreatedAt,
        );

        final map = tag.toMap();

        expect(map.containsKey('id'), isFalse);
        expect(map['vault_id'], 1);
        expect(map['name'], 'Test');
        expect(map['color'], '#2196F3');
        expect(map['created_at'], testCreatedAt.millisecondsSinceEpoch);
      });

      test('should convert to map with id when set', () {
        final tag = FileTag(
          id: 5,
          vaultId: 1,
          name: 'Test',
          createdAt: testCreatedAt,
        );

        final map = tag.toMap();

        expect(map['id'], 5);
      });

      test('should include custom color in map', () {
        final tag = FileTag(
          vaultId: 1,
          name: 'Custom',
          color: '#FF5722',
          createdAt: testCreatedAt,
        );

        final map = tag.toMap();
        expect(map['color'], '#FF5722');
      });
    });

    group('fromMap', () {
      test('should create from map with required fields', () {
        final map = {
          'vault_id': 1,
          'name': 'FromMap',
          'created_at': testCreatedAt.millisecondsSinceEpoch,
        };

        final tag = FileTag.fromMap(map);

        expect(tag.id, isNull);
        expect(tag.vaultId, 1);
        expect(tag.name, 'FromMap');
        expect(tag.color, '#2196F3'); // Default
        expect(tag.createdAt, testCreatedAt);
      });

      test('should create from map with all fields', () {
        final map = {
          'id': 10,
          'vault_id': 2,
          'name': 'Full Tag',
          'color': '#9C27B0',
          'created_at': testCreatedAt.millisecondsSinceEpoch,
        };

        final tag = FileTag.fromMap(map);

        expect(tag.id, 10);
        expect(tag.vaultId, 2);
        expect(tag.name, 'Full Tag');
        expect(tag.color, '#9C27B0');
      });

      test('should use default color when null in map', () {
        final map = {
          'vault_id': 1,
          'name': 'No Color',
          'color': null,
          'created_at': testCreatedAt.millisecondsSinceEpoch,
        };

        final tag = FileTag.fromMap(map);
        expect(tag.color, '#2196F3');
      });
    });

    group('Roundtrip toMap/fromMap', () {
      test('should preserve data through roundtrip', () {
        final original = FileTag(
          id: 99,
          vaultId: 5,
          name: 'Roundtrip Test',
          color: '#673AB7',
          createdAt: testCreatedAt,
        );

        final map = original.toMap();
        final restored = FileTag.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.vaultId, original.vaultId);
        expect(restored.name, original.name);
        expect(restored.color, original.color);
        expect(restored.createdAt, original.createdAt);
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = FileTag(
          id: 1,
          vaultId: 2,
          name: 'Original',
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.color, original.color);
      });

      test('should copy with partial changes', () {
        final original = FileTag(
          id: 1,
          vaultId: 2,
          name: 'Original',
          color: '#2196F3',
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith(
          name: 'Renamed',
          color: '#F44336',
        );

        expect(copy.id, original.id);
        expect(copy.vaultId, original.vaultId);
        expect(copy.name, 'Renamed');
        expect(copy.color, '#F44336');
      });
    });

    group('colorValue', () {
      test('should parse valid hex color', () {
        final tag = FileTag(
          vaultId: 1,
          name: 'Test',
          color: '#FF5722',
          createdAt: testCreatedAt,
        );

        expect(tag.colorValue, 0xFFFF5722);
      });

      test('should return default blue for invalid color', () {
        final tag = FileTag(
          vaultId: 1,
          name: 'Test',
          color: 'invalid',
          createdAt: testCreatedAt,
        );

        expect(tag.colorValue, 0xFF2196F3);
      });

      test('should handle color without hash', () {
        // The implementation expects # prefix
        final tag = FileTag(
          vaultId: 1,
          name: 'Test',
          color: 'FF5722', // Missing #
          createdAt: testCreatedAt,
        );

        // This will fail to parse and return default
        expect(tag.colorValue, 0xFF2196F3);
      });

      test('should parse all predefined colors', () {
        for (final color in FileTag.predefinedColors) {
          final tag = FileTag(
            vaultId: 1,
            name: 'Test',
            color: color,
            createdAt: testCreatedAt,
          );

          // Should not return default (unless it's the default blue)
          expect(
            tag.colorValue,
            isNot(equals(0xFF2196F3)),
            reason: 'Color $color should parse correctly',
          );
        }
      });
    });

    group('predefinedColors', () {
      test('should have 19 predefined colors', () {
        expect(FileTag.predefinedColors.length, 19);
      });

      test('all predefined colors should start with #', () {
        for (final color in FileTag.predefinedColors) {
          expect(color.startsWith('#'), isTrue);
        }
      });

      test('all predefined colors should be 7 characters', () {
        for (final color in FileTag.predefinedColors) {
          expect(color.length, 7, reason: '$color should be 7 characters (#RRGGBB)');
        }
      });

      test('should include common colors', () {
        expect(FileTag.predefinedColors, contains('#F44336')); // Red
        expect(FileTag.predefinedColors, contains('#4CAF50')); // Green
        expect(FileTag.predefinedColors, contains('#2196F3')); // Blue
        expect(FileTag.predefinedColors, contains('#FFEB3B')); // Yellow
      });
    });
  });

  group('FileTagAssignment Model Tests', () {
    group('Constructor', () {
      test('should create FileTagAssignment', () {
        final assignment = FileTagAssignment(
          fileId: 1,
          tagId: 2,
        );

        expect(assignment.fileId, 1);
        expect(assignment.tagId, 2);
      });
    });

    group('toMap', () {
      test('should convert to map', () {
        final assignment = FileTagAssignment(
          fileId: 10,
          tagId: 20,
        );

        final map = assignment.toMap();

        expect(map['file_id'], 10);
        expect(map['tag_id'], 20);
      });
    });

    group('fromMap', () {
      test('should create from map', () {
        final map = {
          'file_id': 5,
          'tag_id': 15,
        };

        final assignment = FileTagAssignment.fromMap(map);

        expect(assignment.fileId, 5);
        expect(assignment.tagId, 15);
      });
    });

    group('Roundtrip', () {
      test('should preserve data through roundtrip', () {
        final original = FileTagAssignment(
          fileId: 100,
          tagId: 200,
        );

        final map = original.toMap();
        final restored = FileTagAssignment.fromMap(map);

        expect(restored.fileId, original.fileId);
        expect(restored.tagId, original.tagId);
      });
    });
  });
}
