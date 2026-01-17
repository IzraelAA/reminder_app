import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_app/core/route/app_router.gr.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/presentation/cubit/reminder_cubit.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/animated_reminder_list.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/empty_state_widget.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    // Start FAB animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<ReminderCubit, ReminderState>(
                builder: (context, state) {
                  if (state.isLoading && state.reminders.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (state.reminders.isEmpty) {
                    return const EmptyStateWidget();
                  }

                  return AnimatedReminderList(
                    reminders: state.reminders,
                    onToggleComplete: (reminder) {
                      context.read<ReminderCubit>().toggleReminderCompletion(
                        reminder.id,
                      );
                    },
                    onDelete: (reminder) {
                      context.read<ReminderCubit>().deleteReminder(reminder.id);
                    },
                    onEdit: (reminder) => _navigateToEditReminder(reminder),
                    onRefresh: () async {
                      context.read<ReminderCubit>().loadReminders();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'My Reminders',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _buildStatsChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsChip() {
    return BlocBuilder<ReminderCubit, ReminderState>(
      builder: (context, state) {
        final activeCount = state.reminders.where((r) => !r.isCompleted).length;
        final overdueCount = state.reminders.where((r) => r.isOverdue).length;

        if (activeCount == 0 && overdueCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: overdueCount > 0
                ? LinearGradient(
                    colors: [
                      AppColor.error.withValues(alpha: 0.1),
                      AppColor.error.withValues(alpha: 0.05),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColor.primary.withValues(alpha: 0.1),
                      AppColor.primary.withValues(alpha: 0.05),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: overdueCount > 0
                  ? AppColor.error.withValues(alpha: 0.2)
                  : AppColor.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                overdueCount > 0
                    ? Icons.warning_amber_rounded
                    : Icons.notifications_active_rounded,
                size: 16,
                color: overdueCount > 0 ? AppColor.error : AppColor.primary,
              ),
              const SizedBox(width: 6),
              Text(
                overdueCount > 0
                    ? '$overdueCount overdue'
                    : '$activeCount active',
                style: AppTypography.labelMedium.copyWith(
                  color: overdueCount > 0 ? AppColor.error : AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading reminders...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColor.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _navigateToAddReminder,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Evening 🌙';
    }
  }

  void _navigateToAddReminder() {
    context.router.push(AddReminderRoute());
  }

  void _navigateToEditReminder(ReminderEntity reminder) {
    context.router.push(AddReminderRoute(reminder: reminder));
  }
}
