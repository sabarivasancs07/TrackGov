import 'audit_log_model.dart';
import 'workflow_step_model.dart';

class ApplicationModel {
  final String applicationNumber;
  final String applicantName;
  final String certificateType;
  final DateTime submissionDate;
  final String currentOffice;
  final String currentStage;
  final String status;
  final int daysPending;
  final int expectedProcessingDays;
  final List<WorkflowStep> workflowHistory;
  final String? officerRemarks;
  final List<AuditLog> auditLog;
  final List<String> requiredDocuments;
  final List<String> completedDocuments;

  ApplicationModel({
    required this.applicationNumber,
    required this.applicantName,
    required this.certificateType,
    required this.submissionDate,
    required this.currentOffice,
    required this.currentStage,
    required this.status,
    required this.daysPending,
    required this.expectedProcessingDays,
    required this.workflowHistory,
    this.officerRemarks,
    required this.auditLog,
    required this.requiredDocuments,
    required this.completedDocuments,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationNumber: json['applicationNumber'] ?? '',
      applicantName: json['applicantName'] ?? '',
      certificateType: json['certificateType'] ?? '',
      submissionDate: DateTime.parse(json['submissionDate'] ?? DateTime.now().toIso8601String()),
      currentOffice: json['currentOffice'] ?? '',
      currentStage: json['currentStage'] ?? '',
      status: json['status'] ?? 'Pending',
      daysPending: json['daysPending'] ?? 0,
      expectedProcessingDays: json['expectedProcessingDays'] ?? 15,
      workflowHistory: (json['workflowHistory'] as List<dynamic>?)
              ?.map((e) => WorkflowStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      officerRemarks: json['officerRemarks'],
      auditLog: (json['auditLog'] as List<dynamic>?)
              ?.map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requiredDocuments: (json['requiredDocuments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      completedDocuments: (json['completedDocuments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationNumber': applicationNumber,
      'applicantName': applicantName,
      'certificateType': certificateType,
      'submissionDate': submissionDate.toIso8601String(),
      'currentOffice': currentOffice,
      'currentStage': currentStage,
      'status': status,
      'daysPending': daysPending,
      'expectedProcessingDays': expectedProcessingDays,
      'workflowHistory': workflowHistory.map((e) => e.toJson()).toList(),
      'officerRemarks': officerRemarks,
      'auditLog': auditLog.map((e) => e.toJson()).toList(),
      'requiredDocuments': requiredDocuments,
      'completedDocuments': completedDocuments,
    };
  }

  bool get isDelayed => status == 'Delay Detected' || daysPending > expectedProcessingDays;
}
