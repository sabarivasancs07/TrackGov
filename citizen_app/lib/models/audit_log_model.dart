class AuditLog {
  final String action;
  final String actor;
  final DateTime timestamp;
  final String details;

  AuditLog({
    required this.action,
    required this.actor,
    required this.timestamp,
    required this.details,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      action: json['action'] ?? '',
      actor: json['actor'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      details: json['details'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'actor': actor,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}
