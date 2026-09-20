import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ai_summary_provider.dart';
import '../../navigation/route_names.dart';
import '../../models/application_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/citizen_app_shell.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_card.dart';

class ApplicationStatusScreen extends StatefulWidget {
  final String? applicationNumber;

  const ApplicationStatusScreen({super.key, this.applicationNumber});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  int _selectedTab = 0; // 0: Timeline, 1: Documents, 2: AI Summary

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    final appNum = widget.applicationNumber ??
        provider.currentApplication?.applicationNumber ??
        auth.user?.applicationNumber;

    if (appNum != null && appNum.isNotEmpty) {
      if (provider.currentApplication?.applicationNumber != appNum) {
        provider.searchApplication(appNum, auth.user?.name ?? '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, _) {
        final app = provider.currentApplication;
        final appNum = widget.applicationNumber ?? app?.applicationNumber ?? '';

        return CitizenAppShell(
          currentRoute: RouteNames.applicationStatus,
          applicationNumber: appNum,
          showBackButton: true,
          title: 'Application Details',
          child: _buildBody(context, provider, app, appNum),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ApplicationProvider provider,
    ApplicationModel? app,
    String appNum,
  ) {
    if (provider.isLoading && app == null) {
      return const Center(
        child: LoadingWidget(message: 'Loading application details...'),
      );
    }

    if (provider.errorMessage != null && app == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorCard(
            message: provider.errorMessage!,
            onRetry: _loadData,
          ),
        ),
      );
    }

    if (app == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            const Text(
              'No application details found.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshStatus,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header description
                const Text(
                  'Complete information about your application.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Primary Information Card
                _buildInformationCard(app),

                const SizedBox(height: 24),

                // Tab Selector Controls (Timeline | Documents | AI Summary)
                _buildTabSelector(),

                const SizedBox(height: 20),

                // Selected Tab Body
                if (_selectedTab == 0) _buildTimelineSection(app),
                if (_selectedTab == 1) _buildDocumentsSection(app),
                if (_selectedTab == 2) _buildAiSummarySection(context, app),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================
  Widget _buildInformationCard(ApplicationModel app) {
    final submissionDateStr = DateFormat('dd MMM yyyy').format(app.submissionDate);
    final estimatedDate = app.submissionDate.add(Duration(days: app.expectedProcessingDays));
    final estimatedStr = DateFormat('dd MMM yyyy').format(estimatedDate);
    final isDelayed = app.isDelayed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: App Type & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.certificateType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: ${app.applicationNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDelayed ? const Color(0xFFFFF0F0) : const Color(0xFFE8F8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDelayed ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                      size: 14,
                      color: isDelayed ? const Color(0xFFE53E3E) : AppColors.successGreen,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isDelayed ? 'Delayed' : app.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDelayed ? const Color(0xFFC53030) : AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFEDF2F7)),
          const SizedBox(height: 20),

          // Details Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 550;
              if (isWide) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _infoField('Application ID', app.applicationNumber)),
                        Expanded(child: _infoField('Applicant Name', app.applicantName)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _infoField('Application Type', app.certificateType)),
                        Expanded(child: _infoField('Submitted Date', submissionDateStr)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _infoField('Current Stage', app.currentStage)),
                        Expanded(child: _infoField('Estimated Completion', '$estimatedStr (~${app.expectedProcessingDays} days)')),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _infoField('Application ID', app.applicationNumber),
                  const SizedBox(height: 12),
                  _infoField('Applicant Name', app.applicantName),
                  const SizedBox(height: 12),
                  _infoField('Application Type', app.certificateType),
                  const SizedBox(height: 12),
                  _infoField('Submitted Date', submissionDateStr),
                  const SizedBox(height: 12),
                  _infoField('Current Stage', app.currentStage),
                  const SizedBox(height: 12),
                  _infoField('Estimated Completion', '$estimatedStr (~${app.expectedProcessingDays} days)'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAB SELECTOR
  // ============================================================
  Widget _buildTabSelector() {
    final tabs = ['Timeline', 'Documents', 'AI Summary'];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF6),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final idx = entry.key;
          final title = entry.value;
          final isSelected = _selectedTab == idx;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _selectedTab = idx),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryNavy : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // TAB 1: TIMELINE
  // ============================================================
  Widget _buildTimelineSection(ApplicationModel app) {
    final history = app.workflowHistory;

    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4EAF2)),
        ),
        child: const Center(
          child: Text(
            'No workflow history recorded yet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workflow History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final step = history[index];
              final isLast = index == history.length - 1;
              final isCompleted = step.status.toLowerCase() == 'completed';

              return Stack(
                children: [
                  if (!isLast)
                    Positioned(
                      left: 17,
                      top: 32,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: isCompleted ? AppColors.successGreen : const Color(0xFFE2E8F0),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.successGreen : AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_rounded : Icons.schedule_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 8 : 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.stageName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.remarks ?? 'Status update confirmed.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              if (step.officerName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Officer: ${step.officerName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (step.completedAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(step.completedAt!),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textDisabled,
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
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: DOCUMENTS
  // ============================================================
  Widget _buildDocumentsSection(ApplicationModel app) {
    final completed = app.completedDocuments;
    final requiredDocs = app.requiredDocuments;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (requiredDocs.isEmpty && completed.isEmpty)
            const Text(
              'No document verification records available.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else ...[
            ...completed.map((doc) => _buildDocTile(doc, isVerified: true)),
            ...requiredDocs
                .where((doc) => !completed.contains(doc))
                .map((doc) => _buildDocTile(doc, isVerified: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildDocTile(String name, {required bool isVerified}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF1)),
        ),
        child: Row(
          children: [
            Icon(
              isVerified ? Icons.check_circle_outline_rounded : Icons.pending_outlined,
              color: isVerified ? AppColors.successGreen : const Color(0xFFF59E0B),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isVerified ? 'Verified & Accepted' : 'Pending Verification',
                    style: TextStyle(
                      fontSize: 12,
                      color: isVerified ? AppColors.successGreen : const Color(0xFFD97706),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isVerified
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isVerified ? 'Verified' : 'Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isVerified ? AppColors.successGreen : const Color(0xFFD97706),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB 3: AI SUMMARY
  // ============================================================
  Widget _buildAiSummarySection(BuildContext context, ApplicationModel app) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.aiPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Application Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Powered by Gemini AI',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    RouteNames.aiSummary,
                    arguments: app.applicationNumber,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Open Full Summary'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<AiSummaryProvider>(
            builder: (context, aiProv, _) {
              if (aiProv.summary != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        aiProv.summary!.explanation,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.primaryBlue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Click "Open Full Summary" to generate real-time plain language insights with Gemini AI.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
