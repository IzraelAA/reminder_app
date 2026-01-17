import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:reminder_app/features/reminder/services/notification_service.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

/// ReminderBloc handles all reminder-related business logic
/// Following Single Responsibility Principle - only orchestrates reminder operations
@injectable
class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _repository;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  ReminderBloc(this._repository, this._notificationService)
    : super(ReminderState.initial()) {
    on<ReminderLoadRequested>(_onLoadRequested);
    on<ReminderCreateRequested>(_onCreateRequested);
    on<ReminderUpdateRequested>(_onUpdateRequested);
    on<ReminderDeleteRequested>(_onDeleteRequested);
    on<ReminderToggleCompletionRequested>(_onToggleCompletionRequested);
    on<ReminderLoadUpcomingRequested>(_onLoadUpcomingRequested);
    on<ReminderLoadOverdueRequested>(_onLoadOverdueRequested);
  }

  Future<void> _onLoadRequested(
    ReminderLoadRequested event,
    Emitter<ReminderState> emit,
  ) async {
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

  Future<void> _onCreateRequested(
    ReminderCreateRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    final reminder = ReminderEntity(
      id: _uuid.v4(),
      title: event.title,
      description: event.description,
      dateTime: event.dateTime,
      priority: event.priority,
      repeatType: event.repeatType,
      createdAt: DateTime.now(),
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInMeters: event.radiusInMeters,
      locationName: event.locationName,
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
          // Log but don't fail the operation - notification scheduling is best effort
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

  Future<void> _onUpdateRequested(
    ReminderUpdateRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    final result = await _repository.updateReminder(event.reminder);

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

  Future<void> _onDeleteRequested(
    ReminderDeleteRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    // Cancel notification first
    await _notificationService.cancelNotification(event.id);

    final result = await _repository.deleteReminder(event.id);

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
              lastDeletedId: event.id,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onToggleCompletionRequested(
    ReminderToggleCompletionRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    final result = await _repository.toggleReminderCompletion(event.id);

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

  Future<void> _onLoadUpcomingRequested(
    ReminderLoadUpcomingRequested event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await _repository.getUpcomingReminders(
      withinHours: event.withinHours,
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

  Future<void> _onLoadOverdueRequested(
    ReminderLoadOverdueRequested event,
    Emitter<ReminderState> emit,
  ) async {
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
