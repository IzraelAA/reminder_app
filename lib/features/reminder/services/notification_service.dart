import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';

/// Service responsible for managing local notifications
/// Single Responsibility: Only handles notification scheduling and cancellation
@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;
  bool _isRequestingPermission = false;

  NotificationService()
    : _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Get device timezone and set it as local
    // Use try-catch as flutter_timezone may fail on hot reload
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('NotificationService: Timezone set to $timeZoneName');
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      debugPrint('NotificationService: Failed to get timezone, using UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings - these flags automatically request permission on iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel for Android 8+
    await _createNotificationChannel();

    _isInitialized = true;
    debugPrint('NotificationService: Initialized successfully');

    // Request Android permissions after initialization
    await requestPermissions();
  }

  /// Create notification channel for Android 8+
  Future<void> _createNotificationChannel() async {
    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      const channel = AndroidNotificationChannel(
        'reminder_channel',
        'Reminders',
        description: 'Notifications for reminders',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await android.createNotificationChannel(channel);
      debugPrint('NotificationService: Notification channel created');
    }
  }

  /// Handle notification tap
  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap - navigate to reminder detail
    // This can be expanded to deep link to specific reminder
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation based on payload (reminder ID)
    }
  }

  /// Request notification permissions
  /// Guards against concurrent permission requests
  Future<bool> requestPermissions() async {
    // Prevent concurrent permission requests
    if (_isRequestingPermission) return true;

    _isRequestingPermission = true;
    try {
      final android = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (android != null) {
        // Request notification permission (Android 13+)
        final notificationGranted = await android
            .requestNotificationsPermission();

        // Note: We don't request exact alarm permission here as it redirects to Settings
        // Instead, we check and fallback in scheduleNotification() method
        return notificationGranted ?? false;
      }

      final ios = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } finally {
      _isRequestingPermission = false;
    }
  }

  /// Schedule a notification for a reminder
  Future<void> scheduleNotification(ReminderEntity reminder) async {
    if (!_isInitialized) await initialize();

    // Don't schedule if reminder time is in the past
    if (reminder.dateTime.isBefore(DateTime.now())) {
      debugPrint(
        'NotificationService: Skipping past reminder: ${reminder.title}',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Notifications for reminders',
      importance: _getImportance(reminder.priority),
      priority: _getPriority(reminder.priority),
      ticker: 'Reminder',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate a unique notification ID from reminder ID
    final notificationId = reminder.id.hashCode;

    // Check if exact alarms are permitted on Android
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;

    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      // Check if exact alarms are permitted (Android 12+)
      // We don't request permission here to avoid redirecting to Settings
      // Inexact mode still works, notifications might be delayed by a few minutes
      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact != true) {
        // Fall back to inexact scheduling if exact alarms are not permitted
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        debugPrint(
          'NotificationService: Using inexact mode (exact alarms not permitted)',
        );
      }
    }

    final scheduledTime = tz.TZDateTime.from(reminder.dateTime, tz.local);
    debugPrint(
      'NotificationService: Scheduling "${reminder.title}" for $scheduledTime (mode: $scheduleMode)',
    );

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      reminder.title,
      reminder.description ?? 'You have a reminder',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: scheduleMode,
      payload: reminder.id,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('NotificationService: Notification scheduled successfully');
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(String reminderId) async {
    if (!_isInitialized) await initialize();

    final notificationId = reminderId.hashCode;
    await _notificationsPlugin.cancel(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    if (!_isInitialized) await initialize();
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    return pending.length;
  }

  /// Map priority to Android importance
  Importance _getImportance(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.high:
        return Importance.high;
      case ReminderPriority.medium:
        return Importance.defaultImportance;
      case ReminderPriority.low:
        return Importance.low;
    }
  }

  /// Map priority to Android priority
  Priority _getPriority(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.high:
        return Priority.high;
      case ReminderPriority.medium:
        return Priority.defaultPriority;
      case ReminderPriority.low:
        return Priority.low;
    }
  }
}
