part of 'add_reminder_bloc.dart';

/// Base event class for AddReminderBloc
sealed class AddReminderEvent extends Equatable {
  const AddReminderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to update the selected date
final class AddReminderDateChanged extends AddReminderEvent {
  final DateTime date;

  const AddReminderDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Event to update the selected time
final class AddReminderTimeChanged extends AddReminderEvent {
  final TimeOfDay time;

  const AddReminderTimeChanged(this.time);

  @override
  List<Object?> get props => [time];
}

/// Event to update the priority
final class AddReminderPriorityChanged extends AddReminderEvent {
  final ReminderPriority priority;

  const AddReminderPriorityChanged(this.priority);

  @override
  List<Object?> get props => [priority];
}

/// Event to update the repeat type
final class AddReminderRepeatTypeChanged extends AddReminderEvent {
  final RepeatType repeatType;

  const AddReminderRepeatTypeChanged(this.repeatType);

  @override
  List<Object?> get props => [repeatType];
}

/// Event to toggle location
final class AddReminderLocationToggled extends AddReminderEvent {
  final bool enabled;

  const AddReminderLocationToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update latitude
final class AddReminderLatitudeChanged extends AddReminderEvent {
  final double? latitude;

  const AddReminderLatitudeChanged(this.latitude);

  @override
  List<Object?> get props => [latitude];
}

/// Event to update longitude
final class AddReminderLongitudeChanged extends AddReminderEvent {
  final double? longitude;

  const AddReminderLongitudeChanged(this.longitude);

  @override
  List<Object?> get props => [longitude];
}

/// Event to update radius
final class AddReminderRadiusChanged extends AddReminderEvent {
  final double radius;

  const AddReminderRadiusChanged(this.radius);

  @override
  List<Object?> get props => [radius];
}

/// Event to update location name
final class AddReminderLocationNameChanged extends AddReminderEvent {
  final String? name;

  const AddReminderLocationNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}
