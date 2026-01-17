import 'package:flutter_test/flutter_test.dart';
import 'package:reminder_app/core/network/failure.dart';
import 'package:reminder_app/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:reminder_app/features/reminder/data/models/reminder_model.dart';
import 'package:reminder_app/features/reminder/data/repositories/reminder_repository_impl.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';

/// Fake implementation of ReminderLocalDataSource for testing
class FakeReminderLocalDataSource implements ReminderLocalDataSource {
  final Map<String, ReminderModel> _reminders = {};
  bool shouldThrowError = false;
  String errorMessage = 'Test error';

  void reset() {
    _reminders.clear();
    shouldThrowError = false;
    errorMessage = 'Test error';
  }

  void seedReminders(List<ReminderModel> reminders) {
    for (final reminder in reminders) {
      _reminders[reminder.id] = reminder;
    }
  }

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _reminders.values.toList();
  }

  @override
  Future<ReminderModel?> getReminderById(String id) async {
    if (shouldThrowError) throw Exception(errorMessage);
    return _reminders[id];
  }

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _reminders[reminder.id] = reminder;
    return reminder;
  }

  @override
  Future<ReminderModel> updateReminder(ReminderModel reminder) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _reminders[reminder.id] = reminder;
    return reminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    if (shouldThrowError) throw Exception(errorMessage);
    _reminders.remove(id);
  }

  @override
  Future<void> clearAllReminders() async {
    if (shouldThrowError) throw Exception(errorMessage);
    _reminders.clear();
  }
}

void main() {
  late FakeReminderLocalDataSource fakeDataSource;
  late ReminderRepositoryImpl repository;

  /// Helper to create test reminder model
  ReminderModel createTestReminderModel({
    String id = 'test-id',
    String title = 'Test Reminder',
    DateTime? dateTime,
    bool isCompleted = false,
  }) {
    return ReminderModel(
      id: id,
      title: title,
      description: 'Test Description',
      dateTime: dateTime ?? DateTime(2026, 1, 20, 10, 0),
      isCompleted: isCompleted,
      priorityIndex: 1,
      repeatTypeIndex: 0,
      createdAt: DateTime(2026, 1, 16),
    );
  }

  /// Helper to create test reminder entity
  ReminderEntity createTestReminderEntity({
    String id = 'test-id',
    String title = 'Test Reminder',
    DateTime? dateTime,
    bool isCompleted = false,
  }) {
    return ReminderEntity(
      id: id,
      title: title,
      description: 'Test Description',
      dateTime: dateTime ?? DateTime(2026, 1, 20, 10, 0),
      isCompleted: isCompleted,
      priority: ReminderPriority.medium,
      repeatType: RepeatType.none,
      createdAt: DateTime(2026, 1, 16),
    );
  }

  setUp(() {
    fakeDataSource = FakeReminderLocalDataSource();
    repository = ReminderRepositoryImpl(fakeDataSource);
  });

  tearDown(() {
    fakeDataSource.reset();
  });

  group('ReminderRepositoryImpl', () {
    group('getAllReminders', () {
      test('should return Right with empty list when no reminders', () async {
        // Act
        final result = await repository.getAllReminders();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (reminders) => expect(reminders, isEmpty),
        );
      });

      test('should return Right with sorted reminders by dateTime', () async {
        // Arrange
        final reminder1 = createTestReminderModel(
          id: 'id-1',
          dateTime: DateTime(2026, 1, 22),
        );
        final reminder2 = createTestReminderModel(
          id: 'id-2',
          dateTime: DateTime(2026, 1, 20),
        );
        final reminder3 = createTestReminderModel(
          id: 'id-3',
          dateTime: DateTime(2026, 1, 21),
        );
        fakeDataSource.seedReminders([reminder1, reminder2, reminder3]);

        // Act
        final result = await repository.getAllReminders();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (
          reminders,
        ) {
          expect(reminders.length, 3);
          expect(reminders[0].id, 'id-2'); // earliest
          expect(reminders[1].id, 'id-3');
          expect(reminders[2].id, 'id-1'); // latest
        });
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;

          // Act
          final result = await repository.getAllReminders();

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to get reminders'));
          }, (reminders) => fail('Should return failure'));
        },
      );
    });

    group('getReminderById', () {
      test('should return Right with reminder when found', () async {
        // Arrange
        final reminder = createTestReminderModel(id: 'existing-id');
        fakeDataSource.seedReminders([reminder]);

        // Act
        final result = await repository.getReminderById('existing-id');

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (entity) {
          expect(entity.id, 'existing-id');
          expect(entity.title, reminder.title);
        });
      });

      test('should return Left with CacheFailure when not found', () async {
        // Act
        final result = await repository.getReminderById('non-existent-id');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Reminder not found');
        }, (reminder) => fail('Should return failure'));
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;

          // Act
          final result = await repository.getReminderById('any-id');

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to get reminder'));
          }, (reminder) => fail('Should return failure'));
        },
      );
    });

    group('createReminder', () {
      test('should return Right with created reminder', () async {
        // Arrange
        final entity = createTestReminderEntity();

        // Act
        final result = await repository.createReminder(entity);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (created) {
          expect(created.id, entity.id);
          expect(created.title, entity.title);
        });
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;
          final entity = createTestReminderEntity();

          // Act
          final result = await repository.createReminder(entity);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to create reminder'));
          }, (reminder) => fail('Should return failure'));
        },
      );
    });

    group('updateReminder', () {
      test('should return Right with updated reminder', () async {
        // Arrange
        final entity = createTestReminderEntity();

        // Act
        final result = await repository.updateReminder(entity);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (updated) {
          expect(updated.id, entity.id);
          expect(updated.updatedAt, isNotNull);
        });
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;
          final entity = createTestReminderEntity();

          // Act
          final result = await repository.updateReminder(entity);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to update reminder'));
          }, (reminder) => fail('Should return failure'));
        },
      );
    });

    group('deleteReminder', () {
      test('should return Right with void when deleted successfully', () async {
        // Arrange
        final reminder = createTestReminderModel(id: 'delete-id');
        fakeDataSource.seedReminders([reminder]);

        // Act
        final result = await repository.deleteReminder('delete-id');

        // Assert
        expect(result.isRight(), isTrue);
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;

          // Act
          final result = await repository.deleteReminder('any-id');

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to delete reminder'));
          }, (_) => fail('Should return failure'));
        },
      );
    });

    group('toggleReminderCompletion', () {
      test('should toggle from incomplete to complete', () async {
        // Arrange
        final reminder = createTestReminderModel(
          id: 'toggle-id',
          isCompleted: false,
        );
        fakeDataSource.seedReminders([reminder]);

        // Act
        final result = await repository.toggleReminderCompletion('toggle-id');

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (toggled) {
          expect(toggled.isCompleted, isTrue);
          expect(toggled.updatedAt, isNotNull);
        });
      });

      test('should toggle from complete to incomplete', () async {
        // Arrange
        final reminder = createTestReminderModel(
          id: 'toggle-id',
          isCompleted: true,
        );
        fakeDataSource.seedReminders([reminder]);

        // Act
        final result = await repository.toggleReminderCompletion('toggle-id');

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (toggled) => expect(toggled.isCompleted, isFalse),
        );
      });

      test(
        'should return Left with CacheFailure when reminder not found',
        () async {
          // Act
          final result = await repository.toggleReminderCompletion(
            'non-existent-id',
          );

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, 'Reminder not found');
          }, (reminder) => fail('Should return failure'));
        },
      );

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;

          // Act
          final result = await repository.toggleReminderCompletion('any-id');

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to toggle completion'));
          }, (reminder) => fail('Should return failure'));
        },
      );
    });

    group('getRemindersByDateRange', () {
      test(
        'should return reminders within date range sorted by dateTime',
        () async {
          // Arrange
          final reminder1 = createTestReminderModel(
            id: 'id-1',
            dateTime: DateTime(2026, 1, 15), // before range
          );
          final reminder2 = createTestReminderModel(
            id: 'id-2',
            dateTime: DateTime(2026, 1, 22), // in range
          );
          final reminder3 = createTestReminderModel(
            id: 'id-3',
            dateTime: DateTime(2026, 1, 18), // in range
          );
          final reminder4 = createTestReminderModel(
            id: 'id-4',
            dateTime: DateTime(2026, 2, 1), // after range
          );
          fakeDataSource.seedReminders([
            reminder1,
            reminder2,
            reminder3,
            reminder4,
          ]);

          final startDate = DateTime(2026, 1, 17);
          final endDate = DateTime(2026, 1, 25);

          // Act
          final result = await repository.getRemindersByDateRange(
            startDate: startDate,
            endDate: endDate,
          );

          // Assert
          expect(result.isRight(), isTrue);
          result.fold((failure) => fail('Should not return failure'), (
            reminders,
          ) {
            expect(reminders.length, 2);
            expect(reminders[0].id, 'id-3'); // earlier
            expect(reminders[1].id, 'id-2'); // later
          });
        },
      );

      test('should return empty list when no reminders in range', () async {
        // Arrange
        final reminder = createTestReminderModel(
          dateTime: DateTime(2026, 1, 10),
        );
        fakeDataSource.seedReminders([reminder]);

        // Act
        final result = await repository.getRemindersByDateRange(
          startDate: DateTime(2026, 1, 20),
          endDate: DateTime(2026, 1, 25),
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (reminders) => expect(reminders, isEmpty),
        );
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;

          // Act
          final result = await repository.getRemindersByDateRange(
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 1, 31),
          );

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<CacheFailure>()),
            (reminders) => fail('Should return failure'),
          );
        },
      );
    });

    group('getUpcomingReminders', () {
      test('should return incomplete reminders within hours range', () async {
        // Arrange - using fixed "now" simulation
        final now = DateTime.now();
        final withinRange = now.add(const Duration(hours: 12));
        final outsideRange = now.add(const Duration(hours: 30));
        final pastTime = now.subtract(const Duration(hours: 1));

        final reminder1 = createTestReminderModel(
          id: 'upcoming',
          dateTime: withinRange,
          isCompleted: false,
        );
        final reminder2 = createTestReminderModel(
          id: 'too-far',
          dateTime: outsideRange,
          isCompleted: false,
        );
        final reminder3 = createTestReminderModel(
          id: 'past',
          dateTime: pastTime,
          isCompleted: false,
        );
        final reminder4 = createTestReminderModel(
          id: 'completed',
          dateTime: withinRange,
          isCompleted: true,
        );
        fakeDataSource.seedReminders([
          reminder1,
          reminder2,
          reminder3,
          reminder4,
        ]);

        // Act
        final result = await repository.getUpcomingReminders(withinHours: 24);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (
          reminders,
        ) {
          expect(reminders.length, 1);
          expect(reminders[0].id, 'upcoming');
        });
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;

          // Act
          final result = await repository.getUpcomingReminders();

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to get upcoming'));
          }, (reminders) => fail('Should return failure'));
        },
      );
    });

    group('getOverdueReminders', () {
      test('should return incomplete past reminders', () async {
        // Arrange
        final now = DateTime.now();
        final pastTime = now.subtract(const Duration(hours: 2));
        final futureTime = now.add(const Duration(hours: 2));

        final reminder1 = createTestReminderModel(
          id: 'overdue',
          dateTime: pastTime,
          isCompleted: false,
        );
        final reminder2 = createTestReminderModel(
          id: 'future',
          dateTime: futureTime,
          isCompleted: false,
        );
        final reminder3 = createTestReminderModel(
          id: 'completed-past',
          dateTime: pastTime,
          isCompleted: true,
        );
        fakeDataSource.seedReminders([reminder1, reminder2, reminder3]);

        // Act
        final result = await repository.getOverdueReminders();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (
          reminders,
        ) {
          expect(reminders.length, 1);
          expect(reminders[0].id, 'overdue');
        });
      });

      test('should return empty list when no overdue reminders', () async {
        // Arrange
        final futureTime = DateTime.now().add(const Duration(days: 1));
        final reminder = createTestReminderModel(dateTime: futureTime);
        fakeDataSource.seedReminders([reminder]);

        // Act
        final result = await repository.getOverdueReminders();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (reminders) => expect(reminders, isEmpty),
        );
      });

      test(
        'should return Left with CacheFailure when exception occurs',
        () async {
          // Arrange
          fakeDataSource.shouldThrowError = true;

          // Act
          final result = await repository.getOverdueReminders();

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to get overdue'));
          }, (reminders) => fail('Should return failure'));
        },
      );
    });
  });
}
