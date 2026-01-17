part of 'reminder_cubit.dart';

/// Enum representing the status of reminder operations
enum ReminderStatus { initial, loading, success, failure }

/// State class for ReminderCubit
/// Using single state class with status enum for cleaner state management
final class ReminderState extends Equatable {
  final ReminderStatus status;
  final List<ReminderEntity> reminders;
  final List<ReminderEntity> upcomingReminders;
  final List<ReminderEntity> overdueReminders;
  final String? errorMessage;
  final ReminderEntity? lastCreated;
  final ReminderEntity? lastUpdated;
  final String? lastDeletedId;

  const ReminderState({
    this.status = ReminderStatus.initial,
    this.reminders = const [],
    this.upcomingReminders = const [],
    this.overdueReminders = const [],
    this.errorMessage,
    this.lastCreated,
    this.lastUpdated,
    this.lastDeletedId,
  });

  /// Initial state
  factory ReminderState.initial() => const ReminderState();

  /// Check if currently loading
  bool get isLoading => status == ReminderStatus.loading;

  /// Check if has error
  bool get hasError => status == ReminderStatus.failure;

  /// Get completed reminders
  List<ReminderEntity> get completedReminders =>
      reminders.where((r) => r.isCompleted).toList();

  /// Get pending reminders (not completed)
  List<ReminderEntity> get pendingReminders =>
      reminders.where((r) => !r.isCompleted).toList();

  /// Get reminders count
  int get totalCount => reminders.length;
  int get pendingCount => pendingReminders.length;
  int get completedCount => completedReminders.length;

  ReminderState copyWith({
    ReminderStatus? status,
    List<ReminderEntity>? reminders,
    List<ReminderEntity>? upcomingReminders,
    List<ReminderEntity>? overdueReminders,
    String? errorMessage,
    ReminderEntity? lastCreated,
    ReminderEntity? lastUpdated,
    String? lastDeletedId,
  }) {
    return ReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      upcomingReminders: upcomingReminders ?? this.upcomingReminders,
      overdueReminders: overdueReminders ?? this.overdueReminders,
      errorMessage: errorMessage,
      lastCreated: lastCreated,
      lastUpdated: lastUpdated,
      lastDeletedId: lastDeletedId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    reminders,
    upcomingReminders,
    overdueReminders,
    errorMessage,
    lastCreated,
    lastUpdated,
    lastDeletedId,
  ];
}
