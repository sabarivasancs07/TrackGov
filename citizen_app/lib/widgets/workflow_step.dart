import 'package:flutter/material.dart';
import '../models/workflow_step_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'package:intl/intl.dart';

class WorkflowStepWidget extends StatelessWidget {
  final WorkflowStep step;
  final bool isLast;

  const WorkflowStepWidget({
    super.key,
    required this.step,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = step.status == 'Completed';
    final bool isInProgress = step.status == 'In Progress';

    Color indicatorColor = AppColors.textDisabled;
    if (isCompleted) indicatorColor = AppColors.success;
    if (isInProgress) indicatorColor = AppColors.primary;

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 14,
            top: 24,
            bottom: 0,
            child: Container(
              width: 2,
              color: isCompleted ? AppColors.success : AppColors.border,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isInProgress
                        ? indicatorColor
                        : Colors.transparent,
                    border: Border.all(
                      color: indicatorColor,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.stageName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isCompleted || isInProgress
                                ? AppColors.textPrimary
                                : AppColors.textDisabled,
                          ),
                    ),
                    if (step.officerName != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Officer: ${step.officerName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (step.completedAt != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(step.completedAt!),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                    if (isInProgress) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Currently Here',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
