import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:reminder_app/features/reminder/services/notification_service.dart';

part 'reminder_state.dart';

/// ReminderCubit handles all reminder-related business logic
/// Following Single Responsibility Principle - only orchestrates reminder operations
@injectable
class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository _repository;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  ReminderCubit(this._repository, this._notificationService)
    : super(ReminderState.initial());

  Future<void> loadReminders() async {
    emit(state.copyWith(status: ReminderStatus.loading));

    final result = await _repository.getAllReminders();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (reminders) => emit(
        state.copyWith(status: ReminderStatus.success, reminders: reminders),
      ),
    );
  }

  Future<void> createReminder({
    required String title,
    String? description,
    required DateTime dateTime,
    ReminderPriority priority = ReminderPriority.medium,
    RepeatType repeatType = RepeatType.none,
    double? latitude,
    double? longitude,
    double? radiusInMeters,
    String? locationName,
  }) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    final reminder = ReminderEntity(
      id: _uuid.v4(),
      title: title,
      description: description,
      dateTime: dateTime,
      priority: priority,
      repeatType: repeatType,
      createdAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      radiusInMeters: radiusInMeters,
      locationName: locationName,
    );

    final result = await _repository.createReminder(reminder);

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (created) async {
        // Schedule notification
        try {
          await _notificationService.scheduleNotification(created);
        } catch (e) {
          // Log but don't fail the operation
          print('Failed to schedule notification: $e');
        }

        // Refresh the list
        final allResult = await _repository.getAllReminders();
        allResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ReminderStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (reminders) => emit(
            state.copyWith(
              status: ReminderStatus.success,
              reminders: reminders,
              lastCreated: created,
            ),
          ),
        );
      },
    );
  }

  Future<void> updateReminder(ReminderEntity reminder) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    final result = await _repository.updateReminder(reminder);

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (updated) async {
        // Cancel old and schedule new notification
        await _notificationService.cancelNotification(updated.id);
        if (!updated.isCompleted) {
          await _notificationService.scheduleNotification(updated);
        }

        // Refresh the list
        final allResult = await _repository.getAllReminders();
        allResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ReminderStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (reminders) => emit(
            state.copyWith(
              status: ReminderStatus.success,
              reminders: reminders,
              lastUpdated: updated,
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteReminder(String id) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    // Cancel notification first
    await _notificationService.cancelNotification(id);

    final result = await _repository.deleteReminder(id);

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        // Refresh the list
        final allResult = await _repository.getAllReminders();
        allResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ReminderStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (reminders) => emit(
            state.copyWith(
              status: ReminderStatus.success,
              reminders: reminders,
              lastDeletedId: id,
            ),
          ),
        );
      },
    );
  }

  Future<void> toggleReminderCompletion(String id) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    final result = await _repository.toggleReminderCompletion(id);

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (updated) async {
        // Cancel or reschedule notification based on completion status
        if (updated.isCompleted) {
          await _notificationService.cancelNotification(updated.id);
        } else {
          await _notificationService.scheduleNotification(updated);
        }

        // Refresh the list
        final allResult = await _repository.getAllReminders();
        allResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ReminderStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (reminders) => emit(
            state.copyWith(
              status: ReminderStatus.success,
              reminders: reminders,
              lastUpdated: updated,
            ),
          ),
        );
      },
    );
  }

  Future<void> loadUpcomingReminders({int withinHours = 24}) async {
    final result = await _repository.getUpcomingReminders(
      withinHours: withinHours,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (reminders) => emit(
        state.copyWith(
          status: ReminderStatus.success,
          upcomingReminders: reminders,
        ),
      ),
    );
  }

  Future<void> loadOverdueReminders() async {
    final result = await _repository.getOverdueReminders();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (reminders) => emit(
        state.copyWith(
          status: ReminderStatus.success,
          overdueReminders: reminders,
        ),
      ),
    );
  }
}
