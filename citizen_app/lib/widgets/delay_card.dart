import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class DelayCard extends StatelessWidget {
  final int daysPending;
  final int expectedDays;

  const DelayCard({
    super.key,
    required this.daysPending,
    required this.expectedDays,
  });

  @override
  Widget build(BuildContext context) {
    final delayDays = daysPending - expectedDays;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delay Detected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'This application is delayed by $delayDays days. The expected processing time is $expectedDays days, but it has been pending for $daysPending days.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
