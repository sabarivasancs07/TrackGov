class AppConstants {
  AppConstants._();

  // Workflow Stages
  static const String stageSubmitted = 'Application Submitted';
  static const String stageVao = 'VAO Verification';
  static const String stageRi = 'Revenue Inspector Verification';
  static const String stageTahsildar = 'Tahsildar Approval';
  static const String stageCompleted = 'Certificate Generated';

  // Status Labels
  static const String statusOnSchedule = 'On Schedule';
  static const String statusDelayDetected = 'Delay Detected';
  
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';

  // Certificate Types
  static const String certIncome = 'Income Certificate';
  static const String certCommunity = 'Community Certificate';
  static const String certNativity = 'Nativity Certificate';
}
