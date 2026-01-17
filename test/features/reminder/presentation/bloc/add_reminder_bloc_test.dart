import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/presentation/bloc/add_reminder/add_reminder_bloc.dart';

void main() {
  group('AddReminderBloc', () {
    late AddReminderBloc bloc;

    setUp(() {
      bloc = AddReminderBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should have default values', () {
      expect(bloc.state.selectedPriority, ReminderPriority.medium);
      expect(bloc.state.selectedRepeatType, RepeatType.none);
      expect(bloc.state.hasLocation, isFalse);
      expect(bloc.state.radiusInMeters, 150);
      expect(bloc.state.latitude, isNull);
      expect(bloc.state.longitude, isNull);
      expect(bloc.state.locationName, isNull);
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

      final blocWithReminder = AddReminderBloc(reminder: existingReminder);

      expect(blocWithReminder.state.selectedPriority, ReminderPriority.high);
      expect(blocWithReminder.state.selectedRepeatType, RepeatType.daily);
      expect(blocWithReminder.state.selectedDate, existingReminder.dateTime);
      expect(blocWithReminder.state.selectedTime.hour, 14);
      expect(blocWithReminder.state.selectedTime.minute, 30);
      expect(blocWithReminder.state.hasLocation, isTrue);
      expect(blocWithReminder.state.latitude, 10.5);
      expect(blocWithReminder.state.longitude, 20.5);
      expect(blocWithReminder.state.radiusInMeters, 200);
      expect(blocWithReminder.state.locationName, 'Office');

      blocWithReminder.close();
    });

    group('AddReminderDateChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with new date when AddReminderDateChanged is added',
        build: () => AddReminderBloc(),
        act: (bloc) => bloc.add(AddReminderDateChanged(DateTime(2026, 3, 15))),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedDate,
            'selectedDate',
            DateTime(2026, 3, 15),
          ),
        ],
      );
    });

    group('AddReminderTimeChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with new time when AddReminderTimeChanged is added',
        build: () => AddReminderBloc(),
        act: (bloc) => bloc.add(
          const AddReminderTimeChanged(TimeOfDay(hour: 15, minute: 45)),
        ),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedTime,
            'selectedTime',
            const TimeOfDay(hour: 15, minute: 45),
          ),
        ],
      );
    });

    group('AddReminderPriorityChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with high priority when AddReminderPriorityChanged is added',
        build: () => AddReminderBloc(),
        act: (bloc) =>
            bloc.add(const AddReminderPriorityChanged(ReminderPriority.high)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedPriority,
            'selectedPriority',
            ReminderPriority.high,
          ),
        ],
      );

      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with low priority when AddReminderPriorityChanged is added',
        build: () => AddReminderBloc(),
        act: (bloc) =>
            bloc.add(const AddReminderPriorityChanged(ReminderPriority.low)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedPriority,
            'selectedPriority',
            ReminderPriority.low,
          ),
        ],
      );
    });

    group('AddReminderRepeatTypeChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with daily repeat type',
        build: () => AddReminderBloc(),
        act: (bloc) =>
            bloc.add(const AddReminderRepeatTypeChanged(RepeatType.daily)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedRepeatType,
            'selectedRepeatType',
            RepeatType.daily,
          ),
        ],
      );

      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with weekly repeat type',
        build: () => AddReminderBloc(),
        act: (bloc) =>
            bloc.add(const AddReminderRepeatTypeChanged(RepeatType.weekly)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.selectedRepeatType,
            'selectedRepeatType',
            RepeatType.weekly,
          ),
        ],
      );
    });

    group('AddReminderLocationToggled', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with hasLocation true when toggled on',
        build: () => AddReminderBloc(),
        act: (bloc) => bloc.add(const AddReminderLocationToggled(true)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.hasLocation,
            'hasLocation',
            isTrue,
          ),
        ],
      );

      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with cleared location data when toggled off',
        build: () => AddReminderBloc(),
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
        act: (bloc) => bloc.add(const AddReminderLocationToggled(false)),
        expect: () => [
          isA<AddReminderState>()
              .having((s) => s.hasLocation, 'hasLocation', isFalse)
              .having((s) => s.latitude, 'latitude', isNull)
              .having((s) => s.longitude, 'longitude', isNull)
              .having((s) => s.locationName, 'locationName', isNull),
        ],
      );
    });

    group('AddReminderLatitudeChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with new latitude',
        build: () => AddReminderBloc(),
        act: (bloc) => bloc.add(const AddReminderLatitudeChanged(37.7749)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.latitude,
            'latitude',
            37.7749,
          ),
        ],
      );
    });

    group('AddReminderLongitudeChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with new longitude',
        build: () => AddReminderBloc(),
        act: (bloc) => bloc.add(const AddReminderLongitudeChanged(-122.4194)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.longitude,
            'longitude',
            -122.4194,
          ),
        ],
      );
    });

    group('AddReminderRadiusChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with new radius',
        build: () => AddReminderBloc(),
        act: (bloc) => bloc.add(const AddReminderRadiusChanged(300)),
        expect: () => [
          isA<AddReminderState>().having(
            (s) => s.radiusInMeters,
            'radiusInMeters',
            300,
          ),
        ],
      );
    });

    group('AddReminderLocationNameChanged', () {
      blocTest<AddReminderBloc, AddReminderState>(
        'emits state with new location name',
        build: () => AddReminderBloc(),
        act: (bloc) => bloc.add(const AddReminderLocationNameChanged('Home')),
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
        bloc.add(AddReminderDateChanged(DateTime(2026, 3, 15)));
        bloc.add(const AddReminderTimeChanged(TimeOfDay(hour: 14, minute: 30)));

        // Wait for events to be processed
        Future.delayed(const Duration(milliseconds: 100), () {
          final combined = bloc.state.combinedDateTime;

          expect(combined.year, 2026);
          expect(combined.month, 3);
          expect(combined.day, 15);
          expect(combined.hour, 14);
          expect(combined.minute, 30);
        });
      });
    });
  });
}
