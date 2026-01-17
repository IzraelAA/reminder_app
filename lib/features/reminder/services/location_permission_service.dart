import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a permission request
enum LocationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

/// Service responsible for handling location permissions
/// Single Responsibility: Only handles permission requests and status checks
@lazySingleton
class LocationPermissionService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermissionResult> checkPermissionStatus() async {
    // First check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult.serviceDisabled;
    }

    // Check location permission
    final status = await Permission.location.status;

    if (status.isGranted) {
      return LocationPermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionResult.permanentlyDenied;
    } else {
      return LocationPermissionResult.denied;
    }
  }

  /// Request location permission (when in use)
  Future<LocationPermissionResult> requestLocationPermission() async {
    // First check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult.serviceDisabled;
    }

    // Request basic location permission
    final status = await Permission.location.request();

    if (status.isGranted) {
      return LocationPermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionResult.permanentlyDenied;
    } else {
      return LocationPermissionResult.denied;
    }
  }

  /// Request background location permission (required for geofencing)
  /// Note: On Android 11+, this will redirect to settings
  Future<LocationPermissionResult> requestBackgroundLocationPermission() async {
    // First ensure basic location is granted
    final basicStatus = await requestLocationPermission();
    if (basicStatus != LocationPermissionResult.granted) {
      return basicStatus;
    }

    // Request background location
    final status = await Permission.locationAlways.request();

    if (status.isGranted) {
      return LocationPermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionResult.permanentlyDenied;
    } else {
      return LocationPermissionResult.denied;
    }
  }

  /// Check if background location is granted
  Future<bool> hasBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.status;
    return status.isGranted;
  }

  /// Open app settings for user to grant permission manually
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get current device location
  Future<Position?> getCurrentLocation() async {
    try {
      final permissionResult = await checkPermissionStatus();
      if (permissionResult != LocationPermissionResult.granted) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
