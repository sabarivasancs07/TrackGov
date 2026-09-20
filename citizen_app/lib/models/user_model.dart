class CitizenUser {
  final String name;
  final String applicationNumber;
  final bool isVerified;

  CitizenUser({
    required this.name,
    required this.applicationNumber,
    this.isVerified = false,
  });

  factory CitizenUser.fromJson(Map<String, dynamic> json) {
    return CitizenUser(
      name: json['name'] ?? '',
      applicationNumber: json['applicationNumber'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'applicationNumber': applicationNumber,
      'isVerified': isVerified,
    };
  }
}
