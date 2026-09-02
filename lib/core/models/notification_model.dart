enum NotificationType { newQuestion, newAnswer, newPoll, meetingReminder, general }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  String get typeIcon {
    switch (type) {
      case NotificationType.newQuestion:
        return '❓';
      case NotificationType.newAnswer:
        return '✅';
      case NotificationType.newPoll:
        return '📊';
      case NotificationType.meetingReminder:
        return '📅';
      case NotificationType.general:
        return '📢';
    }
  }
}
