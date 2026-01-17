import 'package:equatable/equatable.dart';

/// Reminder priority levels
enum ReminderPriority { low, medium, high }

/// Reminder repeat type
enum RepeatType { none, daily, weekly, monthly }

/// Domain entity for Reminder
/// This is a pure business object without any framework dependencies
class ReminderEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final bool isCompleted;
  final ReminderPriority priority;
  final RepeatType repeatType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Location-based reminder fields (optional)
  final double? latitude;
  final double? longitude;
  final double? radiusInMeters;
  final String? locationName;

  const ReminderEntity({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.priority = ReminderPriority.medium,
    this.repeatType = RepeatType.none,
    required this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.radiusInMeters,
    this.locationName,
  });

  /// Check if this is a location-based reminder
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if reminder is overdue
  bool get isOverdue => !isCompleted && dateTime.isBefore(DateTime.now());

  /// Check if reminder is upcoming (within next 24 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(hours: 24));
    return !isCompleted && dateTime.isAfter(now) && dateTime.isBefore(tomorrow);
  }

  ReminderEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    ReminderPriority? priority,
    RepeatType? repeatType,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    double? radiusInMeters,
    String? locationName,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      repeatType: repeatType ?? this.repeatType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dateTime,
    isCompleted,
    priority,
    repeatType,
    createdAt,
    updatedAt,
    latitude,
    longitude,
    radiusInMeters,
    locationName,
  ];
}
