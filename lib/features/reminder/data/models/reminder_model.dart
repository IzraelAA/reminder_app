import 'package:hive/hive.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';

part 'reminder_model.g.dart';

/// Data model for Reminder with Hive type adapter for persistence
/// Follows Single Responsibility - handles data serialization only
@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final int priorityIndex;

  @HiveField(6)
  final int repeatTypeIndex;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  // Location-based reminder fields (optional)
  @HiveField(9)
  final double? latitude;

  @HiveField(10)
  final double? longitude;

  @HiveField(11)
  final double? radiusInMeters;

  @HiveField(12)
  final String? locationName;

  ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.priorityIndex = 1, // medium
    this.repeatTypeIndex = 0, // none
    required this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.radiusInMeters,
    this.locationName,
  });

  /// Convert from domain entity to data model
  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dateTime: entity.dateTime,
      isCompleted: entity.isCompleted,
      priorityIndex: entity.priority.index,
      repeatTypeIndex: entity.repeatType.index,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      latitude: entity.latitude,
      longitude: entity.longitude,
      radiusInMeters: entity.radiusInMeters,
      locationName: entity.locationName,
    );
  }

  /// Convert from data model to domain entity
  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      title: title,
      description: description,
      dateTime: dateTime,
      isCompleted: isCompleted,
      priority: ReminderPriority.values[priorityIndex],
      repeatType: RepeatType.values[repeatTypeIndex],
      createdAt: createdAt,
      updatedAt: updatedAt,
      latitude: latitude,
      longitude: longitude,
      radiusInMeters: radiusInMeters,
      locationName: locationName,
    );
  }

  /// Create a copy with updated fields
  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    int? priorityIndex,
    int? repeatTypeIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    double? radiusInMeters,
    String? locationName,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      repeatTypeIndex: repeatTypeIndex ?? this.repeatTypeIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      locationName: locationName ?? this.locationName,
    );
  }
}
