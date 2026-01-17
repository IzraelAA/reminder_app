import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_app/app/app_theme.dart';
import 'package:reminder_app/core/di/injection.dart';
import 'package:reminder_app/core/route/app_router.dart';
import 'package:reminder_app/features/reminder/presentation/cubit/reminder_cubit.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReminderCubit>(
          create: (context) => getIt<ReminderCubit>()..loadReminders(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Reminder App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
