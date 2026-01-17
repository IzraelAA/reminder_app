// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:flutter/material.dart' as _i5;
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart'
    as _i6;
import 'package:reminder_app/features/reminder/presentation/pages/add_reminder_page.dart'
    as _i1;
import 'package:reminder_app/features/reminder/presentation/pages/home_page.dart'
    as _i2;
import 'package:reminder_app/features/splash/presentation/pages/splash_page.dart'
    as _i3;

/// generated route for
/// [_i1.AddReminderPage]
class AddReminderRoute extends _i4.PageRouteInfo<AddReminderRouteArgs> {
  AddReminderRoute({
    _i5.Key? key,
    _i6.ReminderEntity? reminder,
    List<_i4.PageRouteInfo>? children,
  }) : super(
          AddReminderRoute.name,
          args: AddReminderRouteArgs(
            key: key,
            reminder: reminder,
          ),
          initialChildren: children,
        );

  static const String name = 'AddReminderRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddReminderRouteArgs>(
          orElse: () => const AddReminderRouteArgs());
      return _i1.AddReminderPage(
        key: args.key,
        reminder: args.reminder,
      );
    },
  );
}

class AddReminderRouteArgs {
  const AddReminderRouteArgs({
    this.key,
    this.reminder,
  });

  final _i5.Key? key;

  final _i6.ReminderEntity? reminder;

  @override
  String toString() {
    return 'AddReminderRouteArgs{key: $key, reminder: $reminder}';
  }
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.SplashPage]
class SplashRoute extends _i4.PageRouteInfo<void> {
  const SplashRoute({List<_i4.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.SplashPage();
    },
  );
}
