import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../navigation/route_names.dart';
import '../../models/application_model.dart';
import '../../models/workflow_step_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/citizen_app_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplicationIfNeeded();
    });
  }

  Future<void> _loadApplicationIfNeeded() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
    if (auth.user != null && appProvider.currentApplication == null) {
      await appProvider.searchApplication(
        auth.user!.applicationNumber,
        auth.user!.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ApplicationProvider>(
      builder: (context, auth, appProvider, _) {
        final userName = auth.user?.name ?? 'Citizen';
        final appNum = auth.user?.applicationNumber ?? '';
        final app = appProvider.currentApplication;

        return CitizenAppShell(
          currentRoute: RouteNames.home,
          applicationNumber: appNum,
          child: RefreshIndicator(
            onRefresh: appProvider.refreshStatus,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header greeting & Top-Right Quote card
                      _buildHeaderSection(context, userName: userName),

                      const SizedBox(height: 24),

                      // Main Application Card
                      appProvider.isLoading && app == null
                          ? _buildLoadingCard()
                          : _buildApplicationCard(context, app: app, appNum: appNum),

                      const SizedBox(height: 28),

                      // Quick Actions Section
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildQuickActions(context, appNum: appNum),

                      const SizedBox(height: 28),

                      // Dual Columns: Recent Updates & What's Next
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 720;
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildRecentUpdates(context, app: app)),
                                const SizedBox(width: 20),
                                Expanded(child: _buildWhatsNext(context, app: app)),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _buildRecentUpdates(context, app: app),
                              const SizedBox(height: 20),
                              _buildWhatsNext(context, app: app),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Floating Ask AI Banner / Action
                      _buildAiAssistantBanner(context, appNum: appNum),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER SECTION (Greeting + Top-Right Quote Card)
  // ============================================================
  Widget _buildHeaderSection(BuildContext context, {required String userName}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;

        final greetingWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, $userName 👋',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Here's the latest on your applications.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );

        final quoteWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5EAF2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Empowered citizens\nbuild a stronger nation.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );

        if (isWide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: greetingWidget),
              quoteWidget,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            greetingWidget,
            const SizedBox(height: 16),
            quoteWidget,
          ],
        );
      },
    );
  }

  // ============================================================
  // APPLICATION CARD WITH REAL TIMELINE
  // ============================================================
  Widget _buildApplicationCard(
    BuildContext context, {
    required ApplicationModel? app,
    required String appNum,
  }) {
    final applicationType = app?.certificateType ?? 'Application for Certificate';
    final applicationNumber = app?.applicationNumber ?? appNum;
    final currentStage = app?.currentStage ?? 'Processing';
    final status = app?.status ?? 'In Progress';
    final daysPending = app?.daysPending ?? 0;
    final expectedDays = app?.expectedProcessingDays ?? 15;
    final progress = app != null
        ? ((daysPending / expectedDays) * 100).clamp(10, 100).toInt()
        : 35;
    final isDelayed = app?.isDelayed ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Application Card Top Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicationType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Application No: $applicationNumber',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status: status, isDelayed: isDelayed),
            ],
          ),

          const SizedBox(height: 24),

          // Stage & Progress Row
          Row(
            children: [
              const Text(
                'Current Stage',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$progress% Complete',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            currentStage,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // 5-Stage Visual Journey Timeline
          _buildJourneyTimeline(app: app),

          const SizedBox(height: 20),

          // Progress percentage bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EDF4),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),

          const SizedBox(height: 20),

          // Action footer
          Row(
            children: [
              Text(
                'Application is $progress% processed',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    RouteNames.applicationStatus,
                    arguments: applicationNumber,
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View Full Details'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // JOURNEY TIMELINE (5 Stages: Submitted, Documents, Officer Verification, Field Verification, Final Approval)
  // ============================================================
  Widget _buildJourneyTimeline({required ApplicationModel? app}) {
    final stages = [
      'Submitted',
      'Documents',
      'Officer Verification',
      'Field Verification',
      'Final Approval',
    ];

    // Determine completion status using real workflow history
    final history = app?.workflowHistory ?? [];
    final currentStageName = (app?.currentStage ?? '').toLowerCase();

    // Map stages to status (completed, current, pending)
    final stageStates = <String, String>{};

    for (final stage in stages) {
      final matchInHistory = history.firstWhere(
        (step) => _stageMatches(step.stageName, stage),
        orElse: () => WorkflowStep(
          stageName: '',
          stageCode: '',
          status: 'Pending',
        ),
      );

      if (matchInHistory.stageName.isNotEmpty && matchInHistory.status.toLowerCase() == 'completed') {
        stageStates[stage] = 'completed';
      } else if (_stageMatches(currentStageName, stage)) {
        stageStates[stage] = 'current';
      } else {
        stageStates[stage] = 'pending';
      }
    }

    // Default fallback if no history exists yet: Submitted is completed
    if (stageStates['Submitted'] == 'pending' && app != null) {
      stageStates['Submitted'] = 'completed';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        if (isCompact) {
          return Column(
            children: stages.map((stageName) {
              final state = stageStates[stageName] ?? 'pending';

              Color iconBg = const Color(0xFFE8EDF4);
              Color iconColor = AppColors.textDisabled;
              if (state == 'completed') {
                iconBg = AppColors.successGreen;
                iconColor = Colors.white;
              } else if (state == 'current') {
                iconBg = AppColors.primaryBlue;
                iconColor = Colors.white;
              }

              return Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state == 'completed'
                          ? Icons.check_rounded
                          : (state == 'current' ? Icons.circle : Icons.schedule_rounded),
                      size: state == 'current' ? 10 : 16,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stageName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: state == 'current' ? FontWeight.w700 : FontWeight.w500,
                        color: state == 'pending' ? AppColors.textDisabled : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    state == 'completed' ? 'Completed' : (state == 'current' ? 'In Progress' : 'Pending'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: state == 'completed'
                          ? AppColors.successGreen
                          : (state == 'current' ? AppColors.primaryBlue : AppColors.textDisabled),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        }

        // Horizontal Timeline
        return Row(
          children: stages.asMap().entries.map((entry) {
            final idx = entry.key;
            final stageName = entry.value;
            final state = stageStates[stageName] ?? 'pending';
            final isLast = idx == stages.length - 1;

            Color nodeColor = const Color(0xFFE2E8F0);
            if (state == 'completed') {
              nodeColor = AppColors.successGreen;
            } else if (state == 'current') {
              nodeColor = AppColors.primaryBlue;
            }

            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      // Left line connector
                      Expanded(
                        child: idx == 0
                            ? const SizedBox.shrink()
                            : Container(
                                height: 3,
                                color: (stageStates[stages[idx - 1]] == 'completed')
                                    ? AppColors.successGreen
                                    : const Color(0xFFE2E8F0),
                              ),
                      ),
                      // Step node
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: nodeColor,
                          shape: BoxShape.circle,
                          boxShadow: state == 'current'
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          state == 'completed'
                              ? Icons.check_rounded
                              : (state == 'current' ? Icons.circle : Icons.schedule_rounded),
                          size: state == 'current' ? 10 : 16,
                          color: Colors.white,
                        ),
                      ),
                      // Right line connector
                      Expanded(
                        child: isLast
                            ? const SizedBox.shrink()
                            : Container(
                                height: 3,
                                color: state == 'completed'
                                    ? AppColors.successGreen
                                    : const Color(0xFFE2E8F0),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stageName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: state == 'current' ? FontWeight.w700 : FontWeight.w500,
                      color: state == 'pending' ? AppColors.textDisabled : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  bool _stageMatches(String a, String b) {
    final sA = a.toLowerCase().replaceAll(' ', '');
    final sB = b.toLowerCase().replaceAll(' ', '');
    return sA.contains(sB) || sB.contains(sA);
  }

  Widget _buildStatusBadge({required String status, required bool isDelayed}) {
    final isDelay = isDelayed || status.toLowerCase().contains('delay');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDelay ? const Color(0xFFFFF0F0) : const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDelay ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
            size: 14,
            color: isDelay ? const Color(0xFFE53E3E) : AppColors.successGreen,
          ),
          const SizedBox(width: 5),
          Text(
            isDelay ? 'Delayed' : 'On Track',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDelay ? const Color(0xFFC53030) : AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS (4 Cards, responsive wrap)
  // ============================================================
  Widget _buildQuickActions(BuildContext context, {required String appNum}) {
    final actions = [
      (
        'Track Application',
        'Check detailed progress',
        Icons.track_changes_rounded,
        const Color(0xFFE6F0FF),
        AppColors.primaryBlue,
        () => Navigator.of(context).pushNamed(RouteNames.applicationStatus, arguments: appNum),
      ),
      (
        'AI Summary',
        'Plain English explanation',
        Icons.auto_awesome_rounded,
        const Color(0xFFF3E8FF),
        AppColors.aiPurple,
        () => Navigator.of(context).pushNamed(RouteNames.aiSummary, arguments: appNum),
      ),
      (
        'Upload Documents',
        'Review required records',
        Icons.folder_copy_outlined,
        const Color(0xFFE6F0FF),
        AppColors.primaryBlue,
        () => Navigator.of(context).pushNamed(RouteNames.documents),
      ),
      (
        'Ask a Question',
        '24/7 AI chat assistant',
        Icons.chat_bubble_outline_rounded,
        const Color(0xFFE8F8F0),
        AppColors.successGreen,
        () => Navigator.of(context).pushNamed(RouteNames.aiAssistant, arguments: appNum),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 4;
        if (width < 600) {
          columns = 1;
        } else if (width < 960) {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: columns == 1 ? 3.2 : (columns == 2 ? 2.3 : 1.7),
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: action.$6,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5EAF1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: action.$4,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action.$3,
                        color: action.$5,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.$1,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            action.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // RECENT UPDATES (White rounded card with real updates)
  // ============================================================
  Widget _buildRecentUpdates(BuildContext context, {required ApplicationModel? app}) {
    final history = app?.workflowHistory ?? [];
    final recentSteps = history.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Updates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.notifications);
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (recentSteps.isNotEmpty)
            Column(
              children: recentSteps.asMap().entries.map((entry) {
                final step = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: entry.key < recentSteps.length - 1 ? 16 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.successGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.stageName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              step.remarks ?? 'Stage status recorded successfully.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.completedAt != null
                                  ? '${step.completedAt!.day} ${_month(step.completedAt!.month)} ${step.completedAt!.year}'
                                  : 'Recent update',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.hourglass_bottom_rounded, color: AppColors.primaryBlue, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Submitted',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your application has been received and verification is underway.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  // WHAT'S NEXT (White rounded card with real next stage)
  // ============================================================
  Widget _buildWhatsNext(BuildContext context, {required ApplicationModel? app}) {
    final nextStage = app?.currentStage ?? 'Processing';
    final daysPending = app?.daysPending ?? 0;
    final expectedDays = app?.expectedProcessingDays ?? 15;
    final daysLeft = (expectedDays - daysPending).clamp(0, expectedDays);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's Next?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextStage,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Next scheduled administrative step',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    daysLeft > 0
                        ? 'Expected timeline: ~$daysLeft days remaining'
                        : 'Review stage in final verification',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI ASSISTANT PROMOTIONAL BANNER
  // ============================================================
  Widget _buildAiAssistantBanner(BuildContext context, {required String appNum}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryNavy,
            Color(0xFF1E1B4B),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFC084FC),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have questions about your application?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TrackGov AI assistant can explain delays, requirements, and next steps.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(RouteNames.aiAssistant, arguments: appNum);
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Ask AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryNavy,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: AppColors.primaryBlue),
          SizedBox(height: 16),
          Text(
            'Retrieving application data from Firestore...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const ms = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return ms[(m - 1).clamp(0, 11)];
  }
}