import 'package:dartz/dartz.dart';
import 'package:reminder_app/core/network/failure.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';

/// Abstract repository contract for Reminder operations
/// Following Dependency Inversion Principle - domain defines the interface,
/// data layer provides the implementation
abstract class ReminderRepository {
  /// Get all reminders from storage
  Future<Either<Failure, List<ReminderEntity>>> getAllReminders();

  /// Get a single reminder by ID
  Future<Either<Failure, ReminderEntity>> getReminderById(String id);

  /// Create a new reminder
  Future<Either<Failure, ReminderEntity>> createReminder(
    ReminderEntity reminder,
  );

  /// Update an existing reminder
  Future<Either<Failure, ReminderEntity>> updateReminder(
    ReminderEntity reminder,
  );

  /// Delete a reminder by ID
  Future<Either<Failure, void>> deleteReminder(String id);

  /// Mark reminder as completed
  Future<Either<Failure, ReminderEntity>> toggleReminderCompletion(String id);

  /// Get reminders by date range
  Future<Either<Failure, List<ReminderEntity>>> getRemindersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get upcoming reminders (within specified hours)
  Future<Either<Failure, List<ReminderEntity>>> getUpcomingReminders({
    int withinHours = 24,
  });

  /// Get overdue reminders
  Future<Either<Failure, List<ReminderEntity>>> getOverdueReminders();
}
