import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:reminder_app/core/network/failure.dart';
import 'package:reminder_app/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:reminder_app/features/reminder/data/models/reminder_model.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/domain/repositories/reminder_repository.dart';

/// Implementation of ReminderRepository
/// Open/Closed Principle: Can be extended for remote sync without modifying existing code
@LazySingleton(as: ReminderRepository)
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource _localDataSource;

  ReminderRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<ReminderEntity>>> getAllReminders() async {
    try {
      final models = await _localDataSource.getAllReminders();
      final entities = models.map((m) => m.toEntity()).toList();
      // Sort by dateTime ascending
      entities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> getReminderById(String id) async {
    try {
      final model = await _localDataSource.getReminderById(id);
      if (model == null) {
        return Left(CacheFailure(message: 'Reminder not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> createReminder(
    ReminderEntity reminder,
  ) async {
    try {
      final model = ReminderModel.fromEntity(reminder);
      final created = await _localDataSource.createReminder(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to create reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> updateReminder(
    ReminderEntity reminder,
  ) async {
    try {
      final model = ReminderModel.fromEntity(
        reminder.copyWith(updatedAt: DateTime.now()),
      );
      final updated = await _localDataSource.updateReminder(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String id) async {
    try {
      await _localDataSource.deleteReminder(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> toggleReminderCompletion(
    String id,
  ) async {
    try {
      final model = await _localDataSource.getReminderById(id);
      if (model == null) {
        return Left(CacheFailure(message: 'Reminder not found'));
      }

      final updatedModel = model.copyWith(
        isCompleted: !model.isCompleted,
        updatedAt: DateTime.now(),
      );
      final updated = await _localDataSource.updateReminder(updatedModel);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to toggle completion: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getRemindersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await _localDataSource.getAllReminders();
      final filtered = models
          .where(
            (m) =>
                m.dateTime.isAfter(startDate) && m.dateTime.isBefore(endDate),
          )
          .map((m) => m.toEntity())
          .toList();
      filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getUpcomingReminders({
    int withinHours = 24,
  }) async {
    try {
      final now = DateTime.now();
      final future = now.add(Duration(hours: withinHours));
      final models = await _localDataSource.getAllReminders();
      final filtered = models
          .where(
            (m) =>
                !m.isCompleted &&
                m.dateTime.isAfter(now) &&
                m.dateTime.isBefore(future),
          )
          .map((m) => m.toEntity())
          .toList();
      filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return Right(filtered);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get upcoming reminders: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getOverdueReminders() async {
    try {
      final now = DateTime.now();
      final models = await _localDataSource.getAllReminders();
      final filtered = models
          .where((m) => !m.isCompleted && m.dateTime.isBefore(now))
          .map((m) => m.toEntity())
          .toList();
      filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get overdue reminders: $e'));
    }
  }
}
