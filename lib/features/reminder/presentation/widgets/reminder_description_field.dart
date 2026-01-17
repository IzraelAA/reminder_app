import 'package:flutter/material.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

class ReminderDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const ReminderDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (optional)',
          style: AppTypography.labelLarge.copyWith(
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
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
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Add some details...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColor.textTertiary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            maxLines: 3,
            style: AppTypography.bodyLarge,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}
