part of 'add_reminder_bloc.dart';

/// State class for AddReminderBloc
final class AddReminderState extends Equatable {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ReminderPriority selectedPriority;
  final RepeatType selectedRepeatType;
  final bool hasLocation;
  final double? latitude;
  final double? longitude;
  final double radiusInMeters;
  final String? locationName;

  const AddReminderState({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPriority,
    required this.selectedRepeatType,
    required this.hasLocation,
    this.latitude,
    this.longitude,
    required this.radiusInMeters,
    this.locationName,
  });

  factory AddReminderState.initial({ReminderEntity? reminder}) {
    final defaultDateTime = DateTime.now().add(const Duration(hours: 1));

    return AddReminderState(
      selectedDate: reminder?.dateTime ?? defaultDateTime,
      selectedTime: TimeOfDay.fromDateTime(
        reminder?.dateTime ?? defaultDateTime,
      ),
      selectedPriority: reminder?.priority ?? ReminderPriority.medium,
      selectedRepeatType: reminder?.repeatType ?? RepeatType.none,
      hasLocation: reminder?.hasLocation ?? false,
      latitude: reminder?.latitude,
      longitude: reminder?.longitude,
      radiusInMeters: reminder?.radiusInMeters ?? 150,
      locationName: reminder?.locationName,
    );
  }

  /// Get the combined DateTime from selected date and time
  DateTime get combinedDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  AddReminderState copyWith({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    ReminderPriority? selectedPriority,
    RepeatType? selectedRepeatType,
    bool? hasLocation,
    double? latitude,
    double? longitude,
    double? radiusInMeters,
    String? locationName,
    bool clearLocation = false,
  }) {
    return AddReminderState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedRepeatType: selectedRepeatType ?? this.selectedRepeatType,
      hasLocation: hasLocation ?? this.hasLocation,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      locationName: clearLocation ? null : (locationName ?? this.locationName),
    );
  }

  @override
  List<Object?> get props => [
    selectedDate,
    selectedTime,
    selectedPriority,
    selectedRepeatType,
    hasLocation,
    latitude,
    longitude,
    radiusInMeters,
    locationName,
  ];
}
