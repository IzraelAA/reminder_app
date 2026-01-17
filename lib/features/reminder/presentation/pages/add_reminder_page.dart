import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/presentation/bloc/add_reminder/add_reminder_bloc.dart';
import 'package:reminder_app/features/reminder/presentation/bloc/reminder/reminder_bloc.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/location_picker_widget.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/priority_selector_widget.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/reminder_description_field.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/reminder_header_widget.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/reminder_title_field.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/repeat_selector_widget.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/submit_button_widget.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/time_selector_widget.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

@RoutePage()
class AddReminderPage extends StatefulWidget {
  final ReminderEntity? reminder;

  const AddReminderPage({super.key, this.reminder});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.reminder?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.reminder?.description ?? '',
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddReminderBloc(reminder: widget.reminder),
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                ReminderHeaderWidget(isEditing: isEditing),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: BlocBuilder<AddReminderBloc, AddReminderState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TimeSelectorWidget(
                                selectedDate: state.selectedDate,
                                selectedTime: state.selectedTime,
                                onTimeTap: () => _showTimePicker(context),
                                onDateTap: () => _showDatePicker(context),
                              ),
                              const SizedBox(height: 24),
                              ReminderTitleField(controller: _titleController),
                              const SizedBox(height: 16),
                              ReminderDescriptionField(
                                controller: _descriptionController,
                              ),
                              const SizedBox(height: 24),
                              PrioritySelectorWidget(
                                selectedPriority: state.selectedPriority,
                                onPriorityChanged: (priority) {
                                  context.read<AddReminderBloc>().add(
                                    AddReminderPriorityChanged(priority),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              RepeatSelectorWidget(
                                selectedRepeatType: state.selectedRepeatType,
                                onRepeatTypeChanged: (repeatType) {
                                  context.read<AddReminderBloc>().add(
                                    AddReminderRepeatTypeChanged(repeatType),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              LocationPickerWidget(
                                isEnabled: state.hasLocation,
                                latitude: state.latitude,
                                longitude: state.longitude,
                                radiusInMeters: state.radiusInMeters,
                                locationName: state.locationName,
                                onEnabledChanged: (enabled) {
                                  context.read<AddReminderBloc>().add(
                                    AddReminderLocationToggled(enabled),
                                  );
                                },
                                onLatitudeChanged: (lat) => context
                                    .read<AddReminderBloc>()
                                    .add(AddReminderLatitudeChanged(lat)),
                                onLongitudeChanged: (lng) => context
                                    .read<AddReminderBloc>()
                                    .add(AddReminderLongitudeChanged(lng)),
                                onRadiusChanged: (radius) => context
                                    .read<AddReminderBloc>()
                                    .add(AddReminderRadiusChanged(radius)),
                                onLocationNameChanged: (name) => context
                                    .read<AddReminderBloc>()
                                    .add(AddReminderLocationNameChanged(name)),
                              ),
                              const SizedBox(height: 32),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    return SubmitButtonWidget(
                      isEditing: isEditing,
                      onSubmit: () => _submit(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final bloc = context.read<AddReminderBloc>();
    final picked = await showTimePicker(
      context: context,
      initialTime: bloc.state.selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
              surface: AppColor.white,
              onSurface: AppColor.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColor.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dialBackgroundColor: AppColor.primary.withValues(alpha: 0.1),
              dialHandColor: AppColor.primary,
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColor.primary;
                }
                return AppColor.gray100;
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppColor.textPrimary;
              }),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      bloc.add(AddReminderTimeChanged(picked));
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final bloc = context.read<AddReminderBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: bloc.state.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
              surface: AppColor.white,
              onSurface: AppColor.textPrimary,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColor.white,
              headerBackgroundColor: AppColor.primary,
              headerForegroundColor: Colors.white,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColor.primary;
                }
                return null;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColor.primary;
                }
                return AppColor.primary.withValues(alpha: 0.1);
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppColor.primary;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      bloc.add(AddReminderDateChanged(picked));
    }
  }

  void _submit(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title');
      return;
    }

    final bloc = context.read<AddReminderBloc>();
    final state = bloc.state;
    final dateTime = state.combinedDateTime;

    if (dateTime.isBefore(DateTime.now())) {
      _showErrorSnackBar('Please select a future date and time');
      return;
    }

    if (isEditing) {
      context.read<ReminderBloc>().add(
        ReminderUpdateRequested(
          widget.reminder!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            dateTime: dateTime,
            priority: state.selectedPriority,
            repeatType: state.selectedRepeatType,
            latitude: state.hasLocation ? state.latitude : null,
            longitude: state.hasLocation ? state.longitude : null,
            radiusInMeters: state.hasLocation ? state.radiusInMeters : null,
            locationName: state.hasLocation ? state.locationName : null,
          ),
        ),
      );
    } else {
      context.read<ReminderBloc>().add(
        ReminderCreateRequested(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dateTime: dateTime,
          priority: state.selectedPriority,
          repeatType: state.selectedRepeatType,
          latitude: state.hasLocation ? state.latitude : null,
          longitude: state.hasLocation ? state.longitude : null,
          radiusInMeters: state.hasLocation ? state.radiusInMeters : null,
          locationName: state.hasLocation ? state.locationName : null,
        ),
      );
    }

    context.router.maybePop();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColor.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
