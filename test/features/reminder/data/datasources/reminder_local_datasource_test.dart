import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:reminder_app/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:reminder_app/features/reminder/data/models/reminder_model.dart';

/// Fake Box implementation for testing purposes
/// This avoids the need for Hive initialization in tests
class FakeBox<T> implements Box<T> {
  final Map<dynamic, T> _data = {};

  @override
  T? get(dynamic key, {T? defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, T value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Iterable<T> get values => _data.values;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  int get length => _data.length;

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);

  // Unused Box methods - throw UnimplementedError
  @override
  String get name => throw UnimplementedError();

  @override
  bool get isOpen => true;

  @override
  String? get path => throw UnimplementedError();

  @override
  bool get lazy => throw UnimplementedError();

  @override
  Future<void> putAll(Map<dynamic, T> entries) async {
    _data.addAll(entries);
  }

  @override
  Future<void> putAt(int index, T value) => throw UnimplementedError();

  @override
  Future<void> deleteAt(int index) => throw UnimplementedError();

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      _data.remove(key);
    }
  }

  @override
  Map<dynamic, T> toMap() => Map<dynamic, T>.from(_data);

  @override
  T? getAt(int index) => throw UnimplementedError();

  @override
  Future<int> add(T value) => throw UnimplementedError();

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) =>
      throw UnimplementedError();

  @override
  Iterable<T> valuesBetween({dynamic startKey, dynamic endKey}) =>
      throw UnimplementedError();

  @override
  Stream<BoxEvent> watch({dynamic key}) => throw UnimplementedError();

  @override
  Future<void> compact() => throw UnimplementedError();

  @override
  Future<void> close() async {}

  @override
  Future<void> flush() async {}

  @override
  dynamic keyAt(int index) {
    return _data.keys.elementAt(index);
  }

  @override
  Future<void> deleteFromDisk() async {
    _data.clear();
  }
}

/// Testable implementation that accepts a fake box
class TestableReminderLocalDataSource implements ReminderLocalDataSource {
  final Box<ReminderModel> box;

  TestableReminderLocalDataSource(this.box);

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    return box.values.toList();
  }

  @override
  Future<ReminderModel?> getReminderById(String id) async {
    return box.get(id);
  }

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    await box.put(reminder.id, reminder);
    return reminder;
  }

  @override
  Future<ReminderModel> updateReminder(ReminderModel reminder) async {
    await box.put(reminder.id, reminder);
    return reminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    await box.delete(id);
  }

  @override
  Future<void> clearAllReminders() async {
    await box.clear();
  }
}

void main() {
  late FakeBox<ReminderModel> fakeBox;
  late TestableReminderLocalDataSource dataSource;

  /// Helper to create test reminder
  ReminderModel createTestReminder({
    String id = 'test-id-1',
    String title = 'Test Reminder',
    String? description = 'Test Description',
    bool isCompleted = false,
  }) {
    return ReminderModel(
      id: id,
      title: title,
      description: description,
      dateTime: DateTime(2026, 1, 17, 10, 0),
      isCompleted: isCompleted,
      priorityIndex: 1,
      repeatTypeIndex: 0,
      createdAt: DateTime(2026, 1, 16, 12, 0),
    );
  }

  setUp(() {
    fakeBox = FakeBox<ReminderModel>();
    dataSource = TestableReminderLocalDataSource(fakeBox);
  });

  group('ReminderLocalDataSource', () {
    group('getAllReminders', () {
      test('should return empty list when no reminders exist', () async {
        // Act
        final result = await dataSource.getAllReminders();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all reminders from box', () async {
        // Arrange
        final reminder1 = createTestReminder(id: 'id-1', title: 'Reminder 1');
        final reminder2 = createTestReminder(id: 'id-2', title: 'Reminder 2');
        await fakeBox.put(reminder1.id, reminder1);
        await fakeBox.put(reminder2.id, reminder2);

        // Act
        final result = await dataSource.getAllReminders();

        // Assert
        expect(result.length, 2);
        expect(result.any((r) => r.id == 'id-1'), isTrue);
        expect(result.any((r) => r.id == 'id-2'), isTrue);
      });
    });

    group('getReminderById', () {
      test('should return reminder when exists', () async {
        // Arrange
        final reminder = createTestReminder();
        await fakeBox.put(reminder.id, reminder);

        // Act
        final result = await dataSource.getReminderById(reminder.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, reminder.id);
        expect(result.title, reminder.title);
      });

      test('should return null when reminder does not exist', () async {
        // Act
        final result = await dataSource.getReminderById('non-existent-id');

        // Assert
        expect(result, isNull);
      });
    });

    group('createReminder', () {
      test('should save reminder and return it', () async {
        // Arrange
        final reminder = createTestReminder();

        // Act
        final result = await dataSource.createReminder(reminder);

        // Assert
        expect(result.id, reminder.id);
        expect(result.title, reminder.title);

        // Verify it's in the box
        final savedReminder = fakeBox.get(reminder.id);
        expect(savedReminder, isNotNull);
        expect(savedReminder!.id, reminder.id);
      });

      test('should overwrite existing reminder with same id', () async {
        // Arrange
        final original = createTestReminder(title: 'Original');
        final updated = createTestReminder(title: 'Updated');
        await dataSource.createReminder(original);

        // Act
        await dataSource.createReminder(updated);

        // Assert
        final result = fakeBox.get(original.id);
        expect(result!.title, 'Updated');
        expect(fakeBox.length, 1);
      });
    });

    group('updateReminder', () {
      test('should update existing reminder and return it', () async {
        // Arrange
        final original = createTestReminder(title: 'Original');
        await fakeBox.put(original.id, original);

        final updated = createTestReminder(
          id: original.id,
          title: 'Updated Title',
          isCompleted: true,
        );

        // Act
        final result = await dataSource.updateReminder(updated);

        // Assert
        expect(result.title, 'Updated Title');
        expect(result.isCompleted, isTrue);

        final savedReminder = fakeBox.get(original.id);
        expect(savedReminder!.title, 'Updated Title');
      });

      test('should create reminder if it does not exist', () async {
        // Arrange
        final reminder = createTestReminder();

        // Act
        final result = await dataSource.updateReminder(reminder);

        // Assert
        expect(result.id, reminder.id);
        expect(fakeBox.containsKey(reminder.id), isTrue);
      });
    });

    group('deleteReminder', () {
      test('should remove reminder from box', () async {
        // Arrange
        final reminder = createTestReminder();
        await fakeBox.put(reminder.id, reminder);

        // Act
        await dataSource.deleteReminder(reminder.id);

        // Assert
        expect(fakeBox.get(reminder.id), isNull);
        expect(fakeBox.isEmpty, isTrue);
      });

      test('should not throw when deleting non-existent reminder', () async {
        // Act & Assert
        expect(
          () => dataSource.deleteReminder('non-existent-id'),
          returnsNormally,
        );
      });
    });

    group('clearAllReminders', () {
      test('should remove all reminders from box', () async {
        // Arrange
        final reminder1 = createTestReminder(id: 'id-1');
        final reminder2 = createTestReminder(id: 'id-2');
        final reminder3 = createTestReminder(id: 'id-3');
        await fakeBox.put(reminder1.id, reminder1);
        await fakeBox.put(reminder2.id, reminder2);
        await fakeBox.put(reminder3.id, reminder3);

        expect(fakeBox.length, 3);

        // Act
        await dataSource.clearAllReminders();

        // Assert
        expect(fakeBox.isEmpty, isTrue);
        expect(fakeBox.length, 0);
      });

      test('should not throw when box is already empty', () async {
        // Act & Assert
        expect(() => dataSource.clearAllReminders(), returnsNormally);
      });
    });
  });
}
