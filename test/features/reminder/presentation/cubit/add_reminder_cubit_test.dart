import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/presentation/cubit/add_reminder_cubit.dart';

void main() {
  group('AddReminderCubit', () {
    late AddReminderCubit cubit;

    setUp(() {
      cubit = AddReminderCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should have default values', () {
      expect(cubit.state.selectedPriority, ReminderPriority.medium);
      expect(cubit.state.selectedRepeatType, RepeatType.none);
      expect(cubit.state.hasLocation, isFalse);
      expect(cubit.state.radiusInMeters, 150);
      expect(cubit.state.latitude, isNull);
      expect(cubit.state.longitude, isNull);
      expect(cubit.state.locationName, isNull);
    });

    test('initial state with existing reminder should use reminder values', () {
      final existingReminder = ReminderEntity(
        id: 'test-id',
        title: 'Existing Reminder',
        description: 'Description',
        dateTime: DateTime(2026, 2, 1, 14, 30),
        priority: ReminderPriority.high,
        repeatType: RepeatType.daily,
        createdAt: DateTime(2026, 1, 16),
        latitude: 10.5,
        longitude: 20.5,
        radiusInMeters: 200,
        locationName: 'Office',
      );

      final cubitWithReminder = AddReminderCubit(reminder: existingReminder);

      expect(cubitWithReminder.state.selectedPriority, ReminderPriority.high);
      expect(cubitWithReminder.state.selectedRepeatType, RepeatType.daily);
      expect(cubitWithReminder.state.selectedDate, existingReminder.dateTime);
      expect(cubitWithReminder.state.selectedTime.hour, 14);
      expect(cubitWithReminder.state.selectedTime.minute, 30);
      expect(cubitWithReminder.state.hasLocation, isTrue);
      expect(cubitWithReminder.state.latitude, 10.5);
      expect(cubitWithReminder.state.longitude, 20.5);
      expect(cubitWithReminder.state.radiusInMeters, 200);
      expect(cubitWithReminder.state.locationName, 'Office');

      cubitWithReminder.close();
    });

    group('updateDate', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with new date when updateDate is called',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateDate(DateTime(2026, 3, 15)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedDate,
            'selectedDate',
            DateTime(2026, 3, 15),
          ),
        ],
      );
    });

    group('updateTime', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with new time when updateTime is called',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateTime(const TimeOfDay(hour: 15, minute: 45)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedTime,
            'selectedTime',
            const TimeOfDay(hour: 15, minute: 45),
          ),
        ],
      );
    });

    group('updatePriority', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with high priority when updatePriority is called',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updatePriority(ReminderPriority.high),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedPriority,
            'selectedPriority',
            ReminderPriority.high,
          ),
        ],
      );

      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with low priority when updatePriority is called',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updatePriority(ReminderPriority.low),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedPriority,
            'selectedPriority',
            ReminderPriority.low,
          ),
        ],
      );
    });

    group('updateRepeatType', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with daily repeat type',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateRepeatType(RepeatType.daily),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedRepeatType,
            'selectedRepeatType',
            RepeatType.daily,
          ),
        ],
      );

      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with weekly repeat type',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateRepeatType(RepeatType.weekly),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedRepeatType,
            'selectedRepeatType',
            RepeatType.weekly,
          ),
        ],
      );
    });

    group('toggleLocation', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with hasLocation true when toggled on',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.toggleLocation(true),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.hasLocation,
            'hasLocation',
            isTrue,
          ),
        ],
      );

      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with cleared location data when toggled off',
        build: () => AddReminderCubit(),
        seed: () => AddReminderState(
          selectedDate: DateTime.now(),
          selectedTime: const TimeOfDay(hour: 10, minute: 0),
          selectedPriority: ReminderPriority.medium,
          selectedRepeatType: RepeatType.none,
          hasLocation: true,
          latitude: 10.5,
          longitude: 20.5,
          radiusInMeters: 150,
          locationName: 'Test Location',
        ),
        act: (cubit) => cubit.toggleLocation(false),
        expect: () => [
          isA<AddReminderState>()
              .having((s) => s.hasLocation, 'hasLocation', isFalse)
              .having((s) => s.latitude, 'latitude', isNull)
              .having((s) => s.longitude, 'longitude', isNull)
              .having((s) => s.locationName, 'locationName', isNull),
        ],
      );
    });

    group('updateLatitude', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with new latitude',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateLatitude(37.7749),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.latitude,
            'latitude',
            37.7749,
          ),
        ],
      );
    });

    group('updateLongitude', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with new longitude',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateLongitude(-122.4194),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.longitude,
            'longitude',
            -122.4194,
          ),
        ],
      );
    });

    group('updateRadius', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with new radius',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateRadius(300),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.radiusInMeters,
            'radiusInMeters',
            300,
          ),
        ],
      );
    });

    group('updateLocationName', () {
      blocTest<AddReminderCubit, AddReminderState>(
        'emits state with new location name',
        build: () => AddReminderCubit(),
        act: (cubit) => cubit.updateLocationName('Home'),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.locationName,
            'locationName',
            'Home',
          ),
        ],
      );
    });

    group('combinedDateTime', () {
      test('should return combined date and time', () {
        cubit.updateDate(DateTime(2026, 3, 15));
        cubit.updateTime(const TimeOfDay(hour: 14, minute: 30));

        final combined = cubit.combinedDateTime;

        expect(combined.year, 2026);
        expect(combined.month, 3);
        expect(combined.day, 15);
        expect(combined.hour, 14);
        expect(combined.minute, 30);
      });
    });
  });
}
