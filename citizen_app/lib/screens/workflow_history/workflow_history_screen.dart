import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/workflow_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/workflow_step_model.dart';
import '../../models/application_model.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_card.dart';

import '../../widgets/citizen_app_shell.dart';
import '../../navigation/route_names.dart';

class WorkflowHistoryScreen extends StatefulWidget {
  final String? applicationNumber;

  const WorkflowHistoryScreen({super.key, this.applicationNumber});

  @override
  State<WorkflowHistoryScreen> createState() => _WorkflowHistoryScreenState();
}

class _WorkflowHistoryScreenState extends State<WorkflowHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final appNum = widget.applicationNumber ??
        Provider.of<ApplicationProvider>(context, listen: false)
            .currentApplication
            ?.applicationNumber;

    if (appNum != null && appNum.isNotEmpty) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);

      Provider.of<WorkflowProvider>(context, listen: false).fetchTimeline(appNum);

      if (appProvider.currentApplication == null ||
          appProvider.currentApplication?.applicationNumber != appNum) {
        appProvider.searchApplication(appNum, auth.user?.name ?? '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);
    final appNum = widget.applicationNumber ?? appProvider.currentApplication?.applicationNumber ?? '';

    return CitizenAppShell(
      currentRoute: RouteNames.workflowHistory,
      applicationNumber: appNum,
      showBackButton: true,
      title: 'Application Journey',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Consumer2<WorkflowProvider, ApplicationProvider>(
            builder: (context, workflowProv, appProv, _) {
                      if (workflowProv.isLoading &&
                          (workflowProv.timeline == null ||
                              workflowProv.timeline!.isEmpty)) {
                        return const Center(
                          child: LoadingWidget(
                            message: 'Loading application journey...',
                          ),
                        );
                      }

                      if (workflowProv.errorMessage != null &&
                          (workflowProv.timeline == null ||
                              workflowProv.timeline!.isEmpty)) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: ErrorCard(
                              message: workflowProv.errorMessage!,
                              onRetry: _loadData,
                            ),
                          ),
                        );
                      }

                      final timeline = workflowProv.timeline ?? [];
                      final app = appProv.currentApplication;

                      if (timeline.isEmpty && app?.workflowHistory.isNotEmpty == true) {
                        // Fallback to application's embedded workflow if available
                        return _buildJourneyContent(
                          context,
                          app!.workflowHistory,
                          app,
                          workflowProv,
                          isDesktop,
                        );
                      }

                      if (timeline.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.timeline_outlined,
                                size: 54,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No workflow history available yet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildJourneyContent(
                        context,
                        timeline,
                        app,
                        workflowProv,
                        isDesktop,
                      );
                    },
                  );
                },
              ),
            );
          }

  // ============================================================
  // MAIN JOURNEY CONTENT
  // ============================================================
  Widget _buildJourneyContent(
    BuildContext context,
    List<WorkflowStep> stages,
    ApplicationModel? app,
    WorkflowProvider workflowProv,
    bool isDesktop,
  ) {
    final appId = widget.applicationNumber ??
        app?.applicationNumber ??
        stages.firstOrNull?.stageCode ??
        'INC-2026';
    final appType = app?.certificateType ?? 'Certificate Application';

    // Calculate completed and progress
    final completedCount = stages.where((s) => _isCompleted(s.status)).length;
    final totalCount = stages.length;
    final calculatedProgress = totalCount > 0
        ? ((completedCount / totalCount) * 100).toInt()
        : 0;
    final progress = workflowProv.progressPercentage ??
        (app != null ? _calculateAppProgress(app.currentStage) : calculatedProgress);

    // Active/Current stage
    final currentStageStep = stages.firstWhere(
      (s) => _isInProgress(s.status),
      orElse: () => stages.firstWhere(
        (s) => !_isCompleted(s.status),
        orElse: () => stages.last,
      ),
    );

    final currentStageName = workflowProv.currentStage ??
        app?.currentStage ??
        currentStageStep.stageName;

    final overallStatus = workflowProv.overallStatus ??
        app?.status ??
        (completedCount == totalCount ? 'Approved' : 'Under Verification');

    // Find next pending stage
    WorkflowStep? nextStageStep;
    final currentIndex = stages.indexOf(currentStageStep);
    if (currentIndex >= 0 && currentIndex < stages.length - 1) {
      for (int i = currentIndex + 1; i < stages.length; i++) {
        if (!_isCompleted(stages[i].status)) {
          nextStageStep = stages[i];
          break;
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 36 : 18,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(appType, appId),
                const SizedBox(height: 20),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Timeline
                      Expanded(
                        flex: 6,
                        child: _buildTimelineSection(stages, currentStageStep),
                      ),
                      const SizedBox(width: 24),
                      // Right Column: Cards
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _buildStatusAndProgressCard(
                              overallStatus,
                              currentStageName,
                              progress,
                              completedCount,
                              totalCount,
                            ),
                            const SizedBox(height: 20),
                            _buildCurrentStageHeroCard(currentStageStep, currentStageName),
                            const SizedBox(height: 20),
                            _buildWhatsNextCard(nextStageStep),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildStatusAndProgressCard(
                        overallStatus,
                        currentStageName,
                        progress,
                        completedCount,
                        totalCount,
                      ),
                      const SizedBox(height: 18),
                      _buildCurrentStageHeroCard(currentStageStep, currentStageName),
                      const SizedBox(height: 22),
                      _buildTimelineSection(stages, currentStageStep),
                      const SizedBox(height: 20),
                      _buildWhatsNextCard(nextStageStep),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER APPLICATION INFO
  // ============================================================
  Widget _buildHeaderInfo(String appType, String appId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: Color(0xFF2463C9),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF162642),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Application ID: $appId',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
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

  // ============================================================
  // STATUS & PROGRESS CARD
  // ============================================================
  Widget _buildStatusAndProgressCard(
    String overallStatus,
    String currentStageName,
    int progress,
    int completedCount,
    int totalCount,
  ) {
    final statusColor = _getStatusColor(overallStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      overallStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Current Stage',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentStageName,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEAEFF5)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Application Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              Text(
                '$progress% Complete',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2463D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (progress.clamp(0, 100)) / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EEF5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2463D4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedCount of $totalCount stages completed',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT STAGE HERO CARD
  // ============================================================
  Widget _buildCurrentStageHeroCard(WorkflowStep step, String currentStageName) {
    final startedTime = step.startedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(step.startedAt!)
        : (step.completedAt != null
            ? DateFormat('dd MMM yyyy, hh:mm a').format(step.completedAt!)
            : null);

    final description = step.remarks != null && step.remarks!.trim().isNotEmpty
        ? step.remarks!
        : _getDefaultStageDescription(step.stageName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2463D4).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2463D4).withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStageIcon(step.stageName),
                  color: const Color(0xFF2463D4),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Stage',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2463D4),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      currentStageName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10213D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
          if (startedTime != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  'Started: $startedTime',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (step.officerName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  'Assigned: ${step.officerName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // VERTICAL TIMELINE SECTION
  // ============================================================
  Widget _buildTimelineSection(
    List<WorkflowStep> stages,
    WorkflowStep currentStep,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Detailed historical tracking across administrative checkpoints',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final step = stages[index];
              final isCompleted = _isCompleted(step.status);
              final isCurrent = step == currentStep || _isInProgress(step.status);
              final isLast = index == stages.length - 1;

              return Stack(
                children: [
                  if (!isLast)
                    Positioned(
                      left: 21,
                      top: 36,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: isCompleted
                            ? const Color(0xFF20A66A)
                            : (isCurrent
                                ? const Color(0xFF2463D4)
                                : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _buildTimelineNode(isCompleted, isCurrent, step.stageName),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 8 : 26),
                          child: _buildTimelineStepCard(step, isCompleted, isCurrent),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(bool isCompleted, bool isCurrent, String stageName) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF20A66A),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 18,
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF2463D4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2463D4).withValues(alpha: 0.35),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          _getStageIcon(stageName),
          color: Colors.white,
          size: 19,
        ),
      );
    }

    // Pending
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.circle_outlined,
        color: Color(0xFF94A3B8),
        size: 14,
      ),
    );
  }

  Widget _buildTimelineStepCard(WorkflowStep step, bool isCompleted, bool isCurrent) {
    final formattedDate = step.completedAt != null
        ? DateFormat('dd MMM yyyy • hh:mm a').format(step.completedAt!)
        : (step.startedAt != null
            ? DateFormat('dd MMM yyyy • hh:mm a').format(step.startedAt!)
            : null);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFF5F8FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFFBFDBFE)
              : (isCompleted ? const Color(0xFFE2E8F0) : const Color(0xFFECEFF3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  step.stageName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isCurrent || isCompleted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isCurrent
                        ? const Color(0xFF1E3A8A)
                        : (isCompleted ? const Color(0xFF1E293B) : const Color(0xFF64748B)),
                  ),
                ),
              ),
              _buildStepBadge(step.status, isCompleted, isCurrent),
            ],
          ),
          if (formattedDate != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle_outline : Icons.schedule,
                  size: 13,
                  color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
          if (step.remarks != null && step.remarks!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              step.remarks!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ] else if (isCompleted) ...[
            const SizedBox(height: 6),
            Text(
              '${step.stageName} was successfully processed.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepBadge(String status, bool isCompleted, bool isCurrent) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Completed',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15803D),
          ),
        ),
      );
    }

    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE0EDFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'In Progress',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D4ED8),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // ============================================================
  // WHAT'S NEXT CARD
  // ============================================================
  Widget _buildWhatsNextCard(WorkflowStep? nextStep) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.next_plan_outlined,
                  color: Color(0xFFDD7A00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "What's Next?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF14213D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (nextStep != null) ...[
            Text(
              nextStep.stageName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _getNextStageExpectation(nextStep.stageName),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ] else ...[
            const Text(
              'Final Approval Granted',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'All required workflow stages have been completed. Your certificate is ready or in the final issuance phase.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  bool _isCompleted(String status) {
    final s = status.toLowerCase();
    return s.contains('completed') || s.contains('approved') || s.contains('done');
  }

  bool _isInProgress(String status) {
    final s = status.toLowerCase();
    return s.contains('progress') || s.contains('active') || s.contains('under');
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('approved')) {
      return const Color(0xFF20A66A);
    }
    if (s.contains('delay') || s.contains('warning')) {
      return const Color(0xFFDD7A00);
    }
    if (s.contains('reject') || s.contains('error')) {
      return const Color(0xFFDC3545);
    }
    return const Color(0xFF2463D4); // Active / In Progress
  }

  IconData _getStageIcon(String stageName) {
    final s = stageName.toLowerCase();
    if (s.contains('submit') || s.contains('receive')) return Icons.file_upload_outlined;
    if (s.contains('document')) return Icons.task_outlined;
    if (s.contains('officer')) return Icons.shield_outlined;
    if (s.contains('field')) return Icons.location_on_outlined;
    if (s.contains('final') || s.contains('approval')) return Icons.verified_outlined;
    return Icons.account_tree_outlined;
  }

  String _getDefaultStageDescription(String stageName) {
    final s = stageName.toLowerCase();
    if (s.contains('submit') || s.contains('receive')) {
      return 'Your application has been received and registered in the state database.';
    }
    if (s.contains('document')) {
      return 'Officials are validating attached identity, address, and proof documents.';
    }
    if (s.contains('officer')) {
      return 'Your application is currently under direct review by the assigned government officer.';
    }
    if (s.contains('field')) {
      return 'An on-site inquiry or verification is scheduled at your designated residence.';
    }
    if (s.contains('final') || s.contains('approval')) {
      return 'The designated authorizing officer is reviewing the final documentation for certificate issuance.';
    }
    return 'Your application is progressing through this checkpoint.';
  }

  String _getNextStageExpectation(String nextStageName) {
    final s = nextStageName.toLowerCase();
    if (s.contains('document')) {
      return 'Your uploaded records and credentials will be reviewed for compliance.';
    }
    if (s.contains('officer')) {
      return 'The assigned officer will evaluate your application dossier.';
    }
    if (s.contains('field')) {
      return 'A field officer may verify your details at the provided address if requested.';
    }
    if (s.contains('final') || s.contains('approval')) {
      return 'Final authorization by the executive authority before official seal and delivery.';
    }
    return 'The administrative team will process this step once the current review concludes.';
  }

  int _calculateAppProgress(String stage) {
    final s = stage.toLowerCase();
    if (s.contains('submit') || s.contains('application received')) return 20;
    if (s.contains('document')) return 40;
    if (s.contains('officer')) return 60;
    if (s.contains('field')) return 80;
    if (s.contains('final') || s.contains('approved') || s.contains('complete')) return 100;
    return 50;
  }
}
