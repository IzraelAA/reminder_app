import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';

part 'add_reminder_state.dart';

/// Cubit for managing AddReminderPage form state
/// Follows Single Responsibility Principle - only manages form state
class AddReminderCubit extends Cubit<AddReminderState> {
  AddReminderCubit({ReminderEntity? reminder})
    : super(AddReminderState.initial(reminder: reminder));

  void updateDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void updateTime(TimeOfDay time) {
    emit(state.copyWith(selectedTime: time));
  }

  void updatePriority(ReminderPriority priority) {
    emit(state.copyWith(selectedPriority: priority));
  }

  void updateRepeatType(RepeatType repeatType) {
    emit(state.copyWith(selectedRepeatType: repeatType));
  }

  void toggleLocation(bool enabled) {
    if (enabled) {
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

  void updateLatitude(double? latitude) {
    emit(state.copyWith(latitude: latitude));
  }

  void updateLongitude(double? longitude) {
    emit(state.copyWith(longitude: longitude));
  }

  void updateRadius(double radius) {
    emit(state.copyWith(radiusInMeters: radius));
  }

  void updateLocationName(String? name) {
    emit(state.copyWith(locationName: name));
  }

  /// Get the combined DateTime from selected date and time
  DateTime get combinedDateTime => DateTime(
    state.selectedDate.year,
    state.selectedDate.month,
    state.selectedDate.day,
    state.selectedTime.hour,
    state.selectedTime.minute,
  );
}
