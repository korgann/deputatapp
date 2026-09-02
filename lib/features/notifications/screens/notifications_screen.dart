import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Уведомления'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: provider.markAllNotificationsRead,
            child: const Text('Все прочитаны', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Уведомлений нет', style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (ctx, i) => _NotificationCard(
                notification: notifications[i],
                onTap: () => provider.markNotificationRead(notifications[i].id),
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.newQuestion: return AppColors.warning;
      case NotificationType.newAnswer: return AppColors.success;
      case NotificationType.newPoll: return AppColors.lightBlue;
      case NotificationType.meetingReminder: return AppColors.primaryBlue;
      case NotificationType.general: return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('dd.MM HH:mm').format(notification.createdAt);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppColors.backgroundBlue,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? Colors.grey[200]! : _typeColor.withAlpha(77),
            width: notification.isRead ? 1 : 1.5,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _typeColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(notification.typeIcon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(notification.title,
                  style: TextStyle(fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
              ),
              if (!notification.isRead)
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                ),
            ]),
            const SizedBox(height: 4),
            Text(notification.message, style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          ])),
        ]),
      ),
    );
  }
}
