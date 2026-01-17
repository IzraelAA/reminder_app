import 'package:flutter/material.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';
import 'package:intl/intl.dart';

/// Premium reminder card with clear visual hierarchy
/// Time is prominently displayed as per gaming company standards
class ReminderCard extends StatelessWidget {
  final ReminderEntity reminder;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reminder.id),
      background: _buildSwipeBackground(
        color: AppColor.success,
        icon: Icons.check_rounded,
        alignment: Alignment.centerLeft,
        label: 'Complete',
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColor.error,
        icon: Icons.delete_rounded,
        alignment: Alignment.centerRight,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Toggle complete - swipe right
          onToggleComplete();
          return false;
        } else {
          // Delete - swipe left
          final shouldDelete = await _showDeleteConfirmation(context);
          if (shouldDelete) {
            onDelete();
          }
          // Always return false to prevent Dismissible from auto-removing
          // Let AnimatedList handle the removal animation
          return false;
        }
      },
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: reminder.isCompleted ? AppColor.gray50 : AppColor.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: reminder.isCompleted
                  ? AppColor.gray200
                  : _getPriorityColor().withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: reminder.isCompleted
                ? null
                : [
                    BoxShadow(
                      color: AppColor.gray200.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Priority indicator bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: _getPriorityGradient(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeDisplay(),
                      const SizedBox(width: 16),
                      Expanded(child: _buildContent()),
                      _buildCheckbox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Time display - Most prominent element
  Widget _buildTimeDisplay() {
    final timeFormat = DateFormat('HH:mm');
    final isOverdue = reminder.isOverdue;
    final isUpcoming = reminder.isUpcoming;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: isOverdue
            ? LinearGradient(
                colors: [
                  AppColor.error.withValues(alpha: 0.15),
                  AppColor.error.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : isUpcoming
            ? LinearGradient(
                colors: [
                  AppColor.primary.withValues(alpha: 0.15),
                  AppColor.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [AppColor.gray100, AppColor.gray50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? AppColor.error.withValues(alpha: 0.2)
              : isUpcoming
              ? AppColor.primary.withValues(alpha: 0.2)
              : AppColor.gray200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeFormat.format(reminder.dateTime),
            style: AppTypography.timeLarge.copyWith(
              color: isOverdue
                  ? AppColor.error
                  : isUpcoming
                  ? AppColor.primary
                  : reminder.isCompleted
                  ? AppColor.textTertiary
                  : AppColor.textPrimary,
              fontWeight: FontWeight.w700,
              decoration: reminder.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(reminder.dateTime),
            style: AppTypography.labelSmall.copyWith(
              color: isOverdue
                  ? AppColor.error.withValues(alpha: 0.7)
                  : AppColor.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isOverdue = reminder.isOverdue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          reminder.title,
          style: AppTypography.titleMedium.copyWith(
            decoration: reminder.isCompleted
                ? TextDecoration.lineThrough
                : null,
            color: reminder.isCompleted
                ? AppColor.textTertiary
                : AppColor.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Description
        if (reminder.description != null &&
            reminder.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            reminder.description!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColor.textSecondary,
              decoration: reminder.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 8),

        // Tags row
        Row(
          children: [
            // Priority badge
            _buildPriorityBadge(),

            const SizedBox(width: 8),

            // Repeat badge if applicable
            if (reminder.repeatType != RepeatType.none) _buildRepeatBadge(),

            // Overdue badge
            if (isOverdue) ...[const Spacer(), _buildOverdueBadge()],
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getPriorityColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getPriorityColor(),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            reminder.priority.name.toUpperCase(),
            style: AppTypography.badge.copyWith(
              color: _getPriorityColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat_rounded, size: 10, color: AppColor.secondary),
          const SizedBox(width: 4),
          Text(
            _getRepeatLabel(reminder.repeatType),
            style: AppTypography.badge.copyWith(
              color: AppColor.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.error.withValues(alpha: 0.15),
            AppColor.error.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 10, color: AppColor.error),
          const SizedBox(width: 4),
          Text(
            'OVERDUE',
            style: AppTypography.badge.copyWith(
              color: AppColor.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggleComplete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: reminder.isCompleted ? AppColor.primaryGradient : null,
          color: reminder.isCompleted ? null : Colors.transparent,
          border: Border.all(
            color: reminder.isCompleted ? Colors.transparent : AppColor.gray300,
            width: 2,
          ),
          boxShadow: reminder.isCompleted
              ? [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: reminder.isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required String label,
  }) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.9), color],
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: EdgeInsets.only(left: isLeft ? 24 : 0, right: isLeft ? 0 : 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft) ...[
            Text(
              label,
              style: AppTypography.buttonMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          if (isLeft) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.buttonMedium.copyWith(color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  LinearGradient _getPriorityGradient() {
    switch (reminder.priority) {
      case ReminderPriority.high:
        return LinearGradient(
          colors: [AppColor.priorityHigh, AppColor.neonPink],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case ReminderPriority.medium:
        return LinearGradient(
          colors: [AppColor.priorityMedium, AppColor.accent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case ReminderPriority.low:
        return LinearGradient(
          colors: [AppColor.priorityLow, AppColor.secondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  Color _getPriorityColor() {
    switch (reminder.priority) {
      case ReminderPriority.high:
        return AppColor.priorityHigh;
      case ReminderPriority.medium:
        return AppColor.priorityMedium;
      case ReminderPriority.low:
        return AppColor.priorityLow;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(date.year, date.month, date.day);

    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  String _getRepeatLabel(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return '';
      case RepeatType.daily:
        return 'DAILY';
      case RepeatType.weekly:
        return 'WEEKLY';
      case RepeatType.monthly:
        return 'MONTHLY';
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColor.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Delete Reminder', style: AppTypography.titleLarge),
              ],
            ),
            content: Text(
              'Are you sure you want to delete "${reminder.title}"? This action cannot be undone.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: AppTypography.buttonMedium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Delete', style: AppTypography.buttonMedium),
              ),
            ],
          ),
        ) ??
        false;
  }
}
