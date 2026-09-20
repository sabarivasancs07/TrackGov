
import '../models/application_model.dart';
import '../models/ai_summary_model.dart';
import '../models/workflow_step_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();

  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();

  final List<ApplicationModel> _applications = [
    ApplicationModel(
      applicationNumber: 'INC-2023-001',
      applicantName: 'Ramesh Kumar',
      certificateType: 'Income Certificate',
      submissionDate: DateTime.now().subtract(const Duration(days: 3)),
      currentOffice: 'VAO Office - Tambaram',
      currentStage: 'VAO Verification',
      status: 'On Schedule',
      daysPending: 3,
      expectedProcessingDays: 15,
      workflowHistory: [
        WorkflowStep(
          stageName: 'Application Submitted',
          stageCode: 'SUB',
          status: 'Completed',
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        WorkflowStep(
          stageName: 'VAO Verification',
          stageCode: 'VAO',
          status: 'In Progress',
          officerName: 'Suresh Babu',
          officeId: 'VAO-TMB',
        ),
        WorkflowStep(
          stageName: 'Revenue Inspector Verification',
          stageCode: 'RI',
          status: 'Pending',
        ),
        WorkflowStep(
          stageName: 'Tahsildar Approval',
          stageCode: 'TAH',
          status: 'Pending',
        ),
      ],
      auditLog: [],
      requiredDocuments: ['Aadhaar Card', 'Income Certificate Proof'],
      completedDocuments: ['Aadhaar Card'],
    ),
    ApplicationModel(
      applicationNumber: 'INC-2023-002',
      applicantName: 'Priya Sharma',
      certificateType: 'Income Certificate',
      submissionDate: DateTime.now().subtract(const Duration(days: 20)),
      currentOffice: 'RI Office - Guindy',
      currentStage: 'Revenue Inspector Verification',
      status: 'Delay Detected',
      daysPending: 20,
      expectedProcessingDays: 15,
      workflowHistory: [
        WorkflowStep(
          stageName: 'Application Submitted',
          stageCode: 'SUB',
          status: 'Completed',
          completedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        WorkflowStep(
          stageName: 'VAO Verification',
          stageCode: 'VAO',
          status: 'Completed',
          completedAt: DateTime.now().subtract(const Duration(days: 15)),
          officerName: 'Rajan M',
        ),
        WorkflowStep(
          stageName: 'Revenue Inspector Verification',
          stageCode: 'RI',
          status: 'In Progress',
          officerName: 'Muthu K',
        ),
      ],
      auditLog: [],
      requiredDocuments: ['Aadhaar Card', 'Age Proof'],
      completedDocuments: ['Aadhaar Card', 'Age Proof'],
    ),
  ];

  final Map<String, AiSummary> _aiSummaries = {
    'INC-2023-001': AiSummary(
      applicationNumber: 'INC-2023-001',
      explanation: 'Your application has been successfully submitted and is currently under review by the Village Administrative Officer (VAO). The processing is on schedule.',
      nextExpectedStep: 'Revenue Inspector Verification',
      estimatedCompletion: 'Within 12 days',
      generatedAt: DateTime.now(),
    ),
    'INC-2023-002': AiSummary(
      applicationNumber: 'INC-2023-002',
      explanation: 'Your application is currently delayed at the Revenue Inspector level. The expected 15-day timeline has been exceeded by 5 days. The officer is likely reviewing additional documents.',
      nextExpectedStep: 'Tahsildar Approval',
      delayReason: 'Pending physical field verification due to current backlog.',
      generatedAt: DateTime.now(),
    ),
  };

  ApplicationModel? getApplication(String id) {
    try {
      return _applications.firstWhere((app) => app.applicationNumber == id);
    } catch (e) {
      return null;
    }
  }

  AiSummary? getAiSummary(String id) {
    return _aiSummaries[id];
  }
}
