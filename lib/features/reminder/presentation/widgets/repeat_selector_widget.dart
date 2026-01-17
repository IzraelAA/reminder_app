import 'package:flutter/material.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder_entity.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

class RepeatSelectorWidget extends StatelessWidget {
  final RepeatType selectedRepeatType;
  final ValueChanged<RepeatType> onRepeatTypeChanged;

  const RepeatSelectorWidget({
    super.key,
    required this.selectedRepeatType,
    required this.onRepeatTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat',
          style: AppTypography.labelLarge.copyWith(
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.gray200.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<RepeatType>(
            initialValue: selectedRepeatType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.repeat_rounded,
                  color: AppColor.accent,
                  size: 20,
                ),
              ),
            ),
            dropdownColor: AppColor.white,
            borderRadius: BorderRadius.circular(16),
            items: RepeatType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  _getRepeatLabel(type),
                  style: AppTypography.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onRepeatTypeChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  String _getRepeatLabel(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return 'No repeat';
      case RepeatType.daily:
        return 'Every day';
      case RepeatType.weekly:
        return 'Every week';
      case RepeatType.monthly:
        return 'Every month';
    }
  }
}
