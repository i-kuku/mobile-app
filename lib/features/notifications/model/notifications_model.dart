class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String? referenceKey;
  final String titleEn;
  final String titleSw;
  final String messageEn;
  final String messageSw;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.referenceKey,
    required this.titleEn,
    required this.titleSw,
    required this.messageEn,
    required this.messageSw,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      referenceKey: json['reference_key'] as String?,
      titleEn: json['title_en'] as String,
      titleSw: json['title_sw'] as String,
      messageEn: json['message_en'] as String,
      messageSw: json['message_sw'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map toJson() {
    return {
      'user_id': userId,
      'type': type,
      'reference_key': referenceKey,
      'title_en': titleEn,
      'title_sw': titleSw,
      'message_en': messageEn,
      'message_sw': messageSw,
      'is_read': isRead,
    };
  }

  String getTitle(String languageCode) {
    return languageCode == 'sw' ? titleSw : titleEn;
  }

  String getMessage(String languageCode) {
    return languageCode == 'sw' ? messageSw : messageEn;
  }
}