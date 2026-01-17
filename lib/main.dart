import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_app/app/app.dart';
import 'package:reminder_app/core/di/injection.dart';
import 'package:reminder_app/core/state_management/cubit_observer.dart';
import 'package:reminder_app/features/reminder/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize dependencies
  await configureDependencies();

  // Initialize notification service (also requests permissions)
  await getIt<NotificationService>().initialize();

  // Set up Bloc observer for debugging
  Bloc.observer = AppBlocObserver();

  runApp(App());
}
