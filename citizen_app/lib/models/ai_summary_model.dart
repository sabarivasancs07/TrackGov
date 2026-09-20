class AiSummary {
  final String applicationNumber;
  final String explanation;
  final String nextExpectedStep;
  final String? estimatedCompletion;
  final String? delayReason;
  final DateTime generatedAt;
  final String? currentStage;
  final String? overallStatus;

  AiSummary({
    required this.applicationNumber,
    required this.explanation,
    required this.nextExpectedStep,
    this.estimatedCompletion,
    this.delayReason,
    required this.generatedAt,
    this.currentStage,
    this.overallStatus,
  });

  factory AiSummary.fromJson(Map<String, dynamic> json) {
    return AiSummary(
      applicationNumber: json['applicationNumber'] ?? '',
      explanation: json['explanation'] ?? '',
      nextExpectedStep: json['nextExpectedStep'] ?? '',
      estimatedCompletion: json['estimatedCompletion'],
      delayReason: json['delayReason'],
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
      currentStage: json['currentStage'],
      overallStatus: json['overallStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationNumber': applicationNumber,
      'explanation': explanation,
      'nextExpectedStep': nextExpectedStep,
      'estimatedCompletion': estimatedCompletion,
      'delayReason': delayReason,
      'generatedAt': generatedAt.toIso8601String(),
      'currentStage': currentStage,
      'overallStatus': overallStatus,
    };
  }
}
