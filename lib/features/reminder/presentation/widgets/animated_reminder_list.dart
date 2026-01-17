import 'package:flutter/material.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/features/reminder/presentation/widgets/reminder_card.dart';

/// AnimatedList wrapper for reminders with smooth add/remove animations
class AnimatedReminderList extends StatefulWidget {
  final List<ReminderEntity> reminders;
  final Function(ReminderEntity) onToggleComplete;
  final Function(ReminderEntity) onDelete;
  final Function(ReminderEntity) onEdit;
  final Future<void> Function() onRefresh;

  const AnimatedReminderList({
    super.key,
    required this.reminders,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  State<AnimatedReminderList> createState() => _AnimatedReminderListState();
}

class _AnimatedReminderListState extends State<AnimatedReminderList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<ReminderEntity> _displayedReminders;

  @override
  void initState() {
    super.initState();
    _displayedReminders = List.from(widget.reminders);
  }

  @override
  void didUpdateWidget(AnimatedReminderList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle list updates
    final newReminders = widget.reminders;
    final oldReminders = _displayedReminders;

    // Find removed items
    for (var i = oldReminders.length - 1; i >= 0; i--) {
      final oldReminder = oldReminders[i];
      if (!newReminders.any((r) => r.id == oldReminder.id)) {
        _removeItem(i, oldReminder);
      }
    }

    // Find added items
    for (var i = 0; i < newReminders.length; i++) {
      final newReminder = newReminders[i];
      if (!oldReminders.any((r) => r.id == newReminder.id)) {
        _insertItem(i, newReminder);
      }
    }

    // Update existing items
    _displayedReminders = List.from(newReminders);
  }

  void _insertItem(int index, ReminderEntity reminder) {
    _displayedReminders.insert(index, reminder);
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _removeItem(int index, ReminderEntity reminder) {
    final removedItem = _displayedReminders.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildRemovedItem(
    ReminderEntity reminder,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: ReminderCard(
            reminder: reminder,
            onToggleComplete: () {},
            onDelete: () {},
            onEdit: () {},
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        initialItemCount: _displayedReminders.length,
        itemBuilder: (context, index, animation) {
          if (index >= _displayedReminders.length) {
            return const SizedBox.shrink();
          }
          final reminder = _displayedReminders[index];
          return _buildAnimatedItem(reminder, animation, index);
        },
      ),
    );
  }

  Widget _buildAnimatedItem(
    ReminderEntity reminder,
    Animation<double> animation,
    int index,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    // Staggered delay for initial load
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    return FadeTransition(
      opacity: delayedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: ReminderCard(
          reminder: reminder,
          onToggleComplete: () => widget.onToggleComplete(reminder),
          onDelete: () => widget.onDelete(reminder),
          onEdit: () => widget.onEdit(reminder),
        ),
      ),
    );
  }
}
