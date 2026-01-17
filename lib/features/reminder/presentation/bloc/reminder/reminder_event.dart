part of 'reminder_bloc.dart';

/// Base event class for ReminderBloc
sealed class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all reminders
final class ReminderLoadRequested extends ReminderEvent {
  const ReminderLoadRequested();
}

/// Event to create a new reminder
final class ReminderCreateRequested extends ReminderEvent {
  final String title;
  final String? description;
  final DateTime dateTime;
  final ReminderPriority priority;
  final RepeatType repeatType;
  final double? latitude;
  final double? longitude;
  final double? radiusInMeters;
  final String? locationName;

  const ReminderCreateRequested({
    required this.title,
    this.description,
    required this.dateTime,
    this.priority = ReminderPriority.medium,
    this.repeatType = RepeatType.none,
    this.latitude,
    this.longitude,
    this.radiusInMeters,
    this.locationName,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    dateTime,
    priority,
    repeatType,
    latitude,
    longitude,
    radiusInMeters,
    locationName,
  ];
}

/// Event to update an existing reminder
final class ReminderUpdateRequested extends ReminderEvent {
  final ReminderEntity reminder;

  const ReminderUpdateRequested(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

/// Event to delete a reminder
final class ReminderDeleteRequested extends ReminderEvent {
  final String id;

  const ReminderDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to toggle reminder completion status
final class ReminderToggleCompletionRequested extends ReminderEvent {
  final String id;

  const ReminderToggleCompletionRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to load upcoming reminders
final class ReminderLoadUpcomingRequested extends ReminderEvent {
  final int withinHours;

  const ReminderLoadUpcomingRequested({this.withinHours = 24});

  @override
  List<Object?> get props => [withinHours];
}

/// Event to load overdue reminders
final class ReminderLoadOverdueRequested extends ReminderEvent {
  const ReminderLoadOverdueRequested();
}
