class AdminNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String type;

  AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.type = 'new_order',
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      time: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'new_order',
    );
  }
}
