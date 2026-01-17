import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:reminder_app/features/reminder/data/models/reminder_model.dart';

/// Local data source for Reminder operations using Hive
/// Single Responsibility: Handle local persistence only
abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getAllReminders();
  Future<ReminderModel?> getReminderById(String id);
  Future<ReminderModel> createReminder(ReminderModel reminder);
  Future<ReminderModel> updateReminder(ReminderModel reminder);
  Future<void> deleteReminder(String id);
  Future<void> clearAllReminders();
}

@LazySingleton(as: ReminderLocalDataSource)
class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  static const String _boxName = 'reminders_box';
  late Box<ReminderModel> _box;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReminderModelAdapter());
    }

    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<ReminderModel>(_boxName);
    } else {
      _box = Hive.box<ReminderModel>(_boxName);
    }
    _isInitialized = true;
  }

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    await _ensureInitialized();
    return _box.values.toList();
  }

  @override
  Future<ReminderModel?> getReminderById(String id) async {
    await _ensureInitialized();
    return _box.get(id);
  }

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    await _ensureInitialized();
    await _box.put(reminder.id, reminder);
    return reminder;
  }

  @override
  Future<ReminderModel> updateReminder(ReminderModel reminder) async {
    await _ensureInitialized();
    await _box.put(reminder.id, reminder);
    return reminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _ensureInitialized();
    await _box.delete(id);
  }

  @override
  Future<void> clearAllReminders() async {
    await _ensureInitialized();
    await _box.clear();
  }
}
