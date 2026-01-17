import 'package:flutter/material.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';
import 'package:intl/intl.dart';

class TimeSelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onTimeTap;
  final VoidCallback onDateTap;

  const TimeSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTimeTap,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withValues(alpha: 0.08),
            AppColor.primaryLight.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColor.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Time Display
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeDigit(selectedTime.hour ~/ 10),
                  _buildTimeDigit(selectedTime.hour % 10),
                  _buildTimeSeparator(),
                  _buildTimeDigit(selectedTime.minute ~/ 10),
                  _buildTimeDigit(selectedTime.minute % 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Date Display
          GestureDetector(
            onTap: onDateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColor.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: AppColor.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatSelectedDate(),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColor.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDigit(int digit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.gray50, AppColor.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Text(
        digit.toString(),
        style: AppTypography.timeDisplay.copyWith(
          color: AppColor.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selectedDay == today) {
      return 'Today, ${DateFormat('MMMM d').format(selectedDate)}';
    } else if (selectedDay == tomorrow) {
      return 'Tomorrow, ${DateFormat('MMMM d').format(selectedDate)}';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
    }
  }
}
