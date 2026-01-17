import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_foreground_service/constants/geofence_event_type.dart';
import 'package:geofence_foreground_service/geofence_foreground_service.dart';
import 'package:geofence_foreground_service/models/zone.dart';
import 'package:injectable/injectable.dart';
import 'package:latlng/latlng.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';

/// Service responsible for managing location-based reminders using geofencing
/// Single Responsibility: Only handles geofence registration and callbacks
@lazySingleton
class LocationReminderService {
  bool _isInitialized = false;

  /// Check if geofencing service is running
  bool get isRunning => _isInitialized;

  /// Initialize the geofencing service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final success = await GeofenceForegroundService().startGeofencingService(
        contentTitle: 'Location Reminder Active',
        contentText: 'Monitoring your reminder locations',
        notificationChannelId: 'location_reminder_channel',
        serviceId: 1001,
        callbackDispatcher: _handleGeofenceTrigger,
      );

      if (success) {
        // Set up the trigger handler
        GeofenceForegroundService().handleTrigger(
          backgroundTriggerHandler: _backgroundTriggerHandler,
        );
      }

      _isInitialized = success;
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Add a location-based reminder geofence
  /// Returns true if geofence was added successfully
  Future<bool> addLocationReminder(ReminderEntity reminder) async {
    if (!reminder.hasLocation) return false;
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      final zone = Zone(
        id: reminder.id,
        radius: reminder.radiusInMeters ?? 150.0,
        coordinates: [LatLng.degree(reminder.latitude!, reminder.longitude!)],
        triggers: const [GeofenceEventType.enter],
      );

      return await GeofenceForegroundService().addGeofenceZone(zone: zone);
    } catch (e) {
      return false;
    }
  }

  /// Remove a location reminder geofence
  Future<bool> removeLocationReminder(String reminderId) async {
    if (!_isInitialized) return false;

    try {
      return await GeofenceForegroundService().removeGeofenceZone(
        zoneId: reminderId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Remove all geofences
  Future<bool> removeAllGeofences() async {
    if (!_isInitialized) return false;

    try {
      return await GeofenceForegroundService().removeAllGeoFences();
    } catch (e) {
      return false;
    }
  }

  /// Stop the geofencing service
  Future<bool> stopService() async {
    if (!_isInitialized) return true;

    try {
      final success = await GeofenceForegroundService().stopGeofencingService();
      if (success) _isInitialized = false;
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Check if service is currently running
  Future<bool> checkServiceRunning() async {
    return await GeofenceForegroundService().isForegroundServiceRunning();
  }
}

/// Background trigger handler - called when geofence event occurs
Future<bool> _backgroundTriggerHandler(
  String zoneId,
  GeofenceEventType triggerType,
) async {
  // Only handle ENTER events for triggering notifications
  if (triggerType != GeofenceEventType.enter) return true;

  try {
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Initialize notifications plugin for background
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await notificationsPlugin.initialize(initSettings);

    // Show the notification
    await notificationsPlugin.show(
      zoneId.hashCode,
      '📍 Location Reminder',
      'You have arrived at your reminder location!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'location_reminder_channel',
          'Location Reminders',
          channelDescription: 'Notifications for location-based reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: zoneId,
    );
    return true;
  } catch (e) {
    return false;
  }
}

/// Top-level callback dispatcher (required by geofence_foreground_service)
@pragma('vm:entry-point')
void _handleGeofenceTrigger() {
  // This function is called when the service starts in the background
  // The actual handling is done by _backgroundTriggerHandler
}
