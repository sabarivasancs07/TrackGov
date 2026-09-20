import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../config/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (status) {
      case AppConstants.statusOnSchedule:
      case AppConstants.statusApproved:
      case 'Completed':
        backgroundColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case AppConstants.statusDelayDetected:
      case AppConstants.statusRejected:
        backgroundColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        icon = Icons.error_outline;
        break;
      case AppConstants.statusPending:
      case AppConstants.statusInProgress:
      default:
        backgroundColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        icon = Icons.pending_actions;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
