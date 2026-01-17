import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reminder_app/core/network/failure.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:reminder_app/features/reminder/presentation/bloc/reminder/reminder_bloc.dart';
import 'package:reminder_app/features/reminder/services/notification_service.dart';

/// Mock for ReminderRepository
class MockReminderRepository extends Mock implements ReminderRepository {}

/// Mock for NotificationService
class MockNotificationService extends Mock implements NotificationService {}

/// Fake for ReminderEntity to be used in registerFallbackValue
class FakeReminderEntity extends Fake implements ReminderEntity {}

void main() {
  late MockReminderRepository mockRepository;
  late MockNotificationService mockNotificationService;
  late ReminderBloc bloc;

  /// Helper to create test reminder
  ReminderEntity createTestReminder({
    String id = 'test-id',
    String title = 'Test Reminder',
    bool isCompleted = false,
  }) {
    return ReminderEntity(
      id: id,
      title: title,
      description: 'Test Description',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      isCompleted: isCompleted,
      priority: ReminderPriority.medium,
      repeatType: RepeatType.none,
      createdAt: DateTime(2026, 1, 16),
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeReminderEntity());
  });

  setUp(() {
    mockRepository = MockReminderRepository();
    mockNotificationService = MockNotificationService();
    bloc = ReminderBloc(mockRepository, mockNotificationService);
  });

  tearDown(() {
    bloc.close();
  });

  group('ReminderBloc', () {
    test('initial state should be ReminderState.initial()', () {
      expect(bloc.state, ReminderState.initial());
      expect(bloc.state.status, ReminderStatus.initial);
      expect(bloc.state.reminders, isEmpty);
    });

    group('ReminderLoadRequested', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, success] with reminders when repository returns Right',
        setUp: () {
          final reminders = [
            createTestReminder(id: 'id-1'),
            createTestReminder(id: 'id-2'),
          ];
          when(
            () => mockRepository.getAllReminders(),
          ).thenAnswer((_) async => Right(reminders));
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(const ReminderLoadRequested()),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.success)
              .having((s) => s.reminders.length, 'reminders.length', 2),
        ],
        verify: (_) {
          verify(() => mockRepository.getAllReminders()).called(1);
        },
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, failure] when repository returns Left',
        setUp: () {
          when(() => mockRepository.getAllReminders()).thenAnswer(
            (_) async =>
                const Left(CacheFailure(message: 'Failed to load reminders')),
          );
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(const ReminderLoadRequested()),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Failed to load reminders',
              ),
        ],
      );
    });

    group('ReminderCreateRequested', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, success] when reminder is created successfully',
        setUp: () {
          when(
            () => mockRepository.createReminder(any()),
          ).thenAnswer((_) async => Right(createTestReminder()));
          when(
            () => mockRepository.getAllReminders(),
          ).thenAnswer((_) async => Right([createTestReminder()]));
          when(
            () => mockNotificationService.scheduleNotification(any()),
          ).thenAnswer((_) async {});
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(
          ReminderCreateRequested(
            title: 'New Reminder',
            dateTime: DateTime.now().add(const Duration(hours: 1)),
          ),
        ),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.success)
              .having((s) => s.lastCreated, 'lastCreated', isNotNull),
        ],
        verify: (_) {
          verify(() => mockRepository.createReminder(any())).called(1);
          verify(
            () => mockNotificationService.scheduleNotification(any()),
          ).called(1);
        },
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, failure] when create fails',
        setUp: () {
          when(() => mockRepository.createReminder(any())).thenAnswer(
            (_) async =>
                const Left(CacheFailure(message: 'Failed to create reminder')),
          );
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(
          ReminderCreateRequested(
            title: 'New Reminder',
            dateTime: DateTime.now(),
          ),
        ),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Failed to create reminder',
              ),
        ],
      );
    });

    group('ReminderUpdateRequested', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, success] when reminder is updated successfully',
        setUp: () {
          final reminder = createTestReminder(isCompleted: false);
          when(
            () => mockRepository.updateReminder(any()),
          ).thenAnswer((_) async => Right(reminder));
          when(
            () => mockRepository.getAllReminders(),
          ).thenAnswer((_) async => Right([reminder]));
          when(
            () => mockNotificationService.cancelNotification(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockNotificationService.scheduleNotification(any()),
          ).thenAnswer((_) async {});
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(ReminderUpdateRequested(createTestReminder())),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.success)
              .having((s) => s.lastUpdated, 'lastUpdated', isNotNull),
        ],
        verify: (_) {
          verify(() => mockRepository.updateReminder(any())).called(1);
          verify(
            () => mockNotificationService.cancelNotification(any()),
          ).called(1);
          verify(
            () => mockNotificationService.scheduleNotification(any()),
          ).called(1);
        },
      );

      blocTest<ReminderBloc, ReminderState>(
        'does not reschedule notification when reminder is completed',
        setUp: () {
          final completedReminder = createTestReminder(isCompleted: true);
          when(
            () => mockRepository.updateReminder(any()),
          ).thenAnswer((_) async => Right(completedReminder));
          when(
            () => mockRepository.getAllReminders(),
          ).thenAnswer((_) async => Right([completedReminder]));
          when(
            () => mockNotificationService.cancelNotification(any()),
          ).thenAnswer((_) async {});
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(
          ReminderUpdateRequested(createTestReminder(isCompleted: true)),
        ),
        verify: (_) {
          verify(
            () => mockNotificationService.cancelNotification(any()),
          ).called(1);
          verifyNever(
            () => mockNotificationService.scheduleNotification(any()),
          );
        },
      );
    });

    group('ReminderDeleteRequested', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, success] when reminder is deleted successfully',
        setUp: () {
          when(
            () => mockRepository.deleteReminder(any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockRepository.getAllReminders(),
          ).thenAnswer((_) async => const Right([]));
          when(
            () => mockNotificationService.cancelNotification(any()),
          ).thenAnswer((_) async {});
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(const ReminderDeleteRequested('test-id')),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.success)
              .having((s) => s.lastDeletedId, 'lastDeletedId', 'test-id'),
        ],
        verify: (_) {
          verify(
            () => mockNotificationService.cancelNotification('test-id'),
          ).called(1);
          verify(() => mockRepository.deleteReminder('test-id')).called(1);
        },
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, failure] when delete fails',
        setUp: () {
          when(() => mockRepository.deleteReminder(any())).thenAnswer(
            (_) async =>
                const Left(CacheFailure(message: 'Failed to delete reminder')),
          );
          when(
            () => mockNotificationService.cancelNotification(any()),
          ).thenAnswer((_) async {});
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(const ReminderDeleteRequested('test-id')),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.failure,
          ),
        ],
      );
    });

    group('ReminderToggleCompletionRequested', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, success] and cancels notification when toggled to complete',
        setUp: () {
          final completedReminder = createTestReminder(isCompleted: true);
          when(
            () => mockRepository.toggleReminderCompletion(any()),
          ).thenAnswer((_) async => Right(completedReminder));
          when(
            () => mockRepository.getAllReminders(),
          ).thenAnswer((_) async => Right([completedReminder]));
          when(
            () => mockNotificationService.cancelNotification(any()),
          ).thenAnswer((_) async {});
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) =>
            bloc.add(const ReminderToggleCompletionRequested('test-id')),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => mockNotificationService.cancelNotification('test-id'),
          ).called(1);
          verifyNever(
            () => mockNotificationService.scheduleNotification(any()),
          );
        },
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits [loading, success] and schedules notification when toggled to incomplete',
        setUp: () {
          final incompleteReminder = createTestReminder(isCompleted: false);
          when(
            () => mockRepository.toggleReminderCompletion(any()),
          ).thenAnswer((_) async => Right(incompleteReminder));
          when(
            () => mockRepository.getAllReminders(),
          ).thenAnswer((_) async => Right([incompleteReminder]));
          when(
            () => mockNotificationService.scheduleNotification(any()),
          ).thenAnswer((_) async {});
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) =>
            bloc.add(const ReminderToggleCompletionRequested('test-id')),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.loading,
          ),
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => mockNotificationService.scheduleNotification(any()),
          ).called(1);
        },
      );
    });

    group('ReminderLoadUpcomingRequested', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [success] with upcoming reminders',
        setUp: () {
          final reminders = [createTestReminder()];
          when(
            () => mockRepository.getUpcomingReminders(
              withinHours: any(named: 'withinHours'),
            ),
          ).thenAnswer((_) async => Right(reminders));
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) =>
            bloc.add(const ReminderLoadUpcomingRequested(withinHours: 24)),
        expect: () => [
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.success)
              .having(
                (s) => s.upcomingReminders.length,
                'upcomingReminders.length',
                1,
              ),
        ],
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits [failure] when loading fails',
        setUp: () {
          when(
            () => mockRepository.getUpcomingReminders(
              withinHours: any(named: 'withinHours'),
            ),
          ).thenAnswer(
            (_) async =>
                const Left(CacheFailure(message: 'Failed to load upcoming')),
          );
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(const ReminderLoadUpcomingRequested()),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.failure,
          ),
        ],
      );
    });

    group('ReminderLoadOverdueRequested', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [success] with overdue reminders',
        setUp: () {
          final reminders = [createTestReminder()];
          when(
            () => mockRepository.getOverdueReminders(),
          ).thenAnswer((_) async => Right(reminders));
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(const ReminderLoadOverdueRequested()),
        expect: () => [
          isA<ReminderState>()
              .having((s) => s.status, 'status', ReminderStatus.success)
              .having(
                (s) => s.overdueReminders.length,
                'overdueReminders.length',
                1,
              ),
        ],
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits [failure] when loading fails',
        setUp: () {
          when(() => mockRepository.getOverdueReminders()).thenAnswer(
            (_) async =>
                const Left(CacheFailure(message: 'Failed to load overdue')),
          );
        },
        build: () => ReminderBloc(mockRepository, mockNotificationService),
        act: (bloc) => bloc.add(const ReminderLoadOverdueRequested()),
        expect: () => [
          isA<ReminderState>().having(
            (s) => s.status,
            'status',
            ReminderStatus.failure,
          ),
        ],
      );
    });

    group('ReminderState getters', () {
      test('isLoading returns true when status is loading', () {
        final state = const ReminderState(status: ReminderStatus.loading);
        expect(state.isLoading, isTrue);
      });

      test('hasError returns true when status is failure', () {
        final state = const ReminderState(status: ReminderStatus.failure);
        expect(state.hasError, isTrue);
      });

      test('completedReminders returns only completed reminders', () {
        final state = ReminderState(
          reminders: [
            createTestReminder(id: 'completed', isCompleted: true),
            createTestReminder(id: 'pending', isCompleted: false),
          ],
        );
        expect(state.completedReminders.length, 1);
        expect(state.completedReminders.first.id, 'completed');
      });

      test('pendingReminders returns only non-completed reminders', () {
        final state = ReminderState(
          reminders: [
            createTestReminder(id: 'completed', isCompleted: true),
            createTestReminder(id: 'pending', isCompleted: false),
          ],
        );
        expect(state.pendingReminders.length, 1);
        expect(state.pendingReminders.first.id, 'pending');
      });

      test('count getters return correct values', () {
        final state = ReminderState(
          reminders: [
            createTestReminder(id: 'completed-1', isCompleted: true),
            createTestReminder(id: 'completed-2', isCompleted: true),
            createTestReminder(id: 'pending', isCompleted: false),
          ],
        );
        expect(state.totalCount, 3);
        expect(state.completedCount, 2);
        expect(state.pendingCount, 1);
      });
    });
  });
}
