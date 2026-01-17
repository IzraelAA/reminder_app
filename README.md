# Reminder App

A modern Flutter reminder application with time-based and location-based reminders.

## Screenshots

<p align="center">
  <img src="assets/Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 12.30.55.png" width="200" alt="Home Screen"/>
  <img src="assets/Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 12.31.14.png" width="200" alt="Add Reminder"/>
  <img src="assets/Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 12.31.24.png" width="200" alt="Priority Selection"/>
  <img src="assets/Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 12.31.33.png" width="200" alt="Repeat Options"/>
  <img src="assets/Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 12.31.41.png" width="200" alt="Location Picker"/>
</p>

## Features

- ✅ Create, edit, and delete reminders
- ✅ Time-based notifications
- ✅ Priority levels (Low, Medium, High)
- ✅ Repeat options (None, Daily, Weekly, Monthly)
- ✅ Location-based reminders (Optional)

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Architecture

This project follows **Clean Architecture** with:
- **Domain Layer**: Entities, Repositories (interfaces)
- **Data Layer**: Models, Data Sources, Repository implementations
- **Presentation Layer**: BLoC pattern, Pages, Widgets

## Location-Based Reminders (Optional Feature)

This app supports triggering reminders when you arrive at specific locations. This feature uses geofencing and requires background location permissions.

### Requirements

- Location permission: "Allow all the time" (background access)
- Minimum radius: 100-150 meters for optimal accuracy
- Active network connection for notifications

---

## ⚠️ Platform Limitations

### Android

| Aspect | Limitation |
|--------|------------|
| **Max Geofences** | 100 per device user |
| **Minimum Radius** | 100-150 meters (recommended for accuracy) |
| **Background Updates** | Events processed every ~2-3 minutes (Android 8.0+) |
| **Permissions** | Requires `ACCESS_FINE_LOCATION` + `ACCESS_BACKGROUND_LOCATION` |
| **Android 11+** | User must manually select "Allow all the time" in Settings |
| **App Termination** | App will NOT auto-restart on geofence events |
| **Network Dependency** | Requires Wi-Fi/Mobile data + Google Location Accuracy enabled |

### iOS

| Aspect | Limitation |
|--------|------------|
| **Max Geofences** | 20 concurrent regions |
| **Update Frequency** | Triggers when device moves ≥500m, max once per 5 minutes |
| **Permissions** | Requires "Always Allow" location permission |
| **Geofence Shape** | Circular regions only (no polygon support) |
| **Accuracy** | 5-50 meters in real-world conditions |
| **App Termination** | iOS WILL restart app on geofence events ✅ |
| **Network Dependency** | Push notifications require active network |

### General Considerations

- Battery consumption increases with geofencing enabled
- Indoor accuracy may be reduced (relies on Wi-Fi positioning)
- Dense urban areas may affect accuracy
- User may revoke location permissions at any time
- Time-based reminders are always available as fallback

---

## Dependencies

### Core
- `flutter_bloc` - State management
- `get_it` + `injectable` - Dependency injection
- `hive` + `hive_flutter` - Local storage
- `auto_route` - Navigation

### Notifications
- `flutter_local_notifications` - Local notifications
- `timezone` - Timezone support

### Location (Optional Feature)
- `geofence_foreground_service` - Geofencing
- `geolocator` - Location services
- `permission_handler` - Permission handling

## Testing

Run all tests:
```bash
flutter test
```

Run specific test files:
```bash
# Data layer tests
flutter test test/features/reminder/data/

# Bloc tests
flutter test test/features/reminder/presentation/bloc/
```

### Test Coverage

| Layer | Component | Tests |
|-------|-----------|-------|
| Data | `ReminderLocalDataSource` | 12 tests |
| Data | `ReminderRepositoryImpl` | 24 tests |
| Presentation | `AddReminderBloc` | 14 tests |
| Presentation | `ReminderBloc` | 21 tests |

### Testing Libraries
- `bloc_test` - Cubit/BLoC state testing
- `mocktail` - Mocking dependencies

## License

MIT License
