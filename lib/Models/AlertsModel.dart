class AlertModel {
  final int id;
  final String deviceId;
  final String type;
  final String title;
  final String message;
  final String severity;
  final String status;
  final String? createdAt;

  AlertModel({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.status,
    this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      deviceId: json['device_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      severity: json['severity'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
