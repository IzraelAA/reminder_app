import 'package:flutter/material.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

class PrioritySelectorWidget extends StatelessWidget {
  final ReminderPriority selectedPriority;
  final ValueChanged<ReminderPriority> onPriorityChanged;

  const PrioritySelectorWidget({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AppTypography.labelLarge.copyWith(
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ReminderPriority.values.map((priority) {
            final isSelected = selectedPriority == priority;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: priority != ReminderPriority.values.last ? 12 : 0,
                ),
                child: _PriorityChip(
                  priority: priority,
                  isSelected: isSelected,
                  onTap: () => onPriorityChanged(priority),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final ReminderPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);
    final icon = _getPriorityIcon(priority);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColor.white,
          border: Border.all(
            color: isSelected ? color : AppColor.gray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColor.textTertiary,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              priority.name.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? color : AppColor.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.high:
        return AppColor.priorityHigh;
      case ReminderPriority.medium:
        return AppColor.priorityMedium;
      case ReminderPriority.low:
        return AppColor.priorityLow;
    }
  }

  IconData _getPriorityIcon(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.high:
        return Icons.priority_high_rounded;
      case ReminderPriority.medium:
        return Icons.remove_rounded;
      case ReminderPriority.low:
        return Icons.keyboard_arrow_down_rounded;
    }
  }
}
