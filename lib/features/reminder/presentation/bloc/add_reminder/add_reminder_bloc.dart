import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';

part 'add_reminder_event.dart';
part 'add_reminder_state.dart';

/// Bloc for managing AddReminderPage form state
/// Follows Single Responsibility Principle - only manages form state
class AddReminderBloc extends Bloc<AddReminderEvent, AddReminderState> {
  AddReminderBloc({ReminderEntity? reminder})
    : super(AddReminderState.initial(reminder: reminder)) {
    on<AddReminderDateChanged>(_onDateChanged);
    on<AddReminderTimeChanged>(_onTimeChanged);
    on<AddReminderPriorityChanged>(_onPriorityChanged);
    on<AddReminderRepeatTypeChanged>(_onRepeatTypeChanged);
    on<AddReminderLocationToggled>(_onLocationToggled);
    on<AddReminderLatitudeChanged>(_onLatitudeChanged);
    on<AddReminderLongitudeChanged>(_onLongitudeChanged);
    on<AddReminderRadiusChanged>(_onRadiusChanged);
    on<AddReminderLocationNameChanged>(_onLocationNameChanged);
  }

  void _onDateChanged(
    AddReminderDateChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onTimeChanged(
    AddReminderTimeChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(selectedTime: event.time));
  }

  void _onPriorityChanged(
    AddReminderPriorityChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(selectedPriority: event.priority));
  }

  void _onRepeatTypeChanged(
    AddReminderRepeatTypeChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(selectedRepeatType: event.repeatType));
  }

  void _onLocationToggled(
    AddReminderLocationToggled event,
    Emitter<AddReminderState> emit,
  ) {
    if (event.enabled) {
      emit(state.copyWith(hasLocation: true));
    } else {
      emit(
        state.copyWith(
          hasLocation: false,
          latitude: null,
          longitude: null,
          locationName: null,
          clearLocation: true,
        ),
      );
    }
  }

  void _onLatitudeChanged(
    AddReminderLatitudeChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(latitude: event.latitude));
  }

  void _onLongitudeChanged(
    AddReminderLongitudeChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(longitude: event.longitude));
  }

  void _onRadiusChanged(
    AddReminderRadiusChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(radiusInMeters: event.radius));
  }

  void _onLocationNameChanged(
    AddReminderLocationNameChanged event,
    Emitter<AddReminderState> emit,
  ) {
    emit(state.copyWith(locationName: event.name));
  }
}
