class WorkflowStep {
  final String stageName;
  final String stageCode;
  final String? officerName;
  final String? officeId;
  final String status;
  final DateTime? completedAt;
  final DateTime? startedAt;
  final String? remarks;

  WorkflowStep({
    required this.stageName,
    required this.stageCode,
    this.officerName,
    this.officeId,
    required this.status,
    this.completedAt,
    this.startedAt,
    this.remarks,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      stageName: json['stageName'] ?? '',
      stageCode: json['stageCode'] ?? '',
      officerName: json['officerName'],
      officeId: json['officeId'],
      status: json['status'] ?? 'Pending',
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageName': stageName,
      'stageCode': stageCode,
      'officerName': officerName,
      'officeId': officeId,
      'status': status,
      'completedAt': completedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'remarks': remarks,
    };
  }
}
