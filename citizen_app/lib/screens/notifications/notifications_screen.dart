import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/application_provider.dart';
import '../../models/workflow_step_model.dart';
import '../../navigation/route_names.dart';
import '../../theme/app_colors.dart';
import '../../widgets/citizen_app_shell.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      if (appProvider.currentApplication == null) {
        appProvider.refreshStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, _) {
        final app = appProvider.currentApplication;
        final appNum = app?.applicationNumber ?? '';

        return CitizenAppShell(
          currentRoute: RouteNames.notifications,
          applicationNumber: appNum,
          showBackButton: true,
          title: 'Notifications',
          child: _buildBody(context, appProvider, app),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ApplicationProvider appProvider,
    dynamic app,
  ) {
    if (appProvider.isLoading && app == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    final history = app?.workflowHistory ?? <WorkflowStep>[];
    final notifications = _generateNotifications(history, app);
    final filtered = _filterNotifications(notifications, _selectedFilter);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stay updated about your applications and government services.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // Filter Chips (All, Updates, Alerts)
              _buildFilterChips(),

              const SizedBox(height: 22),

              // Notification Cards
              if (filtered.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(filtered[index]);
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Updates', 'Alerts'];
    return Row(
      children: filters.map((label) {
        final isSelected = _selectedFilter == label;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _selectedFilter = label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationCard(_NotificationModel item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isUnread ? AppColors.primaryBlue.withValues(alpha: 0.3) : const Color(0xFFE5EAF1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textDisabled),
          SizedBox(height: 16),
          Text(
            'No notifications found',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'You will receive updates when your application status changes.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  List<_NotificationModel> _generateNotifications(List<dynamic> history, dynamic app) {
    final list = <_NotificationModel>[];

    // If app is delayed, add alert
    if (app != null && app.isDelayed == true) {
      list.add(
        _NotificationModel(
          title: 'Delay Alert: Processing Window Exceeded',
          description: 'Your application has been pending for ${app.daysPending} days (exceeds ${app.expectedProcessingDays} days SLA target). AI escalated status.',
          time: 'Active Alert',
          type: 'Alerts',
          icon: Icons.warning_amber_rounded,
          iconBgColor: const Color(0xFFFFF0F0),
          iconColor: const Color(0xFFDC2626),
          isUnread: true,
        ),
      );
    }

    for (int i = 0; i < history.length; i++) {
      final step = history[i];
      final isCompleted = step.status.toLowerCase() == 'completed';
      final timeStr = step.completedAt != null
          ? DateFormat('dd MMM yyyy, hh:mm a').format(step.completedAt!)
          : 'Recent';

      list.add(
        _NotificationModel(
          title: '${step.stageName} ${isCompleted ? 'Completed' : 'Updated'}',
          description: step.remarks ?? 'Workflow stage has been processed by government authorities.',
          time: timeStr,
          type: 'Updates',
          icon: isCompleted ? Icons.check_circle_outline_rounded : Icons.schedule_rounded,
          iconBgColor: isCompleted ? const Color(0xFFE8F8F0) : const Color(0xFFE8F0FF),
          iconColor: isCompleted ? AppColors.successGreen : AppColors.primaryBlue,
          isUnread: i == 0,
        ),
      );
    }

    if (list.isEmpty) {
      list.add(
        _NotificationModel(
          title: 'Application Received',
          description: 'Your application has been submitted and acknowledged by the departmental registry.',
          time: 'Recent',
          type: 'Updates',
          icon: Icons.assignment_turned_in_outlined,
          iconBgColor: const Color(0xFFE8F0FF),
          iconColor: AppColors.primaryBlue,
          isUnread: false,
        ),
      );
    }

    return list;
  }

  List<_NotificationModel> _filterNotifications(List<_NotificationModel> all, String filter) {
    if (filter == 'All') return all;
    return all.where((item) => item.type == filter).toList();
  }
}

class _NotificationModel {
  final String title;
  final String description;
  final String time;
  final String type;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isUnread;

  _NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isUnread,
  });
}
