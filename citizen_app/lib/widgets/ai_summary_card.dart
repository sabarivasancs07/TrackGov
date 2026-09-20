import 'package:flutter/material.dart';
import '../models/ai_summary_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AiSummaryCard extends StatelessWidget {
  final AiSummary summary;

  const AiSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'AI Analysis',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              summary.explanation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            _buildDetailRow(
              context,
              'Next Expected Step:',
              summary.nextExpectedStep,
            ),
            if (summary.estimatedCompletion != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildDetailRow(
                context,
                'Estimated Completion:',
                summary.estimatedCompletion!,
              ),
            ],
            if (summary.delayReason != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildDetailRow(
                context,
                'Delay Reason:',
                summary.delayReason!,
                isError: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isError ? AppColors.error : AppColors.textPrimary,
                  fontWeight: isError ? FontWeight.w500 : FontWeight.normal,
                ),
          ),
        ),
      ],
    );
  }
}
